<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "aweportal";
String pgmid   = "DuelScreen"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
if("imgsearch".equals(func)) {
        Connection conn = null;
        OUTVAR.put("INVAR",INVAR);
        try {
            conn = getConn("LFN");
            
            String qry = getQuery(pgmid, "imgsearch");
            
            String qryRun = bindVAR(qry, INVAR);
            
            JSONArray list = selectSVC(conn, qryRun);
            
            OUTVAR.put("list", list);
            
            OUTVAR.put("qryRun",qryRun);
            
        } catch(Exception e) {
            rtnCode = "ERR";
            rtnMsg  = e.toString();
            
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
