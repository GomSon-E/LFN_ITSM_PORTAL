<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   
JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_pos";
String pgmid   = "registerSONew"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";
try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/
/* New: 신규전표 전표번호 조회 - 현재 최대값+1로 조회 => 실제 채번은 저장시 함 **************************/
if("sonoSearch".equals(func)) {
    Connection conn = null;     
    try { 
        conn = getConn("LFN");
        conn.setAutoCommit(false);

        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        OUTVAR.put("INVAR",INVAR);
        
        String qry = getQuery(pgmid, "sonoSearch");  
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray arrMst = selectSVC(conn, qryRun);
        OUTVAR.put("mst",arrMst); //화면에 돌려줌 
        
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}     

/* 상품검색 ***************************************************************************************/
if("goodsSearch".equals(func)) {
    Connection conn = null; 
    try {
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        //INVAR barcd, shopcd
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        String qry = getQuery(pgmid, "checkBarcd"); 
        String qryRun = bindVAR(qry,INVAR);
        JSONObject rst = executeSVC(conn, qryRun);
        OUTVAR.put("rst",rst);
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd");
            rtnMsg = getVal(rst,"rtnMsg");
        } else { 
            conn.commit();
            String goods_cd = getVal(rst,"rtnMsg");  //barcd에 대한 godos_cd가 있으므로 상품정보를 조회하여 Return한다.
            logger.info(goods_cd);
            qry = getQuery(pgmid,"goodsSearch"); 
            INVAR.put("goods_cd",goods_cd);
            qryRun = bindVAR(qry,INVAR); 
            JSONArray list = selectSVC(conn,qryRun);
            OUTVAR.put("qryRun",qryRun);
            OUTVAR.put("list",list); 
            
            /*
            String promogoods_cd = goods_cd.substring(0,9);
            INVAR.put("promogoods_cd",promogoods_cd);
            String qry2 = getQuery(pgmid,"promogoodsSearch"); 
            String qryRun2 = bindVAR(qry2,INVAR); 
            JSONArray list2 = selectSVC(conn,qryRun2);
            OUTVAR.put("list2",list2);
            OUTVAR.put("qryRun2",qryRun2);
            */
            
        }   
        
    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();	
    } finally {
        closeConn(conn);
    }  
}
if("searchPromo".equals(func)) {
    Connection conn = null; 
    try {
        conn = getConn("LFN");  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);   
        String qry = getQuery(pgmid,"promogoodsSearch"); 
        String qryRun = bindVAR(qry,INVAR); //goods_cd,shopcd,sale_dt
        JSONArray list = selectSVC(conn,qryRun);
        OUTVAR.put("qryRun",qryRun);
        OUTVAR.put("list",list);  
        
    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}

/* 신규전표번호 채번 : cf. 시퀀스 및 POS별 순번이 마구 증가하는 것을 방지하기 위해 실 저장 직전에 채번 */
if("sonoSave".equals(func)) {
    Connection conn = null;     
    try {
        conn = getConn("LFN");
        conn.setAutoCommit(false);

        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        OUTVAR.put("INVAR",INVAR);
        
        String qry = getQuery(pgmid, "sonoSaveGetSeq");  
        String qryRun = bindVAR(qry,INVAR);
        JSONArray arrMst = selectSVC(conn, qryRun);
        OUTVAR.put("qryRun",qryRun); //for debug
        String sale_seq = getVal(arrMst,0,"sale_seq");  //채번
        
        INVAR.put("sale_seq",sale_seq);
        String qrySave = getQuery(pgmid, "sonoSave"); 
        String qrySaveRun = bindVAR(qrySave,INVAR);
        JSONObject rst = executeSVC(conn, qrySaveRun);  //채번저장
        OUTVAR.put("qrySaveRun",qrySaveRun); //for debug
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg");
        } else {
            conn.commit(); 
            OUTVAR.put("mst",arrMst); //화면에 돌려줌
        }
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}   

/* save: 대기전표 저장 이벤트처리(DB_Write) **********************************************/
if("save".equals(func)) { 
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);

        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID); 
        //TP_SO 헤더저장 : delete insert
        String qry = getQuery(pgmid, "insertTP_SO"); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun);
        JSONObject rst = executeSVC(conn, qryRun);
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg");
        } else { 
            String qryGoodsTp = "";
            if("N".equals(getVal(rst,"rtnMsg"))) { 
                qryGoodsTp = "insertTP_SO_GOODS";     //임시저장이면 GOODS INSERT수행
            } else {
                qryGoodsTp = "mergeTP_SO_GOODS";      //아니면 GOODS MERGE수행
            }
            String qryGoods = getQuery(pgmid, qryGoodsTp); //
            String qryGoodsRun = "";
            JSONArray arrList = getArray(INVAR,"itemlist");
            for(int i = 0; i < arrList.size(); i++) {
                JSONObject row = getRow(arrList,i); 
                row.put("comcd",ORGCD);
                row.put("so_no", getVal(INVAR,"so_no"));
                row.put("shopcd", getVal(INVAR,"shopcd"));
                row.put("sale_dt", getVal(INVAR,"sale_dt"));
                row.put("so_seq", (i+1));
                row.put("usid",USERID);
                qryGoodsRun += bindVAR(qryGoods,row) + "\n";
            }
            
            JSONObject rstGoods = executeSVC(conn, qryGoodsRun);  
            OUTVAR.put("qryGoodsRun",qryGoodsRun);
            if(!"OK".equals(getVal(rstGoods,"rtnCd"))) {
                conn.rollback();
                rtnCode = getVal(rstGoods,"rtnCd"); 
                rtnMsg  = getVal(rstGoods,"rtnMsg"); 
            } else { 
                conn.commit();
            }   
        }
        
        String qrySearch = getQuery(pgmid,"selectTP_SO_GOODS");
        qrySearch = bindVAR(qrySearch,INVAR);
        JSONArray itemlistRtn = selectSVC(conn, qrySearch);
        OUTVAR.put("itemlistRtn",itemlistRtn); 
        OUTVAR.put("qrySearch",qrySearch);

    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
} 

