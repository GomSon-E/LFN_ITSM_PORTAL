<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    import="java.util.*, 
            java.io.*,
            org.json.XML,
            com.google.gson.*" %> 
<%! 
public String lpad(String CHAR, int Times) {
    String rtn = "";
    for(int i = 0; i < Times; i++) {
        rtn += CHAR;
    }
    return rtn; 
}
public String makeXML(JSONObject jo, String rootTag, int Depth) throws Exception {
    
    /* usage: 
       JSONObject INVAR = {HEADER:{keyH:"val"},DATA:[{goods_cd:"val",qty:1,chk:true},{goods_cd:"val2",qty:-1,chk:false}]}
       makeXML(INVAR,"SABANG_RESULT",true);
       => <SABANG_RESULT>
            <HEADER>
                <keyH>val</keyH>
            </HEADER>
            <DATA>
                <goods_cd>val</goods_cd>
                <qty>1</qty>
                <chk>true</chk>
            </DATA> 
            <DATA>
                <goods_cd>val2</goods_cd>
                <qty>-1</qty>
                <chk>false</chk>
            </DATA> 
          </SABANG_RESULT>
    */ 
    java.util.Date now = new java.util.Date();
	SimpleDateFormat sf = new SimpleDateFormat("yyyyMMdd");
	String today = sf.format(now);
    String CR  = "\r\n";
    String TAB = "\t";
    String rtn = "";
    try {
        if(Depth==0) rtn = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
        if(!isNull(rootTag)) rtn += "<"+rootTag+">"+CR;
		for(Object k : jo.keySet()) {
            String key = (String)k;
            String keys = key.toUpperCase();
            if(!isNull(keys)) {
                //value의 type에 따라 값 연결
                Object v = jo.get(k); 
                if(v instanceof org.json.simple.JSONArray) {
                    for(int i=0; i < ((JSONArray)v).size(); i++) { 
                        rtn += lpad(TAB,(Depth+1))+ "<"+keys+">"+CR;
                        JSONObject vi = (JSONObject)((JSONArray)v).get(i); 
                        rtn += makeXML(vi,"",(Depth+1)); 
                        rtn += "</"+keys+">"+CR; 
                    }
                } else if(v instanceof org.json.simple.JSONObject) {
                    rtn += makeXML((JSONObject)v,keys,Depth+1); 
                } else { //if (isNull(v)|| v instanceof java.lang.String || v instanceof java.lang.Long || v instanceof java.lang.Float || v instanceof java.lang.Integer || v instanceof java.lang.Double || v instanceof Boolean ) { 
                    rtn += lpad(TAB,(Depth+1))+ "<"+keys+"><![CDATA["+ v + "]]></"+keys+">"+CR;
                }
            }
        } 
		if(!isNull(rootTag)) rtn += "</"+rootTag+">";
		return rtn;
	} catch (Exception e) {
		throw e; 
	}
}    
%>
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_mdp";
String pgmid   = "OnlineSearch"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/
//search:조회 이벤트처리(DB_Read)     

