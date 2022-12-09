<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"%> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "api";
String pgmid   = "itsm_naver_bot"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";
Boolean success = true;
int     code    = 200;
String  message  = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/

if("sendMsg3".equals(func)) {
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
        String token = "kr1AAAA2uPTC2EAllKzC5ic+5UYtQvBUpwvSy60aIy26YKGeQTEfI4fNhTZ95QArHBrK1qNYUFSZncwAH9aYb7zQySHy+KhIK9aYRcGrDseLU3OxfAIjgH3fGQyq5FTJllwqFq8iWDtRBQsxfiJqiBgPf2Q7fw7gS74ato9dsB3rpMoYJrbctQdGhOAflZdLif82LWeizKhqoCk07xFrMgoMjdFkAP6f6540WxUuJQUOPqqlmQSYhHCMHVt8ehdXHGfBhQJNRzZ42jCHBvgl9CssI/mFVN5qa+ERzar48oGUrdBhf2I";

        for(int k=0; k<usidlist.size(); k++){
        
            usidobj = getRow(usidlist, k);
            usid= getVal(usidobj,"usid");
            type = getVal(usidobj,"type");
            textMsg = getVal(usidobj,"msg");
            link = getVal(usidobj,"link");
            
            INVAR.put("comcd","LFN");
            conn = getConn("LFN");  
            String header = "Bearer " + token; // Bearer 다음에 공백 추가

            //전송한 후 
            //if(isNull(sUrl)) 
            sUrl = "https://www.worksapis.com/v1.0/bots/4608623/users/" + usid + "@lfnetworks.co.kr/messages";
    	    //if(isNull(enc)) 
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

            if(type.equals("text")){
                content.put("type","text");
                content.put("text", textMsg);
                body.put("content",content);
            }else{ //'link'
                content.put("type","link");
                content.put("contentText",textMsg);
                content.put("linkText","Open the link");
                content.put("link",link);
                body.put("content",content);
            }
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