<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_pos";
String pgmid   = "adjust"; 
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
        INVAR.put("comcd",ORGCD);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "qrysearch"); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray list = selectSVC(conn, qryRun);
        OUTVAR.put("list",list); 
        
        String qry2 = getQuery(pgmid, "salepricesearch"); 
        String qryRun2 = bindVAR(qry2,INVAR);
        OUTVAR.put("qryRun2",qryRun2); //for debug
        JSONArray salepricelist = selectSVC(conn, qryRun2);
        OUTVAR.put("salepricelist",salepricelist); 
        
        String qry3 = getQuery(pgmid, "mattplistsearch"); 
        String qryRun3 = bindVAR(qry3,INVAR);
        OUTVAR.put("qryRun3",qryRun3); //for debug
        JSONArray mattplist = selectSVC(conn, qryRun3);
        OUTVAR.put("mattplist",mattplist);
        
        String qry4 = getQuery(pgmid, "cdstatlistsearch"); 
        String qryRun4 = bindVAR(qry4,INVAR);
        OUTVAR.put("qryRun4",qryRun4); //for debug
        JSONArray cdstatlist = selectSVC(conn, qryRun4);
        OUTVAR.put("cdstatlist",cdstatlist);
        
        String qry5 = getQuery(pgmid, "paytplistsearch"); 
        String qryRun5 = bindVAR(qry5,INVAR);
        OUTVAR.put("qryRun5",qryRun5); //for debug
        JSONArray paytplist = selectSVC(conn, qryRun5);
        OUTVAR.put("paytplist",paytplist);
        
        String qry6 = getQuery(pgmid, "costcomcdlistsearch"); 
        String qryRun6 = bindVAR(qry6,INVAR);
        OUTVAR.put("qryRun6",qryRun6); //for debug
        JSONArray costcomcdlist = selectSVC(conn, qryRun6);
        OUTVAR.put("costcomcdlist",costcomcdlist);
        
        String qry7 = getQuery(pgmid, "delilistsearch"); 
        String qryRun7 = bindVAR(qry7,INVAR);
        OUTVAR.put("qryRun7",qryRun7); //for debug
        JSONArray delilist = selectSVC(conn, qryRun7);
        OUTVAR.put("delilist",delilist); 
        

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}
/***************************************************************************************************/// *********************************************************************************************/
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
