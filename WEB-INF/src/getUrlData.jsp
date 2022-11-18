<%@ include file="../common/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" 
    import="java.net.*" %>
<%   
/*** USAGE : from javascript 
	var fnSelect = function() { //조회
	    var url = "https://jqueryui.com/resources/demos/autocomplete/search.php?term=JA";//"http://192.168.253.20:8080/v1/result";
	    if(pageObj["_condForm"].cval("cd_company")=="PASTEL") url = "http://192.168.253.20:8081/v1/result";
 
	    $("#"+pageid+" #testbed").attr("src",url); 
	    
	    gfnTx("getUrlData","rtn",{url:url,enc:"UTF-8",rtn:"rtn"}, function(OUTVAR){
            if(OUTVAR.rtnCd =="OK") {
                pageObj["codelist"].importData(OUTVAR.rtn);  
            } else {
                console.dir(OUTVAR);
                gfnAlert("오류:"+OUTVAR.rtnCd, "다음 오류가 발생했습니다.:"+OUTVAR.rtnMsg); 
            } 
        });
    }                  
***/
JSONObject OUTVAR = new JSONObject(); 
String rtnCode    = "OK";
String rtnMsg     = "";
try { 
	String sUrl = request.getParameter("url");
	String enc = request.getParameter("enc");
	String rtn = request.getParameter("rtn");
	InputStreamReader isr = null;
	BufferedReader bin = null;
	try {
		if(isNull(sUrl)) sUrl = "http://ep.tribons.co.kr/json";
		if(isNull(enc)) enc = "UTF-8";
		if(isNull(rtn)) rtn = "rtn";
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
		logger.error("jsonp error occurred", e);
	} finally {
		if(bin!=null) bin.close();	
		if(isr!=null) isr.close();	
	}
	
} catch (Exception e) {
	logger.error("jsonp error occurred:"+e.toString());
	rtnCode    = "ERR";
	rtnMsg     = e.toString();
} finally { 
	OUTVAR.put("rtnCd",rtnCode);
	OUTVAR.put("rtnMsg",rtnMsg);  
	out.println(OUTVAR.toJSONString());
}
%>