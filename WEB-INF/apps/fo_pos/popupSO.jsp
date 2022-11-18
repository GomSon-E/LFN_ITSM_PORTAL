<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_pos";
String pgmid   = "popupSO"; 
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
        conn = getConn("LFN");
        
        INVAR.put("comcd",ORGCD); 
        String qry = getQuery(pgmid,"selectTP_SO");
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray list = selectSVC(conn, qryRun);
        OUTVAR.put("list",list);
        
        String qry2 = getQuery(pgmid,"selectTP_SO_GOODS");
        String qryRun2 = bindVAR(qry2,INVAR);
        OUTVAR.put("qryRun2",qryRun2); //for debug
        JSONArray list2 = selectSVC(conn, qryRun2);
        OUTVAR.put("list2",list2);
        
        String qry3 = getQuery(pgmid, "selectTP_SO_PAY"); 
        INVAR.put("SO_NOval",getVal(INVAR,"so_no"));
        String qryRun3 = bindVAR(qry3,INVAR);
        OUTVAR.put("qryRun3",qryRun3); //for debug
        JSONArray paylist = selectSVC(conn, qryRun3);
        OUTVAR.put("paylist",paylist);
        
        String qry4 = getQuery(pgmid, "selectTP_SO_PAY_LOG"); 
        INVAR.put("SO_NOval",getVal(INVAR,"so_no"));
        String qryRun4 = bindVAR(qry4,INVAR);
        OUTVAR.put("qryRun4",qryRun4); //for debug
        JSONArray apvRst = selectSVC(conn, qryRun4);
        OUTVAR.put("apvRst",apvRst);

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}

if("saveDet".equals(func)) {
    Connection conn = null; 
    try {
        conn = getConn("LFN");
        INVAR.put("comcd",ORGCD);
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "qrysaveDet");
        String qryRun = "";
        JSONArray arrList = getArray(INVAR,"list");
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            qryRun += bindVAR(qry,row) + "\n";
        }
        OUTVAR.put("qryRun",qryRun);
        JSONObject rst = executeSVC(conn, qryRun);  
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else { 
            String rotate_no = getVal(rst,"rtnMsg"); 
            conn.commit();
        } 
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}

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
