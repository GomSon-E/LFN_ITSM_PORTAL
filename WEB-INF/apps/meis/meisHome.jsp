<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "meis";
String pgmid   = "meisHome"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/
if("retrieveMenu".equals(func)) {
    Connection conn = null;  
    try {
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  

        INVAR.put("usid",USERID);
        String qry = getQuery(pgmid,"qryMenu");   
        qry = bindVAR(qry,INVAR);        
        JSONArray menu = selectSVC(conn,qry);   
        OUTVAR.put("usermenu",menu); 
        
    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    }        
}

if("search".equals(func)) {
    Connection conn = null;  
    try {
        conn = getConn("LFSQDB");  // DB 커넥션 파라미터 세팅  
        String qry = getQuery(pgmid,"qrysearch");   
        qry = bindVAR(qry,INVAR);        
        JSONArray list = selectSVC(conn,qry);   
        OUTVAR.put("list",list); 
        
    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    }        
}

if("search2".equals(func)) {
    Connection conn = null;  
    try {
        conn = getConn("LFFODB");  // DB 커넥션 파라미터 세팅  
        String qry = getQuery(pgmid,"qrysearch2");   
        qry = bindVAR(qry,INVAR);        
        JSONArray list = selectSVC(conn,qry);   
        OUTVAR.put("list",list); 
        
    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
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
