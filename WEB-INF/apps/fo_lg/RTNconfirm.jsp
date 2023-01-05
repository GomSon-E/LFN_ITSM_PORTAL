<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_lg";
String pgmid   = "RTNconfirm"; 
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

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}

//searchMst : 선택된 물류문서 조회
if("searchMst".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qryMst = getQuery(pgmid, "qryMst"); 
        String qryBox = getQuery(pgmid, "qryBox");  
        
        qryMst = bindVAR(qryMst,INVAR); 
        JSONArray mst = selectSVC(conn, qryMst);
        OUTVAR.put("mst",mst); 
        
        qryBox = bindVAR(qryBox,INVAR); 
        JSONArray boxlist = selectSVC(conn, qryBox);
        OUTVAR.put("det",boxlist);  
        
    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
} 

/*
//saveDet:입고등록 이벤트처리(DB_Write)
if("saveQty".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID); 
        
        conn = getConn("LFN");
        conn.setAutoCommit(false); 
        
        String qryupdateMst = getQuery(pgmid, "updateMst"); 
        String qrysaveDet = getQuery(pgmid, "saveDet"); 
        
        String qryRun = "";  
        qryRun = bindVAR(qryupdateMst,INVAR);

        JSONObject rst = executeSVC(conn, qryRun);  
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else { 
            qryRun = "";         
            JSONArray arrList = getArray(INVAR,"det");
            for(int i = 0; i < arrList.size(); i++) {
                JSONObject row = getRow(arrList,i); 
                row.put("comcd",ORGCD);
                row.put("usid",USERID);
                row.put("lg_ord_no",getVal(INVAR,"lg_ord_no"));
            
                qryRun += bindVAR(qrysaveDet,row) + "\n";
            }
            rst = executeSVC(conn, qryRun);  
            if(!"OK".equals(getVal(rst,"rtnCd"))) {
                conn.rollback();
                rtnCode = getVal(rst,"rtnCd"); 
                rtnMsg  = getVal(rst,"rtnMsg"); 
            } else { 
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
*/



/*
//save:입고확정 이벤트처리(DB_Write)
if("save".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID); 
        
        conn = getConn("LFN");
        conn.setAutoCommit(false); 
        
        // det우선 저장
        String qrysaveDet = getQuery(pgmid, "saveDet");  
        String qryRun = "";  
        JSONArray arrList = getArray(INVAR,"det");
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i);  
            row.put("comcd",ORGCD);
            row.put("usid",USERID);
            row.put("lg_ord_no",getVal(INVAR,"lg_ord_no"));
            qryRun += bindVAR(qrysaveDet,row) + "\n";
        }
        JSONObject rst = executeSVC(conn, qryRun);  
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else { 
            String qrysaveMst = getQuery(pgmid, "saveMst"); 
            qryRun = bindVAR(qrysaveMst,INVAR);  
            rst = executeSVC(conn, qryRun);  
            if(!"OK".equals(getVal(rst,"rtnCd"))) {
                conn.rollback();
                rtnCode = getVal(rst,"rtnCd"); 
                rtnMsg  = getVal(rst,"rtnMsg"); 
            } else { 
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
*/


