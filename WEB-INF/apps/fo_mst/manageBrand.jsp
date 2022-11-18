<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid   = "aweportal";
String pgmid   = "manageBrand"; 
String func    = request.getParameter("func"); 
String rtnCode = "OK";
String rtnMsg  = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/
    if("retrieveComcd".equals(func)) {
        Connection conn = null; 
        try {  
            conn = getConn("LFN");  
            String qry = getQuery(pgmid, "retrieveComcd"); 
            String qryRun = bindVAR(qry, INVAR);
            JSONArray comcd = selectSVC(conn, qryRun);
            OUTVAR.put("comcd", comcd);

        } catch (Exception e) { 
            rtnCode = "ERR";
            rtnMsg = e.toString();				
        } finally {
            closeConn(conn);
        }  
    }
    
    //search:조회 이벤트처리(DB_Read)     
    else if("search".equals(func)) {
        Connection conn = null; 
        try {  
            OUTVAR.put("INVAR", INVAR); //for debug
            conn = getConn("LFN");  
            String qry = getQuery(pgmid, "retrieveBrcd"); 
            String qryRun = bindVAR(qry, INVAR);
            OUTVAR.put("qryRun", qryRun); //for debug
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
    else if("save".equals(func)) {
        Connection conn = null; 
        try {  
            conn = getConn("LFN");
            conn.setAutoCommit(false);
            boolean bError = false;
            
            JSONArray arrList = getArray(INVAR, "list");
            String qry = getQuery(pgmid, "mergeBrcd");
    
            int RunCnt = 0;
            String qryRun = "";
            
            for(int i = 0; i < arrList.size(); i++) {
                JSONObject row = getRow(arrList, i);
                row.put("comcd", getVal(INVAR, "comcd"));
                row.put("br_lv", getVal(INVAR, "br_lv"));
                row.put("userid", USERID);
                
                qryRun += bindVAR(qry,row) + "\n";
                
                RunCnt++;
                
                if(RunCnt == 10) {
                    JSONObject rst = executeSVC(conn, qryRun);
                    
                    RunCnt = 0;
                    qryRun = "";
                    
                    if(!"OK".equals(getVal(rst, "rtnCd"))) {
                        bError = true;
                        rtnCode = getVal(rst, "rtnCd");
                        rtnMsg  = getVal(rst, "rtnMsg");
                        break;
                    }
                }
            }
            
            if(RunCnt > 0) {
                JSONObject rst = executeSVC(conn, qryRun);
                
                if(!"OK".equals(getVal(rst, "rtnCd"))) {
                    bError = true;
                    rtnCode = getVal(rst, "rtnCd");
                    rtnMsg  = getVal(rst, "rtnMsg");
                }
            }
            OUTVAR.put("qryRun",qryRun);
            if(bError) {
                conn.rollback();
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
    
    //delete: 저장 이벤트처리(DB_Write) - 데이터 정비기간동안 삭제기능 허용
    else if("delete".equals(func)) {
        Connection conn = null; 
        try {  
            conn = getConn("LFN");
            conn.setAutoCommit(false);
            boolean bError = false;
            
            JSONArray arrList = getArray(INVAR, "list");
            String qry = getQuery(pgmid, "deleteBrcd");
    
            int RunCnt = 0;
            String qryRun = "";
            
            for(int i = 0; i < arrList.size(); i++) {
                JSONObject row = getRow(arrList, i);
                row.put("comcd", getVal(INVAR, "comcd"));
                row.put("br_lv", getVal(INVAR, "br_lv"));
                row.put("userid", USERID);
                
                qryRun += bindVAR(qry,row) + "\n";
                
                RunCnt++;
                
                if(RunCnt == 10) {
                    JSONObject rst = executeSVC(conn, qryRun);
                    
                    RunCnt = 0;
                    qryRun = "";
                    
                    if(!"OK".equals(getVal(rst, "rtnCd"))) {
                        bError = true;
                        rtnCode = getVal(rst, "rtnCd");
                        rtnMsg  = getVal(rst, "rtnMsg");
                        break;
                    }
                }
            }
            
            if(RunCnt > 0) {
                JSONObject rst = executeSVC(conn, qryRun);
                
                if(!"OK".equals(getVal(rst, "rtnCd"))) {
                    bError = true;
                    rtnCode = getVal(rst, "rtnCd");
                    rtnMsg  = getVal(rst, "rtnMsg");
                }
            }
            
            if(bError) {
                conn.rollback();
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
    
    //search:공급사 코드 조회(DB_Read)
    else if("searchMap".equals(func)) {
        Connection conn = null;
        
        try {
            conn = getConn("LFN");
            
            String qry = getQuery(pgmid, "searchMap");
            
            String qryRun = bindVAR(qry, INVAR);
            
            JSONArray map = selectSVC(conn, qryRun);
            
            OUTVAR.put("map", map);
            
        } catch(Exception e) {
            rtnCode = "ERR";
            rtnMsg  = e.toString();
            
        } finally {
            closeConn(conn);
        }
    }
    
    else if("imgSearch".equals(func)) {
        Connection conn = null;
        
        try {
            conn = getConn("LFN");
            
            String qry = getQuery(pgmid, "imgSearch");
            
            String qryRun = bindVAR(qry, INVAR);
            
            JSONArray list = selectSVC(conn, qryRun);
            
            OUTVAR.put("list", list);
            
        } catch(Exception e) {
            rtnCode = "ERR";
            rtnMsg  = e.toString();
            
        } finally {
            closeConn(conn);
        }
    }
    else if("imgDelete".equals(func)) {
        Connection conn = null;
        
        try {
            conn = getConn("LFN"); 
            conn.setAutoCommit(false);
            String qry = getQuery(pgmid, "imgDelete"); 
            String qryRun = bindVAR(qry,INVAR);
            OUTVAR.put("qryRun",qryRun);
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
    //save:공급사 코드 저장(DB_Write)
    else if("saveMap".equals(func)) {
        Connection conn = null;
        
        try {
            conn = getConn("LFN");
            conn.setAutoCommit(false);
            
            String qry = getQuery(pgmid, "saveMap");
            
            String qryRun = "";
        
            JSONArray map = getArray(INVAR, "map");
            
            for(int i = 0; i < map.size(); i++) {
                JSONObject row = getRow(map, i);
                
                row.put("grpcd", getVal(INVAR, "grpcd"));
                row.put("keycd", getVal(INVAR, "brcd"));
                row.put("nm", getVal(INVAR, "br_nm"));
                row.put("usid", USERID);
                
                if("D".equals(getVal(row, "crud"))) {
                    row.put("cd_stat", "N");
                } else {
                    row.put("cd_stat", "Y");
                }
                
                row.put("sort_seq", getVal(INVAR, "sort_seq"));
            
                qryRun += bindVAR(qry, row) + "\n";

            }
            OUTVAR.put("qry",qryRun);
            
            JSONObject rst = executeSVC(conn, qryRun);

            if(!"OK".equals(getVal(rst, "rtnCd"))) {
                conn.rollback();
                rtnCode = getVal(rst, "rtnCd");
                rtnMsg  = getVal(rst, "rtnMsg");
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
    else if ("checkStcl".equals(func)) {
    Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅
        String qry = getQuery(pgmid, "checkStcl");
        qry = bindVAR(qry, INVAR);
        JSONArray chkValid = selectSVC(conn, qry);
        OUTVAR.put("chkValid", chkValid);
    } catch(Exception e) {
        rtnCode = "ERR";
        rtnMsg  = e.toString();
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
