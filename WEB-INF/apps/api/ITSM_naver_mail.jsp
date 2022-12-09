// <%@ include file="/WEB-INF/src/common.jsp" %>
// <%@ page language="java" contentType="text/html; charset=UTF-8"%> 
// <%  
// //if (!aweCheck(session)) return;   

// JSONObject OUTVAR = new JSONObject(); 
// String appid = "api";
// String pgmid   = "ITSM_naver_mail"; 
// String func  = request.getParameter("func"); 
// String rtnCode    = "OK";
// String rtnMsg     = "";
// Boolean success = true;
// int     code    = 200;
// String  message  = "";

// try { 
// String invar = request.getParameter("INVAR");
// JSONObject INVAR  = getObject(invar); 
// /***************************************************************************************************/

// if("sendMsg2".equals(func)) {
//     Connection conn = null; 
    
//     JSONObject content      = new JSONObject();
//     JSONObject body = new JSONObject();
//     JSONObject usidobj = new JSONObject();
    
//     String usid = "";
//     String type = "";
//     String textMsg = "";
//     String link = "";
//     String linkText = "Open the link";
//     String sUrl = request.getParameter("url");
// 	String enc = request.getParameter("enc"); 
// 	InputStreamReader isr = null;
// 	BufferedReader bin = null;
//     OutputStreamWriter writer = null;
    
//     try {  
//         OUTVAR.put("INVAR",INVAR);
//         JSONArray usidlist = getArray(INVAR,"usidlist"); 
//         String token = "";
    
//         //Token을 조회하여 사용한다. 없으면 갱신발행한 후 진행한다.
//         conn = getConn("LFN");
//         String qry = getQuery(pgmid,"searchToken");
//         JSONObject JOtoken = getRow(selectSVC(conn, qry),0);
//         token = getVal(JOtoken,"access_token");
//         OUTVAR.put("JOtoken",JOtoken);
        
//         if(isNull(getVal(JOtoken,"access_token"))) {
        
//             String refresh_token = getVal(JOtoken,"refresh_token");
//             refresh_token = URLEncoder.encode(refresh_token,"UTF-8");
//             String client_id = "P_l79E070QjeXChMmSi6";
//             String client_secret = "tpJUC7pK9A";
    
//             try {  
//                 enc = "UTF-8"; 
//                 sUrl = "https://auth.worksmobile.com/oauth2/v2.0/token";
//                 URL url = new URL(sUrl);
//         	    HttpURLConnection huc = (HttpURLConnection)url.openConnection();
        	    
//         	    huc.setDoInput(true); // InputStream으로 서버로 부터 응답을 받겠다는 옵션.
//                 huc.setRequestProperty("Content-Type", "application/x-www-form-urlencoded"); //multipart/form-data
//                 huc.setRequestMethod("POST");
                
        
//                 huc.setDoOutput(true); // OutputStream으로 POST 데이터를 넘겨주겠다는 옵션. 
//                 String params = "grant_type=refresh_token&refresh_token="+refresh_token+"&client_id="+client_id+"&client_secret="+client_secret;
                
//                 OutputStream os = huc.getOutputStream();
//                 os.write(params.getBytes("UTF-8"));
//                 os.flush(); // Request Body에 Data 입력. 
//                 os.close(); // OutputStream 종료.
//                 OUTVAR.put("params",params);
        
//                 int responseCode = huc.getResponseCode();  //실제 서버로 Request 요청 하는 부분. (응답 코드를 받는다. 200 성공, 나머지 에러)
//                 OUTVAR.put("responseCodeT",responseCode);
//                 bin = new BufferedReader(new InputStreamReader(huc.getInputStream(), "UTF-8")); 
//                 StringBuffer sb = new StringBuffer(); 
//                 String temp = "";
//                 while ((temp = bin.readLine()) != null) {
//                     sb.append(temp);
//                 }
//                 OUTVAR.put("responseCodeT",responseCode);
//                 OUTVAR.put("sbT",sb.toString());
        
//                 bin.close();
                
//                 JSONParser json = new JSONParser();
//                 JSONObject jobj = (JSONObject)json.parse(sb.toString());
//                 OUTVAR.put("jobj",jobj.get("access_token"));
                
//                 INVAR.put("access_token",jobj.get("access_token"));
//                 token = (jobj.get("access_token")).toString();
//                 OUTVAR.put("INVAR",INVAR);
                
//                 //conn = getConn("LFN");
//                 conn.setAutoCommit(false);
                
