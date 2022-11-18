<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   
JSONObject OUTVAR = new JSONObject(); 
String appid = "aweportal";    //<===== 수정할 것!
String pgmid   = "manageProfileTest"; //<===== 수정할 것!
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";
try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar);
/***************************************************************************************************/
if("selectprofile".equals(func)) {
    Connection conn = null;  
    try {
        
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        INVAR.put("userid",USERID);
        String qry = "SELECT NM, NICK_NM , EMAIL FROM T_USER WHERE USID = {userid}";//T_PGM_SRC.content 

        String qryRun = bindVAR(qry,INVAR);
        JSONArray list = selectSVC(conn,qryRun);

        OUTVAR.put("list",list);
      
    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    }        
}
if("search".equals(func)) {
    Connection conn = null;  
    try {
        
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        String qry = getQuery(pgmid,"retrieveProfile"); //T_PGM_SRC.content 
        String qryRun = bindVAR(qry,INVAR);
        JSONArray list = selectSVC(conn,qryRun);
        
        OUTVAR.put("list",list);
        System.out.println(OUTVAR.toJSONString());
      
    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    }        
} 
else if ("save".equals(func)) {
    Connection conn = null;  
    try {   
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        conn.setAutoCommit(false);
        INVAR.put("usid",USERID); 
        //INVAR {list:[{cd: "PGM", remark: "프로그램", sort_seq: "1", nm: "프로그램"}]}
        String qry = "UPDATE T_USER SET NICK_NM = {nick_nm}, EMAIL = {email} WHERE USID = {usid};"; //T_PGM_SRC.content 
        String qryRun = bindVAR(qry,INVAR);
        JSONObject rst = executeSVC(conn, qryRun);
        System.out.println(rst);
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