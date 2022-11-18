<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "plas";
String pgmid   = "popupPlasGRP"; 
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
        String DZ_ORG_TP = getVal(INVAR,"dz_org_tp");
        
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "qrySearch"); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("dz_org_tp",DZ_ORG_TP); //for debug
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
 
if("searchList".equals(func)) {
    Connection conn = null; 
    try {   
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "qrySearchList"); 
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

if("searchListQuery".equals(func)) {
    Connection conn = null; 
    try {   
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "searchListQuery"); 
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


//mergeUser:저장 이벤트처리(DB_Write)
if("mergeUser".equals(func)) {
    Connection conn = null; 
    try {   
        INVAR.put("reg_usid",USERID);
        INVAR.put("temp_pwd","6cbefd8960d511540f34779628ef4e5a55b758d3be5749cd8878a09b348c052b");  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "qrySave");
        String qryRun = bindVAR(qry, INVAR);  //매장정보 저장 
            
        JSONObject rst = executeSVC(conn, qryRun);          
        /******************************************/
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
