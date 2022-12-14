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
        String token = "kr1AAAA21rfK8+Gq4jHV8fCkTgfIYZodBpDiIi9W+f6pS37Z7/IxO8yTmIe7eRQp+oqhRbJ7SF/SaF1ZxyiOixEitOZz+SBYeCCeypZNHY3pOd8iYmT+qhFw6hijeg0UBH02mHVNFJlYzb0vOXrf4yv4c1jgYjWO/0PfQP2e+yWKGgyIDqm++JswvYrO6NjpMyeuBlk2b5nWmJv+MTGLgGDWeV3GlfOkqFArsRsSOmlMdFJld8OPXpDfrCtOVATW1PFinNTh3DyjhCiX8LqrEYTTwFxZYBd8SfX+plJIrbBrvUYUWSu",
    "refresh_token": "kr1AAAAg9et/NHoB76VK6bYGB5i8ni67lW/wHvpjo6h3gkzA9ehYqHo9RahpTv/XSiZf/utRGGZuYYSAcm0kQAWyza83NzpOt5Y2hC/ugwhlaEUVdxLjkCVhlAPlDFrYZdsC6UDYjBoVV4vnCCT0LWOScWEl5BW8DSjkAmfkmyHrRV6vPwCng30yNdGKrAEHAICvGRVYw==";
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
            String header = "Bearer " + token; // Bearer ????????? ?????? ??????

            //????????? ??? 
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
            huc.setRequestProperty("Cache-Control","no-cache");  // ????????? ?????? ?????? 
            huc.setRequestProperty("Content-Length", "length");  // ???????????? ??????(Request Body ????????? Data Type??? ????????? ??????.) 
            huc.setRequestProperty("User-Agent", "LFN_EP");        // User-Agent ??? ?????? 
            huc.setDoOutput(true); // OutputStream?????? POST ???????????? ?????????????????? ??????. 
            huc.setDoInput(true); // InputStream?????? ????????? ?????? ????????? ???????????? ??????. 

                body.put(  "to", usid);
                body.put( "subject", "??????????????? ????????? ");
                body.put("body", "??????????????? ????????? ???????????????. ?????? ????????? ??????????????????. ?????? ??????????????? 1234! ?????????. <a href='http://localhost:9090/?''>???????????? ?????????</a>");
                body.put("contentType", "html");
                body.put(  "userName", "admin");
                body.put("isSaveSentMail", true);
                body.put("isSendSeparately", false);
            
            OutputStream os = huc.getOutputStream(); // Request Body??? Data??? ???????????? OutputStream ????????? ??????.    
            os.write(body.toString().getBytes("UTF-8"));
            OUTVAR.put("body",body);
            os.flush(); // Request Body??? Data ??????. 
            os.close(); // OutputStream ??????.     

            int responseCode = huc.getResponseCode();  //?????? ????????? Request ?????? ?????? ??????. (?????? ????????? ?????????. 200 ??????, ????????? ??????) 
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
