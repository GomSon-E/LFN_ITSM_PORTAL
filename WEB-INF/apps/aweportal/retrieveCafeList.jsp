<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "aweportal";
String pgmid   = "retrieveCafeList"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar);
/***************************************************************************************************/
if("loadCafeList".equals(func)) {
    Connection conn = null;  
    try {         
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  

        INVAR.put("usid", USERID);

        String qry = getQuery(pgmid,"cafeList");
        JSONArray cafeList = selectSVC(conn,qry);
        OUTVAR.put("cafeList",cafeList);

        String qry1 = getQuery(pgmid,"joinedList");    
        qry1 = bindVAR(qry1,INVAR);
        JSONArray joinedlist = selectSVC(conn,qry1);
        OUTVAR.put("joinedlist",joinedlist);

        //가입하지 않은 카페명 R
        String qry2 = getQuery(pgmid,"notjoinedList");
        qry2 = bindVAR(qry2,INVAR);
        JSONArray notjoinedlist = selectSVC(conn,qry2);
        OUTVAR.put("notjoinedlist",notjoinedlist);

    } catch(Exception e) {
        rtnCode = "ERR";
        rtnMsg  = e.toString();

    } finally {
        closeConn(conn);
    }
} else if ("saveCreateCafe".equals(func)) {
    Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅 
        conn.setAutoCommit(false);

        String grpid= getUUID(20);
        INVAR.put("usid", USERID);
        INVAR.put("nickname",USERNM);
        INVAR.put("grpid",grpid);

        String qry = getQuery(pgmid,"createCafe");    
        qry = bindVAR(qry,INVAR); 
        JSONObject rst = executeSVC(conn, qry);

        String qry2 = getQuery(pgmid,"createCafejoin");    
        qry2 = bindVAR(qry2,INVAR); 
        JSONObject rst2 = executeSVC(conn, qry2);

        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg");
        } else {
            conn.commit(); 
        } 
        if(!"OK".equals(getVal(rst2,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst2,"rtnCd"); 
            rtnMsg  = getVal(rst2,"rtnMsg");
        } else {
            conn.commit(); 
        } 
    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    } 
} else if ("search".equals(func)) {
    Connection conn = null;  

    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        String qry = getQuery(pgmid,"searchCafe");
        qry = bindVAR(qry,INVAR); 
        JSONArray searchlist = selectSVC(conn, qry);
        OUTVAR.put("searchlist", searchlist);

    } catch(Exception e) {
        rtnCode = "ERR";
        rtnMsg  = e.toString();
    } finally {
        closeConn(conn); 
    } 
}

/***************************************************************************************************/
} catch (Exception e) {
	logger.error(pgmid+" error occurred:"+rtnCode,e);
	rtnCode    = "ERR";
	rtnMsg     = e.toString();
} finally {
	OUTVAR.put("rtnCd",rtnCode);
	OUTVAR.put("rtnMsg",rtnMsg); 
	out.println(OUTVAR.toJSONString());
}
%> 