if("search".equals(func)) {
    String sUrl = request.getParameter("url");
	String enc = request.getParameter("enc"); 
    JSONObject INVAR_REQ = new JSONObject();
    InputStreamReader isr = null;
	BufferedReader bin = null;
	java.util.Date now = new java.util.Date();
	SimpleDateFormat sf = new SimpleDateFormat("yyyyMMdd");
	String today = sf.format(now);
    //INVAR_REQ = {url, parameter}
    //JSONObject OUTVAR_RES = SabangNetAPI(INVAR_REQ);
    
    //Store OUTVAR_RES.result INTO DB TABLE : for( .size() ) { db write } 
    //return OUTVAR_RES.result to Web Page  : OUTVAR.put("list",OUTVAR_RES.result)
    
    /* include commonAPI.jsp - SabangNetAPI(INVAR_REQ)메쏘드 returns JSONObject OUTVAR_RES  
            mr_naver_bot 의 sendMsg (line:158참조)
            sUrl = "https://www.worksapis.com/v1.0/bots/3482880/users/"+usid+"/messages";
    	    //if(isNull(enc)) 
    	    enc = "UTF-8"; 
            URL url = new URL(sUrl);
    	    HttpURLConnection huc = (HttpURLConnection)url.openConnection();
    	    huc.setRequestMethod("POST");  
            huc.setRequestProperty("Authorization", header);
            //OUTVAR.put("header",header);
            huc.setRequestProperty("Content-Type", "application/json");
            huc.setRequestProperty("Accept", "application/json");
            huc.setRequestProperty("Cache-Control","no-cache");  // 컨트롤 캐쉬 설정 
            huc.setRequestProperty("Content-Length", "length");  // 타입길이 설정(Request Body 전달시 Data Type의 길이를 정함.) 
            huc.setRequestProperty("User-Agent", "LFN_EP");        // User-Agent 값 설정 
            huc.setDoOutput(true); // OutputStream으로 POST 데이터를 넘겨주겠다는 옵션. 
            huc.setDoInput(true); // InputStream으로 서버로 부터 응답을 받겠다는 옵션. 
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
    */ 
    //OUTVAR.put("jsonObj", org.json.XML.toJSONObject(xmlStr));  //org.json.JSONObject -> Object
    //String jsonStr  = getVal(OUTVAR,"jsonObj");                //Object -> String    
    //OUTVAR.put("jsonStr", jsonStr);
    //JSONObject json = getObject(jsonStr);                      //String -> org.json-simple.JSONObject  
    //OUTVAR.put("json"   , json);

    //String xmlStr       = getVal(INVAR,"xmlStr"); //Request에서 XML String 가져와서
    //OUTVAR.put("xmlStr",xmlStr);    
    //org.json.XML xmlDoc = org.json.XML. 
    //org.json.JSONObject json = org.json.XML.toJSONObject(xmlStr);
    //OUTVAR.put("json",json);

    //org.json.JSONObject json = org.json.JSONObject.toJSONObject(invar);
//String xmlStr =  
//OUTVAR.put("jsonObj", org.json.XML.toJSONObject(xmlStr)); 

    String xmlStr2 = makeXML(INVAR,"SABANG_MALL_LIST",0); //JSONObject jo, String rootTag, Boolean bRoot)//org.json.XML.toString(INVAR);
    OUTVAR.put("xmlStr2",xmlStr2); 
    
    String fileid = getUUID(20); 
    String sPath   = application.getRealPath("pds");
    try {
        String sNewPath = sPath + "/API/"+ today + "/"; 
		File newPath = new File(sNewPath); //일자별로 경로를 만들어준다.
	    if (!newPath.exists()) {
	    	newPath.mkdirs();
	    }
	    String fullPath = sNewPath+fileid+".xml"; //UUID로 파일명을 채번한다.
	    File newfile = new File(fullPath);
	    if(newfile.exists()) newfile.delete();    //혹시 존재하면 삭제하고 새로 만든다.
	    newfile.createNewFile();
    	Writer fw = null;
	    //fw = new OutputStreamWriter(new FileOutputStream(fullPath), StandardCharsets.UTF_8);
	    fw = new OutputStreamWriter(new FileOutputStream(fullPath), "MS949");
	    fw.write( xmlStr2 ); 
	    fw.close(); 
	    
	    String LFurl = "https://fo.lfnetworks.co.kr/pds/API/" + today + "/";
	    if(isNull(sUrl)) sUrl = "https://sbadmin01.sabangnet.co.kr/RTL_API/xml_mall_info.html?xml_url=" + LFurl + fileid + ".xml";
	    if(isNull(enc)) enc = "UTF-8";
	    //if(isNull(enc)) 
        URL url = new URL(sUrl);
        OUTVAR.put("sUrl",sUrl);
	    HttpURLConnection huc = (HttpURLConnection)url.openConnection();
	    huc.setRequestMethod("POST");  
        //huc.setRequestProperty("Authorization", header);
        //OUTVAR.put("header",header);
        //huc.setRequestProperty("Content-Type", "application/xml;UTF-8");
        //huc.setRequestProperty("Accept", "application/xml");
        //huc.setRequestProperty("Cache-Control","no-cache");  // 컨트롤 캐쉬 설정 
        //huc.setRequestProperty("Content-Length", "length");  // 타입길이 설정(Request Body 전달시 Data Type의 길이를 정함.) 
        //huc.setRequestProperty("User-Agent", "LFN_EP");        // User-Agent 값 설정 
        huc.setDoOutput(true); // OutputStream으로 POST 데이터를 넘겨주겠다는 옵션. 
        huc.setDoInput(true); // InputStream으로 서버로 부터 응답을 받겠다는 옵션. 
        OutputStream os = huc.getOutputStream(); // Request Body에 Data를 담기위해 OutputStream 객체를 생성.    
        os.flush(); // Request Body에 Data 입력. 
        os.close(); // OutputStream 종료.     
    
        int responseCode = huc.getResponseCode();  //실제 서버로 Request 요청 하는 부분. (응답 코드를 받는다. 200 성공, 나머지 에러) 
        OUTVAR.put("responseCode",responseCode);
        bin = new BufferedReader(new InputStreamReader(huc.getInputStream(), "MS949")); 
        StringBuffer sb = new StringBuffer(); 
        String decodedString;
        String temp = "";
        while ((decodedString = bin.readLine()) != null) {
            temp = decodedString;
            sb.append(temp);
        }
        Object result =  org.json.XML.toJSONObject(sb.toString());
        OUTVAR.put("responseCode",responseCode);
        OUTVAR.put("sb",sb.toString());
        OUTVAR.put("result",result);
        
        bin.close();
	    
	    
	} catch( IOException e) {
		log.error("error in writing log file :", e);
	} 
}

