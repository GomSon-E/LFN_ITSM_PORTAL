<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "plas";
String pgmid   = "plasGRP"; 
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
        String DZ_ORG_TP = getVal(INVAR,"dz_org_tp");
        
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "qrySearch"); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("dz_org_tp",DZ_ORG_TP); //for debug
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

//sync:동기화 이벤트처리(DB_Write)
if("sync".equals(func)) {
    Connection conn = null; 
    Connection connDZ = null; 
    try {  
        conn = getConn("LFN");
        connDZ = getConn("DOUZONE");
        conn.setAutoCommit(false);
        
        /* 가져와야 하는 테이블목록과 최근 싱크일자를 가져온다. */
        String qryTP  = "SELECT cd dz_org_tp, TO_CHAR(upd_dt,'yyyy-mm-dd') sync_dt FROM T_CODE WHERE grpcd = 'DZ_ORG_TP' AND cd_stat = 'Y'";
        String qry    = "";
        String qryUpd = getQuery(pgmid, "qrySave");
        
        JSONArray arrDZ_ORG_TP = selectSVC(conn, qryTP);
        
        for(int k = 0; k < arrDZ_ORG_TP.size(); k++) {  
            String DZ_ORG_TP = getVal(arrDZ_ORG_TP,k,"dz_org_tp");
            INVAR.put("dz_org_tp",DZ_ORG_TP);
            INVAR.put("sync_dt",getVal(arrDZ_ORG_TP,k,"sync_dt"));
            
            /* 테이블별 조회쿼리를 가져와서 */ 
            qry = getQuery(pgmid, "qrySearch"+DZ_ORG_TP);
            qry = bindVAR(qry,INVAR);
            OUTVAR.put("qry",qry);
            JSONArray arrList = selectSVC(connDZ, qry);
            String qryRun = "";
            int txCnt = 0;  int oneTx = 50;
            JSONObject rst = new JSONObject();  
            rst.put("rtnCd","OK"); //arrList.size()==0 일때 오류발생하므로 rst초기화처리 
            
            for(int i = 0; i < arrList.size(); i++) {
                JSONObject row = getRow(arrList,i); 
                row.put("usid",USERID);
                qryRun += bindVAR(qryUpd,row) + "\n";
                
                if(txCnt > oneTx) { 
                    /* 업데이트 해준다. */
                    rst = executeSVC(conn, qryRun);  
                    qryRun="";
                    if(!"OK".equals(getVal(rst,"rtnCd"))) break;
                    txCnt = 0;
                } else {
                    txCnt++;
                }
            } 
            if(!"".equals(qryRun)) rst = executeSVC(conn, qryRun);     
            if(!"OK".equals(getVal(rst,"rtnCd"))) {
                conn.rollback(); 
                OUTVAR.put("qryRun",qryRun);
                rtnCode = getVal(rst,"rtnCd"); 
                rtnMsg  = getVal(rst,"rtnMsg"); 
                break;
            } else { 
                String updTP  = "UPDATE T_CODE SET upd_dt = SYSDATE WHERE grpcd='DZ_ORG_TP' AND cd='"+DZ_ORG_TP+"';"; 
                rst = executeSVC(conn, updTP);   
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


//save:저장 이벤트처리(DB_Write)
if("save".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "qrySave");
        String qryRun = "";
        
        int txCnt = 0;  int oneTx = 50;
        JSONObject rst = new JSONObject();
        JSONArray arrList = getArray(INVAR,"list");
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            row.put("dz_org_tp", getVal(INVAR,"dz_org_tp")); 
            row.put("co_cd", getVal(INVAR,"co_cd")); 
            row.put("comcd",ORGCD); 
            row.put("usid",USERID);
            qryRun += bindVAR(qry,row) + "\n";  //매장정보 저장 
            
            if(txCnt > oneTx) { 
                rst = executeSVC(conn, qryRun);   
                qryRun="";
                if(!"OK".equals(getVal(rst,"rtnCd"))) break;
                txCnt = 0;
            } else {
                txCnt++;
            }
        } 
        if(!"".equals(qryRun)) rst = executeSVC(conn, qryRun);          
        /******************************************/
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



//saveDeptChief:저장 이벤트처리(DB_Write)
if("saveDeptChief".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "qrySave");
        String qryRun = "";
        
        int txCnt = 0;  int oneTx = 50;
        JSONObject rst = new JSONObject();
        JSONArray arrList = getArray(INVAR,"list");
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            row.put("dz_org_tp", getVal(INVAR,"dz_org_tp")); 
            row.put("co_cd", getVal(INVAR,"co_cd")); 
            row.put("comcd",ORGCD); 
            row.put("usid",USERID);
            qryRun += bindVAR(qry,row) + "\n";  //매장정보 저장 
            
            if(txCnt > oneTx) { 
                rst = executeSVC(conn, qryRun);   
                qryRun="";
                if(!"OK".equals(getVal(rst,"rtnCd"))) break;
                txCnt = 0;
            } else {
                txCnt++;
            }
        } 
        if(!"".equals(qryRun)) rst = executeSVC(conn, qryRun);          
        /******************************************/
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


//searchDZ: 더존정보조회
if("searchDZ".equals(func)) {
    Connection conn = null; 
    try {  
        
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("DOUZONE");  //getConn("DOUZONE");  
        String qry = getQuery(pgmid, "qrySearchDZ"); 
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

//saveDZ
if("saveDZ".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "qrySaveDZ");
        String qryRun = "";
        
        JSONObject rst = new JSONObject();
        JSONArray arrList = getArray(INVAR,"list");
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            //row.put("dz_org_tp", getVal(INVAR,"dz_org_tp")); 
            row.put("co_cd", getVal(INVAR,"co_cd")); 
            row.put("comcd",ORGCD); 
            row.put("usid",USERID);
            qryRun += bindVAR(qry,row) + "\n";  
        } 
        if(!"".equals(qryRun)) rst = executeSVC(conn, qryRun);    
        
        /******************************************/
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
        OUTVAR.put("qryRun",qryRun);
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
