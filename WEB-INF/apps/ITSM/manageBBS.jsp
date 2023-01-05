<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "ITSM";
String pgmid   = "manageBBS"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/
if ("selectAllDoc".equals(func)) {
    Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        String qry = getQuery(pgmid, "selectAllDoc");
        qry = bindVAR(qry,INVAR);
        JSONArray list = selectSVC(conn, qry);
    	OUTVAR.put("list", list);

    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    } 
} if ("selectAllBanner".equals(func)) {
    Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        String qry = getQuery(pgmid, "selectAllBanner"); 
        JSONArray list = selectSVC(conn, qry);
    	OUTVAR.put("list", list);

    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    } 
} else if ("selectRecentDoc".equals(func)) {
    Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        // String qry = getQuery(pgmid, "selectRecentDoc");
        String qry = "SELECT * FROM (	SELECT D.DOCID, D.TITLE, D.CONTENT, D.DOC_TEMPLATE_ID, D.DOC_FILEID, D.DOC_NO, D.TAG, D.VER, D.REF_DOCID, D.REF_INFO_TP, D.REF_ID, D.READ_CNT, D.DOC_STAT, D.REG_USID, D.REG_DT, D.UPD_USID, D.UPD_DT, D.OWN_USID, U.NM 	FROM T_DOC D, T_USER U 	WHERE D.REG_USID = U.USID	AND D.REG_DT > (SYSDATE - (INTERVAL '5' MONTH))	AND D.DOC_STAT = 'Y' 	AND D.DOC_TEMPLATE_ID = '포털사용자그룹'	OR D.DOC_TEMPLATE_ID LIKE 'banner%'	AND U.NM = '관리자'	ORDER BY D.REG_DT DESC	) WHERE ROWNUM <= 28";
        qry = bindVAR(qry,INVAR);
        JSONArray list = selectSVC(conn, qry);
    	OUTVAR.put("list", list);

    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    } 
} else if("searchDoc".equals(func)) { 
	Connection conn = null; 
	try { 
	    String disp   = getVal(INVAR, "disp");
	    String term   = getVal(INVAR, "term");
        conn = getConn("LFN");
        String qry = getQuery(pgmid, "searchDoc");
        qry = bindVAR(qry, INVAR);
        JSONArray list = selectSVC(conn, qry);
    	OUTVAR.put("list", list);

	} catch (Exception e) { 
		rtnCode = "ERR";
		rtnMsg  = e.toString();	
		
	} finally {
		closeConn(conn);
	}  
} else if ("selectOneDoc".equals(func)) {
     Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        String qry = getQuery(pgmid, "selectOneDoc");
        qry = bindVAR(qry, INVAR);
        JSONArray list = selectSVC(conn, qry);
    	OUTVAR.put("list", list);

    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    }
} else if ("updateDoc".equals(func)) {
    Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "updateDoc");
        qry = bindVAR(qry,INVAR); 

        JSONObject rst = executeSVC(conn, qry);

        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg");
        } else {
            executeUpdateClob(conn, 
						                     "T_DOC",
						                     "CONTENT",
						                     getVal(INVAR,"content"),
						                     "WHERE docid='"+getVal(INVAR,"docid") + "'");
            conn.commit(); 
        } 
    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    } 
} else if ("deleteDoc".equals(func)) {
    Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "deleteDoc");
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
} else if ("increaseReadcnt".equals(func)) {
    Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "increaseReadcnt");
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
} else if ("selectComm".equals(func)) {
     Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
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
} else if ("insertComm".equals(func)) {
    Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅 
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
} else if ("updateComm".equals(func)) {
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
} else if ("deleteComm".equals(func)) {
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
} else if ("selectFile".equals(func)) {
    Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        String qry = getQuery(pgmid, "selectFile");
        qry = bindVAR(qry, INVAR);
        JSONArray fList = selectSVC(conn, qry);
        OUTVAR.put("fList", fList);
    } catch(Exception e) {
        rtnCode = "ERR";
        rtnMsg  = e.toString();
    } finally {
        closeConn(conn); 
    } 
}
/***************************************************************************************************/
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
