<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"%> 
<%  
//if (!aweCheck(session)) return; 
JSONObject OUTVAR = new JSONObject(); 
String  appid     = "api";
String  pgmid     = "mr_jandi_bot"; 
String  func      = request.getParameter("func"); 
String  rtnCode   = "OK";
String  rtnMsg    = "";
Boolean success   = true;
int     code      = 200;
String  message   = "";

try { 
String invar = request.getParameter("INVAR");
if(isNull(invar)) { 
    invar = (String)request.getAttribute("INVAR");
}
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/
if("sendMsg".equals(func)) {
    /** INVAR.msgs 
      
      JSONArray email        @~포함한 메일계정 
      String    body         메시지본문
      
      또는 
      
      JSONArray email        @~포함한 메일계정 (여러명일 경우 콤마로 연결가능)
      String    body         메시지본문
      String    connectColor 상세항목 컬러
      JSONArray connectInfo  상세항목배열 ( connectItem = new JSONObject();
                                            connectItem.put("title","홍길동 사원님 생일을 축하합니다~!");
                                            connectItem.put("description","2 Empire State Building, 5th Ave, New York");
                                            connectItem.put("imageUrl","http://url_to_text2");
                                            connectInfo.add(connectItem) )

      ex1)
      INVAR : { msgs :  [ { email        : "airjaws7@naver.com,kihyunlee21@naver.com", 
                            body         : "회의실 예약관리 시스템 안내" 
                          }
                        ]
              } 
      
      ex2)                                            
      INVAR : { msgs :  [ { email        : "airjaws7@naver.com,kihyunlee21@naver.com", 
                            body         : "회의실 예약관리 시스템 안내",
                            connectColor : "#FAC11B",
                            connectInfo  : [ { title       : "회의예정시간 도래 - 입장 후 사용등록 해주세요(15분내 사용 미등록시 No Show 자동취소 됩니다.)",
                                               description : "1월1일 10시 3회의실",
                                               imageUrl:   : "https://fo.lfnetworks.co.kr/meet.jsp?r=1000203" },
                                             { title       : "No Show 자동취소 안내 - 다른 분들의 사용을 위해 아래 회의실 예약이 자동취소 되었습니다.",
                                               description : "1월1일 10시 3회의실",
                                               imageUrl:   : "https://fo.lfnetworks.co.kr/meet.jsp?r=1000204" } 
                                           ] 
                          }
                        ]
              }
    **/ 
    //debug OUTVAR.put("INVAR",INVAR);    
	String enc = "UTF-8";  
	String url_webhook = "https://wh.jandi.com/connect-api/webhook/20736797/0254859c476d6cd040d34ecbeacac8d6";
    		
	InputStreamReader isr = null;
	BufferedReader bin = null;
	HttpURLConnection huc = null;  
	StringBuffer sb   = null;  
    try { 
        JSONArray msgs = getArray(INVAR,"msgs"); 
        //debug  OUTVAR.put("msgs",msgs);
        for(int k=0; k < msgs.size(); k++){
            //debug  OUTVAR.put("k",k);
            JSONObject msg = getRow(msgs,k);
            //debug  OUTVAR.put("msg",msg); 
    		URL url = new URL(url_webhook); 
    		huc = (HttpURLConnection) url.openConnection();
            huc.setRequestMethod("POST");  
            huc.setRequestProperty("Accept", "application/vnd.tosslab.jandi-v2+json");
            huc.setRequestProperty("Content-Type", "application/json");  
            huc.setRequestProperty("Cache-Control","no-cache");  // 컨트롤 캐쉬 설정 
            huc.setRequestProperty("Content-Length", "length");  // 타입길이 설정(Request Body 전달시 Data Type의 길이를 정함.) 
            huc.setRequestProperty("User-Agent", "LFN_EP");        // User-Agent 값 설정 
            huc.setDoOutput(true); // OutputStream으로 POST 데이터를 넘겨주겠다는 옵션. 
            huc.setDoInput(true); // InputStream으로 서버로 부터 응답을 받겠다는 옵션.  
            OutputStream os = huc.getOutputStream(); // Request Body에 Data를 담기위해 OutputStream 객체를 생성.    
            os.write(msg.toString().getBytes(enc));
            //debug  OUTVAR.put("msg",msg); //for debug
            os.flush(); // Request Body에 Data 입력. 
            os.close(); // OutputStream 종료 
            int responseCode = huc.getResponseCode();  //실제 서버로 Request 요청 하는 부분. (응답 코드를 받는다. 200 성공, 나머지 에러) 
            bin = new BufferedReader(new InputStreamReader(huc.getInputStream(),enc)); 
            sb = new StringBuffer(); 
            String temp = "";
            while ((temp = bin.readLine()) != null) {
                sb.append(temp);
            } 
            OUTVAR.put("responseCode",responseCode);
            bin.close();
        } 
    } catch (Exception e) { 
        success = false;
        code    = 208;
        message = e.toString();
			
    } finally {
		if(bin!=null) try{ bin.close(); } catch(Exception ex1){ logger.error("JANDI",ex1);};	
		if(isr!=null) try{ isr.close();	} catch(Exception ex2){ logger.error("JANDI",ex2);};
		if(huc!=null) huc.disconnect();	
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