//                 String qryX = getQuery(pgmid, "refreshToken"); 
//                 String qryRunX = bindVAR(qryX,INVAR);  
//                 OUTVAR.put("qryRunX",qryRunX); //for debug  
//                 JSONObject rst = executeSVC(conn, qryRunX);
//                 //rst.put("rtnCd","OK");
//                 if(!"OK".equals(getVal(rst,"rtnCd"))) {
//                     conn.rollback(); 
//                     rtnCode = getVal(rst, "rtnCd");
//                     rtnMsg  = getVal(rst, "rtnMsg");
//                 } else { 
//                     conn.commit(); 
//                 }
                
//             } catch(Exception e) {
//                 OUTVAR.put("refreshToken",e.toString());
//             }    
//         }
        
//         for(int k=0; k<usidlist.size(); k++){
        
//             usidobj = getRow(usidlist, k);
//             usid= getVal(usidobj,"usid");
//             type = getVal(usidobj,"type");
//             textMsg = getVal(usidobj,"msg");
//             link = getVal(usidobj,"link");
            
//             INVAR.put("comcd","LFN");
//             //conn = getConn("LFN");  
//             String header = "Bearer " + token; // Bearer 다음에 공백 추가
        
//             if(type.equals("text")){
//                 content.put("type","text");
//                 content.put("text",textMsg);
//                 body.put("content",content);
//             }else{ //'link'
//                 content.put("type","link");
//                 content.put("contentText",textMsg);
//                 content.put("linkText","Open the link");
//                 content.put("link",link);
//                 body.put("content",content);
//             }
            
//             //전송한 후 
//             //if(isNull(sUrl)) 
//             sUrl =  sUrl = "https://www.worksapis.com/v1.0/users/"+userId+"/mail";
//     	    //if(isNull(enc)) 
//     	    enc = "UTF-8"; 
//             URL url = new URL(sUrl);
//     	    HttpURLConnection huc = (HttpURLConnection)url.openConnection();
//     	    huc.setRequestMethod("POST");  
//             huc.setRequestProperty("Authorization", header);
//             //OUTVAR.put("header",header);
//             huc.setRequestProperty("Content-Type", "application/json");
//             huc.setRequestProperty("Accept", "application/json");
//             huc.setRequestProperty("Cache-Control","no-cache");  // 컨트롤 캐쉬 설정 
//             huc.setRequestProperty("Content-Length", "length");  // 타입길이 설정(Request Body 전달시 Data Type의 길이를 정함.) 
//             huc.setRequestProperty("User-Agent", "LFN_EP");        // User-Agent 값 설정 
//             huc.setDoOutput(true); // OutputStream으로 POST 데이터를 넘겨주겠다는 옵션. 
//             huc.setDoInput(true); // InputStream으로 서버로 부터 응답을 받겠다는 옵션. 
//             OutputStream os = huc.getOutputStream(); // Request Body에 Data를 담기위해 OutputStream 객체를 생성.    
            
//             os.write(body.toString().getBytes("UTF-8"));
//             OUTVAR.put("body",body);
//             os.flush(); // Request Body에 Data 입력. 
//             os.close(); // OutputStream 종료.     
        
//             int responseCode = huc.getResponseCode();  //실제 서버로 Request 요청 하는 부분. (응답 코드를 받는다. 200 성공, 나머지 에러) 
//             OUTVAR.put("responseCode",responseCode);
//             bin = new BufferedReader(new InputStreamReader(huc.getInputStream(), "UTF-8")); 
//             StringBuffer sb = new StringBuffer(); 
//             String temp = "";
//             while ((temp = bin.readLine()) != null) {
//                 sb.append(temp);
//             }
            
//             OUTVAR.put("responseCode",responseCode);
//             OUTVAR.put("sb",sb.toString());
            
//             bin.close();
//         } 
//     } catch (Exception e) { 
//         success = false;
//         code    = 208;
//         message = e.toString();
			
//     } finally {
//         closeConn(conn);
//     }   
// }


// if("sendBotChat".equals(func)) {
//     Connection conn = null; 
    
//     JSONObject content = new JSONObject();
//     JSONObject body    = new JSONObject();
    
//     String channelId = "";
//     String type = "";  /* text nor link */
//     String textMsg = "";
//     String link = "";
//     String linkText = "Open the link";
//     String sUrl = request.getParameter("url");
// 	String enc  = request.getParameter("enc"); 
// 	InputStreamReader isr = null;
// 	BufferedReader bin = null;
//     OutputStreamWriter writer = null;
    
//     try {  
//         OUTVAR.put("INVAR",INVAR);
//         String token = "";
    
//         //Token을 조회하여 사용한다. 없으면 갱신발행한 후 진행한다.
//         conn = getConn("LFN");
//         String qry = getQuery(pgmid,"searchToken");
//         JSONObject JOtoken = getRow(selectSVC(conn, qry),0);
//         token = getVal(JOtoken,"access_token");
//         //OUTVAR.put("JOtoken",JOtoken);
        
