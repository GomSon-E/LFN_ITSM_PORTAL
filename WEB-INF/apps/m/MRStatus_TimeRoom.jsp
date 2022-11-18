<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "m";
String pgmid   = "MRStatus_TimeRoom"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/
if("search".equals(func)) {
    Connection conn = null; 
    try {  
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        
        String qry = getQuery(pgmid, "searchRooms"); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug 
        JSONArray rooms = selectSVC(conn, qryRun); 
        OUTVAR.put("rooms",rooms); 
        
        String qry2 = getQuery(pgmid, "searchResvs"); 
        String qryRun2 = bindVAR(qry2,INVAR);
        OUTVAR.put("qryRun2",qryRun2); //for debug 
        JSONArray resvs = selectSVC(conn, qryRun2); 
        OUTVAR.put("resvs",resvs); 
        
        String qry3 = getQuery(pgmid, "searchUsers"); 
        String qryRun3 = bindVAR(qry3,INVAR);
        OUTVAR.put("qryRun3",qryRun3); //for debug 
        JSONArray users = selectSVC(conn, qryRun3); 
        OUTVAR.put("users",users); 

        /* 세션이 있으면 사용자정보 읽어오고 세션세팅 */
        JSONObject sessionUser = new JSONObject();
        sessionUser.put("orgcd", session.getAttribute("ORGCD"));
        sessionUser.put("orgnm", session.getAttribute("ORGNM"));
        sessionUser.put("deptcd", session.getAttribute("DEPTCD"));
        sessionUser.put("deptnm", session.getAttribute("DEPTNM"));
        sessionUser.put("userid", session.getAttribute("USERID"));
        sessionUser.put("usernm", session.getAttribute("USERNM"));
        sessionUser.put("jobgradenm", session.getAttribute("JOBGRADENM"));
        sessionUser.put("jobrolenm", session.getAttribute("JOBROLENM"));
        sessionUser.put("tel_no", session.getAttribute("TEL_NO"));
        sessionUser.put("email", session.getAttribute("EMAIL")); 
        sessionUser.put("admin_yn", session.getAttribute("ADMIN_YN")); 
        OUTVAR.put("sessionUser",sessionUser); 

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    } 
}

else if("refresh".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        OUTVAR.put("INVAR",INVAR); //for debug
        
        conn = getConn("LFN");   
        
        String qry2 = getQuery(pgmid, "searchResvs"); 
        String qryRun2 = bindVAR(qry2,INVAR);
        OUTVAR.put("qryRun2",qryRun2); //for debug 
        JSONArray resvs = selectSVC(conn, qryRun2); 
        OUTVAR.put("resvs",resvs);  
        
        String qry1 = getQuery(pgmid, "searchNotiResv"); 
        String qryRun1 = bindVAR(qry1,INVAR);
        OUTVAR.put("qryRun1",qryRun1); //for debug 
        JSONArray notiResv = selectSVC(conn, qryRun1); 
        OUTVAR.put("notiResv",notiResv);    

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    } 
}

else if("botUpdate".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        OUTVAR.put("INVAR",INVAR); //for debug
        
        conn = getConn("LFN");  
        conn.setAutoCommit(false);    
        
        String qry1Upd = getQuery(pgmid, "updateNotiResv"); 
        String qryRun1Upd = ""; 
        
        JSONArray arrItemlist = getArray(INVAR,"list"); 
        for(int i = 0; i < arrItemlist.size(); i++) {
            JSONObject row = getRow(arrItemlist,i); 
            row.put("comcd",ORGCD); 
            row.put("usid",USERID);
            qryRun1Upd += bindVAR(qry1Upd,row) + "\n";
        }  
        OUTVAR.put("qryRun1Upd",qryRun1Upd); 
        JSONObject rst = executeSVC(conn, qryRun1Upd); 
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg");
        } else {
            conn.commit(); 
        }   
        

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
