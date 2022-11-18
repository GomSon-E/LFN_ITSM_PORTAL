<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_pos";
String pgmid   = "onlineOrder2"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/// *********************************************************************************************/
if("search".equals(func)) {
    Connection conn = null; 
    try {  
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        
        /* 조회전 API데이터로 SO생성
        conn.setAutoCommit(false); 
        String qryBatch = getQuery(pgmid, "qryBatch"); 
        JSONObject rst = executeSVC(conn, qryBatch);
        OUTVAR.put("qryBatch",qryBatch);
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg");
        } else {
            conn.commit();  
        }
        */
        
        INVAR.put("comcd",ORGCD);
        String qry = getQuery(pgmid, "qrySearch"); 
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

if("calc".equals(func)) {
    Connection conn = null;     
    try {
        conn = getConn("LFN");
        conn.setAutoCommit(false);
 
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        OUTVAR.put("INVAR",INVAR);
        String qry = getQuery(pgmid, "qryCalc");   
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

if("save".equals(func)) {
    Connection conn = null;     
    try {
        conn = getConn("LFN");
        conn.setAutoCommit(false);
 
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        OUTVAR.put("INVAR",INVAR);
        String qry = getQuery(pgmid, "qrySave");   
        String qryRun = ""; 
        
        JSONArray arrItemlist = getArray(INVAR,"list"); 
        for(int i = 0; i < arrItemlist.size(); i++) {
            JSONObject row = getRow(arrItemlist,i); 
            row.put("comcd",ORGCD); 
            row.put("usid",USERID);
            qryRun += bindVAR(qry,row) + "\n";
        }  
        JSONObject rst = executeSVC(conn, qryRun);
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg");
        } else {
            
            String qry2 = getQuery(pgmid, "qrySaveBatch");   
            String qryRun2 = bindVAR(qry2,INVAR);  
            JSONObject rst2 = executeSVC(conn, qryRun2);
            if(!"OK".equals(getVal(rst2,"rtnCd"))) {
                conn.rollback();
                rtnCode = getVal(rst2,"rtnCd"); 
                rtnMsg  = getVal(rst2,"rtnMsg");
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
