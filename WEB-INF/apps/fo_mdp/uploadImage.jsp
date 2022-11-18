<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_mdp";
String pgmid   = "uploadImage"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/
if ("searchList".equals(func)) {
    Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅 
        INVAR.put("comcd", ORGCD);
        String qry = getQuery(pgmid, "searchList");
        qry = bindVAR(qry, INVAR);
        JSONArray imgList = selectSVC(conn, qry);
        OUTVAR.put("imgList", imgList);
    } catch(Exception e) {
        rtnCode = "ERR";
        rtnMsg  = e.toString();
    } finally {
        closeConn(conn); 
    } 
} else if ("checkStcl".equals(func)) {
    Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅
        String qry = getQuery(pgmid, "checkStcl");
        qry = bindVAR(qry, INVAR);
        JSONArray chkValid = selectSVC(conn, qry);
        OUTVAR.put("chkValid", chkValid);
    } catch(Exception e) {
        rtnCode = "ERR";
        rtnMsg  = e.toString();
    } finally {
        closeConn(conn); 
    } 
} else if ("getDetail".equals(func)) {
    Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅
        String qry = getQuery(pgmid, "getDetail");
        qry = bindVAR(qry, INVAR);
        JSONArray list = selectSVC(conn, qry);
        OUTVAR.put("list", list);
    } catch(Exception e) {
        rtnCode = "ERR";
        rtnMsg  = e.toString();
    } finally {
        closeConn(conn); 
    } 
} else if ("getDetail2".equals(func)) {
    Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅
        String qry = getQuery(pgmid, "getDetail2");
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
/*********************************************************************************************/
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