/* saveDirect: 무승인 결제정보 저장 이벤트처리(DB_Write) ***********************/
if("saveDirect".equals(func)) { 
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);

        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);  
        /*무승인 전표 승인내역 저장 : 무승인 현금
            var args = me.pageObj.mst.exportData()[0];
            mst.so_no
            args.shopcd = gUserinfo.deptcd;  
            args.pay_tp = '2'; //현금 {pay_tp} 
            args.pay_amt = me.pageObj.itemlist.cvalbottom("0","sale_amt")    //등록된 판매금액 {pay_amt} 
            args.pos_no = me.pageObj.mst.getVal("pos_no"); //{pos_no}  
            args.approvaltime = date("today","yyyymmddhh24miss")
        */
        INVAR.put("seq", null);   
        INVAR.put("card_nm", "현금");   
        INVAR.put("tot_amt", getVal(INVAR,"pay_amt"));   
        INVAR.put("doc_no", "N/A");   
        INVAR.put("remark", "무승인 결제등록");  
        INVAR.put("pay_stat", "Y"); //CD_STAT  E오류/Y승인/C취소     

        String qry = getQuery(pgmid, "mergeTP_SO_PAY"); 
        String qryRun = bindVAR(qry,INVAR); //pay_tp, pos_no, pay_amt
        JSONObject rst = executeSVC(conn, qryRun);  
        logBiz.info(rst.toJSONString());
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            logBiz.error(qryRun);
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else {   
            INVAR.put("seq",null);
            INVAR.put("pay_seq",getVal(rst,"rtnMsg"));
            INVAR.put("snd_msg","");   //발송전문
            INVAR.put("rcv_cd","0000");  //RES_CD
            INVAR.put("rcv_comments","무승인 결제등록"); //DISPLAY
            INVAR.put("rcv_msg","");      //수신전문전체
            INVAR.put("approvalno","");   //승인번호
            INVAR.put("acquire_nm","");   //카드사명 or 국세청 
            INVAR.put("cardno","");       //카드번호 앞6자리  
            INVAR.put("tax_amt","");     //카드부가세 
            String qry2 = getQuery(pgmid, "insertTP_SO_PAY_LOG"); 
            String qryRun2 = bindVAR(qry2,INVAR); //pay_tp, pos_no, pay_amt
            JSONObject rst2 = executeSVC(conn, qryRun2);  
            if(!"OK".equals(getVal(rst2,"rtnCd"))) {
                conn.rollback();
                rtnCode = getVal(rst2,"rtnCd"); 
                rtnMsg  = getVal(rst2,"rtnMsg"); 
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

/* 전표확정 ********************************************************************/
//***  saveCfm - 판매전표 확정 및 수불반영  ***/
if("saveCfm".equals(func)) {
    Connection conn = null; 
    try {  
        String so_no = getVal(INVAR,"so_no");
        String shopcd = getVal(INVAR,"shopcd");
        String sale_dt = getVal(INVAR,"sale_dt");
    
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "mergeTP_SO_GOODS");
        String qryRun = "";
        JSONArray arrList = getArray(INVAR,"list");
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i);
            row.put("comcd",ORGCD);
            row.put("so_no", so_no);
            row.put("shopcd", shopcd);
            row.put("sale_dt", sale_dt);
            row.put("usid",USERID); 
            qryRun += bindVAR(qry,row) + "\n";
            OUTVAR.put("qryRun",qryRun);
        }
        JSONObject rst = executeSVC(conn, qryRun);  
        OUTVAR.put("qryRun",qryRun);
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            logger.debug(qryRun);
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else { 
            /* 판매확정, 수불반영 */
            INVAR.put("comcd",ORGCD);
            INVAR.put("usid",USERID); 
            String qry2 = getQuery(pgmid, "cfmTP_SO");
            String qryRun2 = bindVAR(qry2,INVAR); 
            logBiz.info(qryRun2);
            JSONObject rst2 = executeSVC(conn, qryRun2);  
            OUTVAR.put("qryRun2",qryRun2);
            if(!"OK".equals(getVal(rst2,"rtnCd"))) {
                logBiz.error(qryRun2);
                conn.rollback();
                rtnCode = getVal(rst2,"rtnCd"); 
                rtnMsg  = getVal(rst2,"rtnMsg"); 
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


/* search: 영수증 검색 및 조회 이벤트처리(DB_Read) ****************************/
/* qrySono: 영수증 검색(DB_Write) ********************************************/
//영수증 검색
if("qrySono".equals(func)) {
    Connection conn = null;     
    try {
        conn = getConn("LFN");
        conn.setAutoCommit(false);

        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        OUTVAR.put("INVAR",INVAR); 
        String qry = getQuery(pgmid, "qrySono");  
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug 
        JSONArray list = selectSVC(conn, qryRun);
        OUTVAR.put("list",list); //화면에 돌려줌 
        logger.info(qryRun);
        
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
} 

if("qrySono2".equals(func)) {
    Connection conn = null;     
    try {
        conn = getConn("LFN");
        conn.setAutoCommit(false);

        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        OUTVAR.put("INVAR",INVAR); 
        String qry = getQuery(pgmid, "qrySono2");  
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug 
        JSONArray list = selectSVC(conn, qryRun);
        OUTVAR.put("list",list); //화면에 돌려줌 
        logger.info(qryRun);
        
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
} 

//search:(재)조회 이벤트처리(DB_Read)     
if("search".equals(func)) {
    Connection conn = null; 
    try {
        conn = getConn("LFN");
        
        INVAR.put("comcd",ORGCD); 
        String qry = getQuery(pgmid,"selectTP_SO");
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray list = selectSVC(conn, qryRun);
        OUTVAR.put("list",list);
        
        String qry2 = getQuery(pgmid,"selectTP_SO_GOODS");
        String qryRun2 = bindVAR(qry2,INVAR);
        OUTVAR.put("qryRun2",qryRun2); //for debug
        JSONArray list2 = selectSVC(conn, qryRun2);
        OUTVAR.put("list2",list2);
        
        String qry3 = getQuery(pgmid, "selectTP_SO_PAY"); 
        INVAR.put("SO_NOval",getVal(INVAR,"so_no"));
        String qryRun3 = bindVAR(qry3,INVAR);
        OUTVAR.put("qryRun3",qryRun3); //for debug
        JSONArray paylist = selectSVC(conn, qryRun3);
        OUTVAR.put("paylist",paylist);
        
        String qry4 = getQuery(pgmid, "selectTP_SO_PAY_LOG"); 
        INVAR.put("SO_NOval",getVal(INVAR,"so_no"));
        String qryRun4 = bindVAR(qry4,INVAR);
        OUTVAR.put("qryRun4",qryRun4); //for debug
        JSONArray apvRst = selectSVC(conn, qryRun4);
        OUTVAR.put("apvRst",apvRst);

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
} 


/* delete: 대기전표 삭제 이벤트처리(DB_Write) ********************************************/
if("delete".equals(func)) { 
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);

        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID); 
        //TP_SO, TP_SO_GOODS 삭제 : delete 
        String qry = getQuery(pgmid, "deleteTP_SO"); 
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


/* saveReturn: 반품확정 이벤트처리(DB_Write) ***********************************/
//saveReturn: 판매반품처리 
if("saveReturn".equals(func)) { 
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);

        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);  
        String qry = getQuery(pgmid, "returnTP_SO"); 
        String qryRun = bindVAR(qry,INVAR);
        JSONObject rst = executeSVC(conn, qryRun);
        OUTVAR.put("qryRun",qryRun);
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg");
        } else { 
            OUTVAR.put("so_no_rtn",getVal(rst,"rtnMsg"));
            conn.commit(); 
        } 
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}

//saveReturnPay: 무승인 결제취소처리
if("saveReturnPay".equals(func)) { 
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);

        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);  
        /* 무승인 전표 승인내역 저장 : 무승인 현금
            var args = me.pageObj.mst.exportData()[0];
            mst.so_no  
            args.pos_no 
            args.pay_amt = me.pageObj.itemlist.cvalbottom("0","sale_amt")    //등록된 판매금액 
            args.approvaltime = date("today","yyyymmddhh24miss")
        */
        INVAR.put("pay_tp","2"); //현금 {pay_tp}  
        INVAR.put("seq", null);  //merge=>insert 
        INVAR.put("card_nm", "현금");   
        INVAR.put("tot_amt", getVal(INVAR,"pay_amt"));   
        INVAR.put("doc_no", "N/A");   
        INVAR.put("remark", "무승인 결제취소");  
        INVAR.put("pay_stat", "C"); //CD_STAT  E오류/Y승인/C취소      
        String qry = getQuery(pgmid, "mergeTP_SO_PAY"); 
        String qryRun = bindVAR(qry,INVAR); //pay_tp, pos_no, pay_amt
        JSONObject rst = executeSVC(conn, qryRun);  
        logBiz.info(rst.toJSONString());
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            logBiz.error(qryRun);
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else {   
            INVAR.put("seq",null);
            INVAR.put("pay_seq",getVal(rst,"rtnMsg"));
            INVAR.put("snd_msg","");   //발송전문
            INVAR.put("rcv_cd","0000");  //RES_CD
            INVAR.put("rcv_comments","무승인 결제취소"); //DISPLAY
            INVAR.put("rcv_msg","");      //수신전문전체
            INVAR.put("approvalno","");   //승인번호
            INVAR.put("acquire_nm","");   //카드사명 or 국세청 
            INVAR.put("cardno","");       //카드번호 앞6자리  
            INVAR.put("tax_amt","");     //카드부가세 
            String qry2 = getQuery(pgmid, "insertTP_SO_PAY_LOG"); 
            String qryRun2 = bindVAR(qry2,INVAR); //pay_tp, pos_no, pay_amt
            JSONObject rst2 = executeSVC(conn, qryRun2);  
            if(!"OK".equals(getVal(rst2,"rtnCd"))) {
                conn.rollback();
                rtnCode = getVal(rst2,"rtnCd"); 
                rtnMsg  = getVal(rst2,"rtnMsg"); 
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

/* reApv: 반품 재승인 이벤트처리(DB_Write) ***********************************/
//reApv:저장 이벤트처리(DB_Write)
if("reApv".equals(func)) { 
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);

        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);  
        String qry = getQuery(pgmid, "reApv"); 
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

if("reChange".equals(func)) { 
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);

        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);  
        String qry = getQuery(pgmid, "reChange"); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun);
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
 
