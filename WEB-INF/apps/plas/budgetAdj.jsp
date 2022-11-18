<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "plas";
String pgmid   = "budgetAdj"; 
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
 

//cfm:저장 이벤트처리(DB_Write)
if("cfm".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("usid",USERID);
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "qrycfm");
        String qryRun = "";
        JSONArray arrList = getArray(INVAR,"list"); 
        JSONObject rst = new JSONObject();
        for(int i = 0; i < arrList.size(); i++) {
            qryRun = "";
            JSONObject row = getRow(arrList,i); 
            for(int j=0; j < 12; j++) {
                String mm = ""+(j+1);
                if(j < 9) mm = "0"+mm;
                if(!isNull(getVal(row,"amt_adj_"+mm))) {
                    row.put("usid",USERID);
                    row.put("co_cd",getVal(INVAR,"co_cd"));
                    row.put("ym",getVal(INVAR,"fiscal_yr")+mm);
                    row.put("amt_adj",getVal(row,"amt_adj_"+mm));
                    row.put("docid",getVal(INVAR,"docid"));
                    row.put("adj_tp",getVal(INVAR,"adj_tp"));
                    row.put("adj_remark",getVal(INVAR,"adj_remark"));
                    qryRun += bindVAR(qry,row) + "\n";
                }
            }
            rst = executeSVC(conn, qryRun);
            if(!"OK".equals(getVal(rst,"rtnCd"))) break;
        } 
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else { 
            
            /* 로그기록 */ 
            qry = getQuery(pgmid, "qryLog");
            qryRun = bindVAR(qry,INVAR);
            rst = executeSVC(conn, qryRun); 
            if(!"OK".equals(getVal(rst,"rtnCd"))) {
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

//lock:저장 이벤트처리(DB_Write)
if("lock".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("usid",USERID);
        INVAR.put("lock","F");
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "qrylock");
        String qryRun = bindVAR(qry,INVAR) + "\n";
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

//unlock:저장 이벤트처리(DB_Write)
if("unlock".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("usid",USERID);
        INVAR.put("lock","N");
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "qrylock");
        String qryRun = bindVAR(qry,INVAR) + "\n";
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
