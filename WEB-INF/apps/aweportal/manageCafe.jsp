<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "aweportal";
String pgmid   = "manageCafe"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar);
/***************************************************************************************************/
if("loadManageCafe".equals(func)) {
    Connection conn = null;  
    try {         
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  

        //String qry = "SELECT USID FROM T_USER_GRP WHERE GRPID={cafe}" //에러?
        String qry = getQuery(pgmid,"memberList");
        qry = bindVAR(qry,INVAR);
        JSONArray members = selectSVC(conn,qry);
        OUTVAR.put("members",members);

        //t_user에서 가입자 user nm 받아오기
        qry = "SELECT nm FROM T_USER WHERE usid IN (SELECT usid FROM T_USER_GRP WHERE grpid={cafe})";
        qry = bindVAR(qry,INVAR);
        JSONArray usnm = selectSVC(conn,qry);
        OUTVAR.put("usnm",usnm);

        //받아온 결과값 출력
        System.out.println(OUTVAR.toJSONString());

    } catch(Exception e) {
        rtnCode = "ERR";
        rtnMsg  = e.toString();

    } finally {
        closeConn(conn);
    }
}else if("retrieveUser".equals(func)){
    Connection conn = null;  
    try {         
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  

        String qry = getQuery(pgmid,"retrieveUser");
        qry = bindVAR(qry,INVAR);
        JSONArray user = selectSVC(conn,qry);
        OUTVAR.put("user",user);

        //받아온 결과값 출력
        System.out.println(OUTVAR.toJSONString());

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
        //INVAR {cafe,nickname} 
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
}else if ("deleteMember".equals(func)) {
    Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        conn.setAutoCommit(false); 
        String qry = getQuery(pgmid,"deleteMember");
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
}else if ("update".equals(func)) {
    Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        conn.setAutoCommit(false); 
        String qry = "UPDATE T_GRP SET grp_nm = {u_cafenm} WHERE grpid = {cafeid} ;";
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