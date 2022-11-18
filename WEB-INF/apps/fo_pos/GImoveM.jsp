<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_lg";
String pgmid   = "GImoveM"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/// *********************************************************************************************/
//searchOrder : 물류지시번호 조회 및 박스
if("searchOrd".equals(func)) {
    Connection conn = null;
    
    try{
        conn = getConn("LFN");

        INVAR.put("comcd", ORGCD);
        INVAR.put("deptcd", DEPTCD);
        
        //행낭 물류 지시 번호 유효성 검사
        String qryOrdNum = getQuery(pgmid, "qryOrdNum");
        qryOrdNum = bindVAR(qryOrdNum, INVAR);
        JSONArray arr = selectSVC(conn, qryOrdNum);
        JSONObject obj = (JSONObject)arr.get(0);
        
        String lg_ord_no = obj.get("lg_ord_no").toString();
        OUTVAR.put("lg_ord_no", lg_ord_no);

        //유효한 경우, 행낭 송장 조회
        if(!lg_ord_no.equals("NULL")) {
            String qryOrd = getQuery(pgmid, "qryOrder");
            qryOrd = bindVAR(qryOrd, INVAR);
            JSONArray list = selectSVC(conn, qryOrd);
            OUTVAR.put("list", list);
            
            String qryBoxCnt = getQuery(pgmid, "qryBoxCnt");
            qryBoxCnt = bindVAR(qryBoxCnt, INVAR);
            JSONArray boxCnt = selectSVC(conn, qryBoxCnt);
            OUTVAR.put("boxCnt", boxCnt);
        }

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    } 
}

if("searchDet".equals(func)) {
    Connection conn = null;
    
    try{
        conn = getConn("LFN");

        INVAR.put("comcd", ORGCD);

        String qryDet = getQuery(pgmid, "qryDet"); 
        
        qryDet = bindVAR(qryDet,INVAR); 
        JSONArray det = selectSVC(conn, qryDet);
        OUTVAR.put("det", det); 
 
    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    
    } finally {
        closeConn(conn);
    } 
}

if("searchOrdNum".equals(func)) {
    Connection conn = null;
    
    try {
        conn = getConn("LFN");
        
        INVAR.put("comcd", ORGCD);
        INVAR.put("whcd", DEPTCD);

        //행낭 박스 바코드로 행낭 물류 지시 번호 조회 
        String qryBoxNum = getQuery(pgmid, "qryBoxNum");
        qryBoxNum = bindVAR(qryBoxNum, INVAR);
        JSONArray arr1 = selectSVC(conn, qryBoxNum);
        JSONObject obj1 = (JSONObject)arr1.get(0);
        String lg_ord_no1 = obj1.get("lg_ord_no").toString();

        //행낭 박스 바코드 유효성 검사
        if(!lg_ord_no1.equals("NULL")) {
            INVAR.put("lg_ord_no", lg_ord_no1);
            OUTVAR.put("lg_ord_no", lg_ord_no1);
            //행낭 물류 지시 번호 유효성 검사
            String qryOrdNum = getQuery(pgmid, "qryOrdNum");
            qryOrdNum = bindVAR(qryOrdNum, INVAR);
            JSONArray arr2 = selectSVC(conn, qryOrdNum);
            JSONObject obj2 = (JSONObject)arr2.get(0);
            String lg_ord_no2 = obj2.get("lg_ord_no").toString();
            
            INVAR.put("lg_ord_no", lg_ord_no2);
           
            
            //유효한 경우, 행낭 송장 조회
            if(!lg_ord_no2.equals("NULL")) {
                String qryOrd = getQuery(pgmid, "qryOrder");
                qryOrd = bindVAR(qryOrd, INVAR);
                JSONArray list = selectSVC(conn, qryOrd);
                OUTVAR.put("list", list);
            } else {
                 OUTVAR.put("lg_ord_no", lg_ord_no2);
            }
        } else {
            OUTVAR.put("lg_ord_no", lg_ord_no1);
        }

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    
    } finally {
        closeConn(conn);
    } 
}

//행낭 인수 및 입고 처리
if("acceptOrd".equals(func)) {
    Connection conn = null;
    
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        INVAR.put("comcd", ORGCD);
        INVAR.put("usid", USERID); 

        int runCnt = 0;
        String qryRun = "";
        boolean bError = false;
       
        //물류 번호에 해당하는 박스 조회
        String qrySearchBox = getQuery(pgmid, "qrySearchBox");
        qrySearchBox = bindVAR(qrySearchBox, INVAR);
        JSONArray boxList = selectSVC(conn, qrySearchBox);
        
        String qryAcceptBox = getQuery(pgmid, "qryAcceptBox");
        
        for(int i = 0; i < boxList.size(); i++) {
            JSONObject temp = (JSONObject)boxList.get(i);
            qryAcceptBox = bindVAR(qryAcceptBox, INVAR);

            qryRun += bindVAR(qryAcceptBox, temp) + "\n";
            runCnt++;
            
            if(runCnt == 10) {
                JSONObject rst = executeSVC(conn, qryRun);
                runCnt = 0;
                qryRun = "";
                
                if(!"OK".equals (getVal(rst, "rtnCd"))) {
                    rtnCode = getVal(rst, "rtnCd");
                    rtnMsg  = getVal(rst, "rtnMsg");
                    bError  = true;
                    break;
                }
            }
        }
        
        if(runCnt > 0) {
            JSONObject rst = executeSVC(conn, qryRun);
            
            if(!"OK".equals (getVal(rst, "rtnCd"))) {
                rtnCode = getVal(rst, "rtnCd");
                rtnMsg  = getVal(rst, "rtnMsg");
                bError  = true;
            }
        }
   
        String qryAcceptOrd = getQuery(pgmid, "qryAcceptOrd");
        qryAcceptOrd = bindVAR(qryAcceptOrd, INVAR);
        JSONObject rst = executeSVC(conn, qryAcceptOrd);
        
        if(!"OK".equals (getVal(rst, "rtnCd"))) {
            rtnCode = getVal(rst, "rtnCd");
            rtnMsg  = getVal(rst, "rtnMsg");
            bError  = true;
        }
        
        if(bError) conn.rollback();
        else conn.commit();

    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}
/***************************************************************************************************/// *********************************************************************************************/
} catch (Exception e) {
	logger.error("error occurred:"+rtnCode,e);
	rtnCode    = "ERR";
	rtnMsg     = e.toString();
} finally {
	OUTVAR.put("rtnCd",rtnCode);
	OUTVAR.put("rtnMsg",rtnMsg); 
	out.println(OUTVAR.toJSONString());
}
%>
