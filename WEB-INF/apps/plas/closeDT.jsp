<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "plas";
String pgmid   = "closeDT"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/
//search:마감일조회 이벤트처리(DB_Read)     
if("search".equals(func)) {
    Connection conn = null;
    Connection connDZ = null; 
    try {  
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        connDZ = getConn("DOUZONE");  
        String qry = getQuery(pgmid, "qrysearch"); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray close_dt = selectSVC(conn, qryRun);
        OUTVAR.put("close_dt",close_dt);  
        
        qry = getQuery(pgmid, "qrylist_dz"); 
        qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qrylist_dz",qryRun); //for debug
        JSONArray list_dz = selectSVC(connDZ, qryRun);
        OUTVAR.put("list_dz",list_dz);   
        
        qry = getQuery(pgmid, "qrylist_plas"); 
        qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qrylist_plas",qryRun); //for debug
        JSONArray list_plas = selectSVC(conn, qryRun);
        OUTVAR.put("list_plas",list_plas); 

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
        closeConn(connDZ);
    }  
}

//save:마감일저장 이벤트처리(DB_Write)
if("save".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("usid",USERID);
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "qrysave");
        String qryRun = bindVAR(qry,INVAR); 
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

//sync:다시 가져오기 이벤트처리(DB_Write)
if("sync".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("usid",USERID);
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "qrysync");
        String qryRun = bindVAR(qry,INVAR);
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
