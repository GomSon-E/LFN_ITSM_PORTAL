<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "aweportal";
String pgmid   = "registerAlert"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/// *********************************************************************************************/
//search:조회 이벤트처리(DB_Read)     
    if("search".equals(func)) {
        Connection conn = null; 
        try {  
            conn = getConn("LFN"); 
            
            String qry1 = getQuery(pgmid, "search"); 
            qry1 = bindVAR(qry1, INVAR);
            JSONArray list = selectSVC(conn, qry1);
            OUTVAR.put("list", list); 
            
            String qry2 = getQuery(pgmid, "searchLog");
            qry2 = bindVAR(qry2, INVAR);
            JSONArray last = selectSVC(conn, qry2);
            OUTVAR.put("last", last);
            

        } catch (Exception e) { 
            rtnCode = "ERR";
            rtnMsg = e.toString();				
        } finally {
            closeConn(conn);
        }  
    }
    
    else if("searchReceiver".equals(func)) {
        Connection conn = null; 
        try {  
            conn = getConn("LFN"); 
            
            String qry = getQuery(pgmid, "searchReceiver"); 
            qry = bindVAR(qry, INVAR);
            JSONArray lastUser = selectSVC(conn, qry);
            OUTVAR.put("lastUser", lastUser); 

        } catch (Exception e) { 
            rtnCode = "ERR";
            rtnMsg = e.toString();				
        } finally {
            closeConn(conn);
        }  
    }

    else if("searchGroup".equals(func)) {
        Connection conn = null; 
        try {  
            conn = getConn("LFN"); 
            
            String qry = getQuery(pgmid, "searchGroup"); 
            qry = bindVAR(qry, INVAR);
            JSONArray grp = selectSVC(conn, qry);
            OUTVAR.put("grp", grp); 

        } catch (Exception e) { 
            rtnCode = "ERR";
            rtnMsg = e.toString();				
        } finally {
            closeConn(conn);
        }  
    }
    
    //알림저장:저장 이벤트처리(DB_Write)
    if("saveLog".equals(func)) {
        Connection conn = null; 
        try {               
            conn = getConn("LFN");
            conn.setAutoCommit(false);
            String qry = getQuery(pgmid, "saveLog");
            String qryRun = bindVAR(qry, INVAR); 
            JSONObject rst = executeSVC(conn,qryRun);
            OUTVAR.put("qryRun",qryRun);
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
