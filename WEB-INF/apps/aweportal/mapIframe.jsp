<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" 
    import="java.net.*" %>
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "aweportal";
String pgmid   = "mapIframe"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/
if("getUrlData".equals(func)) {
    String sUrl  = getVal(INVAR,"url");
	String sArgs = getVal(INVAR,"args");
	String enc   = getVal(INVAR,"enc");
	String rtn   = getVal(INVAR,"rtn");
	InputStreamReader isr = null;
	BufferedReader bin = null;
	try {
		if(isNull(sUrl)) sUrl = "http://fo.lfnetworks.co.kr";
		if(!isNull(sArgs)) {
		    JSONObject args = getObject(sArgs);
		    sUrl += "?dt="+getDate();
		    for(Object k : args.keySet()) {
		        String key = (String)k; 
                sUrl += "&"+key+"="+URLEncoder.encode((String)args.get(k),"UTF-8"); 
            }
		}
		if(isNull(enc)) enc = "UTF-8";
		if(isNull(rtn)) rtn = "rtn";
		OUTVAR.put("url",sUrl);
		URL url = new URL(sUrl);
		URLConnection ucon = url.openConnection();
		ucon.setReadTimeout(1000);
		isr = new InputStreamReader( ucon.getInputStream(), enc ); 
		bin = new BufferedReader(isr);
		StringBuffer sb = new StringBuffer();
		int i;
		while((i=isr.read())!=-1){ 
			sb.append((char)i);  
		} 
		OUTVAR.put( rtn, sb ); 
		
	} catch (Exception e) {
		rtnCode = "ERR";
		rtnMsg  = e.toString(); 
		//logger.error("jsonp error occurred", e);
	} finally {
		if(bin!=null) bin.close();	
		if(isr!=null) isr.close();	
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
