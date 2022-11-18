<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_lg";
String pgmid   = "MVregister"; 
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
        
        String lg_ord_no = getVal(INVAR, "lg_ord_no");
        String qry = null;
        if(lg_ord_no.isEmpty()) {
            qry = getQuery(pgmid, "qrysearch"); 
        } else {
            qry = getQuery(pgmid, "qrysearchord"); 
        }
        
        //String qry = getQuery(pgmid, "qrysearch");
        INVAR.put("comcd",ORGCD);
        //INVAR.put("whcd",whcd);
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
if("check".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN"); 
        
        INVAR.put("comcd",ORGCD);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "qrysearchgoods"); 
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
        String qryDet = getQuery(pgmid, "qrysaveDet");
        String qryRun = "";
        
        
        qryRun = bindVAR(qryMst,INVAR);  
        OUTVAR.put("qryMst",qryRun);
        JSONObject rst = executeSVC(conn, qryRun);  
        
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else {  
            String lg_ord_no = getVal(rst,"rtnMsg"); 
            
            qryRun = "";
            JSONArray arrList = getArray(INVAR,"det");
            for(int i = 0; i < arrList.size(); i++) {
            
                JSONObject row = getRow(arrList,i); 
                row.put("comcd",ORGCD); 
                row.put("usid",USERID);
                row.put("lg_ord_no",lg_ord_no);
                row.put("lg_ord_seq",(i+1));   
                
                row.put("from_whcd", getVal(INVAR,"from_whcd"));
                row.put("to_whcd", getVal(INVAR,"to_whcd"));
                row.put("lg_tp", getVal(INVAR,"lg_tp")); 
                String qryDetRun = bindVAR(qryDet,row);
                OUTVAR.put("qryDetRun#"+i,qryDetRun);    
                qryRun += qryDetRun + "\n"; 
            }          
            rst = executeSVC(conn, qryRun);  
            if(!"OK".equals(getVal(rst,"rtnCd"))) {
                conn.rollback();
                rtnCode = getVal(rst,"rtnCd"); 
                rtnMsg  = getVal(rst,"rtnMsg"); 
            } else { 
                OUTVAR.put("lg_ord_no",lg_ord_no);
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


//save1:대상확정 이벤트처리(DB_Write)
if("save1".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        
        String qryMst = getQuery(pgmid, "qrysaveMst");
        String qryDet = getQuery(pgmid, "qrysaveDet");
        String qryRun = "";
        
        
        qryRun = bindVAR(qryMst,INVAR);  
        OUTVAR.put("qryMst",qryRun);
        JSONObject rst = executeSVC(conn, qryRun);  
        
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else {  
            String lg_ord_no = getVal(rst,"rtnMsg"); 
            
            qryRun = "";
            JSONArray arrList = getArray(INVAR,"det1");
            for(int i = 0; i < arrList.size(); i++) {
            
                JSONObject row = getRow(arrList,i); 
                row.put("comcd",ORGCD); 
                row.put("usid",USERID);
                row.put("lg_ord_no",lg_ord_no);
                row.put("lg_ord_seq",(i+1));   
                
                row.put("from_whcd", getVal(INVAR,"from_whcd"));
                row.put("to_whcd", getVal(INVAR,"to_whcd"));
                row.put("lg_tp", getVal(INVAR,"lg_tp")); 
                String qryDetRun = bindVAR(qryDet,row);
                OUTVAR.put("qryDetRun#"+i,qryDetRun);    
                qryRun += qryDetRun + "\n"; 
            }          
            rst = executeSVC(conn, qryRun);  
            if(!"OK".equals(getVal(rst,"rtnCd"))) {
                conn.rollback();
                rtnCode = getVal(rst,"rtnCd"); 
                rtnMsg  = getVal(rst,"rtnMsg"); 
            } else { 
                OUTVAR.put("lg_ord_no",lg_ord_no);
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

//print : 이동송장 발행
if("print".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qryP = getQuery(pgmid, "qryprint"); 
        String qryRunP = bindVAR(qryP,INVAR);
        OUTVAR.put("qryRunP",qryRunP); //for debug
        JSONArray prnt = selectSVC(conn, qryRunP);
        OUTVAR.put("prnt",prnt);
        
        String qry = getQuery(pgmid, "qryusrInfo"); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray usr = selectSVC(conn, qryRun);
        OUTVAR.put("usr",usr); 

        String qryTo = getQuery(pgmid, "qryusrInfoTo"); 
        String qryRunTo = bindVAR(qryTo,INVAR);
        OUTVAR.put("qryRunTo",qryRunTo); //for debug
        JSONArray usrto = selectSVC(conn, qryRunTo);
        OUTVAR.put("usrto",usrto);

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}

//printCfmAll : 출고송장(묶음발송건) 발행
if("printCfmAll".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        
        JSONArray list = getArray(INVAR,"list");
        String lg_ord_nos = "";
        for(int i=0; i < list.size(); i++) {
            lg_ord_nos += "'"+getVal(list, i, "lg_ord_no")+"',";
        }
        lg_ord_nos += "''";
        INVAR.put("lg_ord_nos",lg_ord_nos);
        
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qryPC = getQuery(pgmid, "qryprintCfmAll"); 
        String qryRunPC = bindVAR(qryPC,INVAR);
        OUTVAR.put("qryRunPC",qryRunPC); //for debug
        JSONArray prtCfm = selectSVC(conn, qryRunPC);
        OUTVAR.put("prtCfm",prtCfm);
        
        String qry = getQuery(pgmid, "qryusrInfo"); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray usr = selectSVC(conn, qryRun);
        OUTVAR.put("usr",usr); 

        String qryTo = getQuery(pgmid, "qryusrInfoTo"); 
        String qryRunTo = bindVAR(qryTo,INVAR);
        OUTVAR.put("qryRunTo",qryRunTo); //for debug
        JSONArray usrto = selectSVC(conn, qryRunTo);
        OUTVAR.put("usrto",usrto);

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}

//print4 : 초도출하 패킹라벨 발행
if("print4".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qryP4 = getQuery(pgmid, "qryprint4"); 
        String qryRunP4 = bindVAR(qryP4,INVAR);
        OUTVAR.put("qryRunP4",qryRunP4); //for debug
        JSONArray prnt4 = selectSVC(conn, qryRunP4);
        OUTVAR.put("prnt4",prnt4);
        
    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}


//reject:지시불가/예정삭제 이벤트처리(DB_Write)
if("reject".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
    
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "qryreject");
        String qryRun = bindVAR(qry,INVAR);
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

//cfm:임시저장 -> 발송완료
if("cfm".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
    
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        String qry2 = getQuery(pgmid,"qrysavegoods");
        String qryRun2 = bindVAR(qry2,INVAR);
        JSONObject rst2 = executeSVC(conn, qryRun2);
        OUTVAR.put("qryRun2",qryRun2);
        if(!"OK".equals(getVal(rst2,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst2,"rtnCd"); 
            rtnMsg  = getVal(rst2,"rtnMsg"); 
        }else{
            String qryMst = getQuery(pgmid, "qrysaveMst");
            String qryDet = getQuery(pgmid, "qrysaveDet");
            String qryRun = "";
            
            qryRun = bindVAR(qryMst,INVAR);  
            OUTVAR.put("qryMst",qryRun);
            JSONObject rst = executeSVC(conn, qryRun);  
            
            if(!"OK".equals(getVal(rst,"rtnCd"))) {
                conn.rollback();
                rtnCode = getVal(rst,"rtnCd"); 
                rtnMsg  = getVal(rst,"rtnMsg"); 
            } else {  
                String lg_ord_no = getVal(rst,"rtnMsg"); 
                
                qryRun = "";
                JSONArray arrList = getArray(INVAR,"det");
                for(int i = 0; i < arrList.size(); i++) {
                
                    JSONObject row = getRow(arrList,i); 
                    row.put("comcd",ORGCD); 
                    row.put("usid",USERID);
                    row.put("lg_ord_no",lg_ord_no);
                    row.put("lg_ord_seq",(i+1));   
                    
                    row.put("from_whcd", getVal(INVAR,"from_whcd"));
                    row.put("to_whcd", getVal(INVAR,"to_whcd"));
                    row.put("lg_tp", getVal(INVAR,"lg_tp")); 
                    String qryDetRun = bindVAR(qryDet,row);
                    OUTVAR.put("qryDetRun#"+i,qryDetRun);    
                    qryRun += qryDetRun + "\n"; 
                }          
                rst = executeSVC(conn, qryRun);  
                if(!"OK".equals(getVal(rst,"rtnCd"))) {
                    conn.rollback();
                    rtnCode = getVal(rst,"rtnCd"); 
                    rtnMsg  = getVal(rst,"rtnMsg"); 
                } else { 
                
                    String qryCfm = getQuery(pgmid, "qrycfm");
                    qryCfm = bindVAR(qryCfm,INVAR);
                    rst = executeSVC(conn, qryCfm);  
                    if(!"OK".equals(getVal(rst,"rtnCd"))) {
                        conn.rollback();
                        rtnCode = getVal(rst,"rtnCd"); 
                        rtnMsg  = getVal(rst,"rtnMsg"); 
                    } else { 
                        OUTVAR.put("lg_ord_no",lg_ord_no);
                        conn.commit(); 
                    }  
                } 
            } 
        }
        
        
        
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
} 




//cfm:임시저장 -> 발송완료
if("cfmAll".equals(func)) {

    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
    
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        String qry2 = getQuery(pgmid,"qrysavegoods");
        String qryRun2 = "";
        
        JSONArray arrList2 = getArray(INVAR,"list");
        
        for(int i = 0; i < arrList2.size(); i++) {
            JSONObject row = getRow(arrList2,i);
            row.put("comcd",ORGCD); 
            row.put("usid",USERID);
            //row.put("lg_ord_no",getVal(row,"lg_ord_no"));
            //row.put("lg_tp", getVal(INVAR,"lg_tp")); 
            String qryCfmRun2 = bindVAR(qry2,row);
            OUTVAR.put("qryCfmRun2#"+i,qryCfmRun2);    
            qryRun2 += qryCfmRun2 + "\n"; 
        }
            
        JSONObject rst2 = executeSVC(conn, qryRun2); 
        
        OUTVAR.put("qryRun2",qryRun2);
        if(!"OK".equals(getVal(rst2,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst2,"rtnCd"); 
            rtnMsg  = getVal(rst2,"rtnMsg"); 
        }else{
        
            String qryCfm = getQuery(pgmid, "qrycfm");
            String qryRun = "";
            JSONArray arrList = getArray(INVAR,"list");
            
            for(int i = 0; i < arrList.size(); i++) {
            
                JSONObject row = getRow(arrList,i);
                row.put("comcd",ORGCD); 
                row.put("usid",USERID);
                //row.put("lg_ord_no",getVal(row,"lg_ord_no"));
                //row.put("lg_tp", getVal(INVAR,"lg_tp")); 
                String qryCfmRun = bindVAR(qryCfm,row);
                OUTVAR.put("qryCfmRun#"+i,qryCfmRun);    
                qryRun += qryCfmRun + "\n"; 
            }
            
            JSONObject rst = executeSVC(conn, qryRun);  
            
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


if("printcnt".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "qryprintCnt"); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONObject rst = executeSVC(conn, qryRun);  

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}

if("searchprtcnt".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "qrysearchPrtcnt"); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray prtcnt = selectSVC(conn, qryRun);
        OUTVAR.put("prtcnt",prtcnt); 

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
