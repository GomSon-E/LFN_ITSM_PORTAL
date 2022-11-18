package ep;

import java.net.*;
import java.util.*; 
import javax.servlet.http.*; 
import org.json.simple.*;
import org.json.simple.parser.*;
import java.sql.*;  
import java.text.SimpleDateFormat;
import javax.sql.DataSource;
import javax.naming.Context;
import javax.naming.InitialContext; 
import javax.servlet.http.*;
import java.io.BufferedReader;
import java.io.Reader;
import java.io.Writer;
import java.io.CharArrayReader;
import oracle.sql.CLOB;
import oracle.sql.BLOB;
import oracle.jdbc.OracleResultSet;    
import java.io.*; 
import java.nio.file.*;
import java.nio.file.Files;
import java.security.*; 

public class HourlyJob implements Runnable {

	@Override
	public void run() {
	    // Do your hourly job here.  
		InputStreamReader isr = null;
		BufferedReader bin = null;
		HttpURLConnection huc = null;
		
		BufferedReader br = null;
	    StringBuffer sb = null;
        String sOUTVAR = "";
		JSONObject OUTVAR = null;
		
		System.out.println("HourlyJob starts at :"+ new java.util.Date() );
        System.out.println("deploy check v2.0");  
          
		try {

	        // Request 용 JSON데이터 생성
			JSONObject INVAR = new JSONObject();
	        JSONObject oBody = new JSONObject();
	        oBody.put("url_webhook","https://wh.jandi.com/connect-api/webhook/20736797/0254859c476d6cd040d34ecbeacac8d6");
	        oBody.put("body", "test");
	        oBody.put("email","kihyunlee@tribons.co.kr"); 
	        oBody.put("connectColor", "#ff0000"); 
	        JSONArray connectInfo = new JSONArray(); 
	        JSONObject connectItem = new JSONObject();
	        connectItem.put("title","테스트");
	        connectItem.put("description","EP 워크벤치에서 고쳤음");
	        connectItem.put("imageUrl","http://url_to_text");
	        connectInfo.add(connectItem);  
	        oBody.put("connectInfo",connectInfo); 
            INVAR.put("INVAR",oBody);			
			
			
	        //커넥션 생성
	        String sUrl = "http://ep.tribons.co.kr/?dir=jandiwebhookteam&func=send";
	        sUrl += "&INVAR="+URLEncoder.encode( oBody.toJSONString(), "UTF-8");

	        URL url = new URL(sUrl);
			huc = (HttpURLConnection) url.openConnection();
	        huc.setRequestMethod("POST");  
	        huc.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
	        huc.setRequestProperty("Accept", "application/json");  
	        huc.setRequestProperty("Cache-Control","no-cache"); // 컨트롤 캐쉬 설정 
	        huc.setRequestProperty("Content-Length", "length"); // 타입길이 설정(Request Body 전달시 Data Type의 길이를 정함.) 
	        huc.setRequestProperty("User-Agent", "test");       // User-Agent 값 설정 
	        huc.setDoOutput(true); // OutputStream으로 서버에서 요청을 보내겠다는 옵션.
	        huc.setDoInput(true);  // InputStream으로 서버로 부터 응답을 받겠다는 옵션. 

	        /* 2안 Stream
	        DataOutputStream os = new DataOutputStream( huc.getOutputStream() ); // Request Body에 Data를 담기위해 OutputStream 객체를 생성. 
	        String invar = "INVAR="+oBody.toJSONString().getBytes("UTF-8");
	        os.writeBytes(invar);
	        //os.write(INVAR.toString().getBytes("UTF-8")); //body.getBytes("UTF-8") 
	        os.flush(); // Request Body에 Data 입력. 
	        os.close(); // OutputStream 종료.
	         */
	        /* 3안 Stream Writer requestBody...
	        OutputStreamWriter wr = new OutputStreamWriter(huc.getOutputStream());
	        wr.write( INVAR.toString() );
	        wr.flush();
	        wr.close();
	        */ 
	        huc.connect(); 
	        
	        // 실제 서버로 Request 요청 하는 부분. (응답 코드를 받는다. 200 성공, 나머지 에러)
	        int responseCode = huc.getResponseCode(); 
	        System.out.println("HourlyJob:"+ responseCode); 
	        br = new BufferedReader(new InputStreamReader(huc.getInputStream(), "UTF-8")); 
	        sb = new StringBuffer(); 
	        String temp = "";
	        while ((temp = br.readLine()) != null) {
	            sb.append(temp);
	        }
	        sOUTVAR = sb.toString();
	        JSONParser parser = new JSONParser();
	        OUTVAR = (JSONObject) parser.parse(sOUTVAR); 
	        System.out.println(OUTVAR.toJSONString());
	        
		} catch (Exception e) {
			System.out.println("HourlyJob error occurred:"+ e);
		} finally {
			if(bin!=null) try{ bin.close(); } catch(Exception ex1){ System.out.println(ex1);};	
			if(isr!=null) try{ isr.close();	} catch(Exception ex2){ System.out.println(ex2);};
			if(huc!=null) huc.disconnect();	
		}	     
	} 
}