//         /* 토큰가져오기 */
//         if(isNull(getVal(JOtoken,"access_token"))) {
        
//             String refresh_token = getVal(JOtoken,"refresh_token");
//             refresh_token = URLEncoder.encode(refresh_token,"UTF-8");
//             String client_id = "xYjo3JDazskQjjz1P3HO";
//             String client_secret = "koc3V3aGEA";
    
//             try {  
//                 enc = "UTF-8"; 
//                 sUrl = "https://auth.worksmobile.com/oauth2/v2.0/token";
//                 URL url = new URL(sUrl);
//         	    HttpURLConnection huc = (HttpURLConnection)url.openConnection();
        	    
//         	    huc.setDoInput(true); // InputStream으로 서버로 부터 응답을 받겠다는 옵션.
//                 huc.setRequestProperty("Content-Type", "application/x-www-form-urlencoded"); //multipart/form-data
//                 huc.setRequestMethod("POST");
                
        
//                 huc.setDoOutput(true); // OutputStream으로 POST 데이터를 넘겨주겠다는 옵션. 
//                 String params = "grant_type=refresh_token&refresh_token="+refresh_token+"&client_id="+client_id+"&client_secret="+client_secret;
                
//                 OutputStream os = huc.getOutputStream();
//                 os.write(params.getBytes("UTF-8"));
//                 os.flush(); // Request Body에 Data 입력. 
//                 os.close(); // OutputStream 종료.
//                 OUTVAR.put("params",params);
        
//                 int responseCode = huc.getResponseCode();  //실제 서버로 Request 요청 하는 부분. (응답 코드를 받는다. 200 성공, 나머지 에러)
//                 OUTVAR.put("responseCodeT",responseCode);
//                 bin = new BufferedReader(new InputStreamReader(huc.getInputStream(), "UTF-8")); 
//                 StringBuffer sb = new StringBuffer(); 
//                 String temp = "";
//                 while ((temp = bin.readLine()) != null) {
//                     sb.append(temp);
//                 }
//                 OUTVAR.put("responseCodeT",responseCode);
//                 OUTVAR.put("sbT",sb.toString());
        
//                 bin.close();
                
//                 JSONParser json = new JSONParser();
//                 JSONObject jobj = (JSONObject)json.parse(sb.toString());
//                 OUTVAR.put("jobj",jobj.get("access_token"));
                
//                 INVAR.put("access_token",jobj.get("access_token"));
//                 token = (jobj.get("access_token")).toString();
//                 OUTVAR.put("INVAR",INVAR);
                
//                 //conn = getConn("LFN");
//                 conn.setAutoCommit(false);
                
//                 String qryX = getQuery(pgmid, "refreshToken"); 
//                 String qryRunX = bindVAR(qryX,INVAR);  
//                 OUTVAR.put("qryRunX",qryRunX); //for debug  
//                 JSONObject rst = executeSVC(conn, qryRunX);
//                 //rst.put("rtnCd","OK");
//                 if(!"OK".equals(getVal(rst,"rtnCd"))) {
//                     conn.rollback(); 
//                     rtnCode = getVal(rst, "rtnCd");
//                     rtnMsg  = getVal(rst, "rtnMsg");
//                 } else { 
//                     conn.commit(); 
//                 }
                
//             } catch(Exception e) {
//                 OUTVAR.put("refreshToken",e.toString());
//             }    
//         }

//         /* 메시지보내기 */
//         channelId = getVal(INVAR,"channelId");  /* 채팅방ID */
//         textMsg   = getVal(INVAR,"msg");
//         type      = getVal(INVAR,"type");        /* 'text' nor 'link' */
//         link      = getVal(INVAR,"url");
//         linkText  = nvl(getVal(INVAR,"linkText"),linkText);
//         INVAR.put("comcd","LFN");            

//         String header = "Bearer " + token; // Bearer 다음에 공백 추가
        
//         if(type.equals("text")){
//             content.put("type","text");
//             content.put("text",textMsg);
//             body.put("content",content);
//         } else { //'link'
//             content.put("type","link");
//             content.put("contentText",textMsg);
//             content.put("linkText",linkText);
//             content.put("link",link);
//             body.put("content",content);
//         }
            
       
// // *********************************************************************************************/
// } catch (Exception e) {
// 	logger.error("error occurred:"+rtnCode,e);
// 	rtnCode    = "ERR";
// 	rtnMsg     = e.toString();
// } finally {
// 	OUTVAR.put("rtnCd",rtnCode);
// 	OUTVAR.put("rtnMsg",rtnMsg); 
// 	out.println(OUTVAR.toJSONString());
// }
// %>