<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_sd";
String pgmid   = "registerRplan"; 
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
        String qry = getQuery(pgmid, "qrysearch"); 
        INVAR.put("comcd",ORGCD);
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


//searchOrd: 조회 이벤트처리(DB_Read)     
if("searchOrd".equals(func)) {
    Connection conn = null; 
    try {  
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "qrysearchMst"); 
        INVAR.put("comcd",ORGCD);
        //INVAR.put("comcd","LFN"); //임의로 데이터 넣음 나중에 수정
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray mst = selectSVC(conn, qryRun);
        OUTVAR.put("mst",mst); 
        
        String qryD = getQuery(pgmid, "qrysearchDet"); 
        String qryRunD = bindVAR(qryD,INVAR);
        OUTVAR.put("qryRunD",qryRunD); //for debug
        JSONArray det = selectSVC(conn, qryRunD);
        OUTVAR.put("det",det);         

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}

//save:대상확정 이벤트처리(DB_Write)
if("save".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        
        String qryMst = getQuery(pgmid, "qrysaveMst");
        String qryRun = "";

        qryRun = bindVAR(qryMst,INVAR);  
        OUTVAR.put("qryMst",qryRun); 
        JSONObject rst = executeSVC(conn, qryRun);  
        
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else {  
            String gr_ord_no = getVal(rst,"rtnMsg"); 
            OUTVAR.put("gr_ord_no",gr_ord_no); 
            conn.commit(); 
        }

    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}

//save:대상확정 이벤트처리(DB_Write)
if("savedet".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        
        String qryDet = getQuery(pgmid, "qrysaveDet");
        String qryRun = "";
        String gr_ord_no = getVal(INVAR,"gr_ord_no"); 
            
        qryRun = "";
        JSONArray arrList = getArray(INVAR,"det");
        for(int i = 0; i < arrList.size(); i++) { 
            JSONObject row = getRow(arrList,i); 
            row.put("comcd",ORGCD); 
            row.put("usid",USERID);
            row.put("gr_ord_no",gr_ord_no); 
            row.put("whcd",getVal(INVAR,"whcd"));
            String qryDetRun = bindVAR(qryDet,row);
            qryRun += qryDetRun + "\n"; 
        }          
        JSONObject rst = executeSVC(conn, qryRun);  
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
            OUTVAR.put("qry",qryRun);
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

//cfm:확정 이벤트처리(DB_Write)
if("cfm".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        String qry = getQuery(pgmid, "qrycfm");
        qry = bindVAR(qry,INVAR);
        JSONObject rst = executeSVC(conn, qry);  
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

//subul:수불반영 
if("subul".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        String qry = getQuery(pgmid, "qrysubul");
        qry = bindVAR(qry,INVAR);
        JSONObject rst = executeSVC(conn, qry);  
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

//delete:확정 이벤트처리(DB_Write)
if("delete".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        String qry = getQuery(pgmid, "qrydelete");
        qry = bindVAR(qry,INVAR);
        JSONObject rst = executeSVC(conn, qry);  
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
