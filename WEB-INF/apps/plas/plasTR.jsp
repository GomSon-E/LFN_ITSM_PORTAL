<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "plas";
String pgmid   = "plasTR"; 
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
            qryRun += bindVAR(qry,row) + "\n";  //매장정보 저장 
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
