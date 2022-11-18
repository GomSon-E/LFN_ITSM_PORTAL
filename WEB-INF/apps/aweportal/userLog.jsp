<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "aweportal";
String pgmid   = "userLog"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/// *********************************************************************************************/
if("searchPgm".equals(func)) {
    Connection conn = null;
    
    try {  
        conn = getConn("LFN");

        INVAR.put("userid", USERID);

        String qry     = getQuery(pgmid, "searchPgm"); 
        String qryRun  = bindVAR(qry, INVAR);
        JSONArray list = selectSVC(conn, qryRun);
        OUTVAR.put("list", list); 
        OUTVAR.put("qryRun", qryRun); //for debug

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}
else if("searchPgmDet".equals(func)) {
    Connection conn = null;

    try {  
        conn = getConn("LFN");

        String qry    = getQuery(pgmid, "searchPgmDet"); 
        String qryRun = bindVAR(qry, INVAR);
        JSONArray det = selectSVC(conn, qryRun);
        OUTVAR.put("det", det); 
        OUTVAR.put("qryRun", qryRun); //for debug

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
