<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "plas";
String pgmid   = "popupCcardDate"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/
//save:저장 이벤트처리(DB_Write)

if("cfmAll".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        //INVAR.put("comcd",ORGCD);
        //INVAR.put("usid",USERID);
        
        String qryCfm = getQuery(pgmid, "qrycfmAll");
        String qryRun = "";
        JSONArray arrList = getArray(INVAR,"list");
        
        for(int i = 0; i < arrList.size(); i++) {
        
            JSONObject row = getRow(arrList,i);
            row.put("comcd",ORGCD); 
            row.put("usid",USERID);
            //row.put("lg_ord_no",getVal(row,"lg_ord_no"));
            row.put("lg_dt", getVal(INVAR,"lg_dt")); 
            row.put("lg_tp", getVal(INVAR,"lg_tp")); 
            row.put("ord_fileid", getVal(INVAR,"ord_fileid")); 
            row.put("ord_content", getVal(INVAR,"ord_content")); 
            String qryCfmRun = bindVAR(qryCfm,row);
            OUTVAR.put("qryCfmRun#"+i,qryCfmRun);    
            qryRun += qryCfmRun + "\n"; 
        }
        
        JSONObject rst = executeSVC(conn, qryRun);  
        
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else { 
            //OUTVAR.put("lg_ord_no",lg_ord_no);
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
