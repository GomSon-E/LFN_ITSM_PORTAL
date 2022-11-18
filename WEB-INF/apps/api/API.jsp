<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<% 
JSONObject OUTVAR = new JSONObject();
String enc = "UTF-8";
InputStreamReader isr = null;
BufferedReader bin = null;
String req = "";
JSONObject BODY  = null; 
Connection conn = null;
String rtnCode    = "OK";
String rtnMsg     = "";
Boolean success = true;
int code = 200;
String message  = "";
JSONParser parser = new JSONParser();
try {
	/**********************POST로 넘어온 값을 받아오기**********************/
	String apicodevalue = request.getParameter("apicode");
	//OUTVAR.put("debug_apicodevalue",apicodevalue);

    isr = new InputStreamReader( request.getInputStream(), enc ); 
	bin = new BufferedReader(isr);
	//StringBuffer sb = new StringBuffer();
	StringBuilder sb = new StringBuilder();
	int i;
	while((i=bin.read())!=-1){ 
		sb.append((char)i);
	}   
	req = sb.toString();
	BODY = getObject(req); //넘어온 값 BODY에 저장
	JSONObject keylist = (JSONObject)BODY.get("userinfo"); // 넘어온 값에서 key값 추출
	String token = getVal(keylist, "key");
//OUTVAR.put("debug_keyvalue",keyvalue ); 

	/********************** KEY값 확인 후 apicode로 포워딩 **********************/
	if("JIGHe-V6De0-VsHYn-a6xd6-BzDe4".equals(token)) {
		/****************TOKEN KEY값과 apicode가 일치하면 다른 JSP로 이동**************/
		if(isNull(BODY.get("INVAR"))) {
    		success = false;
    		code    = 204;
    		message = "INVAR not exists"; 
		} else {
		    if(!isNull(getVal(BODY,"userinfo"))) { BODY.remove("userinfo"); } //userinfo는 삭제 
    		request.setAttribute("INVAR", ((JSONObject)BODY.get("INVAR")).toString() ); //request에 INVAR라는 변수명으로 data저장
    		/* 전달받은 요청주소(app.pgmid)로 Redirect한다. (Redirect시 INVAR data는 자동으로 연결된다.) */
    		pageContext.forward("./WEB-INF/apps/api/"+apicodevalue+".jsp");  
		}
	} else {
		success = false;
		code    = 203;
		message = "invalid token";
	}
} catch (Exception e) {
	success = false;
	code    = 299;
	message = "error on api hub :" + e.toString();
} finally {
	if(bin!=null) bin.close();	
	if(isr!=null) isr.close();	
	OUTVAR.put("success",success); //OUTVAR에 success 넣기
	OUTVAR.put("code",code);
	OUTVAR.put("message",message); //OUTVAR에 message 넣기
	out.println(OUTVAR.toJSONString());
}   
%> 