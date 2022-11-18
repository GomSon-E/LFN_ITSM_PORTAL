<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_lg";
String pgmid   = "GIorder"; 
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
        INVAR.put("comcd",ORGCD);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  

        String qry = getQuery(pgmid, "qrysearch"); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray list = selectSVC(conn, qryRun);
        OUTVAR.put("list",list); 

        String qryList = getQuery(pgmid, "qrysearchList"); 
        qryRun = bindVAR(qryList,INVAR);
        JSONArray listMst = selectSVC(conn, qryRun);
        OUTVAR.put("listMst",listMst); 



    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}

//save:접수마감 이벤트처리(DB_Read)     
if("save".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        OUTVAR.put("INVAR",INVAR); //for debug
        
        conn = getConn("LFN"); 
        conn.setAutoCommit(false); 
        
        String qrySave = getQuery(pgmid, "qrySave");  
        String qryRun = "";
    
        JSONArray arrList = getArray(INVAR,"list"); //dist_no, stcd
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            row.put("usid",USERID);
            row.put("comcd",ORGCD);
            row.put("from_whcd",getVal(INVAR,"whcd"));
            qryRun += bindVAR(qrySave,row) + "\n";
        } 
        OUTVAR.put("qry",qryRun);  
        JSONObject rst = executeSVC(conn, qryRun);  
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else { 
            OUTVAR.put("dist_no", getVal(rst,"rtnMsg"));
            conn.commit();
        }

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}

//searchMst: 헤더, 디테일 조회
if("searchMst".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  

        String qryMst = getQuery(pgmid, "qryMst"); 
        qryMst = bindVAR(qryMst,INVAR);
        JSONArray mst = selectSVC(conn, qryMst);
        OUTVAR.put("mst",mst); 

        String qryDet = getQuery(pgmid, "qryDet"); 
        qryDet = bindVAR(qryDet,INVAR);
        JSONArray det = selectSVC(conn, qryDet);
        OUTVAR.put("det",det); 

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}


//cancel:접수취소 이벤트처리(DB_Read)     
if("cancel".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        OUTVAR.put("INVAR",INVAR); //for debug
        
        conn = getConn("LFN"); 
        conn.setAutoCommit(false); 
        
        String qrySave = getQuery(pgmid, "qryCancel");  
        String qryRun = bindVAR(qrySave,INVAR); 
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

//print2 : 초도출하 패킹라벨 발행
if("print2".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "qryprintList"); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray list = selectSVC(conn, qryRun);
        OUTVAR.put("list",list);
        
        String qryDet = getQuery(pgmid, "qryprintGoods");
        JSONArray boxlist = getArray(OUTVAR,"list");
        JSONObject arlist = new JSONObject();
        
        for(int i = 0; i<boxlist.size(); i++){
            JSONObject row = getRow(boxlist,i);
            
            row.put("comcd",ORGCD); 
            row.put("dist_no", getVal(INVAR,"dist_no"));

            String qryDetRun = bindVAR(qryDet,row);
            //OUTVAR.put("qryDetRun#"+i,qryDetRun); 
            JSONArray goodslist = selectSVC(conn, qryDetRun);
             
            arlist.put("goodslist"+i,goodslist);
            OUTVAR.put("arlist",arlist);
        }
        
    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}

////////
//print3 : 초도출하 패킹라벨 발행 (수정전)
if("print3".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qryP2 = getQuery(pgmid, "qryprint2"); 
        String qryRunP2 = bindVAR(qryP2,INVAR);
        OUTVAR.put("qryRunP2",qryRunP2); //for debug
        JSONArray prnt2 = selectSVC(conn, qryRunP2);
        OUTVAR.put("prnt2",prnt2);
        
    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}


//print : 피킹지시서 발행
if("print".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qryP = getQuery(pgmid, "qryprint"); 
        String qryRunP = bindVAR(qryP,INVAR);
        OUTVAR.put("qryRunP",qryRunP); //for debug
        JSONArray prnt = selectSVC(conn, qryRunP);
        OUTVAR.put("prnt",prnt);
        
    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}

//printHanger : 행거배분표 발행
if("printHanger".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qryP = getQuery(pgmid, "qryprintHanger"); 
        String qryRunP = bindVAR(qryP,INVAR);
        OUTVAR.put("qryRunP",qryRunP); //for debug
        JSONArray prnt = selectSVC(conn, qryRunP);
        OUTVAR.put("prnt",prnt);
        
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