if("search2".equals(func)) {
    String sUrl = request.getParameter("url");
	String enc = request.getParameter("enc"); 
    JSONObject INVAR_REQ = new JSONObject();
    InputStreamReader isr = null;
	BufferedReader bin = null;
	java.util.Date now = new java.util.Date();
	SimpleDateFormat sf = new SimpleDateFormat("yyyyMMdd");
	String today = sf.format(now);
    //INVAR_REQ = {url, parameter}
    //JSONObject OUTVAR_RES = SabangNetAPI(INVAR_REQ);
    
    //Store OUTVAR_RES.result INTO DB TABLE : for( .size() ) { db write } 
    //return OUTVAR_RES.result to Web Page  : OUTVAR.put("list",OUTVAR_RES.result)
    
    /* include commonAPI.jsp - SabangNetAPI(INVAR_REQ)메쏘드 returns JSONObject OUTVAR_RES  
            mr_naver_bot 의 sendMsg (line:158참조)
            sUrl = "https://www.worksapis.com/v1.0/bots/3482880/users/"+usid+"/messages";
    	    //if(isNull(enc)) 
    	    enc = "UTF-8"; 
            URL url = new URL(sUrl);
    	    HttpURLConnection huc = (HttpURLConnection)url.openConnection();
    	    huc.setRequestMethod("POST");  
            huc.setRequestProperty("Authorization", header);
            //OUTVAR.put("header",header);
            huc.setRequestProperty("Content-Type", "application/json");
            huc.setRequestProperty("Accept", "application/json");
            huc.setRequestProperty("Cache-Control","no-cache");  // 컨트롤 캐쉬 설정 
            huc.setRequestProperty("Content-Length", "length");  // 타입길이 설정(Request Body 전달시 Data Type의 길이를 정함.) 
            huc.setRequestProperty("User-Agent", "LFN_EP");        // User-Agent 값 설정 
            huc.setDoOutput(true); // OutputStream으로 POST 데이터를 넘겨주겠다는 옵션. 
            huc.setDoInput(true); // InputStream으로 서버로 부터 응답을 받겠다는 옵션. 
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
    */ 
    //OUTVAR.put("jsonObj", org.json.XML.toJSONObject(xmlStr));  //org.json.JSONObject -> Object
    //String jsonStr  = getVal(OUTVAR,"jsonObj");                //Object -> String    
    //OUTVAR.put("jsonStr", jsonStr);
    //JSONObject json = getObject(jsonStr);                      //String -> org.json-simple.JSONObject  
    //OUTVAR.put("json"   , json);

    //String xmlStr       = getVal(INVAR,"xmlStr"); //Request에서 XML String 가져와서
    //OUTVAR.put("xmlStr",xmlStr);    
    //org.json.XML xmlDoc = org.json.XML. 
    //org.json.JSONObject json = org.json.XML.toJSONObject(xmlStr);
    //OUTVAR.put("json",json);

    //org.json.JSONObject json = org.json.JSONObject.toJSONObject(invar);
//String xmlStr =  
//OUTVAR.put("jsonObj", org.json.XML.toJSONObject(xmlStr)); 

    String xmlStr2 = makeXML(INVAR,"SABANG_GOODS_PROP_CODE_INFO_LIST",0); //JSONObject jo, String rootTag, Boolean bRoot)//org.json.XML.toString(INVAR);
    OUTVAR.put("xmlStr2",xmlStr2); 
    
    String fileid = getUUID(20); 
    String sPath   = application.getRealPath("pds");
    try {
        String sNewPath = sPath + "/API/"+ today + "/"; 
		File newPath = new File(sNewPath); //일자별로 경로를 만들어준다.
	    if (!newPath.exists()) {
	    	newPath.mkdirs();
	    }
	    String fullPath = sNewPath+fileid+".xml"; //UUID로 파일명을 채번한다.
	    File newfile = new File(fullPath);
	    if(newfile.exists()) newfile.delete();    //혹시 존재하면 삭제하고 새로 만든다.
	    newfile.createNewFile();
    	Writer fw = null;
	    //fw = new OutputStreamWriter(new FileOutputStream(fullPath), StandardCharsets.UTF_8);
	    fw = new OutputStreamWriter(new FileOutputStream(fullPath), "MS949");
	    fw.write( xmlStr2 ); 
	    fw.close(); 
	    
	    String LFurl = "https://fo.lfnetworks.co.kr/pds/API/" + today + "/";
	    if(isNull(sUrl)) sUrl = "https://sbadmin01.sabangnet.co.kr/RTL_API/xml_goods_prop_code_info.html?xml_url=" + LFurl + fileid + ".xml";
	    if(isNull(enc)) enc = "UTF-8";
	    //if(isNull(enc)) 
        URL url = new URL(sUrl);
        OUTVAR.put("sUrl",sUrl);
	    HttpURLConnection huc = (HttpURLConnection)url.openConnection();
	    huc.setRequestMethod("POST");  
        //huc.setRequestProperty("Authorization", header);
        //OUTVAR.put("header",header);
        //huc.setRequestProperty("Content-Type", "application/xml;UTF-8");
        //huc.setRequestProperty("Accept", "application/xml");
        //huc.setRequestProperty("Cache-Control","no-cache");  // 컨트롤 캐쉬 설정 
        //huc.setRequestProperty("Content-Length", "length");  // 타입길이 설정(Request Body 전달시 Data Type의 길이를 정함.) 
        //huc.setRequestProperty("User-Agent", "LFN_EP");        // User-Agent 값 설정 
        huc.setDoOutput(true); // OutputStream으로 POST 데이터를 넘겨주겠다는 옵션. 
        huc.setDoInput(true); // InputStream으로 서버로 부터 응답을 받겠다는 옵션. 
        OutputStream os = huc.getOutputStream(); // Request Body에 Data를 담기위해 OutputStream 객체를 생성.    
        os.flush(); // Request Body에 Data 입력. 
        os.close(); // OutputStream 종료.     
    
        int responseCode = huc.getResponseCode();  //실제 서버로 Request 요청 하는 부분. (응답 코드를 받는다. 200 성공, 나머지 에러) 
        OUTVAR.put("responseCode",responseCode);
        bin = new BufferedReader(new InputStreamReader(huc.getInputStream(), "MS949")); 
        StringBuffer sb = new StringBuffer(); 
        String decodedString;
        String temp = "";
        while ((decodedString = bin.readLine()) != null) {
            temp = decodedString;
            sb.append(temp);
        }
        
        Object result =  org.json.XML.toJSONObject(sb.toString());
        OUTVAR.put("responseCode",responseCode);
        OUTVAR.put("sb",sb.toString());
        OUTVAR.put("result",result);
        //OUTVAR.put("list",list);
        
        bin.close();
	    
	    
	} catch( IOException e) {
		log.error("error in writing log file :", e);
	} 
}

