<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<% 
JSONObject OUTVAR = new JSONObject(); 
String appid = "aweportal";  
String pgmid = "manageHelp"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar);
/***************************************************************************************************/
if ("getPgmInfo".equals(func)) {
     Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        String qry = getQuery(pgmid, "getPgmInfo");
        qry = bindVAR(qry, INVAR);
        JSONArray list = selectSVC(conn, qry);
    	OUTVAR.put("list", list);

    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    }
}

if ("getPgmFunc".equals(func)) {
     Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        String qry = getQuery(pgmid, "getPgmFunc");
        qry = bindVAR(qry, INVAR);
        JSONArray list = selectSVC(conn, qry);
    	OUTVAR.put("list", list);

    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    }
}

if ("getImage".equals(func)) {
    Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        String qry = getQuery(pgmid, "getImage");
        qry = bindVAR(qry, INVAR);
        JSONArray imgList = selectSVC(conn, qry);
        OUTVAR.put("imgList", imgList);
    } catch(Exception e) {
        rtnCode = "ERR";
        rtnMsg  = e.toString();
    } finally {
        closeConn(conn); 
    } 
}

if ("checkAdmin".equals(func)) {
    Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        INVAR.put("usid",USERID);
        String qry = getQuery(pgmid, "checkAdmin");
        qry = bindVAR(qry, INVAR);
        JSONArray list = selectSVC(conn, qry);
        OUTVAR.put("list", list);
    } catch(Exception e) {
        rtnCode = "ERR";
        rtnMsg  = e.toString();
    } finally {
        closeConn(conn); 
    } 
}

if ("updateRemark".equals(func)) {
    Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        conn.setAutoCommit(false);
        INVAR.put("usid",USERID);
        String qry = getQuery(pgmid, "updateRemark");
        qry = bindVAR(qry, INVAR);
        OUTVAR.put("qry",qry);  
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