<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "ITSM";
String pgmid   = "componentTest"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/// *********************************************************************************************/
    //search:조회 이벤트처리(DB_Read)     
    if("set".equals(func)) {
        Connection conn = null; 
        try {  
            OUTVAR.put("INVAR",INVAR); //for debug
            conn = getConn("LFN");  
            String qry = "select * from CARDVIEWTEST order by read_cnt"; 
            String qryRun = bindVAR(qry,INVAR);
            OUTVAR.put("qryRun",qryRun); //for debug
            JSONArray list = selectSVC(conn, qryRun);
            OUTVAR.put("list",list); 

        } catch (Exception e) { 
            rtnCode = "ERR";
            rtnMsg = e.toString();				
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
