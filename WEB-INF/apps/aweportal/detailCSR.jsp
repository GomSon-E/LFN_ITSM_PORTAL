<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "aweportal";
String pgmid   = "detailCSR"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/
if("searchCSR".equals(func)) { 
	Connection conn = null; 
	try { 
        conn = getConn("LFN");
        String qry = getQuery(pgmid, "searchCSR");
        qry = bindVAR(qry, INVAR);
        JSONArray mst = selectSVC(conn, qry);
    	OUTVAR.put("mst", mst);

	} catch (Exception e) { 
		rtnCode = "ERR";
		rtnMsg  = e.toString();	
		
	} finally {
		closeConn(conn);
	}  
}

if("searchFile".equals(func)) { 
	Connection conn = null; 
	try { 
        conn = getConn("LFN");
        String qryRes = getQuery(pgmid, "searchFile");
        String qryReq = getQuery(pgmid, "searchFIleReq");
        
        qryRes = bindVAR(qryRes, INVAR);
        JSONArray fileRes = selectSVC(conn, qryRes);
    	OUTVAR.put("fileRes", fileRes);
    	
        qryReq = bindVAR(qryReq, INVAR);
        JSONArray fileReq = selectSVC(conn, qryReq);
    	OUTVAR.put("fileReq", fileReq);    	

	} catch (Exception e) { 
		rtnCode = "ERR";
		rtnMsg  = e.toString();	
		
	} finally {
		closeConn(conn);
	}  
}

//saveRes:요청저장 이벤트처리(DB_Write)
if("saveRes".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "saveRes");
        String qryRun = "";
        JSONArray arrList = getArray(INVAR,"det");
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            row.put("usid",USERID);
            qryRun += bindVAR(qry,row) + "\n";
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
// *********************************************************************************************
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
