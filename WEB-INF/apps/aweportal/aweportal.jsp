<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "aweportal";
String pgmid   = "aweportal"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 

/* return HTML */
if("init".equals(func)) {
    String res = "";
    try {  
        String html = getSingleContent(pgmid,"HTML");
        JSONObject dt = new JSONObject();
        dt.put("dt",getDateTime());
        html = bindVAR(html,dt);
        out.println(html); 
        return; /* 마지막에 return 해주지 않으면 JSON리턴이 따라붙음 */
    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } 
}


try {  
if("retrieveInit".equals(func)) {
    Connection conn = null;  
    try { 
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  

        String qry = getQuery(pgmid,"retrieveComcd"); //T_PGM_SRC.content 
        //OUTVAR.put("qry",qry);
        JSONArray comcd = selectSVC(conn,qry);   
        OUTVAR.put("comcd",comcd);

        INVAR.put("usid",USERID);
        qry = getQuery(pgmid,"retrieveDefval");   
        qry = bindVAR(qry,INVAR);
        //OUTVAR.put("qry",qry);        
        JSONArray defval = selectSVC(conn,qry);   
        OUTVAR.put("defval",defval);

        qry = getQuery(pgmid,"retrieveUsergrp");   
        qry = bindVAR(qry,INVAR);
        //OUTVAR.put("qry",qry);        
        JSONArray usergrp = selectSVC(conn,qry);   
        OUTVAR.put("usergrp",usergrp);

        qry = getQuery(pgmid,"retrieveMenuT");   
        qry = bindVAR(qry,INVAR);
        //OUTVAR.put("qry",qry);        
        JSONArray menu = selectSVC(conn,qry);   
        OUTVAR.put("menu",menu);

        qry = getQuery(pgmid,"retrieveNotice");   
        qry = bindVAR(qry,INVAR);
        //OUTVAR.put("qry",qry);        
        JSONArray notice = selectSVC(conn,qry);   
        OUTVAR.put("notice",notice);

    } catch(Exception e) {
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
