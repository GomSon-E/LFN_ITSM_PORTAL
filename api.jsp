<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<% 
JSONObject OUTVAR = new JSONObject();
String enc = "UTF-8";
InputStreamReader isr = null;
BufferedReader bin = null;
String req = "";
JSONObject INVAR  = null; 
Connection conn = null;
String rtnCode    = "OK";
String rtnMsg     = "";
JSONParser parser = new JSONParser();
try {
	conn = getConn("LFN"); //DB 연결

	/**********************POST로 넘어온 값을 받아오기**********************/
    isr = new InputStreamReader( request.getInputStream(), enc ); 
	bin = new BufferedReader(isr);
	//StringBuffer sb = new StringBuffer();
    StringBuilder sb = new StringBuilder();
	int i;
	while((i=bin.read())!=-1){ 
		sb.append((char)i);
	}   
	req = sb.toString();
	INVAR = getObject(req); //넘어온 값 INVAR에 저장
	System.out.println(INVAR);
	String data = INVAR.toString();
	String apicodevalue = request.getParameter("apicode");
	System.out.println(apicodevalue);
	JSONObject keylist = (JSONObject)INVAR.get("user_info"); // 넘어온 값에서 key값 추출
	String keyvalue = (String)keylist.get("key");
	System.out.println(keyvalue);

	/**********************DB에서  KEY값과 apicode 확인**********************/

	INVAR.put("keyvalue",keyvalue); //INVAR에 추출한 Key값 넣기
	INVAR.put("apicode",apicodevalue); //INVAR에 추출한 api값 넣기
	String pgmid = apicodevalue; //페이지 이동을 위한 값 설정
	String func = apicodevalue; //페이지 이동을 위한 값 설정
	String qry = "SELECT TEST_1, TEST_2 FROM TEST_MJW WHERE TEST_1={keyvalue} AND TEST_2={apicode}"; //DB에 있는 Key값 및 apicode값과 전달된 값이 같은지 비교확인
	String qryRun = bindVAR(qry,INVAR);
	JSONArray val1 = selectSVC(conn, qryRun); //DB에서 비교하여 가져온 key값 및 apicode값
	JSONObject val2 = (JSONObject)val1.get(0);
	String key = (String)val2.get("test_1"); //DB에서 가져온 key값 추출
	String apicode = (String)val2.get("test_2"); //DB에서 가져온 apicode값 추출
	
	/****************KEY값과 apicode가 일치하면 다른 JSP로 이동**************/
	request.setAttribute("INVAR",data); //request에 INVAR라는 변수명으로 data저장
	/* 전달받은 요청주소(app.pgmid func)로 Redirect한다. (Redirect시 INVAR data는 자동으로 연결된다.) */
	if( keyvalue.equals(key) && apicodevalue.equals(apicode)){ //처음 가져온 key 및 apicode값과 DB에서 가져온 key값 및 apicode가 서로 일치하는지 확인
		pageContext.forward("./WEB-INF/apps/api/"+pgmid+".jsp"+"?func="+func); //{INVAR: "{JSON:~~}" }, 두 값이 일치하면 페이지 이동
	}
	
	
   
} catch (Exception e) {
	OUTVAR.put("body", e.toString());
} finally {
	if(bin!=null) bin.close();	
	if(isr!=null) isr.close();	
}   
%> 