if("search3".equals(func)) {
    String sUrl = request.getParameter("url");
	String enc = request.getParameter("enc"); 
    JSONObject INVAR_REQ = new JSONObject();
    InputStreamReader isr = null;
	BufferedReader bin = null;
	java.util.Date now = new java.util.Date();
	SimpleDateFormat sf = new SimpleDateFormat("yyyyMMdd");
	String today = sf.format(now);
    //INVAR_REQ = {url, parameter}
    //JSONObject OUTVAR_RES = SabangNetAPI(INVAR_REQ);
    
    //Store OUTVAR_RES.result INTO DB TABLE : for( .size() ) { db write } 
    //return OUTVAR_RES.result to Web Page  : OUTVAR.put("list",OUTVAR_RES.result)
    
    /* include commonAPI.jsp - SabangNetAPI(INVAR_REQ)메쏘드 returns JSONObject OUTVAR_RES  
            mr_naver_bot 의 sendMsg (line:158참조)
            sUrl = "https://www.worksapis.com/v1.0/bots/3482880/users/"+usid+"/messages";
    	    //if(isNull(enc)) 
    	    enc = "UTF-8"; 
            URL url = new URL(sUrl);
    	    HttpURLConnection huc = (HttpURLConnection)url.openConnection();
    	    huc.setRequestMethod("POST");  
            huc.setRequestProperty("Authorization", header);
            //OUTVAR.put("header",header);
            huc.setRequestProperty("Content-Type", "application/json");
            huc.setRequestProperty("Accept", "application/json");
            huc.setRequestProperty("Cache-Control","no-cache");  // 컨트롤 캐쉬 설정 
            huc.setRequestProperty("Content-Length", "length");  // 타입길이 설정(Request Body 전달시 Data Type의 길이를 정함.) 
            huc.setRequestProperty("User-Agent", "LFN_EP");        // User-Agent 값 설정 
            huc.setDoOutput(true); // OutputStream으로 POST 데이터를 넘겨주겠다는 옵션. 
            huc.setDoInput(true); // InputStream으로 서버로 부터 응답을 받겠다는 옵션. 
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
    */ 
    //OUTVAR.put("jsonObj", org.json.XML.toJSONObject(xmlStr));  //org.json.JSONObject -> Object
    //String jsonStr  = getVal(OUTVAR,"jsonObj");                //Object -> String    
    //OUTVAR.put("jsonStr", jsonStr);
    //JSONObject json = getObject(jsonStr);                      //String -> org.json-simple.JSONObject  
    //OUTVAR.put("json"   , json);

    //String xmlStr       = getVal(INVAR,"xmlStr"); //Request에서 XML String 가져와서
    //OUTVAR.put("xmlStr",xmlStr);    
    //org.json.XML xmlDoc = org.json.XML. 
    //org.json.JSONObject json = org.json.XML.toJSONObject(xmlStr);
    //OUTVAR.put("json",json);

    //org.json.JSONObject json = org.json.JSONObject.toJSONObject(invar);
//String xmlStr =  
//OUTVAR.put("jsonObj", org.json.XML.toJSONObject(xmlStr)); 

    String xmlStr2 = makeXML(INVAR,"SABANG_CATEGORY_LIST",0); //JSONObject jo, String rootTag, Boolean bRoot)//org.json.XML.toString(INVAR);
    OUTVAR.put("xmlStr2",xmlStr2); 
    
    String fileid = getUUID(20); 
    String sPath   = application.getRealPath("pds");
    try {
        String sNewPath = sPath + "/API/"+ today + "/"; 
		File newPath = new File(sNewPath); //일자별로 경로를 만들어준다.
	    if (!newPath.exists()) {
	    	newPath.mkdirs();
	    }
	    String fullPath = sNewPath+fileid+".xml"; //UUID로 파일명을 채번한다.
	    File newfile = new File(fullPath);
	    if(newfile.exists()) newfile.delete();    //혹시 존재하면 삭제하고 새로 만든다.
	    newfile.createNewFile();
    	Writer fw = null;
	    //fw = new OutputStreamWriter(new FileOutputStream(fullPath), StandardCharsets.UTF_8);
	    fw = new OutputStreamWriter(new FileOutputStream(fullPath), "MS949");
	    fw.write( xmlStr2 ); 
	    fw.close(); 
	    
	    String LFurl = "https://fo.lfnetworks.co.kr/pds/API/" + today + "/";
	    if(isNull(sUrl)) sUrl = "https://sbadmin01.sabangnet.co.kr/RTL_API/xml_category_info.html?xml_url=" + LFurl + fileid + ".xml";
	    if(isNull(enc)) enc = "UTF-8";
	    //if(isNull(enc)) 
        URL url = new URL(sUrl);
        OUTVAR.put("sUrl",sUrl);
	    HttpURLConnection huc = (HttpURLConnection)url.openConnection();
	    huc.setRequestMethod("POST");  
        //huc.setRequestProperty("Authorization", header);
        //OUTVAR.put("header",header);
        //huc.setRequestProperty("Content-Type", "application/xml;UTF-8");
        //huc.setRequestProperty("Accept", "application/xml");
        //huc.setRequestProperty("Cache-Control","no-cache");  // 컨트롤 캐쉬 설정 
        //huc.setRequestProperty("Content-Length", "length");  // 타입길이 설정(Request Body 전달시 Data Type의 길이를 정함.) 
        //huc.setRequestProperty("User-Agent", "LFN_EP");        // User-Agent 값 설정 
        huc.setDoOutput(true); // OutputStream으로 POST 데이터를 넘겨주겠다는 옵션. 
        huc.setDoInput(true); // InputStream으로 서버로 부터 응답을 받겠다는 옵션. 
        OutputStream os = huc.getOutputStream(); // Request Body에 Data를 담기위해 OutputStream 객체를 생성.    
        os.flush(); // Request Body에 Data 입력. 
        os.close(); // OutputStream 종료.     
    
        int responseCode = huc.getResponseCode();  //실제 서버로 Request 요청 하는 부분. (응답 코드를 받는다. 200 성공, 나머지 에러) 
        OUTVAR.put("responseCode",responseCode);
        bin = new BufferedReader(new InputStreamReader(huc.getInputStream(), "MS949")); 
        StringBuffer sb = new StringBuffer(); 
        String decodedString;
        String temp = "";
        while ((decodedString = bin.readLine()) != null) {
            temp = decodedString;
            sb.append(temp);
        }
        Object result =  org.json.XML.toJSONObject(sb.toString());
        OUTVAR.put("responseCode",responseCode);
        OUTVAR.put("sb",sb.toString());
        OUTVAR.put("result",result);
        
        bin.close();
	    
	    
	} catch( IOException e) {
		log.error("error in writing log file :", e);
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
