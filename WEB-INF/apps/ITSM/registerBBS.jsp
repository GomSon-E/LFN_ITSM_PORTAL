<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "ITSM";
String pgmid   = "registerBBS"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar);
/***************************************************************************************************/
if ("insertDoc".equals(func)) {
    Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅 
        conn.setAutoCommit(false); 
        //필요한 쿼리를 가져옴 
        String qryRun = "";
        String qry = getQuery(pgmid, "insertDoc");
        INVAR.put("userid", USERID);
        qry = bindVAR(qry,INVAR); 
        JSONObject rst = executeSVC(conn, qry);
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg");
        } else {
            executeUpdateClob(conn, 
						                     "T_DOC",
						                     "CONTENT",
						                     getVal(INVAR,"content"),
						                     "WHERE docid='"+getVal(INVAR,"docid") + "'");
            conn.commit(); 
        } 
    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    } 
} else if ("insertDocRcv".equals(func)) {
    Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅 
        conn.setAutoCommit(false); 
        //필요한 쿼리를 가져옴 
        String qryRun = "";
        String qry = "INSERT INTO T_DOC_RCV (DOCID, RCV_SEQ, RCV_TP, RCV_USID, RCV_GRPID, RCV_ROLE_TP, COMMENTS, SORT_SEQ, RCV_STAT, PROC_STAT, REG_USID, REG_DT, UPD_USID, UPD_DT) VALUES ({docid}, {docid}, '', '', {rcv_grpid}, '', '', '1', 'Y', 'Y', {userid}, SYSDATE, {userid}, SYSDATE);";
        INVAR.put("userid", USERID);
        qry = bindVAR(qry,INVAR); 
        JSONObject rst = executeSVC(conn, qry);
        
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg");
        } else {
            conn.commit(); 
        } 
    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    }
}
/***************************************************************************************************/
} catch (Exception e) {
	logger.error(pgmid+" error occurred:"+rtnCode,e);
	rtnCode    = "ERR";
	rtnMsg     = e.toString();
} finally {
	OUTVAR.put("rtnCd",rtnCode);
	OUTVAR.put("rtnMsg",rtnMsg); 
	out.println(OUTVAR.toJSONString());
}
%> 