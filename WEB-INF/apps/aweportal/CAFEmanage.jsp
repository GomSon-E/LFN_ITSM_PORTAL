<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "aweportal";
String pgmid   = "CAFEmanage"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/// *********************************************************************************************/
if("load".equals(func)) {
    Connection conn = null;  
    try {         
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  

        String qry = getQuery(pgmid,"memberList");
        qry = bindVAR(qry,INVAR);
        JSONArray members = selectSVC(conn,qry);
        OUTVAR.put("members",members);
        
        qry = getQuery(pgmid,"retrieveUser");
        qry = bindVAR(qry,INVAR);
        JSONArray user = selectSVC(conn,qry);
        OUTVAR.put("user",user);

    } catch(Exception e) {
        rtnCode = "ERR";
        rtnMsg  = e.toString();

    } finally {
        closeConn(conn);
    }
}else if("joinCafe".equals(func)){
    Connection conn = null;  
    try {   
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        conn.setAutoCommit(false); 
        String qry = getQuery(pgmid,"joinCafe");
        qry = bindVAR(qry,INVAR);
        OUTVAR.put("qry",qry);        
        JSONObject rst = executeSVC(conn, qry);
    		 
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg");
        } else {
            conn.commit(); 
        } 

    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    }
}else if ("quitCafe".equals(func)) {
    Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        conn.setAutoCommit(false); 
        String qry = getQuery(pgmid,"quitCafe");
        qry = bindVAR(qry,INVAR); 
        JSONObject rst = executeSVC(conn, qry);

        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg");
        } else {
            conn.commit(); 
        } 
    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    } 
}else if ("save".equals(func)) {
    Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        conn.setAutoCommit(false); 
        String qry = getQuery(pgmid,"save");
        qry = bindVAR(qry,INVAR); 
        JSONObject rst = executeSVC(conn, qry);

        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg");
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
