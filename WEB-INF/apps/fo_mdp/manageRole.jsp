<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_mdp";
String pgmid   = "manageRole"; 
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
        
        String qry = getQuery(pgmid, "qrysearch"); 
        String qryRun = bindVAR(qry,INVAR); 
        JSONArray list = selectSVC(conn, qryRun);
        OUTVAR.put("list",list);  
        
        String qry2 = getQuery(pgmid, "qrysearch2"); 
        String qryRun2 = bindVAR(qry2,INVAR); 
        JSONArray list2 = selectSVC(conn, qryRun2);
        OUTVAR.put("list2",list2); 

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

        String qryDel = getQuery(pgmid, "qryClear");
        String qry = getQuery(pgmid, "qrysave");
        String qry2 = getQuery(pgmid, "qrysave2");
        String qryRun = "";
        
        INVAR.put("comcd",ORGCD);
        qryRun += bindVAR(qryDel,INVAR) + "\n";
        
        JSONArray arrList = getArray(INVAR,"list"); 
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            row.put("comcd",getVal(INVAR,"comcd"));
            row.put("reg_usid",USERID);
            qryRun += bindVAR(qry,row) + "\n";
        } 
        JSONArray arrList2 = getArray(INVAR,"list2"); 
        for(int i = 0; i < arrList2.size(); i++) {
            JSONObject row = getRow(arrList2,i); 
            row.put("comcd",getVal(INVAR,"comcd"));
            row.put("reg_usid",USERID);
            qryRun += bindVAR(qry2,row) + "\n";
        } 
        OUTVAR.put("qry",qryRun);
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
