<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_pos";
String pgmid   = "RTregisterTest2"; 
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
        //INVAR.put("comcd","LFN"); //임의로 데이터 넣음 나중에 수정
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

//printReq : 본사지시이동요청서 발행
if("printReq".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "qryprintReq"); 

        JSONArray lgordlist = getArray(INVAR,"list");
        JSONObject prt = new JSONObject();
        for(int i = 0; i<lgordlist.size(); i++){
        
            JSONObject row = getRow(lgordlist,i);  //Distinct lg_ord_no
            row.put("comcd",ORGCD);  
		          
            String qryRun = bindVAR(qry,row);
            //OUTVAR.put("qryDetRun#"+i,qryDetRun); 
            JSONArray req = selectSVC(conn, qryRun);
             
            prt.put("req"+i,req);
            OUTVAR.put("prt",prt);
        }
    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}

//printReqMVO : 온라인,예약판매 요청서 발행
if("printReqMVO".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "qryprintReqMVO"); 
        
        JSONArray lgordlist = getArray(INVAR,"list");
        JSONObject prt = new JSONObject();
        for(int i = 0; i<lgordlist.size(); i++){
        
            JSONObject row = getRow(lgordlist,i);  //Distinct lg_ord_no
            row.put("comcd",ORGCD);  
		          
            String qryRun = bindVAR(qry,row);
            //OUTVAR.put("qryDetRun#"+i,qryDetRun); 
            JSONArray req = selectSVC(conn, qryRun);
             
            prt.put("req"+i,req);
            OUTVAR.put("prt",prt);
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
/*
//usrinfo : 이동송장 매장/창고 주소 및 담당자 연락처 _보내는매장/창고
if("usrinfo".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "qryusrInfo"); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray usr = selectSVC(conn, qryRun);
        OUTVAR.put("usr",usr); 
        
    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}*/
/*
//usrinfoTo : 이동송장 매장/창고 주소 및 담당자 연락처 _받는매장/창고
if("usrinfoTo".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "qryusrInfoTo"); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray usrto = selectSVC(conn, qryRun);
        OUTVAR.put("usrto",usrto); 

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}
*/

if("searchRt".equals(func)) {
    Connection conn = null; 
    try {  
        //INVAR.put("comcd",ORGCD);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "qrysearchRt"); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray rt = selectSVC(conn, qryRun);
        OUTVAR.put("rt",rt); 

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}

//save:대상확정 이벤트처리(DB_Write)
/*
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
*/


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


/************************************************************************/
if("save".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
    
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
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
            int txCnt = 0;  int oneTx = 50;
            /*
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
            */
            JSONArray arrList = getArray(INVAR,"det");
            String qryRunD = "";
            //JSONObject rst = new JSONObject();
            //rst.put("rtnCd","OK");
            for(int i = 0; i < arrList.size(); i++) {
                JSONObject row = getRow(arrList,i); 
                    row.put("comcd",ORGCD); 
                    row.put("usid",USERID);
                    row.put("lg_ord_no",lg_ord_no);
                    row.put("lg_ord_seq",getVal(row,"id")+1); 
                    
                    row.put("from_whcd", getVal(INVAR,"from_whcd"));
                    row.put("to_whcd", getVal(INVAR,"to_whcd"));
                    row.put("lg_tp", getVal(INVAR,"lg_tp")); 
                    String qryDetRun = bindVAR(qryDet,row);
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
                /*
                    String qryCfm = getQuery(pgmid, "qrycfm");
                    qryCfm = bindVAR(qryCfm,INVAR);
                OUTVAR.put("qryCfm",qryCfm);
                    rst = executeSVC(conn, qryCfm);  
                    if(!"OK".equals(getVal(rst,"rtnCd"))) {
                        conn.rollback();
                        rtnCode = getVal(rst,"rtnCd"); 
                        rtnMsg  = getVal(rst,"rtnMsg"); 
                    } else { 
                        OUTVAR.put("lg_ord_no",lg_ord_no);
                        conn.commit(); 
                    } */
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

//saveMVO
if("saveMVO".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
    
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        String qryMst = getQuery(pgmid, "qrysaveMst");
        String qryDet = getQuery(pgmid, "qrysaveDetMVO");
        String qryRun = "";
        
        qryRun = bindVAR(qryMst,INVAR);  
OUTVAR.put("qryMst",qryRun);
        JSONObject rst = executeSVC(conn, qryRun);  
        
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else {  
            JSONArray arrList = getArray(INVAR,"det");
            for(int i = 0; i < arrList.size(); i++) {
            
                JSONObject row = getRow(arrList,i); 
                row.put("comcd",ORGCD); 
                row.put("usid",USERID);
                row.put("lg_ord_no",getVal(INVAR,"lg_ord_no"));

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

//cfm:임시저장 -> 발송완료
if("cfm".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
    
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qryCfm = getQuery(pgmid, "qrycfm");
        qryCfm = bindVAR(qryCfm,INVAR);
        OUTVAR.put("qryCfm",qryCfm);
        JSONObject rst = executeSVC(conn, qryCfm);  
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else { 
            OUTVAR.put("lg_ord_no",getVal(INVAR,"lg_ord_no"));
            
            String qryUdt = getQuery(pgmid, "UdtAcceptX");
        String qryRun = "";
        
        qryRun = bindVAR(qryUdt,INVAR);  
OUTVAR.put("qryUdt",qryRun);
        rst = executeSVC(conn, qryRun);
            
            
            conn.commit(); 
        }
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}

//accept : 직송 RT의뢰건 수락
if("accept".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
    
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "qryAccept");
        String qryRun = bindVAR(qry,INVAR);
        JSONObject rst = executeSVC(conn, qryRun);
        
        String qryS = getQuery(pgmid, "searchSo_no");
        String qryRunS = bindVAR(qryS,INVAR);
        JSONArray sono = selectSVC(conn, qryRunS);
        OUTVAR.put("sono",sono);
        
        
        String qryDet = getQuery(pgmid, "searchOnline_no"); 
        
        JSONArray boxlist = getArray(OUTVAR,"sono");
        JSONObject arlist = new JSONObject();
        for(int i = 0; i<boxlist.size(); i++){
        
            JSONObject row = getRow(boxlist,i);
            
            row.put("comcd",ORGCD); 

            String qryDetRun = bindVAR(qryDet,row);
            //OUTVAR.put("qryDetRun#"+i,qryDetRun); 
            JSONArray goodslist = selectSVC(conn, qryDetRun);
             
            arlist.put("goodslist"+i,goodslist);
            OUTVAR.put("arlist",arlist);
        }
        
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else {
            //OUTVAR.put("lg_ord_no",lg_ord_no);
            conn.commit();
        } 
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
} 

//udtShop : RT직송건일때 해당매장코드 업데이트
if("udtShop".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
    
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "udtShopcd");
        String qryRun = "";
        JSONArray arrList = getArray(INVAR,"list");
        for(int i = 0; i < arrList.size(); i++) {
        
            JSONObject row = getRow(arrList,i); 
            row.put("comcd",ORGCD); 
            row.put("usid",USERID);

            String qryDetRun = bindVAR(qry,row);
OUTVAR.put("qryDetRun#"+i,qryDetRun);    
            qryRun += qryDetRun + "\n"; 
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
            
            
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
} 

/************************************************************************/



/*
if("getOnlineNo".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        
        //String qry = getQuery(pgmid, "searchOnline_no"); 
        //String qryRun = bindVAR(qry,INVAR);
        //OUTVAR.put("qryRun",qryRun); //for debug
        //JSONArray onlineNo = selectSVC(conn, qryRun);
        //OUTVAR.put("onlineNo",onlineNo); 
        
        
        JSONArray list = getArray(OUTVAR,"list");
        JSONObject arlist = new JSONObject();
        for(int i = 0; i<list.size(); i++){
        
            JSONObject row = getRow(list,i);
            
            row.put("comcd",ORGCD); 
            String qry = getQuery(pgmid, "searchOnline_no"); 
            String qryDetRun = bindVAR(qry,row);
            //OUTVAR.put("qryDetRun#"+i,qryDetRun); 
            JSONArray list = selectSVC(conn, qryDetRun);
             
            arlist.put("list"+i,list);
            OUTVAR.put("arlist",arlist);
        }
        
        
        
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}*/


//cancel:본사지시건에 대해 작업취소
if("cancel".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
    
        conn = getConn("LFN");
        String qry = getQuery(pgmid, "qryCancel");
        
        String qryRun = bindVAR(qry,INVAR);

        JSONObject rst = executeSVC(conn, qryRun);
            
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else {
            //OUTVAR.put("lg_ord_no",lg_ord_no);
            conn.commit();
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