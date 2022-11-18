<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "aweportal";
String pgmid   = "manageGrpCode"; 
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
            String qry = getQuery(pgmid, "search"); 
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

    //save:저장 이벤트처리(DB_Write)
    if("save".equals(func)) {
        Connection conn = null; 
        try {  
            conn = getConn("LFN");
            conn.setAutoCommit(false);
            String qry = getQuery(pgmid, "save");
            String qryRun = "";
            JSONArray arrList = getArray(INVAR,"list");
            for(int i = 0; i < arrList.size(); i++) {
                JSONObject row = getRow(arrList,i);
                row.put("grpcd", getVal(INVAR,"grpcd") );  //조회조건에 입력된 값을 사용 
                row.put("grpid", getVal(INVAR,"grpid") );  //조회조건에 입력된 값을 사용
                row.put("usid",USERID);  //현재접속한 사용자ID = USERID 
                qryRun += bindVAR(qry,row) + "\n";         //쿼리문에 row정보를 바인딩.. 
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
