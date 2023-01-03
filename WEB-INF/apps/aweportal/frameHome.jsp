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
  
        // String qry6 = getQuery(pgmid, "list6"); 
        // qry6 = bindVAR(qry6,INVAR);
        // JSONArray list6 = selectSVC(conn, qry6);
        // OUTVAR.put("list6",list6); 

        // String qry2 = getQuery(pgmid, "list2"); 
        // qry2 = bindVAR(qry2,INVAR);
        // JSONArray list2 = selectSVC(conn, qry2);
        // OUTVAR.put("list2",list2);  

        // String qry3 = getQuery(pgmid, "list3"); 
        // qry3 = bindVAR(qry3,INVAR);
        // JSONArray list3 = selectSVC(conn, qry3);
        // OUTVAR.put("list3",list3); 

        // String qry5 = getQuery(pgmid, "list5"); 
        // qry5 = bindVAR(qry5,INVAR);
        // JSONArray list5 = selectSVC(conn, qry5);
        // OUTVAR.put("list5",list5); 

        String qry4 = getQuery(pgmid, "list4"); 
        qry4 = bindVAR(qry4,INVAR);
        JSONArray list4 = selectSVC(conn, qry4);
        OUTVAR.put("list4",list4);         

        // String qry7 = getQuery(pgmid, "list7"); 
        // qry7 = bindVAR(qry7,INVAR);
        // JSONArray list7 = selectSVC(conn, qry7);
        // OUTVAR.put("list7",list7);         

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
