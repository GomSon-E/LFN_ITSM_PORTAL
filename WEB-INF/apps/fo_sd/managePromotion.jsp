<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_sd";
String pgmid   = "managePromotion"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/
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
        OUTVAR.put("checkBarcd",qryRun);
        JSONObject rst = executeSVC(conn, qryRun);  
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd");
            rtnMsg = getVal(rst,"rtnMsg");
        } else { 
            conn.commit();
            String goods_cd = getVal(rst,"rtnMsg");  //barcd에 대한 godos_cd가 있으므로 상품정보를 조회하여 Return한다.
            qry = getQuery(pgmid,"goodsSearch"); 
            INVAR.put("goods_cd",goods_cd);
            qryRun = bindVAR(qry,INVAR); 
            OUTVAR.put("goodsSearch",qryRun);
            JSONArray list = selectSVC(conn,qryRun);
            OUTVAR.put("list",list); 
        }   
    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}

/* 상품검색2 ***************************************************************************************/
if("goodsSearch2".equals(func)) {
    Connection conn = null; 
    try {
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        //INVAR barcds, shopcd
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        
        JSONArray barcds = (JSONArray)INVAR.get("barcds");
        
        String qry = getQuery(pgmid, "checkBarcd"); 
        JSONArray goods_cds = new JSONArray();
        for(int i=0; i < barcds.size(); i++) {
            JSONObject row = new JSONObject();
            row.put("barcd", (String)barcds.get(i)); 
            INVAR.put("barcd", (String)barcds.get(i));
            String qryRun = bindVAR(qry,INVAR);
            JSONObject rst = executeSVC(conn, qryRun); 
            if(!"OK".equals(getVal(rst,"rtnCd"))) {
                conn.rollback();
                row.put("checkBarcd","ERR");             
                row.put("goods_cd",(String)barcds.get(i));               
                row.put("goods_nm",getVal(rst,"rtnMsg"));             
            } else { 
                conn.commit();
                row.put("checkBarcd","OK");             
                row.put("goods_cd",getVal(rst,"rtnMsg"));                
            }    
            goods_cds.add(row); //row = {barcd, goods_cd, goods_nm, checkBarcd}
        }
        JSONArray list = new JSONArray();
        qry = getQuery(pgmid,"goodsSearch");
        
        for(int j=0; j < goods_cds.size(); j++) {
            JSONObject row = getRow(goods_cds,j);
            if("OK".equals(getVal(row,"checkBarcd"))) {
                INVAR.put("goods_cd", getVal(row,"goods_cd")); //barcd에 대한 godos_cd가 있으므로 상품정보를 조회하여 Return한다. 
                String qryRun = bindVAR(qry,INVAR); 
                JSONArray list2 = selectSVC(conn,qryRun);
                if(list2.size() > 0) {
                    JSONObject rtn = getRow(list2,0); 
                    row.put("init_price",getVal(rtn,"init_price"));
                    row.put("sale_price",getVal(rtn,"sale_price"));
                    row.put("goods_nm",getVal(rtn,"goods_nm"));
                    row.put("goods_cd",getVal(rtn,"goods_cd"));
                } else if (list2.size() == 0) {
                    row.put("init_price",null);
                    row.put("sale_price",null);
                    row.put("goods_nm","상품정보 없음"); 
                }
            } else {
                row.put("init_price",null);
                row.put("sale_price",null); 
            }
            list.add(row); 
        }  
        //OUTVAR.put("barcds",barcds);
        //OUTVAR.put("goods_cds",goods_cds);
        OUTVAR.put("list",list);
        
    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}
/***************************************************************************************************/
//중복 조회 이벤트처리(DB_Read)     
if("dupChk".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        conn = getConn("LFN"); 
        JSONArray shopArr = getArray(INVAR,"shops");
        String shops = "";
        for(int i=0; i < shopArr.size(); i++) {
            shops += "'"+getVal(shopArr, i, "shopcd")+"',";
        }
        shops += "''";
        INVAR.put("shops",shops);
        
        String qryRun = "";
        
        JSONArray goods_cds = getArray(INVAR,"goods_cds");
        //String qry = getQuery(pgmid, "checkDup");
        JSONArray listArray = new JSONArray();
        JSONArray listArray2 = new JSONArray();
        
        for(int i=0; i < goods_cds.size(); i++) {
            JSONObject row = getRow(goods_cds,i);
            INVAR.put("goods_cd", getVal(row,"goods_cd"));
            String qry = getQuery(pgmid, "checkDup");
            String qryDetRun = bindVAR(qry,INVAR); 
            //qryRun += qryDetRun + "\n";
            JSONArray list = selectSVC(conn,qryDetRun);
            OUTVAR.put("qryDetRun",qryDetRun); //for debug
            //OUTVAR.put("list",list);
            JSONObject rtn = getRow(list,0); 
            listArray.add(rtn);
            
            String qry2 = getQuery(pgmid, "checkDup2");
            String qryDetRun2 = bindVAR(qry2,INVAR); 
            JSONArray list2 = selectSVC(conn,qryDetRun2);
            OUTVAR.put("qryDetRun2",qryDetRun2); //for debug
            //OUTVAR.put("list2",list2);
            JSONObject rtn2 = getRow(list2,0); 
            listArray2.add(rtn2);
        }  
        //JSONArray list = selectSVC(conn,qryRun);
        //OUTVAR.put("qryRun",qryRun); //for debug
        //OUTVAR.put("list",list); 
        
        OUTVAR.put("list",listArray);
        OUTVAR.put("list2",listArray2);
        
    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}
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

/***************************************************************************************************/
//searchMst: 등록내역 조회 이벤트처리(DB_Read)     
if("searchMst".equals(func)) {
    Connection conn = null; 
    try {  
        OUTVAR.put("INVAR",INVAR); //for debug
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        conn = getConn("LFN");  
        
        String qry = getQuery(pgmid, "searchMst"); 
        String qryRun = bindVAR(qry,INVAR);
        logger.info(qryRun); //for debug
        JSONArray mst = selectSVC(conn, qryRun); 
        OUTVAR.put("mst",mst); 
        
        String qryDet = getQuery(pgmid, "searchDet"); /* 반품건 부호 바꿔줌 */
        qryDet = bindVAR(qryDet,INVAR);
        logger.info(qryDet); //for debug
        JSONArray det = selectSVC(conn, qryDet);
        OUTVAR.put("det",det); 
        
        String qryShop = getQuery(pgmid, "searchShop"); 
        qryShop = bindVAR(qryShop,INVAR);
        logger.info(qryShop); //for debug
        JSONArray shop = selectSVC(conn, qryShop);
        OUTVAR.put("shop", shop); 

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
        
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);

        String saveMst  = getQuery(pgmid, "saveMst");
        String saveShop = getQuery(pgmid, "saveShop");
        String saveDet  = getQuery(pgmid, "saveDet");  //확정전 상품정보 저장/삭제 
        String qryRun = "";

        String promo_cond_no = getVal(INVAR,"promo_cond_no");
        if("TBD".equals(promo_cond_no)) {  //첫번째 저장시 수불전표번호 채번
            JSONArray arrPromoCondNo = selectSVC(conn,"SELECT SEQ_promo_no.NEXTVAL promo_cond_no FROM DUAL");
            promo_cond_no = getVal(arrPromoCondNo,0,"promo_cond_no");
            INVAR.put("promo_cond_no",promo_cond_no);
            qryRun = bindVAR(saveMst,INVAR);  //마스터정보 MERGE(INSERT), 적용매장정보 Clear
        } else {
            qryRun = bindVAR(saveMst,INVAR);  //마스터정보 MERGE, 적용매장정보 Clear
        }
        OUTVAR.put("promo_cond_no",promo_cond_no);

        if("Y".equals(getVal(INVAR,"first_yn"))) {  //Loop의 첫 저장일때 적용매장정보 INSERT
            JSONArray arrShop = getArray(INVAR,"shop");
            for(int i = 0; i < arrShop.size(); i++) {
                JSONObject row = getRow(arrShop,i); 
                row.put("comcd",ORGCD);
                row.put("promo_cond_no",promo_cond_no);
                row.put("usid",USERID);            
                qryRun += bindVAR(saveShop,row)+"\n";
            }
        } 
         
        int txCnt = 0;  int oneTx = 50;
        JSONObject rst = new JSONObject();
        rst.put("rtnCd","OK");
        JSONArray arrList = getArray(INVAR,"det");
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            row.put("comcd",ORGCD);
            row.put("promo_cond_no",promo_cond_no);
            //row.put("promo_price_tp",getVal(INVAR,"promo_price_tp"));
            row.put("usid",USERID);
            qryRun += bindVAR(saveDet,row) + "\n";  //매장정보 저장 
            
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

//cfm:확정 이벤트처리(DB_Write)
if("cfm".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        
        String qry = getQuery(pgmid, "qryCfm");
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

//확정취소
if("revert".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        INVAR.put("comcd",ORGCD);
        String qry = getQuery(pgmid, "qryRevert");
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

//삭제
if("delete".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        INVAR.put("comcd",ORGCD);
        String qry = getQuery(pgmid, "qryDelete");
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
