<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_lg";
String pgmid   = "BoxNumPopupPC"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/

if("searchBoxGrpId".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "searchBoxGrpId"); 
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


if("searchBox".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "searchBox"); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray list = selectSVC(conn, qryRun);
        OUTVAR.put("list",list);
        /*
        String qryG = getQuery(pgmid, "selectBoxNum"); 
        String qryRunG = bindVAR(qryG,INVAR);
        OUTVAR.put("qryRunG",qryRunG); //for debug
        JSONArray grpid = selectSVC(conn, qryRunG);
        OUTVAR.put("grpid",grpid);
*/
    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}

//save:저장 이벤트처리(DB_Write)
if("save".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "updateBoxNum");
        String qryRun = "";
        JSONArray arrList = getArray(INVAR,"list");
        /*
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i);
            row.put("whcd",getVal(INVAR,"whcd"));
            row.put("grp_id",getVal(INVAR, "grp_id"));
            row.put("box_keycd",getVal(INVAR, "box_keycd"));
            row.put("comcd",ORGCD);
            row.put("usid",USERID);
            qryRun += bindVAR(qry,row) + "\n";
        } */
        for(int i = arrList.size()-1; i >= 0; i--) {
            JSONObject row = getRow(arrList,i);
            row.put("whcd",getVal(INVAR,"whcd"));
            row.put("grp_id",getVal(INVAR, "grp_id"));
            row.put("box_keycd",getVal(INVAR, "box_keycd"));
            row.put("comcd",ORGCD);
            row.put("usid",USERID);
            qryRun += bindVAR(qry,row) + "\n";
        }
        JSONObject rst = executeSVC(conn, qryRun);
        OUTVAR.put("qryRun",qryRun);
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else { 
            //conn.commit();
            String qryX = getQuery(pgmid, "updateBoxNum_goods");
            String qryRunX = "";
            arrList = getArray(INVAR,"list");
            /*
            for(int i = 0; i < arrList.size(); i++) {
                JSONObject row = getRow(arrList,i);
                row.put("grp_id",getVal(INVAR, "grp_id"));
                row.put("comcd",ORGCD);
                row.put("usid",USERID);
                qryRunX += bindVAR(qryX,row) + "\n";
            } */
            for(int i = arrList.size()-1; i >= 0; i--) {
                JSONObject row = getRow(arrList,i);
                row.put("grp_id",getVal(INVAR, "grp_id"));
                row.put("comcd",ORGCD);
                row.put("usid",USERID);
                qryRunX += bindVAR(qryX,row) + "\n";
            }
            rst = executeSVC(conn, qryRunX);
            OUTVAR.put("qryRunX",qryRunX);
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
