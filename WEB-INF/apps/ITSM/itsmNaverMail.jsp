<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "ITSM";
String pgmid   = "itsmNaverMail"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/

if("sendMsg4".equals(func)) {
    Connection conn = null; 
    OUTVAR.put("INVAR",INVAR);
    // JSONObject header      = new JSONObject();
    JSONObject content      = new JSONObject();
    JSONObject body = new JSONObject();
    JSONObject usidobj = new JSONObject();
    
    String usid = "";
    String type = "";
    String textMsg = "";
    String link = "";
    String linkText = "Open the link";
    String sUrl = request.getParameter("url");
	String enc = request.getParameter("enc"); 
	InputStreamReader isr = null;
	BufferedReader bin = null;
    OutputStreamWriter writer = null;
    
    try {  
        OUTVAR.put("INVAR",INVAR);
        JSONArray usidlist = getArray(INVAR,"usidlist"); 
        String token = "kr1AAAA3SunikDDk8fj+xwULBh0UbcUEEPl9lgcRucyyfK5hd5sPH0eZv8QOafhz7cNkbTH4Klhhl+/ye1FBGOoNSsu9O74rinnv+WQpW3eREzL1zk6ErXR/AJ3wWcup1xav4Xw/wE38td7ivOwqfzTnMCFr0GZNz51w2ntrpX2CmJeTV5w2MqS5H+XPqhnsdyRhumZywC5MRtWomTZIMc6H4i5mwS/qJlOF+jiLcPjoHMIlfHB6NadZ7vNcVxlBRzbsh+kgZr7lPE34nDKNDD40iNg8Kjvu0AiT0wdOvqhWlVcJkKv";
        // token = URLEncoder.encode(token,"UTF-8");
        

        for(int k=0; k<usidlist.size(); k++){
        
            usidobj = getRow(usidlist, k);
            usid= getVal(usidobj,"usid");
            type = getVal(usidobj,"type");
            textMsg = getVal(usidobj,"msg");
            link = getVal(usidobj,"link");
            OUTVAR.put("usid", usid);
            INVAR.put("comcd","LFN");
            conn = getConn("LFN");  
            String header = "Bearer " + token; // Bearer 다음에 공백 추가

            //전송한 후 
            //if(isNull(sUrl)) 
            // sUrl = "https://www.worksapis.com/v1.0/bots/4608623/users/" + usid + "@lfnetworks.co.kr/messages";

            sUrl = "https://www.worksapis.com/v1.0/users/" + usid + "/mail";            //if(isNull(enc)) 
    	    enc = "UTF-8"; 
            URL url = new URL(sUrl);
            
    	    HttpURLConnection huc = (HttpURLConnection)url.openConnection();
    	    huc.setRequestMethod("POST");  
            huc.setRequestProperty("Authorization", header);
            OUTVAR.put("header",header);
            huc.setRequestProperty("Content-Type", "application/json");
            huc.setRequestProperty("Accept", "application/json");
            huc.setRequestProperty("Cache-Control","no-cache");  // 컨트롤 캐쉬 설정 
            huc.setRequestProperty("Content-Length", "length");  // 타입길이 설정(Request Body 전달시 Data Type의 길이를 정함.) 
            huc.setRequestProperty("User-Agent", "LFN_EP");        // User-Agent 값 설정 
            huc.setDoOutput(true); // OutputStream으로 POST 데이터를 넘겨주겠다는 옵션. 
            huc.setDoInput(true); // InputStream으로 서버로 부터 응답을 받겠다는 옵션. 

                body.put(  "to", usid);
                body.put( "subject", "비밀번호가 초기화 ");
                body.put("body", "비밀번호가 초기화 되었습니다. 다시 로그인 시도해주세요. 초기 비밀번호는 1234! 입니다. <a href='http://localhost:9090/?''>비밀번호 재설정</a>");
                body.put("contentType", "html");
                body.put(  "userName", "admin");
                body.put("isSaveSentMail", true);
                body.put("isSendSeparately", false);
            
            OutputStream os = huc.getOutputStream(); // Request Body에 Data를 담기위해 OutputStream 객체를 생성.    
            os.write(body.toString().getBytes("UTF-8"));
            OUTVAR.put("body",body);
            os.flush(); // Request Body에 Data 입력. 
            os.close(); // OutputStream 종료.     

            int responseCode = huc.getResponseCode();  //실제 서버로 Request 요청 하는 부분. (응답 코드를 받는다. 200 성공, 나머지 에러) 
            OUTVAR.put("responseCode",responseCode);
            bin = new BufferedReader(new InputStreamReader(huc.getInputStream(), "UTF-8")); 
            StringBuffer sb = new StringBuffer(); 
            String temp = "";
            while ((temp = bin.readLine()) != null) {
                sb.append(temp);
            }
            
            OUTVAR.put("responseCode",responseCode);
            OUTVAR.put("sb",sb.toString());
            
            bin.close();
        } 
    } catch (Exception e) { 
        success = false;
        code    = 208;
        message = e.toString();
			
    } finally {
        closeConn(conn);
    }   
}

// *********************************************************************************************/
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
