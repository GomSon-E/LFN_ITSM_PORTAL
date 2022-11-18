<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_pos";
String pgmid   = "OnlinePOP"; 
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
        String qry = getQuery(pgmid, "qrysave");
        String qryRun = "";
        JSONArray arrList = getArray(INVAR,"list");
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i);
            row.put("comcd",ORGCD);
            row.put("usid",USERID);
            row.put("shopcd",getVal(INVAR,"shopcd"));
            qryRun += bindVAR(qry,row) + "\n";
        }
        JSONObject rst = executeSVC(conn, qryRun);  
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else { 
            conn.commit();
            INVAR.put("comcd",ORGCD);
            INVAR.put("usid",USERID);
            String qry2 = getQuery(pgmid, "save_TP_SO");
            String qryRun2 = bindVAR(qry2,INVAR);
            /*
            JSONArray arrList2 = getArray(INVAR,"list");
            for(int i = 0; i < arrList2.size(); i++) {
                JSONObject row = getRow(arrList2,i); 
                row.put("usid",USERID);
                row.put("comcd",ORGCD);
                row.put("sale_dt",getVal(INVAR,"sale_dt"));
                row.put("pos_no",getVal(INVAR,"pos_no"));
                row.put("shopcd",getVal(INVAR,"shopcd"));
                qryRun2 += bindVAR(qry2,row) + "\n";
            }
            */
            JSONObject rst2 = executeSVC(conn, qryRun2);
            OUTVAR.put("qryRun2",qryRun2);
            if(!"OK".equals(getVal(rst2,"rtnCd"))) {
                conn.rollback();
                rtnCode = getVal(rst2,"rtnCd"); 
                rtnMsg  = getVal(rst2,"rtnMsg"); 
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

if("goodsSearch".equals(func)) {
    Connection conn = null; 
    try {  
        OUTVAR.put("INVAR",INVAR); //for debug
        INVAR.put("comcd",ORGCD);
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "goodssearch"); 
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
