<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "aweportal";
String pgmid   = "manageGrp"; 
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
            //System.out.println(INVAR);
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
    else if("searchUser".equals(func)) {
    Connection conn = null; 
    try {   
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "searchUser"); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray user_dt = selectSVC(conn, qryRun);
        OUTVAR.put("user_dt",user_dt); 


    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
        } finally {
            closeConn(conn);
        }  
    }

    //save:저장 이벤트처리(DB_Write)
    else if("save".equals(func)) {
        Connection conn = null; 
        try {  
            conn = getConn("LFN");
            conn.setAutoCommit(false);
            String qry = getQuery(pgmid, "save");
            String qryRun = "";   
            INVAR.put("userid",USERID);
            qryRun += bindVAR(qry,INVAR);
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
    else if("saveUser".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        //System.out.println(INVAR);
        String qryUser = getQuery(pgmid, "saveUser");
        String qrydel = getQuery(pgmid, "delUser");

        String qryRun = "";
        /* 운영시즌 저장 */
        JSONArray arrList = getArray(INVAR,"user_dt");
       
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            row.put("userid",USERID);
            qryRun += bindVAR(qryUser,row) + "\n";
        }  
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            if("D".equals(getVal(row,"crud"))) {
                qryRun += bindVAR(qrydel,row) + "\n";
            }
        } 
        OUTVAR.put("qryUser",qryRun);
        JSONObject rst = executeSVC(conn, qryRun);  
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg");
            //System.out.println(rtnMsg);

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
