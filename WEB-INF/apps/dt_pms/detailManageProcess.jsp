<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "dt_pms";
String pgmid   = "detailManageProcess"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/
//save:저장 이벤트처리(DB_Write)
if("save".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "qrysave");
        String qryRun = "";
        JSONArray arrList = getArray(INVAR,"list");
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            row.put("usid",USERID);
            qryRun += bindVAR(qry,row) + "\n";
        } 
        JSONObject rst = executeSVC(conn, qryRun);  
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


if("searchFile".equals(func)) { 
	Connection conn = null; 
	try { 
        conn = getConn("LFN");
        String qryRes = getQuery(pgmid, "searchFile");
        
        qryRes = bindVAR(qryRes, INVAR);
        JSONArray fileRes = selectSVC(conn, qryRes);
    	OUTVAR.put("fileRes", fileRes);

	} catch (Exception e) { 
		rtnCode = "ERR";
		rtnMsg  = e.toString();	
		
	} finally {
		closeConn(conn);
	}  
}


//saveRes:요청저장 이벤트처리(DB_Write)
if("saveRes".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "saveRes");
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid", USERID);
        qry = bindVAR(qry,INVAR);
        JSONObject rst = executeSVC(conn, qry);  
        //String qryRun = "";
        //JSONArray arrList = getArray(INVAR,"mst");
        //for(int i = 0; i < arrList.size(); i++) {
        //    JSONObject row = getRow(arrList,i); 
        //    row.put("doc_id",nvl(getVal(row,"doc_id"),getUUID(32))); 
        //    row.put("usid",USERID);
        //    qryRun += bindVAR(qry,row) + "\n";
        //} 
        //JSONObject rst = executeSVC(conn, qryRun);  
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


if ("selectComm".equals(func)) {
     Connection conn = null;  
    try {      
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "selectComm");
        qry = bindVAR(qry, INVAR);
        JSONArray list = selectSVC(conn, qry);
    	OUTVAR.put("list", list);

    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    }
} 

if ("insertComm".equals(func)) {
    Connection conn = null;  
    try {      
        conn = getConn("LFN");  
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "insertComm");
        String commid = getUUID(20);
        INVAR.put("commid", commid);
        INVAR.put("userid", USERID);
        qry = bindVAR(qry,INVAR); 
        JSONObject rst = executeSVC(conn, qry);
        OUTVAR.put("commid", commid);
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

if ("updateComm".equals(func)) {
    Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "updateComm");
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

if ("deleteComm".equals(func)) {
    Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "deleteComm");
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
