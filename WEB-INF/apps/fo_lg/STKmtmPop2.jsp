<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_lg";
String pgmid   = "STKmtmPop2"; 
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
        if("N".equals(getVal(INVAR,"done_skip_yn"))) {
            INVAR.put("done_skip_yn",null);
        }
        String componentId = getVal(INVAR,"componentId");
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN"); 
        String qry = getQuery(pgmid, componentId); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray rst = selectSVC(conn, qryRun);
        OUTVAR.put(componentId,rst); 

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
            row.put("mat_tp",getVal(INVAR,"mat_tp"));   
            row.put("yyyy",getVal(INVAR,"yyyy"));  
            row.put("sssn_cd",getVal(INVAR,"sssn_cd"));  
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
