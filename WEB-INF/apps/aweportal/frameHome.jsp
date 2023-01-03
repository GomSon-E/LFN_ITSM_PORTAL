<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "aweportal";
String pgmid   = "frameHome"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 

/***************************************************************************************************/
//조회 - 
if("search".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("deptcd",DEPTCD);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");   

        String qry4 = getQuery(pgmid, "list4"); 
        qry4 = bindVAR(qry4,INVAR);
        JSONArray list4 = selectSVC(conn, qry4);
        OUTVAR.put("list4",list4);               

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}
//그리드 재조회
if("refresh".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("deptcd",DEPTCD);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");   
        String listId = getVal(INVAR,"listId");
        
        String qry = getQuery(pgmid, listId); 
        qry = bindVAR(qry,INVAR);
        JSONArray list = selectSVC(conn, qry);
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
