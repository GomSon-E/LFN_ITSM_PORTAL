<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_lg";
String pgmid   = "RTNmove"; 
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
        conn = getConn("LFN");
        
        INVAR.put("comcd", ORGCD);
        INVAR.put("whcd", DEPTCD);
        
        String lg_ord_no = getVal(INVAR, "lg_ord_no");
        String qry = null;
        if(lg_ord_no.isEmpty()) {
            qry = getQuery(pgmid, "qrysearch");
        } else {
            qry = getQuery(pgmid, "qrysearchord");
        }
        String qryRun = bindVAR(qry, INVAR);
        JSONArray list = selectSVC(conn, qryRun);
        OUTVAR.put("list", list);

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();
        
    } finally {
        closeConn(conn);
    }  
}

//searchMst : 선택된 물류문서 조회
if("searchMst".equals(func)) {
    Connection conn = null; 
    try { 
        conn = getConn("LFN");
        
        INVAR.put("comcd", ORGCD);
        INVAR.put("whcd", DEPTCD);
        
        String qry = getQuery(pgmid, "qrysearch");
        String qryRun = bindVAR(qry, INVAR);
        JSONArray list = selectSVC(conn, qryRun);
        OUTVAR.put("list", list);
        
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
        
    } finally {
        closeConn(conn);
    }  
}

//searchDet : 박스내 상품조회
if("searchDet".equals(func)) {
    Connection conn = null; 
    try {
        conn = getConn("LFN"); 
        
        INVAR.put("comcd", ORGCD);
        INVAR.put("usid", USERID); 

        String qryMst = getQuery(pgmid, "qryMst"); 
        String qryRun = bindVAR(qryMst, INVAR); 
        JSONArray mst = selectSVC(conn, qryRun);
        OUTVAR.put("mst", mst); 
        
        String qryDet = getQuery(pgmid, "qryDet");  
        qryRun = bindVAR(qryDet, INVAR); 
        JSONArray det = selectSVC(conn, qryRun);
        OUTVAR.put("det", det);  

    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
        
    } finally {
        closeConn(conn);
    }
}

if("saveDet".equals(func)) {
    Connection conn = null;
    try {
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        INVAR.put("comcd", ORGCD);
        INVAR.put("usid", USERID);
        
        String qry    = getQuery(pgmid, "saveDet");
        String qryRun = "";

        JSONArray detList = getArray(INVAR, "det");
        for(int i = 0; i < detList.size(); i++) {
            JSONObject row = getRow(detList, i);
            row.put("comcd", ORGCD);
            row.put("usid", USERID);
            row.put("lg_ord_no", getVal(INVAR, "lg_ord_no"));
            qryRun += bindVAR(qry, row) + "\n";
            OUTVAR.put("qryRun", qryRun);
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

if("saveOrd".equals(func)) {
    Connection conn = null;
    
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        INVAR.put("comcd", ORGCD);
        INVAR.put("usid", USERID); 
        
        String saveOrd = getQuery(pgmid, "saveOrd");
        String qryRun  = bindVAR(saveOrd, INVAR);
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
