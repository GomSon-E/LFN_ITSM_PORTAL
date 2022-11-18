<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "m";
String pgmid   = "MRMakeResv"; 
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
    
        INVAR.put("comcd",ORGCD);
        String resv_no = getUUID(20);
        INVAR.put("resv_no",resv_no);
        INVAR.put("userid", USERID); /* 관리자 대행등록시에는 args에서 넘겨 받아서 저장 */ 
        INVAR.put("usid"  , USERID); 
        /* INVAR ARGS 
        args.room_id    = me.room_id;
        args.aday       = isYmd(me.aymd)?me.aymd:date("today","yyyy-mm-dd","yyyymmdd");
    	args.start_time = isNull(me.start_time)?date("today","hh24:mi"):me.start_time; 
    	args.duration_time = 1;
    	args.remark     = "";
    	*/
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        
        String qry = getQuery(pgmid, "qrysearch"); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug 
        JSONArray mst = selectSVC(conn, qryRun); 
        OUTVAR.put("mst",mst);  
        
    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    } 
}

if("save".equals(func)) {
    Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        conn.setAutoCommit(false);  
        INVAR.put("usid",USERID);
        String qry = getQuery(pgmid,"qrySave");
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


if("cancel".equals(func)) {
    Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        conn.setAutoCommit(false);  
        INVAR.put("usid",USERID);
        String qry = getQuery(pgmid,"qryCancel");
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

if("run".equals(func)) {
    Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        conn.setAutoCommit(false);  
        INVAR.put("usid",USERID);
        String qry = getQuery(pgmid,"qryRun");
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


if("finish".equals(func)) {
    Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        conn.setAutoCommit(false);  
        INVAR.put("usid",USERID);
        String qry = getQuery(pgmid,"qryFinish");
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
