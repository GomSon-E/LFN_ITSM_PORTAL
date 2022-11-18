<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_lg";
String pgmid   = "STKmtm"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/
//search:조회 이벤트처리(DB_Read)     
if("search".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "qrysearch"); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray list = selectSVC(conn, qryRun);
        OUTVAR.put("list",list); 

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}
//searchMst:조회 이벤트처리(DB_Read)     
if("searchMst".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qryMst = getQuery(pgmid, "qrysearchMst"); 
        qryMst = bindVAR(qryMst,INVAR);
        OUTVAR.put("qryMst",qryMst); //for debug
        JSONArray mst = selectSVC(conn, qryMst);
        OUTVAR.put("mst",mst); 

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}

//save:수불반영 이벤트처리(DB_Write)
if("save".equals(func)) {
    Connection conn = null; 
    try {   
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "qrysave");
        String qryRun = "";
        JSONArray arrList = getArray(INVAR,"det");
        
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            row.put("comcd",ORGCD);
            row.put("whcd",getVal(INVAR,"whcd"));
            row.put("mov_dt",getVal(INVAR,"mov_dt"));
            row.put("doc_tp",getVal(INVAR,"doc_tp"));
            row.put("doc_no",getVal(INVAR,"doc_no")); 
            row.put("usid",USERID);
            qryRun += bindVAR(qry,row) + "\n";
        } 
        OUTVAR.put("qryRun",qryRun);
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

//cancel:수불반영취소 이벤트처리(DB_Write)
if("cancel".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
    
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "qrycancel");
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
