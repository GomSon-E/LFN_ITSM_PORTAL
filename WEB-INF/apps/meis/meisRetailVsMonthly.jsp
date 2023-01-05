<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "meis";
String pgmid   = "meisRetailVsMonthly"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/
if("search".equals(func)) {
    Connection conn = null;  
    try { 
        conn = getConn("LFSQDB");  // DB 커넥션 파라미터 세팅   
        String qry = getQuery(pgmid, "qrysearch"); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray list = selectSVC(conn, qryRun);
        OUTVAR.put("list",list); 

        String qry2 = getQuery(pgmid, "qrysearch2"); 
        String qryRun2 = bindVAR(qry2,INVAR);
        OUTVAR.put("qryRun2",qryRun2); //for debug
        JSONArray list2 = selectSVC(conn, qryRun2);
        OUTVAR.put("list2",list2); 
        
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