/* 구POS 반품처리************************** ***********************************/
//영수증 검색
if("qrySonoOld".equals(func)) {
    Connection conn = null;     
    try {
        conn = getConn("LFN");
        conn.setAutoCommit(false);

        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        OUTVAR.put("INVAR",INVAR); 
        String qry = getQuery(pgmid, "qrySonoOld");  
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug 
        JSONArray list = selectSVC(conn, qryRun);
        OUTVAR.put("list",list); //화면에 돌려줌 
        logger.info(qryRun);
        
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}  
//영수증 검색
if("qrySonoOldGoods".equals(func)) {
    Connection conn = null;     
    try {
        conn = getConn("LFN");
        conn.setAutoCommit(false);

        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        OUTVAR.put("INVAR",INVAR); 
        String qry = getQuery(pgmid, "qrySonoOldGoods");  
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug 
        JSONArray list = selectSVC(conn, qryRun);
        OUTVAR.put("list",list); //화면에 돌려줌 
        logger.info(qryRun);
        
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}
//returnOldRun: 구POS 판매반품처리 
if("returnOldRun".equals(func)) { 
    Connection conn = null; 
    try {  
    logBiz.info("entered to returnOldRun");   
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        //영수증 번호 채번 
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        OUTVAR.put("INVAR",INVAR);
        /* INVAR
        var args = me.pageObj["mst"].exportData()[0];
        args.so_no  = "N/A";
		args.shopcd = gUserinfo.deptcd;  
		args.itemlist = me.pageObj.itemlist.exportData(); 
		*/
		INVAR.put("grpid",getVal(INVAR,"shopcd"));
        String qry = getQuery(pgmid, "sonoSaveGetSeq");  
        String qryRun = bindVAR(qry,INVAR);
        logBiz.info(qryRun);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray arrMst = selectSVC(conn, qryRun);
        String sale_seq = getVal(arrMst,0,"sale_seq");  //채번
        INVAR.put("sale_seq",sale_seq);
        String qrySave = getQuery(pgmid, "sonoSave"); 
        String qrySaveRun = bindVAR(qrySave,INVAR);
        logBiz.info(qrySaveRun);
        JSONObject rst = executeSVC(conn, qrySaveRun);  //채번저장
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg");
        } else {
            conn.commit(); 
            OUTVAR.put("mst",arrMst); //화면에 돌려줌
        } 
        //상품정보 저장 
        INVAR.put("so_no", getVal(arrMst,0,"so_no"));
        String qryGoods = getQuery(pgmid, "returnOldTP_SO_GOODS");  
        String qryGoodsRun = "";
        JSONArray arrList = getArray(INVAR,"itemlist");
            for(int i = 0; i < arrList.size(); i++) {
                JSONObject row = getRow(arrList,i); 
                row.put("comcd",ORGCD);
                row.put("so_no", getVal(INVAR,"so_no"));
                row.put("shopcd", getVal(INVAR,"shopcd"));
                row.put("sale_dt", getVal(INVAR,"sale_dt"));
                row.put("so_seq", (i+1));
                row.put("usid",USERID);
                qryGoodsRun += bindVAR(qryGoods,row) + "\n";
            }
            logBiz.info(qryGoodsRun);
            JSONObject rstGoods = executeSVC(conn, qryGoodsRun);  
            if(!"OK".equals(getVal(rstGoods,"rtnCd"))) {
                logBiz.error(qryGoodsRun);
                conn.rollback();
                rtnCode = getVal(rstGoods,"rtnCd"); 
                rtnMsg  = getVal(rstGoods,"rtnMsg"); 
            } else { 
                //헤더와 결제정보 저장
                /*
                SELECT SEQ_SO_NO.NEXTVAL AS SO_NO
                    , M.SALE_SEQ
                    , A.SHOP_NM||' '||{sale_dt}||'-'||{pos_no}||'-'||M.SALE_SEQ||' '||C.NM AS SO_NM 
                */
                INVAR.put("sale_seq",getVal(arrMst,0,"sale_seq"));
                String qry2 = getQuery(pgmid, "returnOldTP_SO"); 
                String qryRun2 = bindVAR(qry2,INVAR);
                logBiz.info(qryRun2);
                JSONObject rst2 = executeSVC(conn, qryRun2);
                if(!"OK".equals(getVal(rst2,"rtnCd"))) {
                    logBiz.error(qryRun2);
                    conn.rollback();
                    rtnCode = getVal(rst2,"rtnCd"); 
                    rtnMsg  = getVal(rst2,"rtnMsg");
                } else { 
                    OUTVAR.put("so_no_rtn",getVal(rst2,"rtnMsg"));
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

if("shopsearch".equals(func)) {
    Connection conn = null; 
    try {
        conn = getConn("LFN");
        String qry = getQuery(pgmid, "seleteTM_SHOP"); 
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

if("print".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");  
        INVAR.put("comcd",ORGCD);
        String qry = getQuery(pgmid, "seleteTM_SHOP");
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray list = selectSVC(conn, qryRun);
        OUTVAR.put("list",list);
        
        String qry2 = getQuery(pgmid, "selectTP_SO_GOODS");
        String qryRun2 = bindVAR(qry2,INVAR);
        OUTVAR.put("qryRun2",qryRun2); //for debug
        JSONArray list2 = selectSVC(conn, qryRun2);
        OUTVAR.put("goodslist",list2);
        
        String qry3 = getQuery(pgmid, "selectTP_SO_PAY_LOG");
        INVAR.put("log_stat","0000");
        String qryRun3 = bindVAR(qry3,INVAR);
        OUTVAR.put("qryRun3",qryRun3); //for debug
        JSONArray list3 = selectSVC(conn, qryRun3);
        OUTVAR.put("paylist",list3);
        
    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}

//로그 저장
/*
else if("payment".equals(func)) {
    // 쿼리에 사용 할 필요 한 항목들 추출
    JSONArray list = (JSONArray)INVAR.get("list"); //INVAR에 들어있는 list 추출
    JSONObject sendlist = (JSONObject)list.get(0); //list에 들어있는 첫번째 값 추출
    String SND_MSG = (String)sendlist.get("send"); //key가 post인 값 추출 (요청전문)
    JSONObject receivelist = (JSONObject)list.get(1); //list에 들어있는 두번째 값 추출
    JSONObject receive = (JSONObject)receivelist.get("receive"); //key가 send인 값 추출
    String RCV_MSG = receive.toString(); //추출 한 값이 JSONObject이기 때문에 String으로 변환 (응답전문)
    String RES_CD = (String)receive.get("RES_CD"); //추출한 send 값에 들어있는 RES_CD값 추출
    String DISPLAY = (String)receive.get("DISPLAY"); //추출한 send 값에 들어있는 DISPLAY값 추출
    JSONObject so_no_value = (JSONObject)list.get(2); //list에 들어있는 세번째 값 추출
    String SO_NOval = (String)so_no_value.get("so_no");
    String APPROVALNO = (String)receive.get("APPROVALNO");
    String ACQUIRE_NM = (String)receive.get("ACQUIRE_NM");

    // 쿼리에 사용 할 항목들 INVAR에 저장
    INVAR2.put("RES_CD",RES_CD); 
    INVAR2.put("SND_MSG",SND_MSG);
    INVAR2.put("DISPLAY",DISPLAY);
    INVAR2.put("RCV_MSG",RCV_MSG);
    INVAR2.put("SO_NOval",SO_NOval);
    INVAR2.put("ACQUIRE_NM",ACQUIRE_NM);
    INVAR2.put("APPROVALNO",APPROVALNO);
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = "INSERT INTO TP_SO_PAY_LOG (COMCD,SO_NO,SEQ,SND_MSG,RCV_CD,RCV_COMMENTS,RCV_MSG,APPROVALNO,ACQUIRE_NM) VALUES('LFN',{SO_NOval},logSEQ.NEXTVAL,{SND_MSG},{RES_CD},{DISPLAY},{RCV_MSG},{APPROVALNO},{ACQUIRE_NM});";
        String qryRun = bindVAR(qry,INVAR2);
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
*/
else if("usdcard".equals(func)) {
    Connection conn = null; 
    try {  
    logBiz.info(INVAR.toString());
    JSONObject INVAR2 = new JSONObject();
    // 쿼리에 사용 할 필요 한 항목들 추출
    JSONArray list = (JSONArray)INVAR.get("list"); //INVAR에 들어있는 list 추출
    JSONObject sendlist = (JSONObject)list.get(0); //list에 들어있는 첫번째 값 추출
    JSONObject sendvalue = (JSONObject)sendlist.get("send");
    String SND_MSG = (String)sendvalue.get("taRequest");

    JSONObject receivelist = (JSONObject)list.get(1); //list에 들어있는 두번째 값 추출
  
    JSONObject receive = (JSONObject)receivelist.get("receive"); //key가 send인 값 추출
  
    String RCV_MSG = receive.toString(); //추출 한 값이 JSONObject이기 때문에 String으로 변환 (응답전문)
  
    String RES_CD = (String)receive.get("RES_CD"); //추출한 send 값에 들어있는 RES_CD값 추출
  
    String DISPLAY = (String)receive.get("DISPLAY"); //추출한 send 값에 들어있는 DISPLAY값 추출
  
    String TOT_AMT = (String)receive.get("TOT_AMT");
  
    String APPROVALNO = (String)receive.get("APPROVALNO");
  
    String ACQUIRE_NM = (String)receive.get("ACQUIRE_NM");
  
    JSONObject mst = (JSONObject)list.get(2); //list에 들어있는 세번째 값 추출
  
    String SO_NOval = (String)mst.get("so_no");
  
    String seq = (String)mst.get("sale_seq");
    
    String cd_stat = (String)mst.get("cd_stat");
  
    logBiz.info(INVAR.toString());
  
    String pos_no = (String)mst.get("pos_no");
  
    String so_nm = (String)mst.get("so_nm");
  
    String so_usid = (String)mst.get("so_usid");
  
    String sale_dt = (String)mst.get("sale_dt");
  
    JSONObject orgcdlist = (JSONObject)list.get(3); //list에 들어있는 네번째 값 추출
  
    String orgcd = (String)orgcdlist.get("orgcd");
  
    JSONObject shopcdlist = (JSONObject)list.get(4); //list에 들어있는 다섯째 값 추출
  
    String shopcd = (String)shopcdlist.get("shopcd");
  
    JSONObject so_tplist = (JSONObject)list.get(5); //list에 들어있는 여섯째 값 추출
  
    String so_tp = (String)so_tplist.get("so_tp");
  
    String pay_seq = "1";
  
    // 쿼리에 사용 할 항목들 INVAR에 저장
  
    INVAR2.put("snd_msg",SND_MSG);
  
    INVAR2.put("rcv_cd",RES_CD); 
  
    INVAR2.put("rcv_comments",DISPLAY);
  
    INVAR2.put("rcv_msg",RCV_MSG);
  
    INVAR2.put("SO_NOval",SO_NOval);
  
    INVAR2.put("tot_amt",TOT_AMT);
    INVAR2.put("pay_amt",TOT_AMT);
  
    INVAR2.put("acquire_nm",ACQUIRE_NM);
  
    INVAR2.put("approvalno",APPROVALNO);
  
    INVAR2.put("seq",seq);
  
    INVAR2.put("pos_no",pos_no);
  
    INVAR2.put("orgcd",orgcd);
  
    INVAR2.put("shopcd",shopcd);
  
    INVAR2.put("so_nm",so_nm);
  
    INVAR2.put("usid",so_usid);
  
    INVAR2.put("sale_dt",sale_dt);
  
    INVAR2.put("so_tp",so_tp);
  
    INVAR2.put("so_no",SO_NOval);
    
    INVAR2.put("pay_seq",pay_seq);
  
    INVAR2.put("comcd",getVal(INVAR2,"orgcd"));
  
    INVAR2.put("approvaltime",getVal(INVAR,"approvaltime"));
  
    INVAR2.put("tax_amt",null);
  
    INVAR2.put("cardno",null);
  
    INVAR2.put("pay_tp",1);
  
    INVAR2.put("card_nm",ACQUIRE_NM);
  
    INVAR2.put("doc_no",APPROVALNO);
  
    INVAR2.put("remark","카드승인");
  
    INVAR2.put("pay_stat","Y");
    
    INVAR2.put("comcd",ORGCD);
    
    INVAR2.put("cd_stat",cd_stat);
    
  
    logBiz.info("2 :" +INVAR.toString());

        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        String qry2 = getQuery(pgmid, "insertTP_SO_PAY");
        String qryRun2 = bindVAR(qry2,INVAR2);
        OUTVAR.put("qryRun2",qryRun2);
        JSONObject rst2 = executeSVC(conn, qryRun2);
        if(!"OK".equals(getVal(rst2,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst2,"rtnCd"); 
            rtnMsg  = getVal(rst2,"rtnMsg");
            logBiz.info("3:" + qryRun2);
        } else {
            INVAR2.put("pay_seq",getVal(rst2,"rtnMsg"));
            String qry = getQuery(pgmid, "insertTP_SO_PAY_LOG");
            String qryRun = bindVAR(qry,INVAR2);
            JSONObject rst = executeSVC(conn, qryRun);
            if(!"OK".equals(getVal(rst,"rtnCd"))) {
                conn.rollback();
                rtnCode = getVal(rst,"rtnCd"); 
                rtnMsg  = getVal(rst,"rtnMsg");
            } else {
                conn.commit(); 
            }
        }
        logBiz.info("4:" + qryRun2);

        
        String qry3 = getQuery(pgmid, "selectTP_SO_PAY");
        String qryRun3 = bindVAR(qry3,INVAR2);
        OUTVAR.put("qryRun3",qryRun3); //for debug
        JSONArray list2 = selectSVC(conn, qryRun3);
        OUTVAR.put("list2",list2);

        String qry4 = getQuery(pgmid, "selectTP_SO_PAY_LOG");
        INVAR2.put("log_stat","any");
        String qryRun4 = bindVAR(qry4,INVAR2);
        OUTVAR.put("qryRun4",qryRun4); //for debug
        JSONArray list4 = selectSVC(conn, qryRun4);
        OUTVAR.put("list4",list4);
        logBiz.info("4:" + qryRun4);
        
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    } 
}

//***  usdCancel - 승인취소 저장: pay업데이트, pay_log인서트  *****************/
else if("usdCancel".equals(func)) { 
    JSONObject INVAR2 = new JSONObject();
    Connection conn = null;  
    try {  
     
        /* args.send = rtn.taRequest; //요청전문
        	args.receive   = rtn.data; // 응답전문
        	args.mst       = me.pageObj["mst"].exportData()[0];
        	args.orgcd     = gUserinfo.orgcd;
        	args.shopcd    = gUserinfo.deptcd; 
        	args.so_tp_val = gfnCdNm("SO_TP",gUserinfo.so_tp,"nm");
        	args.so_tp     = so_tp_val;
        	args.so_no     = me.pageObj.mst.getVal("so_no"); 
        	args.seq       = seq;    
        	args.pay_tp    = "1"; //카드 */ 
        INVAR.put("comcd",ORGCD); 
        INVAR.put("usid",USERID); 
        JSONObject send = (JSONObject)INVAR.get("send");
        String SEND = send.toString(); 
        JSONObject receive = (JSONObject)INVAR.get("receive"); //key가 send인 값 추출
        JSONObject mst = (JSONObject)INVAR.get("mst"); //key가 send인 값 추출
        String RCV = receive.toString(); 
        INVAR.put("send",SEND);
        INVAR.put("receive",RCV);
        INVAR.put("log_stat","any");
        INVAR.put("so_no",getVal(INVAR,"so_no"));
        conn = getConn("LFN");
        conn.setAutoCommit(false); 
        
        INVAR2.put("snd_msg",SEND);
        INVAR2.put("rcv_cd","0000"); 
        INVAR2.put("rcv_comments",getVal(receive,"DISPLAY"));
        INVAR2.put("rcv_msg",RCV);
        INVAR2.put("tot_amt",getVal(INVAR,"pay_amt"));
        INVAR2.put("pay_amt",getVal(INVAR,"pay_amt"));
        INVAR2.put("acquire_nm",getVal(receive,"ACQUIRE_NM"));
        INVAR2.put("approvalno",getVal(receive,"APPROVALNO"));
        INVAR2.put("seq",null);
        INVAR2.put("pos_no",getVal(mst,"pos_no"));
        INVAR2.put("shopcd",getVal(INVAR,"shopcd"));
        INVAR2.put("so_nm",getVal(mst,"so_nm"));
        INVAR2.put("usid",USERID);
        INVAR2.put("sale_dt",getVal(mst,"sale_dt"));
        INVAR2.put("so_tp",getVal(INVAR,"so_tp"));
        INVAR2.put("so_no",getVal(mst,"so_no"));
        INVAR2.put("pay_seq",null);
        INVAR2.put("comcd",ORGCD);
        INVAR2.put("approvaltime",getVal(receive,"APPROVALTIME"));
        INVAR2.put("tax_amt",getVal(receive,"TAX_AMT"));
        INVAR2.put("cardno",getVal(receive,"CARDNO"));
        INVAR2.put("pay_tp",getVal(INVAR,"pay_tp"));
        INVAR2.put("card_nm",getVal(INVAR,"card_nm"));
        INVAR2.put("doc_no",getVal(receive,"APPROVALNO"));
        INVAR2.put("remark","승인취소");
        INVAR2.put("pay_stat","C");
        
        String qry2 = getQuery(pgmid, "mergeTP_SO_PAY");
        String qryRun2 = bindVAR(qry2,INVAR2);
        JSONObject rst2 = executeSVC(conn, qryRun2);
        OUTVAR.put("qryRun2",qryRun2);
        if(!"OK".equals(getVal(rst2,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst2,"rtnCd"); 
            rtnMsg  = getVal(rst2,"rtnMsg");
        } else {
            INVAR2.put("pay_seq",getVal(rst2,"rtnMsg"));
            String qry = getQuery(pgmid, "insertTP_SO_PAY_LOG");
            String qryRun = bindVAR(qry,INVAR2);
            JSONObject rst = executeSVC(conn, qryRun);
            if(!"OK".equals(getVal(rst,"rtnCd"))) {
                conn.rollback();
                rtnCode = getVal(rst,"rtnCd"); 
                rtnMsg  = getVal(rst,"rtnMsg");
            } else {
                conn.commit(); 
            }
        }

        String qry3 = getQuery(pgmid, "selectTP_SO_PAY");
        String qryRun3 = bindVAR(qry3,INVAR);
        OUTVAR.put("qryRun3",qryRun3); //for debug
        JSONArray paylist = selectSVC(conn, qryRun3);
        OUTVAR.put("paylist",paylist);

        String qry4 = getQuery(pgmid, "selectTP_SO_PAY_LOG");
        INVAR.put("log_stat","any");
        String qryRun4 = bindVAR(qry4,INVAR);
        OUTVAR.put("qryRun4",qryRun4); //for debug
        JSONArray apvRst = selectSVC(conn, qryRun4);
        OUTVAR.put("apvRst",apvRst);
        
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}


//************************************************************/




else if("usdcash".equals(func)) {
    // 쿼리에 사용 할 필요 한 항목들 추출
    JSONObject INVAR2 = new JSONObject();
    JSONArray list = (JSONArray)INVAR.get("list"); //INVAR에 들어있는 list 추출
    JSONObject sendlist = (JSONObject)list.get(0); //list에 들어있는 첫번째 값 추출
    JSONObject sendvalue = (JSONObject)sendlist.get("send");
    String SND_MSG = (String)sendvalue.get("taRequest");   
    JSONObject receivelist = (JSONObject)list.get(1);     //list에 들어있는 두번째 값 추출
    JSONObject receive = (JSONObject)receivelist.get("receive"); //key가 send인 값 추출
    String RCV_MSG = receive.toString(); //추출 한 값이 JSONObject이기 때문에 String으로 변환 (응답전문)
    String RES_CD = (String)receive.get("RES_CD"); //추출한 send 값에 들어있는 RES_CD값 추출
    String DISPLAY = (String)receive.get("DISPLAY"); //추출한 send 값에 들어있는 DISPLAY값 추출
    String TOT_AMT = (String)receive.get("TOT_AMT");
    String APPROVALNO = (String)receive.get("APPROVALNO");
    String ACQUIRE_NM = (String)receive.get("ACQUIRE_NM");
    JSONObject mst = (JSONObject)list.get(2); //list에 들어있는 세번째 값 추출
    String SO_NOval = (String)mst.get("so_no");
    String seq = (String)mst.get("sale_seq");
    String pos_no = (String)mst.get("pos_no");
    String so_nm = (String)mst.get("so_nm");
    String so_usid = (String)mst.get("so_usid");
    String sale_dt = (String)mst.get("sale_dt");
    JSONObject orgcdlist = (JSONObject)list.get(3); //list에 들어있는 네번째 값 추출
    String orgcd = (String)orgcdlist.get("orgcd");
    JSONObject shopcdlist = (JSONObject)list.get(4); //list에 들어있는 다섯째 값 추출
    String shopcd = (String)shopcdlist.get("shopcd");
    JSONObject so_tplist = (JSONObject)list.get(5); //list에 들어있는 다섯째 값 추출
    String so_tp = (String)so_tplist.get("so_tp"); 
    
    // 쿼리에 사용 할 항목들 INVAR에 저장
    INVAR2.put("snd_msg",SND_MSG);
    INVAR2.put("rcv_cd",RES_CD); 
    INVAR2.put("rcv_comments",DISPLAY);
    INVAR2.put("rcv_msg",RCV_MSG);
    INVAR2.put("acquire_nm",getVal(INVAR,"card_nm"));
    INVAR2.put("SO_NOval",SO_NOval);
    INVAR2.put("pay_amt",TOT_AMT);
    INVAR2.put("tot_amt",TOT_AMT);
    INVAR2.put("approvalno",APPROVALNO);
    INVAR2.put("seq",seq);
    INVAR2.put("pos_no",pos_no);
    INVAR2.put("orgcd",orgcd);
    INVAR2.put("so_nm",so_nm);
    INVAR2.put("usid",so_usid);
    INVAR2.put("sale_dt",sale_dt);
    INVAR2.put("shopcd",shopcd);
    INVAR2.put("so_tp",so_tp);
    INVAR2.put("so_no",SO_NOval);
    INVAR2.put("comcd",getVal(INVAR2,"orgcd"));
    INVAR2.put("approvaltime",getVal(INVAR,"approvaltime"));
    INVAR2.put("tax_amt",null);
    INVAR2.put("cardno",null);
    INVAR2.put("pay_tp",2);
    INVAR2.put("doc_no",APPROVALNO);
    INVAR2.put("remark","현금승인");
    INVAR2.put("pay_stat","Y");
    INVAR2.put("pay_seq",1);
    INVAR2.put("card_nm",getVal(INVAR,"card_nm"));

    Connection conn = null; 
    try{
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        INVAR2.put("comcd",ORGCD);
        String qry2 = getQuery(pgmid, "insertTP_SO_PAY");
        String qryRun2 = bindVAR(qry2,INVAR2);
        OUTVAR.put("qryRun",qryRun2);
        JSONObject rst2 = executeSVC(conn, qryRun2);
        if(!"OK".equals(getVal(rst2,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst2,"rtnCd"); 
            rtnMsg  = getVal(rst2,"rtnMsg");
        } else {
            INVAR2.put("pay_seq",getVal(rst2,"rtnMsg"));
            String qry = getQuery(pgmid, "insertTP_SO_PAY_LOG");
            String qryRun = bindVAR(qry,INVAR2);
            JSONObject rst = executeSVC(conn, qryRun);
            if(!"OK".equals(getVal(rst,"rtnCd"))) {
                conn.rollback();
                rtnCode = getVal(rst,"rtnCd"); 
                rtnMsg  = getVal(rst,"rtnMsg");
            } else {
                
                conn.commit(); 
            }
        }
        
        String qry3 = getQuery(pgmid, "selectTP_SO_PAY");
        String qryRun3 = bindVAR(qry3,INVAR2);
        OUTVAR.put("qryRun3",qryRun3); //for debug
        JSONArray list2 = selectSVC(conn, qryRun3);
        OUTVAR.put("list2",list2);

        String qry4 = getQuery(pgmid, "selectTP_SO_PAY_LOG");
        INVAR2.put("log_stat","any");
        String qryRun4 = bindVAR(qry4,INVAR2);
        OUTVAR.put("qryRun4",qryRun4); //for debug
        JSONArray list4 = selectSVC(conn, qryRun4);
        OUTVAR.put("list4",list4);

        } catch (Exception e) {
            rtnCode = "ERR";
            rtnMsg = e.toString();
        } finally {
            closeConn(conn);
        }
}
if("apvRstsearch".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN"); 
        conn.setAutoCommit(false); 
        if(isNull(getVal(INVAR,"log_stat"))) INVAR.put("log_stat","0000"); //영수증 승인내역만 조회 또는 저장후 전체조회
        String qry = getQuery(pgmid, "selectTP_SO_PAY_LOG");
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
/***************************************************************************************************/
/* loglTx CAT단말기 통신 중 오류발생시 로그기록 ****/
if("logTx".equals(func)) {     
    try {  
        //INVAR = {"log":"전문 전체");
        INVAR.put("orgcd",ORGCD);
        INVAR.put("usid",USERID);
        logBiz.info(INVAR.toString()); 
    } catch (Exception e) {
        logBiz.error("통신로그 저장시 오류: "+e.toString());
    }  
}     


if("failcard".equals(func)) {
    Connection conn = null; 
    INVAR.put("usid",USERID);
    try{
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "saveTP_SO_PAY_fail");
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
if("failcash".equals(func)) {
    Connection conn = null; 
    INVAR.put("usid",USERID);
    try{
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "saveTP_SO_PAY_fail_cash");
        String qryRun = bindVAR(qry,INVAR);
        JSONObject rst = executeSVC(conn, qryRun);
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg");
        } else {
            conn.commit(); 
        }

        String qry2 = getQuery(pgmid, "saveTP_SO_fale");
        String qryRun2 = bindVAR(qry2,INVAR);
        JSONObject rst2 = executeSVC(conn, qryRun2);
        if(!"OK".equals(getVal(rst2,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst2,"rtnCd"); 
            rtnMsg  = getVal(rst2,"rtnMsg");
        } else {
            conn.commit(); 
        }

        String qry3 = getQuery(pgmid, "saveTP_SO_GOODS_fail");
        String qryRun3 = bindVAR(qry3,INVAR);
        JSONObject rst3 = executeSVC(conn, qryRun3);
        if(!"OK".equals(getVal(rst3,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst3,"rtnCd"); 
            rtnMsg  = getVal(rst3,"rtnMsg");
        } else {
            conn.commit(); 
        }

        String qry4 = "SELECT * FROM TP_SO_PAY WHERE SO_NO = {so_no}";
        String qryRun4 = bindVAR(qry4,INVAR);
        OUTVAR.put("qryRun4",qryRun4); //for debug
        JSONArray list = selectSVC(conn, qryRun4);
        OUTVAR.put("list",list);
        
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
