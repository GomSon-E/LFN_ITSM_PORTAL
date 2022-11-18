<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "aweportal";
String pgmid   = "systemLog"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/// *********************************************************************************************/
if("searchFront".equals(func)) {
    Connection conn = null;
    
    try {  
        conn = getConn("LFN");

        String qryRun   = getQuery(pgmid, "searchPgmCnt"); 
        JSONArray most = selectSVC(conn, qryRun);
        OUTVAR.put("most", most); 

        qryRun   = getQuery(pgmid, "searchPgmRecent"); 
        JSONArray last = selectSVC(conn, qryRun);
        OUTVAR.put("last", last); 

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}
else if("searchPgm".equals(func)) {
    Connection conn = null;
    
    try {  
        conn = getConn("LFN");

        INVAR.put("userid", USERID);

        String qry     = getQuery(pgmid, "searchPgm"); 
        String qryRun  = bindVAR(qry, INVAR);
        JSONArray list = selectSVC(conn, qryRun);
        OUTVAR.put("list", list); 
        OUTVAR.put("qryRun", qryRun); //for debug

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}
else if("insertOpenPageLog".equals(func)) {
    Connection conn = null;
    
    try {
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        INVAR.put("userid", USERID);
        
        String qryRun = getQuery(pgmid, "insertOpenPageLog");
        qryRun = bindVAR(qryRun, INVAR);
        //OUTVAR.put("qryRun", qryRun);
        JSONObject rst = executeSVC(conn, qryRun);
        
        if(!"OK".equals(getVal(rst, "rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst, "rtnCd");
            rtnMsg  = getVal(rst, "rtnMsg");
            
        } else {
            conn.commit();
        }

    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    } 
}
else if("insertUserDocLog".equals(func)) {
    Connection conn = null;
    
    try {
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        INVAR.put("userid", USERID);
        
        String qryRun = getQuery(pgmid,"insertUserDocLog");
        qryRun = bindVAR(qryRun, INVAR);
        OUTVAR.put("qryRun", qryRun);
        JSONObject rst = executeSVC(conn, qryRun);
        
        if(!"OK".equals(getVal(rst, "rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst, "rtnCd");
            rtnMsg  = getVal(rst, "rtnMsg");
            
        } else {
            conn.commit();
        }

    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    } 
}
    
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
