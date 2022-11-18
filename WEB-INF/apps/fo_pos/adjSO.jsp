<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_pos";
String pgmid   = "adjSO"; 
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
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
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

/***************************************************************************************************/
//searchMst: 등록내역 조회 이벤트처리(DB_Read)     
if("searchMst".equals(func)) {
    Connection conn = null; 
    try {  
        OUTVAR.put("INVAR",INVAR); //for debug
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        conn = getConn("LFN");  
        
        String regSOpgmId = "registerSO";
        
        String qry = getQuery(regSOpgmId, "selectTP_SO"); 
        String qryRun = bindVAR(qry,INVAR);
        logger.info(qryRun); //for debug
        JSONArray mst = selectSVC(conn, qryRun); 
        OUTVAR.put("mst",mst); 
        
        String qryItemlist = getQuery(pgmid, "selectTP_SO_GOODS"); /* 반품건 부호 바꿔줌 */
        qryItemlist = bindVAR(qryItemlist,INVAR);
        logger.info(qryItemlist); //for debug
        JSONArray itemlist = selectSVC(conn, qryItemlist);
        OUTVAR.put("itemlist",itemlist); 
        
        String qryPaylist = getQuery(regSOpgmId, "selectTP_SO_PAY"); 
        qryPaylist = bindVAR(qryPaylist,INVAR);
        logger.info(qryPaylist); //for debug
        JSONArray paylist = selectSVC(conn, qryPaylist);
        OUTVAR.put("paylist", paylist); 

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
        }   
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
        
        String regSOpgmId = "registerSO";

		//매장정보 조회 - gUserinfo.deptcd = 매장코드
        /* INVAR
        var args = me.pageObj["mst"].exportData()[0];
        args.grpid = gUserinfo.deptcd;  
        args.so_no  = "N/A";
		args.shopcd = gUserinfo.deptcd;  
		args.itemlist = me.pageObj.itemlist.exportData(); 
		*/
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        OUTVAR.put("INVAR",INVAR);
        
        String qry = getQuery(regSOpgmId, "sonoSaveGetSeq");   //registerSO
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray arrMst = selectSVC(conn, qryRun);
        String sale_seq = getVal(arrMst,0,"sale_seq");  //채번
        
        INVAR.put("sale_seq",sale_seq);
        String qrySave = getQuery(regSOpgmId, "sonoSave"); 
        String qrySaveRun = bindVAR(qrySave,INVAR);
        JSONObject rst = executeSVC(conn, qrySaveRun);  //채번저장
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

//save:저장 이벤트처리(DB_Write)
if("save".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        String regSOpgmId = "registerSO";
        
        String qryMst  = getQuery(pgmid, "insMst");
        String qryItem = getQuery(pgmid, "mergeTP_SO_GOODS");
        String qryPay  = getQuery(pgmid, "mergeTP_SO_PAY"); 
        String qryRun = ""; 
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        
        qryRun = bindVAR(qryMst,INVAR);
        
        JSONArray arrItemlist = getArray(INVAR,"itemlist"); 
        for(int i = 0; i < arrItemlist.size(); i++) {
            JSONObject row = getRow(arrItemlist,i); 
            row.put("comcd",ORGCD);
            row.put("so_no",getVal(INVAR,"so_no"));
            row.put("shopcd",getVal(INVAR,"shopcd"));
            row.put("sale_dt",getVal(INVAR,"sale_dt"));
            row.put("sale_amt",getVal(row,"so_amt"));
            row.put("so_seq",nvl(getVal(row,"so_seq"),""+(i+1)));
            row.put("usid",USERID);
            qryRun += bindVAR(qryItem,row) + "\n";
            OUTVAR.put("qryRun",qryRun);
        } 
        
        JSONArray arrPaylist = getArray(INVAR,"paylist");
        for(int i = 0; i < arrPaylist.size(); i++) {
            JSONObject row = getRow(arrPaylist,i); 
            row.put("comcd",ORGCD);
            row.put("so_no",getVal(INVAR,"so_no"));
            row.put("tot_amt",getVal(row,"pay_amt"));
            row.put("pay_stat",getVal(row,"cd_stat"));
            row.put("card_nm",getVal(row,"cost_comcd"));
            row.put("pos_no",getVal(INVAR,"pos_no"));
            row.put("doc_no","N/A");
            row.put("seq",nvl(getVal(row,"seq"),""+(i+1)));
            row.put("usid",USERID);
            qryRun += bindVAR(qryPay,row) + "\n";
            OUTVAR.put("qryRun2",qryRun);
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

//cfm:확정처리 이벤트처리(DB_Write)
if("cfm".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        //TP_SO - 금액이 < 0 이면 반품, >0 이면 완료처리함 / 확정여부 fileid update
        //수불반영  
        
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID); 
        String qry = getQuery(pgmid,"cfm"); //SO_NO
        String qryRun = ""; 
        JSONArray arrlist = getArray(INVAR,"cfmlist"); 
        for(int i = 0; i < arrlist.size(); i++) {
            JSONObject row = getRow(arrlist,i); 
            row.put("comcd",ORGCD);  
            row.put("usid",USERID);
            qryRun += bindVAR(qry,row)+ "\n";
        }  
logBiz.error(qryRun);           
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

//delete:저장 이벤트처리(DB_Write)
if("delete".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        INVAR.put("usid",USERID);
        INVAR.put("comcd",ORGCD);
        /*  {usid}
            {comcd}
            {so_no}; */
        
        String qry = getQuery(pgmid, "qryDelFlag");
        String qryRun = bindVAR(qry,INVAR); 
logBiz.error(qryRun);        
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
