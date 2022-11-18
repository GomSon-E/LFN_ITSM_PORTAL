<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_pos";
String pgmid   = "GIaccept"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/// *********************************************************************************************/
//searchOrder : 선택된 박스의 물류지시번호 조회 및 박스 정보 조회
if("searchOrder".equals(func)) {
    Connection conn = null;
    
    try{
        conn = getConn("LFN");

        INVAR.put("comcd", ORGCD);
        
        String qryOrdNum = getQuery(pgmid, "qryOrdNum");
        qryOrdNum = bindVAR(qryOrdNum, INVAR);
        JSONArray arr = selectSVC(conn, qryOrdNum);
        JSONObject obj = (JSONObject)arr.get(0);
        String lg_ord_no = obj.get("lg_ord_no").toString();
        OUTVAR.put("lg_ord_no", lg_ord_no);

        if(!lg_ord_no.equals("NULL")) {
            String qryMst = getQuery(pgmid, "qryMst");
            String qryBox = getQuery(pgmid, "qryBox");
            
            qryMst = bindVAR(qryMst,INVAR);
            JSONArray mst = selectSVC(conn, qryMst);
            OUTVAR.put("mst", mst); 
            
            qryBox = bindVAR(qryBox,INVAR); 
            JSONArray boxlist = selectSVC(conn, qryBox);
            OUTVAR.put("boxlist", boxlist); 
        }

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
        
        //로그인 유저 조직 및 부서 정보
        INVAR.put("comcd",ORGCD);
        INVAR.put("deptcd", DEPTCD);
        /*INVAR.put("whcd", DEPTCD);*/
        
        //박스 바코드 길이(GIA 박스코드 16자리, GR 코드 12자리에 따라 분기
        String barcd = getVal(INVAR, "barcd");

        //GIA, GIB등 입고 분류 박스 바코드인 경우,
        if(barcd.length() != 12) {
            //박스 바코드 유효 확인
            String qryBoxNum = getQuery(pgmid, "qryBoxNum");
            qryBoxNum = bindVAR(qryBoxNum, INVAR);
            OUTVAR.put("qryBoxNum",qryBoxNum);
            JSONArray arr1 = selectSVC(conn, qryBoxNum);
            JSONObject obj1 = (JSONObject)arr1.get(0);
            String box_no = obj1.get("box_no").toString();
    
            if(!box_no.equals("NULL")) {
                INVAR.put("box_no", box_no);
                
                //송장 바코드 조회
                String qryOrder = getQuery(pgmid, "qryOrder");
                qryOrder = bindVAR(qryOrder, INVAR);
                JSONArray arr2 = selectSVC(conn, qryOrder);
                JSONObject obj2 = (JSONObject)arr2.get(0);
                String lg_ord_no = obj2.get("lg_ord_no").toString();
                INVAR.put("lg_ord_no", lg_ord_no);
                OUTVAR.put("lg_ord_no", lg_ord_no);
                
                //송장 바코드 정보 및 박스 정보 조회
                String qryMst = getQuery(pgmid, "qryMst"); 
                String qryBox = getQuery(pgmid, "qryBox"); 
                
                qryMst = bindVAR(qryMst,INVAR); 
                JSONArray mst = selectSVC(conn, qryMst);
                OUTVAR.put("mst",mst); 
                
                qryBox = bindVAR(qryBox,INVAR); 
                JSONArray boxlist = selectSVC(conn, qryBox);
                OUTVAR.put("boxlist",boxlist);
            
            } else {
                OUTVAR.put("lg_ord_no", box_no);
            }
            
        //직접 입력한 직송 코드인 경우,
        } else if(barcd.length() == 12) {
            //유효 직송 코드 확인
            String qryDirectNum = getQuery(pgmid, "qryDirectNum");
            qryDirectNum = bindVAR(qryDirectNum, INVAR);
            JSONArray arr1 = selectSVC(conn, qryDirectNum);
            JSONObject obj1 = (JSONObject)arr1.get(0);
            String gr_ord_no = obj1.get("gr_ord_no").toString(); 
            
            //유효한 직송 코드인 경우,
            if(!gr_ord_no.equals("NULL")) {
                INVAR.put("box_no", gr_ord_no); 
                
                //송장 바코드 정보 및 박스 정보 조회
                String qryMst = getQuery(pgmid, "qryMstDirect"); 
                String qryBox = getQuery(pgmid, "qryBoxDirect"); 
                
                qryMst = bindVAR(qryMst,INVAR); 
                JSONArray mst = selectSVC(conn, qryMst);
                OUTVAR.put("mst",mst); 
                
                qryBox = bindVAR(qryBox,INVAR); 
                JSONArray boxlist = selectSVC(conn, qryBox);
                OUTVAR.put("boxlist",boxlist);
                
            //NULL인 경우,
            } else {
                OUTVAR.put("lg_ord_no", gr_ord_no);
            }

        //그 외의 코드는 NULL
        } else {
            OUTVAR.put("lg_ord_no", "NULL");
        }
    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    
    } finally {
        closeConn(conn);
    } 
}

if("searchBox".equals(func)) {
    Connection conn = null;
    
    try{
        conn = getConn("LFN");

        INVAR.put("comcd", ORGCD);

        String qryMst = getQuery(pgmid, "qryMst"); 
        String qryBox = getQuery(pgmid, "qryBox"); 
        
        qryMst = bindVAR(qryMst,INVAR); 
        JSONArray mst = selectSVC(conn, qryMst);
        OUTVAR.put("mst", mst); 
        
        qryBox = bindVAR(qryBox,INVAR); 
        JSONArray boxlist = selectSVC(conn, qryBox);
        OUTVAR.put("boxlist",boxlist); 

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    
    } finally {
        closeConn(conn);
    } 
}

//acceptBox : 박스인수등록
if("acceptBox".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        String qry = getQuery(pgmid, "acceptBox");
        String qryRun = bindVAR(qry,INVAR);
        JSONObject rst = executeSVC(conn, qryRun);  
        
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg");
        } else { 
            conn.commit();
        } 
        
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}

//deniedBox : 박스인수거부
if("deniedBox".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID); 
    
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        String qry = getQuery(pgmid, "deniedBox");
        String qryRun = bindVAR(qry,INVAR);

        JSONObject rst = executeSVC(conn, qryRun);  
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else { 
            conn.commit();
        } 
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}

//deniedCancelBox : 인수 거부 취소
if("deniedCancelBox".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID); 
    
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        String qry = getQuery(pgmid, "deniedCancelBox");
        String qryRun = bindVAR(qry,INVAR);

        JSONObject rst = executeSVC(conn, qryRun);  
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else { 
            conn.commit();
        } 
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}

//save:입고등록 이벤트처리(DB_Write)
if("save".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID); 
        
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qryMst = getQuery(pgmid, "qrysaveMst");
        String qryBoxlist = getQuery(pgmid, "qrysaveBoxlist");
        
        String qryRun = ""; 
        
        JSONArray arrList = getArray(INVAR,"boxlist");
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i);  
            row.put("comcd",ORGCD);
            row.put("usid",USERID);
            row.put("lg_ord_no",getVal(INVAR,"lg_ord_no"));
            qryRun += bindVAR(qryBoxlist,row) + "\n";
        } 
        
        qryRun += bindVAR(qryMst,INVAR);
        
        JSONObject rst = executeSVC(conn, qryRun);  
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else { 
            conn.commit();
        } 
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
