<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "aweportal";
String pgmid   = "retrieveCafeHome"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar);
/***************************************************************************************************/
if("loadCafeHome".equals(func)) {
    Connection conn = null;  
    try {         
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  

        INVAR.put("usid", USERID);

        String qry = getQuery(pgmid,"memberList");
        qry = bindVAR(qry,INVAR);
        JSONArray members = selectSVC(conn,qry);
        OUTVAR.put("members",members);

        qry = getQuery(pgmid,"memberNum");
        qry = bindVAR(qry,INVAR);
        JSONArray membernum = selectSVC(conn,qry);
        OUTVAR.put("memberNum",membernum);

        //사용자 카페roletype체크하기
        qry = getQuery(pgmid,"roletpCheck");
        qry = bindVAR(qry,INVAR);
        JSONArray role = selectSVC(conn,qry);
        OUTVAR.put("role",role);

        //grpnm 받아오기
        qry = getQuery(pgmid,"selectGrpnm");
        qry = bindVAR(qry,INVAR);
        JSONArray grpnm = selectSVC(conn,qry);
        OUTVAR.put("grpnm",grpnm);


    } catch(Exception e) {
        rtnCode = "ERR";
        rtnMsg  = e.toString();

    } finally {
        closeConn(conn);
    }
}else if("selectCafeDoc".equals(func)) {
    Connection conn = null;  
    try {         
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  

        String qry = getQuery(pgmid,"selectCafeDoc");
        qry = bindVAR(qry,INVAR);
        JSONArray list = selectSVC(conn,qry);
        OUTVAR.put("list",list);
    } catch(Exception e) {
        rtnCode = "ERR";
        rtnMsg  = e.toString();

    } finally {
        closeConn(conn);
    }
}else if("searchCafeDoc".equals(func)) {
    Connection conn = null;  
    try {         
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  

        String qry = getQuery(pgmid,"searchCafeDoc");
        qry = bindVAR(qry,INVAR);
        JSONArray list = selectSVC(conn,qry);
        OUTVAR.put("list",list);
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
        INVAR.put("usid",USERID);
        INVAR.put("nickname",USERNM);
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