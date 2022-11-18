<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_lg";
String pgmid   = "RTNaccept"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/
//search:조회 이벤트처리(DB_Read)     
if("search".equals(func)) {
    Connection conn = null; 
    
    try {  
        conn = getConn("LFN");  
        
        INVAR.put("comcd", ORGCD);
        //OUTVAR.put("INVAR",INVAR); //for debug
 
        String lg_ord_no = getVal(INVAR, "lg_ord_no");
        String qry       = null;
        if(lg_ord_no.isEmpty()) {
            qry = getQuery(pgmid, "qrysearch");
        } else {
            qry = getQuery(pgmid, "qrysearchord");
        }
        String qryRun    = bindVAR(qry,INVAR);
        //OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray list = selectSVC(conn, qryRun);
        OUTVAR.put("list",list); 
        
        //물류 송장 번호 유효성 확인
        qry            = getQuery(pgmid, "qryOrdNum");
        qryRun         = bindVAR(qry, INVAR);
        JSONArray arr  = selectSVC(conn, qryRun);
        JSONObject obj = (JSONObject)arr.get(0);
        lg_ord_no      = obj.get("lg_ord_no").toString();
        OUTVAR.put("lg_ord_no", lg_ord_no);

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();
        
    } finally {
        closeConn(conn);
    }  
}

//searchMst : 선택된 물류문서 조회
if("searchMst".equals(func)) {
    Connection conn = null; 
    
    try {  
        conn = getConn("LFN");
        
        INVAR.put("comcd", ORGCD);
        //OUTVAR.put("INVAR", INVAR); //for debug
        
        String qryMst = getQuery(pgmid, "qryMst");
        qryMst = bindVAR(qryMst,INVAR); 
        JSONArray mst = selectSVC(conn, qryMst);
        OUTVAR.put("mst",mst); 
        
        String qryBox = getQuery(pgmid, "qryBox"); 
        qryBox = bindVAR(qryBox,INVAR); 
        JSONArray boxlist = selectSVC(conn, qryBox);
        OUTVAR.put("boxlist",boxlist); 

        String qryDet = getQuery(pgmid, "qryDet"); 
        qryDet = bindVAR(qryDet,INVAR); 
        JSONArray det = selectSVC(conn, qryDet);
        OUTVAR.put("det",det); 
        
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
        conn = getConn("LFN");
        conn.setAutoCommit(false);   
        
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID); 

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
//cancel
if("cancel".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID); 
        
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qryMst = getQuery(pgmid, "qrycancelMst");
        String qryBoxlist = getQuery(pgmid, "qrycancelBoxlist");
        
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



else if("print".equals(func)) {
    Connection conn = null;
    
    try {
        conn = getConn("LFN");
        
        INVAR.put("comcd", ORGCD);
        
        String qry    = getQuery(pgmid, "qryPrintInfo");
        String qryRun = bindVAR(qry, INVAR);
        OUTVAR.put("qryRun", qryRun);
        JSONArray qryPrintInfo = selectSVC(conn, qryRun);
        OUTVAR.put("qryPrintInfo", qryPrintInfo);
        
        qry    = getQuery(pgmid, "qryPrintFromUser");
        qryRun = bindVAR(qry, INVAR);
        //OUTVAR.put("qryRun", qryRun);
        JSONArray arrData = selectSVC(conn, qryRun);
        JSONObject qryPrintFromUser = (JSONObject)arrData.get(0);
        OUTVAR.put("qryPrintFromUser", qryPrintFromUser);
        
        qry    = getQuery(pgmid, "qryPrintToUser");
        qryRun = bindVAR(qry, INVAR);
        //OUTVAR.put("qryRun", qryRun);
        arrData = selectSVC(conn, qryRun);
        JSONObject qryPrintToUser = (JSONObject)arrData.get(0);
        OUTVAR.put("qryPrintToUser", qryPrintToUser);
        
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
        
    } finally {
        closeConn(conn);
    }
}
// *********************************************************************************************/
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
