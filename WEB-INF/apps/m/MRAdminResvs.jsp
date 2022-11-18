<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "m";
String pgmid   = "MRAdminResvs"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/
if("search".equals(func)) {
    Connection conn = null; 
    try {  
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        INVAR.put("comcd",ORGCD); 
        String qry2 = getQuery(pgmid, "searchResvs"); 
        String qryRun2 = bindVAR(qry2,INVAR);
        OUTVAR.put("qryRun2",qryRun2); //for debug 
        JSONArray resvs = selectSVC(conn, qryRun2); 
        OUTVAR.put("resvs",resvs);  

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
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        OUTVAR.put("INVAR",INVAR); //for debug
        
        conn = getConn("LFN");  
        conn.setAutoCommit(false);    
        
        String qryUpd = getQuery(pgmid, "qryUpd");  
        String qryRun = ""; 
        
        JSONArray arrItemlist = getArray(INVAR,"list"); 
        for(int i = 0; i < arrItemlist.size(); i++) {
            JSONObject row = getRow(arrItemlist,i); 
            row.put("comcd",ORGCD); 
            row.put("usid",USERID);
            qryRun += bindVAR(qryUpd,row) + "\n";
        }  
        OUTVAR.put("qryRun",qryRun); 
        if(!isNull(qryRun)) {
            JSONObject rst = executeSVC(conn, qryRun); 
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
