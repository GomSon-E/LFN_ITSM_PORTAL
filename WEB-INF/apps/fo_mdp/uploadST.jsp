<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_mdp";
String pgmid   = "uploadST"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/
//save:저장 이벤트처리(DB_Write)
if("save".equals(func)) {
    Connection conn = null; 
    try {   
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qryIns = getQuery(pgmid, "insertSKU");
        /*
        String qryUpd = getQuery(pgmid, "updateSTCL");
        String qryDel = getQuery(pgmid, "deleteSTCL");
        */
        String qryRun = "";
        JSONArray arrList = getArray(INVAR,"list");
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i);
            row.put("comcd",ORGCD);
            row.put("usid",USERID);
            qryRun += bindVAR(qryIns,row) + "\n";
            /*
            if("D".equals(getVal(row,"crud"))) {
                qryRun += bindVAR(qryDel,row) + "\n";
            } else if("U".equals(getVal(row,"crud"))) {
                qryRun += bindVAR(qryUpd,row) + "\n";
            } else if("C".equals(getVal(row,"crud"))) {
                qryRun += bindVAR(qryIns,row) + "\n";
            } 
            */
        }
        /* 스타일컬러 코드 생성 */
        String qrySTCL = getQuery(pgmid, "mergeSTCL"); 
        qryRun += bindVAR(qrySTCL, INVAR) + "\n";
        /* 스타일코드 생성 */
        String qryST = getQuery(pgmid, "mergeST"); 
        qryRun += bindVAR(qryST, INVAR) + "\n";
        /* 실행 */ 
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
