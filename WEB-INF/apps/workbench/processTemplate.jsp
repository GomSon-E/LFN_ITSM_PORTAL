<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "workbench";
String pgmid   = "processTemplate"; 
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
            qry = bindVAR(qry,INVAR);
            JSONArray list = selectSVC(conn, qry);
            OUTVAR.put("list",list); 

        } catch (Exception e) { 
            rtnCode = "ERR";
            rtnMsg = e.toString();				
        } finally {
            closeConn(conn);
        }  
    }
    
//search:조회 이벤트처리(DB_Read)     
    if("searchMst".equals(func)) {
        Connection conn = null; 
        try {  
            OUTVAR.put("INVAR",INVAR); //for debug
            conn = getConn("LFN");    
            String qryMst = getQuery(pgmid, "searchMst");
            qryMst = bindVAR(qryMst,INVAR);
            OUTVAR.put("qryMst",qryMst);
            JSONArray mst = selectSVC(conn, qryMst);
            OUTVAR.put("mst",mst); 
            String qryNxt = getQuery(pgmid, "searchNxt");
            qryNxt = bindVAR(qryNxt,INVAR);
            OUTVAR.put("qryNxt",qryNxt);
            JSONArray nxt = selectSVC(conn, qryNxt);
            OUTVAR.put("nxt",nxt);  
            String qryDet = getQuery(pgmid, "searchDet");
            qryDet = bindVAR(qryDet,INVAR);
            OUTVAR.put("qryDet",qryDet); 
            JSONArray det = selectSVC(conn, qryDet);
            OUTVAR.put("det",det); 

        } catch (Exception e) { 
            rtnCode = "ERR";
            rtnMsg = e.toString();				
        } finally {
            closeConn(conn);
        }  
    }    
    //저장 
    if("save".equals(func)) {
        Connection conn = null; 
        try {  
            conn = getConn("LFN");
            conn.setAutoCommit(false);
            String qry = getQuery(pgmid, "merge");   
            String qryRun = "";
            JSONArray arrList = getArray(INVAR,"mst");
            for(int i = 0; i < arrList.size(); i++) {
                JSONObject row = getRow(arrList,i); 
                row.put("usid",USERID);
                qryRun += bindVAR(qry,row) + "\n";  
            } 
            OUTVAR.put("qry",qryRun);
            JSONObject rst = executeSVC(conn, qryRun);  
            if(!"OK".equals(getVal(rst,"rtnCd"))) {
                conn.rollback();
                rtnCode = getVal(rst,"rtnCd"); 
                rtnMsg  = getVal(rst,"rtnMsg"); 
            } else { 
                /* CLOB컨텐츠는 따로 넣어줌 */
                boolean bRtn = true;
                for(int i = 0; i < arrList.size(); i++) {
                    JSONObject row = getRow(arrList,i);
				    rtnMsg = executeUpdateClob(conn, 
					 	                     "T_PROC_MST",
						                     "content",
						                     getVal(row,"content"),
						                     "WHERE proc_mst_id ='"+getVal(row,"proc_mst_id")+"' ");
    				if(!"OK".equals(rtnMsg)) {
    					rtnCode = "-8888"; 
    					bRtn = false;
    					break;
    				}
    			}
    			if(bRtn) conn.commit();
    			else conn.rollback();
            } 
        } catch (Exception e) {
            rtnCode = "ERR";
            rtnMsg = e.toString();
        } finally {
            closeConn(conn);
        }
    }  
    //삭제 
    if("delete".equals(func)) {
        Connection conn = null; 
        try {  
            conn = getConn("LFN");
            conn.setAutoCommit(false);
            String qry = getQuery(pgmid, "delete");   
            String qryRun = "";
            JSONArray arrList = getArray(INVAR,"mst");
            for(int i = 0; i < arrList.size(); i++) {
                JSONObject row = getRow(arrList,i); 
                row.put("usid",USERID);
                qryRun += bindVAR(qry,row) + "\n"; 
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

/*********************************************************************************************/
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
