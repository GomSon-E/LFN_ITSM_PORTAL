<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "ITSM";
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
            
            String qry = "SELECT A.GRPID AS RECEIVER, B.NM AS SENDER, A.REG_USID AS SENDER_ID, A.REF_ID, A.COMMENTS, A.REF_INFO_TP, A.REG_DT, A.READ_YN, A.rowid ";
            qry += "FROM T_CHAT A, T_USER B WHERE A.REG_USID = B.USID ";
            qry += "AND A.GRPID    = {usid} ";
            qry += "AND A.REF_ID   = NVL({ref_id}, A.REF_ID) ";
            qry += "AND A.READ_YN  = NVL({cd_read}, A.READ_YN) ";
            qry += "AND A.REG_DT BETWEEN TO_DATE({fromdate}, 'YYYYMMDD') AND TO_DATE({todate}, 'YYYYMMDD') ";
            qry += "AND A.COMMENTS LIKE '%[comments]%' ";
            qry += "AND NOT(A.READ_YN = 'E') ";
            qry += "ORDER BY REG_DT DESC";

            qry = bindVAR(qry, INVAR);
            JSONArray list = selectSVC(conn, qry);
        
            OUTVAR.put("list", list);
            OUTVAR.put("qry", qry);
            
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
