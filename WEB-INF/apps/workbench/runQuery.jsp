<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "workbench";
String pgmid   = "runQuery"; 
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
        OUTVAR.put("INVAR",INVAR); //for debug
        INVAR.put("usid",USERID);
        String connTo = getVal(INVAR,"connTo");
        conn = getConn(connTo);  
        String qry = getVal(INVAR,"qryRun"); 
        String qryRun = bindVAR(qry,INVAR);
        if(!"-1".equals(getVal(INVAR,"rowCnt"))) {
            if("DOUZONE".equals(connTo)) {
                qryRun = "SELECT TOP("+getVal(INVAR,"rowCnt")+") A.* FROM (" + qryRun + ") A";
            } else {
                qryRun = "SELECT * FROM ( " + qryRun + " ) WHERE ROWNUM <= "+getVal(INVAR,"rowCnt");
            }
        }
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray rst = selectSVCWithColOrder(conn, qryRun);
        OUTVAR.put("rst",rst); 

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}

//save:저장 이벤트처리(DB_Write)
if("save".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false); 
        String qry = getQuery(pgmid, "mergeQry"); 
        if("D".equals(getVal(INVAR,"crud"))) qry = getQuery(pgmid, "deleteQry"); 
        INVAR.put("usid",USERID);
        qry = bindVAR(qry,INVAR); 
        
        //System.out.println(qry);
        
        JSONObject rst = executeSVC(conn, qry); 
        
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else { 
            rtnMsg = executeUpdateClob(conn, 
				                     "T_PGM_SRC",
				                     "content",
				                     getVal(INVAR,"content"),
				                     "WHERE pgmid='"+getVal(INVAR,"pgmid")+"' AND srcid='"+getVal(INVAR,"srcid")+"'");
			if(!"OK".equals(rtnMsg)) {
				conn.rollback();
                rtnCode = getVal(rst,"rtnCd"); 
                rtnMsg  = getVal(rst,"rtnMsg"); 
			} else { 	                     
                conn.commit();
            }
        } 
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}

//refresh:테이블재조회 이벤트처리(DB_Read)     
if("refresh".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "qryQList");  
        JSONArray qlist = selectSVC(conn, qry);
        OUTVAR.put("qlist",qlist); 
        
        qry = getQuery(pgmid, "qryRefresh");  
        JSONArray tlist = selectSVC(conn, qry);
        OUTVAR.put("tlist",tlist); 

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
