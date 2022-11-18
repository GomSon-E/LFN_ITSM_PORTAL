<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "aweportal";
String pgmid   = "manageBarcode"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/// *********************************************************************************************/
if("BARCD".equals(func)) {
    Connection conn = null;
    
    try {
        conn = getConn("LFN");
        String qry = "";
        
        qry = getQuery(pgmid, "BARCD");
        JSONArray list = selectSVC(conn, qry);
        OUTVAR.put("list", list);
        
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg  = e.toString();
        
    } finally {
        closeConn(conn);
        
    }
}
    
    
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
