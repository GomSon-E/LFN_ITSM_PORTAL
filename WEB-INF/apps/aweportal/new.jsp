<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    import="java.util.*, 
	        java.net.*,
			javax.servlet.http.*, 
        	org.json.simple.*,
          org.json.simple.parser.*,
          java.sql.*,  
        	java.text.SimpleDateFormat,
        	javax.sql.DataSource,
        	javax.naming.Context,
        	javax.naming.InitialContext,  
	    	java.io.BufferedReader,
	    	java.io.Reader,
	    	java.io.Writer,
	    	java.io.CharArrayReader,
	    	oracle.sql.CLOB,
	    	oracle.sql.BLOB,
	    	oracle.jdbc.OracleResultSet, 
        	java.io.*,
        	java.nio.charset.StandardCharsets,
        	java.nio.file.*,
        	java.nio.file.Files,
        	java.security.*"

 %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "aweportal";
String pgmid   = "new"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar);

/***************************************************************************************************/
if("pageInit".equals(func)) {
     Connection conn = null;     
    try {
		OUTVAR.put("INVAR",INVAR);
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        String qry = "SELECT * FROM T_USER ORDER BY NM"; 
        JSONArray rst = selectSVC(conn,qry);   
        OUTVAR.put("rst",rst);
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
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        // String qry = "SELECT * FROM T_USER WHERE NM LIKE '%[srch]%' ORDER BY NM";  
        String qry = "SELECT * FROM T_USER WHERE NM = {srch} ORDER BY NM";  
        String qryRun = bindVAR(qry,INVAR); 
		OUTVAR.put("qryRun",qryRun);
        JSONArray rst = selectSVC(conn,qryRun);   
        OUTVAR.put("rst",rst);
    } catch(Exception e) {
        rtnCode = "ERR";
        rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    }    
}

/***************************************************************************************************/
} catch (Exception e) {
	// logger.error(pgmid+" error occurred:"+rtnCode,e);
	rtnCode    = "ERR in new";
	rtnMsg     = e.toString();
} finally {
	OUTVAR.put("rtnCd",rtnCode);
	OUTVAR.put("rtnMsg",rtnMsg); 
	out.println(OUTVAR.toJSONString());
}
%>