/*100개씩 끊어 저장 로직 추가*/
//saveDet:입고등록 이벤트처리(DB_Write)
if("saveQty".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID); 
        
        conn = getConn("LFN");
        conn.setAutoCommit(false); 
        
        String qryupdateMst = getQuery(pgmid, "updateMst"); 
        String qrysaveDet = getQuery(pgmid, "saveDet"); 
        
        String qryRun = "";  
        qryRun = bindVAR(qryupdateMst,INVAR);

        JSONObject rst = executeSVC(conn, qryRun);  
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else { 
        /*
            qryRun = "";         
            JSONArray arrList = getArray(INVAR,"det");
            for(int i = 0; i < arrList.size(); i++) {
                JSONObject row = getRow(arrList,i);  
                row.put("comcd",ORGCD);
                row.put("usid",USERID);
                row.put("lg_ord_no",getVal(INVAR,"lg_ord_no"));
                qryRun += bindVAR(qrysaveDet,row) + "\n";
            }
            rst = executeSVC(conn, qryRun);  
            if(!"OK".equals(getVal(rst,"rtnCd"))) {
                conn.rollback();
                rtnCode = getVal(rst,"rtnCd"); 
                rtnMsg  = getVal(rst,"rtnMsg"); 
            } else { 
                conn.commit();
            } */
            
            //String lg_ord_no = getVal(rst,"rtnMsg"); 
            int txCnt = 0;  int oneTx = 50;
            
            JSONArray arrList = getArray(INVAR,"det");
            String qryRunD = "";
            for(int i = 0; i < arrList.size(); i++) {
                JSONObject row = getRow(arrList,i); 
                    row.put("comcd",ORGCD); 
                    row.put("usid",USERID);
                    row.put("lg_ord_no",getVal(INVAR,"lg_ord_no"));

                    String qryDetRun = bindVAR(qrysaveDet,row);
                OUTVAR.put("qryDetRun#"+i,qryDetRun);
                    qryRunD += qryDetRun + "\n"; 
                
                if(txCnt > oneTx) { 
                    rst = executeSVC(conn, qryRunD);
                    qryRunD="";
                    if(!"OK".equals(getVal(rst,"rtnCd"))) break;
                    txCnt = 0;
                } else {
                    txCnt++;
                }
            } 
            if(!"".equals(qryRunD)) rst = executeSVC(conn, qryRunD);  
            
            if(!"OK".equals(getVal(rst,"rtnCd"))) {
                conn.rollback();
                rtnCode = getVal(rst,"rtnCd"); 
                rtnMsg  = getVal(rst,"rtnMsg"); 
                } else {
                    //OUTVAR.put("lg_ord_no",lg_ord_no);
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

//cfm:입고확정 이벤트처리(DB_Write)
if("cfm".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
    
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qryCfm = getQuery(pgmid, "saveMst");
        qryCfm = bindVAR(qryCfm,INVAR);
        OUTVAR.put("qryCfm",qryCfm);
        JSONObject rst = executeSVC(conn, qryCfm);  
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else { 
            //OUTVAR.put("lg_ord_no",getVal(INVAR,"lg_ord_no"));
            conn.commit(); 
        }
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}



if("updateMst".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID); 
        
        conn = getConn("LFN");
        conn.setAutoCommit(false); 
        
        /* det우선 저장 */
        String qrysave = getQuery(pgmid, "updateMst");  
        String qryRun = bindVAR(qrysave,INVAR);
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




//rollbackMst:차이 수량 수불 조정
if("rollbackMst".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
                
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID); 
        INVAR.put("whcd",getVal(INVAR,"whcd"));
        OUTVAR.put("INVAR",INVAR); //for debug
        
        String qry = getQuery(pgmid, "rollbackMst"); 
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

//searchMixpack : (선택된 물류지시번호의) 패킹들 중 브/연/시/품목 섞여있는 패킹(박스) 조회
if("searchMixpack".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "searchMixpack"); 

        qry = bindVAR(qry,INVAR); 
        JSONArray mixpack = selectSVC(conn, qry);
        OUTVAR.put("mixpack",mixpack); 
        
    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}
//splitPack
if("splitPack".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID); 
        
        conn = getConn("LFN");
        conn.setAutoCommit(false); 
        
        /* det우선 저장 */
        String qry = getQuery(pgmid, "splitMixpack");  
        String qryRun = "";  
        JSONArray arrList = getArray(INVAR,"mixpack");
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i);  
            row.put("comcd",ORGCD);
            row.put("usid",USERID);
            row.put("lg_ord_no",getVal(arrList, 0, "lg_ord_no"));
            qryRun += bindVAR(qry,row) + "\n";
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

//print: 선택된 출고전표의 패킹라벨 발행
if("print".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        
        String qryDet = getQuery(pgmid, "qryprintGoods"); 
        
        JSONArray boxlist = getArray(INVAR,"list");
        JSONObject arlist = new JSONObject();
        for(int i = 0; i<boxlist.size(); i++){
        
            JSONObject row = getRow(boxlist,i);
            
            row.put("comcd",ORGCD); 
            //row.put("dist_no", getVal(INVAR,"dist_no"));
		    row.put("lg_ord_no", getVal(INVAR, "lg_ord_no"));
		          
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