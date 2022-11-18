<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "aweportal";
String pgmid   = "manageDict"; 
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
            String qry1 = getQuery(pgmid, "searchColList");  
            JSONArray colist = selectSVC(conn, qry1);
            OUTVAR.put("colist",colist); 
            String qry2 = getQuery(pgmid, "searchList");  
            JSONArray list = selectSVC(conn, qry2);
            OUTVAR.put("list",list); 

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
            String qryC = getQuery(pgmid, "insertDict");
            String qryU = getQuery(pgmid, "updateDict");
            String qryD = getQuery(pgmid, "deleteDict");
            String qryRun = "";
            JSONArray arrList = getArray(INVAR,"list");
            for(int i = 0; i < arrList.size(); i++) {
                JSONObject row = getRow(arrList,i); 
                row.put("usid",USERID);
                if("D".equals(getVal(row,"crud"))) qryRun += bindVAR(qryD,row) + "\n";
                else if("U".equals(getVal(row,"crud"))) qryRun += bindVAR(qryU,row) + "\n";
                else if("C".equals(getVal(row,"crud"))) qryRun += bindVAR(qryC,row) + "\n"; 
            } 
            OUTVAR.put("qry",qryRun);
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
