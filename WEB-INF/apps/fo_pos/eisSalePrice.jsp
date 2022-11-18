<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_pos";
String pgmid   = "eisSalePrice"; 
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
        INVAR.put("comcd",ORGCD);
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

if("detsearch".equals(func)) {
    Connection conn = null; 
    try {  
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        getVal(INVAR,"cd_stat_promo");
        if("Y".equals(getVal(INVAR,"cd_stat_promo"))){
            String qry = getQuery(pgmid, "qrysearchdet"); 
            INVAR.put("comcd",ORGCD);
            String qryRun = bindVAR(qry,INVAR);
            OUTVAR.put("qryRun",qryRun); //for debug
            JSONArray detlist = selectSVC(conn, qryRun);
            OUTVAR.put("detlist",detlist); 
        }else{
            String qry = getQuery(pgmid, "qrysearchdet2"); 
            INVAR.put("comcd",ORGCD);
            String qryRun = bindVAR(qry,INVAR);
            OUTVAR.put("qryRun",qryRun); //for debug
            JSONArray detlist = selectSVC(conn, qryRun);
            OUTVAR.put("detlist",detlist); 
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
