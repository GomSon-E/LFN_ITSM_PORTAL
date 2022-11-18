<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<% 
try {
    String reqPgm = nvl(request.getParameter("pgm"),"");
    String[] pgm = reqPgm.split("\\.");   

    //System.out.println( "sessionUser:" + USERID );
    // if( !"aweportal.login".equals(reqPgm) && !aweCheck(session) ) {
    //     JSONObject OUTVAR = new JSONObject();
    //     OUTVAR.put("rtnCd","ERR");
    //     OUTVAR.put("rtnMsg","사용자세션이 종료되었습니다. 브라우저의 새탭을 띄워 다시 접속한 후 작업을 계속하세요!");
    //     out.println(OUTVAR.toString());    
    //     return;
    // }

    String app = pgm[0];
	String pgmid = pgm[1]+".jsp";
    String func = nvl(request.getParameter("func"),"init");

    /* 전달받은 요청주소(app.pgmid func)로 Redirect한다. (Redirect시 INVAR data는 자동으로 연결된다.) */
	pageContext.forward("./WEB-INF/apps/"+app+"/"+pgmid+"?func="+func); //{INVAR: "{JSON:~~}" }
 
} catch(Exception e) { 
    //logger.error("awegtx error:", e);
    JSONObject OUTVAR = new JSONObject();
    OUTVAR.put("rtnCd","ERR");
    OUTVAR.put("rtnMsg","cannot load your request:"+e.toString());
    out.println(OUTVAR.toString());
} 
%> 