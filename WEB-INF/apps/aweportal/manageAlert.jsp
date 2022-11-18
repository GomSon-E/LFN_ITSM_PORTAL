<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "aweportal";
String pgmid   = "manageAlert"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/// *********************************************************************************************/
    if("search".equals(func)) {
        Connection conn = null;
        
        try  {
            conn = getConn("LFN");
            
            //INVAR.put("usid", USERID);
            
            String qry = getQuery(pgmid, "retrieveAlertList");
            qry = bindVAR(qry, INVAR);
            JSONArray list = selectSVC(conn, qry);
            
            OUTVAR.put("list", list);
            
        } catch(Exception e) {
            rtnCode = "ERR";
            rtnMsg  = e.toString();
        } finally {
            closeConn(conn);
        }
    }
    if("checkAlert".equals(func)) {
        Connection conn = null;
        
        try  {
            JSONObject ARGS = new JSONObject();
            ARGS.put("usid",USERID);
            conn = getConn("LFN"); 
            String qry = getQuery(pgmid, "retrieveAlert");
            qry = bindVAR(qry, ARGS);
            JSONArray list = selectSVC(conn, qry); 
            OUTVAR.put("list", list);
            
        } catch(Exception e) {
            rtnCode = "ERR";
            rtnMsg  = e.toString();
        } finally {
            closeConn(conn);
        }
    }    
    if("readAlert".equals(func)) {
        Connection conn = null; 
        try  {
            conn = getConn("LFN");
            conn.setAutoCommit(false);
            String qry = getQuery(pgmid, "readAlert");
            String qryRun = bindVAR(qry, INVAR);   
                
            JSONObject rst = executeSVC(conn, qryRun);          
            /******************************************/
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
    //읽음처리
    if("read".equals(func)) {
        Connection conn = null; 
        try  {
            conn = getConn("LFN");
            conn.setAutoCommit(false);
            String qry = getQuery(pgmid, "read");
            String qryRun = "";
            
            JSONArray arrList = getArray(INVAR,"list");
            JSONObject rst = new JSONObject(); rst.put("rtnCd","OK");
            for(int i = 0; i < arrList.size(); i++) {
                JSONObject row = getRow(arrList,i); 
                qryRun += bindVAR(qry,row) + "\n";
            }  
            if(!"".equals(qryRun)) rst = executeSVC(conn, qryRun);  
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
     
    //삭제처리
    if("delete".equals(func)) {
        Connection conn = null; 
        try  {
            conn = getConn("LFN");
            conn.setAutoCommit(false);
            String qry = getQuery(pgmid, "delete");
            String qryRun = "";
            
            JSONArray arrList = getArray(INVAR,"list");
            JSONObject rst = new JSONObject(); rst.put("rtnCd","OK");
            for(int i = 0; i < arrList.size(); i++) {
                JSONObject row = getRow(arrList,i); 
                qryRun += bindVAR(qry,row) + "\n";
            }  
            if(!"".equals(qryRun)) rst = executeSVC(conn, qryRun);  
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
