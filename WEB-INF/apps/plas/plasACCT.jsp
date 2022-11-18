<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "plas";
String pgmid   = "plasACCT"; 
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
        String qry = getQuery(pgmid, "qrySearch"); 
        String qryRun = bindVAR(qry,INVAR); 
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray list = selectSVC(conn, qryRun);
        OUTVAR.put("list",list);  
        
        qry = getQuery(pgmid, "qrySearch2"); 
        qryRun = bindVAR(qry,INVAR); 
        OUTVAR.put("qryRun2",qryRun); //for debug
        JSONArray list2 = selectSVC(conn, qryRun);
        OUTVAR.put("list2",list2); 

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
} 

if("searchDetail".equals(func)) {
    Connection conn = null; 
    try {  
        
        OUTVAR.put("INVAR",INVAR); //for debug 
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "qryDetail"); 
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
        String qry = getQuery(pgmid, "qrySave");
        String qryRun = "";
        
        int txCnt = 0;  int oneTx = 50;
        JSONObject rst = new JSONObject();
        JSONArray arrList = getArray(INVAR,"list");
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            row.put("grpcd", "DZ_ACCT_INFO"); 
            row.put("co_cd", getVal(INVAR,"co_cd")); 
            row.put("comcd", ORGCD); 
            row.put("usid", USERID);
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
