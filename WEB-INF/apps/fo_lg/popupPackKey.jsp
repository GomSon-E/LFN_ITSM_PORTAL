<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_lg";
String pgmid   = "popupPackKey"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 

if("search".equals(func)) {
    Connection conn = null;  
    try {   
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
         conn.setAutoCommit(false);

        String qry2 = getQuery(pgmid,"retrieveCd"); //T_PGM_SRC.content 
        qry2 = bindVAR(qry2,INVAR); //OUTVAR.put("qry",qry);
        JSONArray list = selectSVC(conn,qry2);   
        OUTVAR.put("list",list); 

    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    }        
} 

else if("save".equals(func)) {
    Connection conn = null;  
    try {   
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qryRun = "";
        String qry = getQuery(pgmid, "mergeGrpcd");
        String qryDel = getQuery(pgmid,"deleteCd"); //T_PGM_SRC.content 
        JSONArray arrList = getArray(INVAR,"list");
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            row.put("usid",USERID);
           if("D".equals(getVal(row,"crud"))) {
                    qryRun += bindVAR(qryDel,row) + "\n";
            } else {
               qryRun += bindVAR(qry,row) + "\n";
            }
                
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
    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    }        
} 

/***************************************************************************************************/// *********************************************************************************************/
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
