<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "plas";
String pgmid   = "plasDocTemMaster"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/
//searchDocTemplate : 템플릿 조회
 
//search:조회 이벤트처리(DB_Read)     
if("search".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("usid",USERID);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "qrysearch"); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qrysearch",qryRun); //for debug
        JSONArray list = selectSVC(conn, qryRun);
        OUTVAR.put("list",list); 

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
        INVAR.put("usid",USERID);
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        OUTVAR.put("INVAR",INVAR); //for debug
        String test = "{co_line3}";
        test = bindVAR(test,INVAR);
        OUTVAR.put("test",test);
        
        String qry = getQuery(pgmid, "qrysave");
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qrysave",qryRun);
        JSONObject rst = executeSVC(conn, qryRun);
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else {  
            executeUpdateClob(conn, 
                 "T_DOC_TEMPLATE",
                 "CONTENT",
                 getVal(INVAR,"content"),
                 "WHERE doc_template_id='"+getVal(INVAR,"doc_template_id") + "'"); 
            executeUpdateClob(conn, 
                 "T_DOC_TEMPLATE_CONTENT",
                 "CONTENT",
                 getVal(INVAR,"src_desc_clob"),
                 "WHERE doc_template_id='"+getVal(INVAR,"doc_template_id") + "' AND content_seq='1'"); 
            executeUpdateClob(conn, 
                 "T_DOC_TEMPLATE_CONTENT",
                 "CONTENT",
                 getVal(INVAR,"pay_desc_clob"),
                 "WHERE doc_template_id='"+getVal(INVAR,"doc_template_id") + "' AND content_seq='2'"); 
            executeUpdateClob(conn, 
                 "T_DOC_TEMPLATE_CONTENT",
                 "CONTENT",
                 getVal(INVAR,"pjt_desc_clob"),
                 "WHERE doc_template_id='"+getVal(INVAR,"doc_template_id") + "' AND content_seq='3'"); 
            executeUpdateClob(conn, 
                 "T_DOC_TEMPLATE_CONTENT",
                 "CONTENT",
                 getVal(INVAR,"drcr_acct_clob"),
                 "WHERE doc_template_id='"+getVal(INVAR,"doc_template_id") + "' AND content_seq='4'");                  
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
