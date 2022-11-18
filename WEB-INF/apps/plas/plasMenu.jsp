<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "plas";
String pgmid   = "plasMenu"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/
//search:조회 이벤트처리(DB_Read)     
if("search".equals(func)) {
    Connection conn = null; 
    try {
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "qrySearch"); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray list = selectSVC(conn, qryRun);
        OUTVAR.put("list",list); 

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}

   
if("pgminfo".equals(func)) {
    Connection conn = null; 
    try {
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        
        String qryInfo = getQuery(pgmid, "qryPgmInfo"); 
        qryInfo = bindVAR(qryInfo,INVAR);
        OUTVAR.put("qryInfo",qryInfo); //for debug
        JSONArray pgmInfo = selectSVC(conn, qryInfo);
        OUTVAR.put("pgmInfo",pgmInfo); 

        String qryFunc = getQuery(pgmid, "qryPgmFunc"); 
        qryFunc = bindVAR(qryFunc,INVAR);
        OUTVAR.put("qryFunc",qryFunc); //for debug
        JSONArray pgmFunc = selectSVC(conn, qryFunc);
        OUTVAR.put("pgmFunc",pgmFunc); 

        String qryData = getQuery(pgmid, "qryPgmData"); 
        qryData = bindVAR(qryData,INVAR);
        OUTVAR.put("qryData",qryData); //for debug
        JSONArray pgmData = selectSVC(conn, qryData);
        OUTVAR.put("pgmData",pgmData); 

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
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
