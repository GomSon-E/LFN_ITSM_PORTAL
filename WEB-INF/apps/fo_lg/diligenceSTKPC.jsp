<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_lg";
String pgmid   = "diligenceSTKPC"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/

//passCfm
if("passCfm".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        String qry = getQuery(pgmid, "qrypassCfm");
        String qryRun = "";
        JSONArray arrList = getArray(INVAR,"list");
        
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i);
            row.put("comcd",ORGCD); 
            row.put("usid",USERID);
            row.put("lg_ord_no",getVal(INVAR, "lg_ord_no"));
            String qryRunP = bindVAR(qry,row);
            OUTVAR.put("qryRunP#"+i,qryRunP);    
            qryRun += qryRunP + "\n"; 
        }
        
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


//search:조회 이벤트처리(DB_Read)     
if("searchMst".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "qrysearchMst"); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray mst = selectSVC(conn, qryRun);
        OUTVAR.put("mst",mst); 

        String qryList = "";
        if(mst.size() == 0 || "D".equals(getVal(mst,0,"cd_stat")) ) {
            qryList = getQuery(pgmid, "qrysearchListD");  
        } else {
            qryList = getQuery(pgmid, "qrysearchList"); 
        }
        
        qryList = bindVAR(qryList,INVAR);
        OUTVAR.put("qryList",qryList); //for debug
        JSONArray list = selectSVC(conn, qryList);
        OUTVAR.put("list",list); 
        
        String qrysearchBoxKeycd = getQuery(pgmid, "qrysearchBoxKeycd");
        qrysearchBoxKeycd = bindVAR(qrysearchBoxKeycd,INVAR);
        JSONArray box_keycd_list = selectSVC(conn, qrysearchBoxKeycd);
        OUTVAR.put("box_keycd_list",box_keycd_list); 
        

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}

 
if("searchDet".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "qrysearchMst"); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray mst = selectSVC(conn, qryRun);
        OUTVAR.put("mst",mst); 

        String qryDet = "";
        if(mst.size() == 0 || "D".equals(getVal(mst,0,"cd_stat")) ) {
            qryDet = getQuery(pgmid, "qrysearchDetD");  
        } else {
            qryDet = getQuery(pgmid, "qrysearchDet"); 
        }
        
        String qryRunDet = bindVAR(qryDet,INVAR);
        OUTVAR.put("qryRunDet",qryRunDet); //for debug
        JSONArray det = selectSVC(conn, qryRunDet);
        OUTVAR.put("det",det); 

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}

//박스키코드추가
if("addBoxKeycd".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        String qryMst = getQuery(pgmid, "qryInsertKeycd");
        
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        qryMst = bindVAR(qryMst,INVAR);
        JSONObject rst = executeSVC(conn, qryMst);  
        
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


//박스키코드추가
if("delBoxKeycd".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        String qryMst = getQuery(pgmid, "qryDeleteKeycd");
        
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        qryMst = bindVAR(qryMst,INVAR);
        JSONObject rst = executeSVC(conn, qryMst);  
        
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


 
if("searchPackDet".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");   

        String qryDet =getQuery(pgmid, "qrysearchPackDet");   
        String qryRunDet = bindVAR(qryDet,INVAR);
        OUTVAR.put("qryRunDet",qryRunDet); //for debug
        JSONArray packdet = selectSVC(conn, qryRunDet);
        OUTVAR.put("packdet",packdet); 

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
} 


//save:임시저장(수불반영) 이벤트처리(DB_Write)
if("save".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "qrySave");
        String qryRun = bindVAR(qry,INVAR); 
        OUTVAR.put("qrySave",qryRun);
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

//cfm:확정(수불반영) 이벤트처리(DB_Write)
if("cfm".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "qryCfm");
        String qryRun = bindVAR(qry,INVAR); 
        OUTVAR.put("qryCfm",qryRun);
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

//cancel:취소 이벤트처리(DB_Write)
if("cancel".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "qrycancel");
        String qryRun = bindVAR(qry,INVAR); 
        OUTVAR.put("qrycancel",qryRun);
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


//delete:삭제 이벤트처리(DB_Write)
if("delete".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "qrydelete");
        String qryRun = bindVAR(qry,INVAR); 
        OUTVAR.put("qrycancel",qryRun);
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

//print : 발행     
if("print".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        
        String qryM = getQuery(pgmid, "printMst"); 
        String qryRunM = bindVAR(qryM,INVAR);
        OUTVAR.put("qryRunM",qryRunM); //for debug
        JSONArray mst = selectSVC(conn, qryRunM);
        OUTVAR.put("mst",mst); 
        
        String qry = getQuery(pgmid, "printSummary"); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray list = selectSVC(conn, qryRun);
        OUTVAR.put("list",list); 
        
        String qryD = "";
        if((getVal(INVAR,"goods_yn")).equals("Y")){
            qryD = getQuery(pgmid, "printDetail"); //스타일코드, 상품코드
        }else{
            qryD = getQuery(pgmid, "printDetailStcd"); //스타일코드
        }
        //String qryD = getQuery(pgmid, "printDetail");
        //String qryD = getQuery(pgmid, "printDetailStcd");
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
