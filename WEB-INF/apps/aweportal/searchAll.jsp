<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "aweportal";
String pgmid   = "searchAll"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 

if("cafeList".equals(func)) {
        Connection conn = null; 
        try {  
            //OUTVAR.put("INVAR",INVAR); //for debug
            conn = getConn("LFN");  
            String qry = getQuery(pgmid, "cafeList"); 
            String qryRun = bindVAR(qry,INVAR);
            //OUTVAR.put("qryRun",qryRun); //for debug
            JSONArray list = selectSVC(conn,qryRun);
            OUTVAR.put("list", list); 

        } catch (Exception e) { 
            rtnCode = "ERR";
            rtnMsg = e.toString();				
        } finally {
            closeConn(conn);
        }  
    }

if("search".equals(func)) {
        Connection conn = null; 
        try {  
            conn = getConn("LFN");  
            String qry = getQuery(pgmid, "search"); 
            String qryRun = bindVAR(qry,INVAR);
            //OUTVAR.put("qryRun",qryRun); //for debug
            JSONArray list = selectSVC(conn, qryRun);
            OUTVAR.put("list",list); 

        } catch (Exception e) { 
            rtnCode = "ERR";
            rtnMsg = e.toString();				
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
