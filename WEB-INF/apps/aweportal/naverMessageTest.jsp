<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   
JSONObject OUTVAR = new JSONObject(); 
String appid = "aweportal";    //<===== 수정할 것!
String pgmid   = "manageProfile"; //<===== 수정할 것!
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";
try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar);
/***************************************************************************************************/
if("selectprofile".equals(func)) {
    Connection conn = null;  
    try {
        
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        INVAR.put("userid",USERID);
        String qry = "SELECT NM, NICK_NM , EMAIL FROM T_USER WHERE USID = {userid}";//T_PGM_SRC.content 

        String qryRun = bindVAR(qry,INVAR);
        JSONArray list = selectSVC(conn,qryRun);
     
        OUTVAR.put("list",list);
      
    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    }        
}
else if("search".equals(func)) {
    Connection conn = null;  
    try {
        
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        String qry = getQuery(pgmid,"retrieveProfile"); //T_PGM_SRC.content 
        String qryRun = bindVAR(qry,INVAR);
        JSONArray list = selectSVC(conn,qryRun);
        
        OUTVAR.put("list",list);
        System.out.println(OUTVAR.toJSONString());
      
    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    }        
} 
else if ("save".equals(func)) {
    Connection conn = null;  
    try {   
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        conn.setAutoCommit(false);
        INVAR.put("usid",USERID); 
        //INVAR {list:[{cd: "PGM", remark: "프로그램", sort_seq: "1", nm: "프로그램"}]}
        String qry = "UPDATE T_USER SET NICK_NM = {nick_nm}, EMAIL = {email} WHERE USID = {usid};"; //T_PGM_SRC.content 
        String qryRun = "";
        JSONArray list = getArray(INVAR,"list");
        System.out.println(list);
        for(int i=0 ; i < list.size(); i++) {
            //qry문을 계속더해준다.
            JSONObject row = getRow(list,i);
            row.put("usid",USERID);
            qryRun += bindVAR(qry,row); 
        }
        JSONObject rst = executeSVC(conn, qryRun);
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg");
        } else {
            conn.commit(); 
        } 

    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    } 
}  
else if ("Search".equals(func)) {
    String enc = "UTF-8"; 
    String sOUTVAR = "";
	HttpURLConnection huc = null;
	try {  
		String url_webhook = getVal(INVAR, "url_webhook"); // request.getParameter("url");
		String ar_order_info = getVal(INVAR, "ar_order_info");
        System.out.println(ar_order_info); 
		//String body = getVal(INVAR, "body"); 
		String connectColor = getVal(INVAR, "connectColor"); 
		//JSONArray connectInfo = getArray(INVAR, "connectInfo"); 
        /* 트라이본즈/파스텔웹훅: 0254859c476d6cd040d34ecbeacac8d6 */
        /* 이기현 테스트웹훅 토큰: b462b488aaa151032d1736df6eeb4c36 */
		if(isNull(url_webhook)) url_webhook = "http://localhost:8080";
		if(isNull(connectColor)) connectColor = "#FAC11B"; 
		URL url = new URL(url_webhook); 
        System.out.println(url);
		huc = (HttpURLConnection) url.openConnection();
        huc.setRequestMethod("GET");  
        huc.setRequestProperty("Accept", "applicateion/json");
        huc.setRequestProperty("Content-Type", "application/json; utf-8");  
        huc.setRequestProperty("Cache-Control","no-cache");  // 컨트롤 캐쉬 설정 
        huc.setRequestProperty("Content-Length", "length");  // 타입길이 설정(Request Body 전달시 Data Type의 길이를 정함.) 
        huc.setRequestProperty("User-Agent", "test");        // User-Agent 값 설정 
        //huc.setDoOutput(true); // OutputStream으로 POST 데이터를 넘겨주겠다는 옵션. 
        //huc.setDoInput(true); // InputStream으로 서버로 부터 응답을 받겠다는 옵션. 
        //OutputStream os = huc.getOutputStream(); // Request Body에 Data를 담기위해 OutputStream 객체를 생성.
        //JSONObject oBody = new JSONObject();     // Request Body에 Data 셋팅.
        //oBody.put("SearchKey",SearchKey);
        //oBody.put("connectColor", connectColor); 
        //oBody.put("connectInfo",connectInfo); 
        //System.out.println(oBody);
        //os.write(oBody.toString().getBytes("UTF-8")); //body.getBytes("UTF-8")  
        //os.flush(); // Request Body에 Data 입력. 
        //os.close(); // OutputStream 종료. 
        
        int responseCode = huc.getResponseCode();  //실제 서버로 Request 요청 하는 부분. (응답 코드를 받는다. 200 성공, 나머지 에러)br = new BufferedReader(new InputStreamReader(huc.getInputStream(), "UTF-8")); 
        System.out.println(responseCode);
        BufferedReader br = new BufferedReader(new InputStreamReader(huc.getInputStream()));
        StringBuilder sb = new StringBuilder();
        String temp = "";
        while ((temp = br.readLine()) != null) {
            sb.append(temp);
        }
        sOUTVAR = sb.toString();
        //System.out.println(sOUTVAR);
        //JSONParser parser = new JSONParser();	
        //OUTVAR = (JSONObject) parser.parse(sOUTVAR);  
        //System.out.println(OUTVAR);
        OUTVAR.put("sOUTVAR",sOUTVAR);
        OUTVAR.put("Code", responseCode); 
        //OUTVAR.put("oBody", oBody);
		
	} catch (Exception e) {
		OUTVAR.put("rtnCd","ERR");
		OUTVAR.put("rtnMsg", e.toString()); 
	} finally {
		if(huc!=null) huc.disconnect();	
	}
} 
else if ("PostSearch".equals(func)) {
    String enc = "UTF-8"; 
    String sOUTVAR = "";
    String sCode = "";
	HttpURLConnection huc = null;
    JSONObject user_info = new JSONObject();
    user_info.put("key","JIGHe-V6De0-VsHYn-a6xd6-BzDe4");
    String list = getVal(INVAR,"list");
    JSONParser parser = new JSONParser();
    JSONArray listdata = (JSONArray)parser.parse(list);
	try {  
		String url_webhook = getVal(INVAR, "url_webhook");// request.getParameter("url");
		String body = getVal(INVAR, "body"); 
		String connectColor = getVal(INVAR, "connectColor"); 
		JSONArray connectInfo = getArray(INVAR, "connectInfo"); 
        /* 트라이본즈/파스텔웹훅: 0254859c476d6cd040d34ecbeacac8d6 */
        /* 이기현 테스트웹훅 토큰: b462b488aaa151032d1736df6eeb4c36 */
		if(isNull(url_webhook)) url_webhook = "https://fo.lfnetworks.co.kr/api.jsp";
		URL url = new URL(url_webhook); 
		huc = (HttpURLConnection) url.openConnection();
        huc.setRequestMethod("POST");  
        huc.setRequestProperty("Accept", "applicateion/json");
        huc.setRequestProperty("Content-Type", "application/json; utf-8");  
        huc.setRequestProperty("Cache-Control","no-cache");  // 컨트롤 캐쉬 설정 
        huc.setRequestProperty("Content-Length", "length");  // 타입길이 설정(Request Body 전달시 Data Type의 길이를 정함.) 
        huc.setRequestProperty("User-Agent", "User-Agent");  // User-Agent 값 설정 
        huc.setDoOutput(true); // OutputStream으로 POST 데이터를 넘겨주겠다는 옵션. 
        huc.setDoInput(true); // InputStream으로 서버로 부터 응답을 받겠다는 옵션. 
        OutputStream os = huc.getOutputStream(); // Request Body에 Data를 담기위해 OutputStream 객체를 생성.
        JSONObject oBody = new JSONObject();
        oBody.put("user_info",user_info);     // Request Body에 Data 셋팅.
        oBody.put("ar_order_info",listdata);
        os.write(oBody.toString().getBytes("UTF-8")); //body.getBytes("UTF-8")  
        os.flush(); // Request Body에 Data 입력. 
        os.close(); // OutputStream 종료. 
        
        int responseCode = huc.getResponseCode();  //실제 서버로 Request 요청 하는 부분. (응답 코드를 받는다. 200 성공, 나머지 에러)br = new BufferedReader(new InputStreamReader(huc.getInputStream(), "UTF-8")); 
        System.out.println(responseCode);
        BufferedReader br = new BufferedReader(new InputStreamReader(huc.getInputStream()));
        StringBuilder sb = new StringBuilder();
        String temp = "";
        while ((temp = br.readLine()) != null) {
            sb.append(temp);
        }
        sOUTVAR = sb.toString();
        OUTVAR.put("sOUTVAR",sOUTVAR);
        
		
	} catch (Exception e) {
		OUTVAR.put("rtnCd","ERR");
		OUTVAR.put("rtnMsg", e.toString()); 
	} finally {
		if(huc!=null) huc.disconnect();	
	}
} 
else if ("userSearch".equals(func)) {
    String enc = "UTF-8"; 
    String sOUTVAR = "";
	HttpURLConnection huc = null;
    JSONObject user_info = new JSONObject();
    user_info.put("key","JIGHe-V6De0-VsHYn-a6xd6-BzDe4");
    JSONObject apicode = new JSONObject();
    apicode.put("apicode","syncPrice");
    String list = getVal(INVAR,"list");
    JSONParser parser = new JSONParser();
    JSONArray listdata = (JSONArray)parser.parse(list);
	try {  
		String url_webhook = getVal(INVAR, "url_webhook");// request.getParameter("url");
		String body = getVal(INVAR, "body"); 
		String connectColor = getVal(INVAR, "connectColor"); 
		JSONArray connectInfo = getArray(INVAR, "connectInfo"); 
        /* 트라이본즈/파스텔웹훅: 0254859c476d6cd040d34ecbeacac8d6 */
        /* 이기현 테스트웹훅 토큰: b462b488aaa151032d1736df6eeb4c36 */
		if(isNull(url_webhook)) url_webhook = "http://localhost:8080/api.jsp";
		URL url = new URL(url_webhook); 
		huc = (HttpURLConnection) url.openConnection();
        huc.setRequestMethod("POST");  
        huc.setRequestProperty("Accept", "applicateion/json");
        huc.setRequestProperty("Content-Type", "application/json; utf-8");  
        huc.setRequestProperty("Cache-Control","no-cache");  // 컨트롤 캐쉬 설정 
        huc.setRequestProperty("Content-Length", "length");  // 타입길이 설정(Request Body 전달시 Data Type의 길이를 정함.) 
        huc.setRequestProperty("User-Agent", "User-Agent");  // User-Agent 값 설정 
        huc.setDoOutput(true); // OutputStream으로 POST 데이터를 넘겨주겠다는 옵션. 
        huc.setDoInput(true); // InputStream으로 서버로 부터 응답을 받겠다는 옵션. 
        OutputStream os = huc.getOutputStream(); // Request Body에 Data를 담기위해 OutputStream 객체를 생성.
        JSONObject oBody = new JSONObject();
        oBody.put("user_info",user_info);     // Request Body에 Data 셋팅.
        oBody.put("ar_order_info",listdata);
        oBody.put("apicode",apicode);
        System.out.println(oBody);
        os.write(oBody.toString().getBytes("UTF-8")); //body.getBytes("UTF-8")  
        os.flush(); // Request Body에 Data 입력. 
        os.close(); // OutputStream 종료. 
        
        int responseCode = huc.getResponseCode();  //실제 서버로 Request 요청 하는 부분. (응답 코드를 받는다. 200 성공, 나머지 에러)br = new BufferedReader(new InputStreamReader(huc.getInputStream(), "UTF-8")); 
        System.out.println(responseCode);
        BufferedReader br = new BufferedReader(new InputStreamReader(huc.getInputStream()));
        StringBuilder sb = new StringBuilder();
        String temp = "";
        while ((temp = br.readLine()) != null) {
            sb.append(temp);
        }
        sOUTVAR = sb.toString();
        OUTVAR.put("sOUTVAR",sOUTVAR);
        System.out.println(OUTVAR);
        
		
	} catch (Exception e) {
		OUTVAR.put("rtnCd","ERR");
		OUTVAR.put("rtnMsg", e.toString()); 
	} finally {
		if(huc!=null) huc.disconnect();	
        
	}
} 
else if ("receiveOnlineOrder".equals(func)) {
    String enc = "UTF-8"; 
    String sOUTVAR = "";
	HttpURLConnection huc = null;
    JSONObject user_info = new JSONObject();
    user_info.put("key","JIGHe-V6De0-VsHYn-a6xd6-BzDe4");
    System.out.println(user_info);
    JSONObject apicode = new JSONObject();
    apicode.put("apicode","receiveOnlineOrder");
    String list = getVal(INVAR,"list");
    System.out.println(list);
    JSONParser parser = new JSONParser();
    JSONArray listdata = (JSONArray)parser.parse(list);
    System.out.println(listdata);
	try {  
		String url_webhook = getVal(INVAR, "url_webhook");// request.getParameter("url");
		String body = getVal(INVAR, "body"); 
		String connectColor = getVal(INVAR, "connectColor"); 
		JSONArray connectInfo = getArray(INVAR, "connectInfo"); 
        /* 트라이본즈/파스텔웹훅: 0254859c476d6cd040d34ecbeacac8d6 */
        /* 이기현 테스트웹훅 토큰: b462b488aaa151032d1736df6eeb4c36 */
		if(isNull(url_webhook)) url_webhook = "http://localhost:8080/api.jsp";
		URL url = new URL(url_webhook); 
        System.out.println(url);
		huc = (HttpURLConnection) url.openConnection();
        huc.setRequestMethod("POST");  
        huc.setRequestProperty("Accept", "applicateion/json");
        huc.setRequestProperty("Content-Type", "application/json; utf-8");  
        huc.setRequestProperty("Cache-Control","no-cache");  // 컨트롤 캐쉬 설정 
        huc.setRequestProperty("Content-Length", "length");  // 타입길이 설정(Request Body 전달시 Data Type의 길이를 정함.) 
        huc.setRequestProperty("User-Agent", "User-Agent");  // User-Agent 값 설정 
        huc.setDoOutput(true); // OutputStream으로 POST 데이터를 넘겨주겠다는 옵션. 
        huc.setDoInput(true); // InputStream으로 서버로 부터 응답을 받겠다는 옵션. 
        OutputStream os = huc.getOutputStream(); // Request Body에 Data를 담기위해 OutputStream 객체를 생성.
        JSONObject oBody = new JSONObject();
        oBody.put("user_info",user_info);     // Request Body에 Data 셋팅.
        oBody.put("ar_order_info",listdata);
        oBody.put("apicode",apicode);
        System.out.println(oBody);
        os.write(oBody.toString().getBytes("UTF-8")); //body.getBytes("UTF-8")  
        os.flush(); // Request Body에 Data 입력. 
        os.close(); // OutputStream 종료. 
        
        int responseCode = huc.getResponseCode();  //실제 서버로 Request 요청 하는 부분. (응답 코드를 받는다. 200 성공, 나머지 에러)br = new BufferedReader(new InputStreamReader(huc.getInputStream(), "UTF-8")); 
        System.out.println(responseCode);
        BufferedReader br = new BufferedReader(new InputStreamReader(huc.getInputStream()));
        StringBuilder sb = new StringBuilder();
        String temp = "";
        while ((temp = br.readLine()) != null) {
            sb.append(temp);
        }
        sOUTVAR = sb.toString();
        System.out.println(sOUTVAR);
        OUTVAR.put("sOUTVAR",sOUTVAR);
        JSONObject jsonobject = new JSONObject();
        jsonobject.put("Code",responseCode);
        System.out.println(jsonobject);
		
	} catch (Exception e) {
		OUTVAR.put("rtnCd","ERR");
		OUTVAR.put("rtnMsg", e.toString()); 
	} finally {
		if(huc!=null) huc.disconnect();	
	}
}
else if ("receiveOnlineDetail".equals(func)) {
    String enc = "UTF-8"; 
    String sOUTVAR = "";
	HttpURLConnection huc = null;
    JSONObject user_info = new JSONObject();
    user_info.put("key","JIGHe-V6De0-VsHYn-a6xd6-BzDe4");
    System.out.println(user_info);
    JSONObject apicode = new JSONObject();
    apicode.put("apicode","receiveOnlineDetail");
    String list = getVal(INVAR,"list");
    System.out.println(list);
    JSONParser parser = new JSONParser();
    JSONArray listdata = (JSONArray)parser.parse(list);
    System.out.println(listdata);
	try {  
		String url_webhook = getVal(INVAR, "url_webhook");// request.getParameter("url");
		String body = getVal(INVAR, "body"); 
		String connectColor = getVal(INVAR, "connectColor"); 
		JSONArray connectInfo = getArray(INVAR, "connectInfo"); 
        /* 트라이본즈/파스텔웹훅: 0254859c476d6cd040d34ecbeacac8d6 */
        /* 이기현 테스트웹훅 토큰: b462b488aaa151032d1736df6eeb4c36 */
		if(isNull(url_webhook)) url_webhook = "http://localhost:8080/api.jsp";
		URL url = new URL(url_webhook); 
        System.out.println(url);
		huc = (HttpURLConnection) url.openConnection();
        huc.setRequestMethod("POST");  
        huc.setRequestProperty("Accept", "applicateion/json");
        huc.setRequestProperty("Content-Type", "application/json; utf-8");  
        huc.setRequestProperty("Cache-Control","no-cache");  // 컨트롤 캐쉬 설정 
        huc.setRequestProperty("Content-Length", "length");  // 타입길이 설정(Request Body 전달시 Data Type의 길이를 정함.) 
        huc.setRequestProperty("User-Agent", "User-Agent");  // User-Agent 값 설정 
        huc.setDoOutput(true); // OutputStream으로 POST 데이터를 넘겨주겠다는 옵션. 
        huc.setDoInput(true); // InputStream으로 서버로 부터 응답을 받겠다는 옵션. 
        OutputStream os = huc.getOutputStream(); // Request Body에 Data를 담기위해 OutputStream 객체를 생성.
        JSONObject oBody = new JSONObject();
        oBody.put("user_info",user_info);     // Request Body에 Data 셋팅.
        oBody.put("ar_order_info",listdata);
        oBody.put("apicode",apicode);
        System.out.println(oBody);
        os.write(oBody.toString().getBytes("UTF-8")); //body.getBytes("UTF-8")  
        os.flush(); // Request Body에 Data 입력. 
        os.close(); // OutputStream 종료. 
        
        int responseCode = huc.getResponseCode();  //실제 서버로 Request 요청 하는 부분. (응답 코드를 받는다. 200 성공, 나머지 에러)br = new BufferedReader(new InputStreamReader(huc.getInputStream(), "UTF-8")); 
        System.out.println(responseCode);
        BufferedReader br = new BufferedReader(new InputStreamReader(huc.getInputStream()));
        StringBuilder sb = new StringBuilder();
        String temp = "";
        while ((temp = br.readLine()) != null) {
            sb.append(temp);
        }
        sOUTVAR = sb.toString();
        System.out.println(sOUTVAR);
        OUTVAR.put("sOUTVAR",sOUTVAR);
		
	} catch (Exception e) {
		OUTVAR.put("rtnCd","ERR");
		OUTVAR.put("rtnMsg", e.toString()); 
	} finally {
		if(huc!=null) huc.disconnect();	
	}
} 
else if ("receiveOnlineConfirm".equals(func)) {
    String enc = "UTF-8"; 
    String sOUTVAR = "";
	HttpURLConnection huc = null;
    JSONObject user_info = new JSONObject();
    user_info.put("key","JIGHe-V6De0-VsHYn-a6xd6-BzDe4");
    System.out.println(user_info);
    JSONObject apicode = new JSONObject();
    apicode.put("apicode","receiveOnlineConfirm");
    String list = getVal(INVAR,"list");
    System.out.println(list);
    JSONParser parser = new JSONParser();
    JSONArray listdata = (JSONArray)parser.parse(list);
    System.out.println(listdata);
	try {  
		String url_webhook = getVal(INVAR, "url_webhook");// request.getParameter("url");
		String body = getVal(INVAR, "body"); 
		String connectColor = getVal(INVAR, "connectColor"); 
		JSONArray connectInfo = getArray(INVAR, "connectInfo"); 
        /* 트라이본즈/파스텔웹훅: 0254859c476d6cd040d34ecbeacac8d6 */
        /* 이기현 테스트웹훅 토큰: b462b488aaa151032d1736df6eeb4c36 */
		if(isNull(url_webhook)) url_webhook = "http://localhost:8080/api.jsp";
		URL url = new URL(url_webhook); 
        System.out.println(url);
		huc = (HttpURLConnection) url.openConnection();
        huc.setRequestMethod("POST");  
        huc.setRequestProperty("Accept", "applicateion/json");
        huc.setRequestProperty("Content-Type", "application/json; utf-8");  
        huc.setRequestProperty("Cache-Control","no-cache");  // 컨트롤 캐쉬 설정 
        huc.setRequestProperty("Content-Length", "length");  // 타입길이 설정(Request Body 전달시 Data Type의 길이를 정함.) 
        huc.setRequestProperty("User-Agent", "User-Agent");  // User-Agent 값 설정 
        huc.setDoOutput(true); // OutputStream으로 POST 데이터를 넘겨주겠다는 옵션. 
        huc.setDoInput(true); // InputStream으로 서버로 부터 응답을 받겠다는 옵션. 
        OutputStream os = huc.getOutputStream(); // Request Body에 Data를 담기위해 OutputStream 객체를 생성.
        JSONObject oBody = new JSONObject();
        oBody.put("user_info",user_info);     // Request Body에 Data 셋팅.
        oBody.put("ar_order_info",listdata);
        oBody.put("apicode",apicode);
        System.out.println(oBody);
        os.write(oBody.toString().getBytes("UTF-8")); //body.getBytes("UTF-8")  
        os.flush(); // Request Body에 Data 입력. 
        os.close(); // OutputStream 종료. 
        
        int responseCode = huc.getResponseCode();  //실제 서버로 Request 요청 하는 부분. (응답 코드를 받는다. 200 성공, 나머지 에러)br = new BufferedReader(new InputStreamReader(huc.getInputStream(), "UTF-8")); 
        System.out.println(responseCode);
        BufferedReader br = new BufferedReader(new InputStreamReader(huc.getInputStream()));
        StringBuilder sb = new StringBuilder();
        String temp = "";
        while ((temp = br.readLine()) != null) {
            sb.append(temp);
        }
        sOUTVAR = sb.toString();
        System.out.println(sOUTVAR);
        OUTVAR.put("sOUTVAR",sOUTVAR);
		
	} catch (Exception e) {
		OUTVAR.put("rtnCd","ERR");
		OUTVAR.put("rtnMsg", e.toString()); 
	} finally {
		if(huc!=null) huc.disconnect();	
	}
} 
else if ("Popuptest".equals(func)) {
    String enc = "UTF-8"; 
    String sOUTVAR = "";
	HttpURLConnection huc = null;
    
	try {  
		String url_webhook = getVal(INVAR, "url_webhook"); // request.getParameter("url");
		String list = getVal(INVAR, "list"); 
        System.out.println(list);
		String body = getVal(INVAR, "body"); 
		String connectColor = getVal(INVAR, "connectColor"); 
		JSONArray connectInfo = getArray(INVAR, "connectInfo"); 
        /* 트라이본즈/파스텔웹훅: 0254859c476d6cd040d34ecbeacac8d6 */
        /* 이기현 테스트웹훅 토큰: b462b488aaa151032d1736df6eeb4c36 */
		if(isNull(url_webhook)) url_webhook = "https://webhook.site/3f00400f-de74-4983-b7d5-a0ca4ed4719c"; 
		if(isNull(connectColor)) connectColor = "#FAC11B"; 
		URL url = new URL(url_webhook); 
        System.out.println(url);
		huc = (HttpURLConnection) url.openConnection();
        huc.setRequestMethod("POST");  
        huc.setRequestProperty("Accept", "applicateion/json");
        huc.setRequestProperty("Content-Type", "application/json; utf-8");  
        huc.setRequestProperty("Cache-Control","no-cache");  // 컨트롤 캐쉬 설정 
        huc.setRequestProperty("Content-Length", "length");  // 타입길이 설정(Request Body 전달시 Data Type의 길이를 정함.) 
        huc.setRequestProperty("User-Agent", "User-Agent");  // User-Agent 값 설정 
        huc.setDoOutput(true); // OutputStream으로 POST 데이터를 넘겨주겠다는 옵션. 
        huc.setDoInput(true); // InputStream으로 서버로 부터 응답을 받겠다는 옵션. 
        OutputStream os = huc.getOutputStream(); // Request Body에 Data를 담기위해 OutputStream 객체를 생성.
        JSONObject oBody = new JSONObject();     // Request Body에 Data 셋팅.
        oBody.put("list",list);
        oBody.put("connectColor", connectColor); 
        System.out.println(oBody);
        os.write(oBody.toString().getBytes("UTF-8")); //body.getBytes("UTF-8")  
        os.flush(); // Request Body에 Data 입력. 
        os.close(); // OutputStream 종료. 
        
        int responseCode = huc.getResponseCode();  //실제 서버로 Request 요청 하는 부분. (응답 코드를 받는다. 200 성공, 나머지 에러)br = new BufferedReader(new InputStreamReader(huc.getInputStream(), "UTF-8")); 
        System.out.println(responseCode);
        BufferedReader br = new BufferedReader(new InputStreamReader(huc.getInputStream()));
        StringBuilder sb = new StringBuilder();
        String temp = "";
        while ((temp = br.readLine()) != null) {
            sb.append(temp);
        }
        sOUTVAR = sb.toString();
        System.out.println(sOUTVAR);
        OUTVAR.put("sOUTVAR",sOUTVAR);
		
	} catch (Exception e) {
		OUTVAR.put("rtnCd","ERR");
		OUTVAR.put("rtnMsg", e.toString()); 
	} finally {
		if(huc!=null) huc.disconnect();	
	}
} 
/***************************************************************************************************/
} catch (Exception e) {
	logger.error(pgmid+" error occurred:"+rtnCode,e);
	rtnCode    = "ERR";
	rtnMsg     = e.toString();
} finally {
	OUTVAR.put("rtnCd",rtnCode);
	OUTVAR.put("rtnMsg",rtnMsg); 
	out.println(OUTVAR.toJSONString());
}
%> 