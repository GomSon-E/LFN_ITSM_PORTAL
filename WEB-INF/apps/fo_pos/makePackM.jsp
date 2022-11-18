<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_pos";
String pgmid   = "makePackM"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/
//search:조회 이벤트처리(DB_Read)     
if("searchBox".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "selelctBoxList"); 
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
//박스 신규 
if("saveBoxSeq".equals(func)) {
    Connection conn = null;     
    try {
        conn = getConn("LFN");
        conn.setAutoCommit(false);

        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        OUTVAR.put("INVAR",INVAR);
        
        String qry = getQuery(pgmid, "selectBoxSeq");  
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray arrBox = selectSVC(conn, qryRun);
        String box_seq = getVal(arrBox,0,"box_seq");  //채번
        String box_no = getVal(arrBox,0,"box_no");
        String box_barcd = getVal(arrBox,0,"box_barcd");
        String box_dt = getVal(arrBox,0,"box_dt");
        INVAR.put("box_seq",box_seq);
        INVAR.put("box_no",box_no);
        INVAR.put("box_barcd",box_barcd);
        INVAR.put("box_dt",box_dt);

        String qrySave = getQuery(pgmid, "saveBoxSeq"); 
        String qrySaveRun = bindVAR(qrySave,INVAR);
        JSONObject rst = executeSVC(conn, qrySaveRun);  //채번저장
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg");
        } else {
            conn.commit(); 
            OUTVAR.put("box",arrBox); //화면에 돌려줌
        }
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}   
if("searchBoxSeq".equals(func)) {
    Connection conn = null;     
    try {
        conn = getConn("LFN");
        conn.setAutoCommit(false);

        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        OUTVAR.put("INVAR",INVAR);
        
        String qry = getQuery(pgmid, "selectBoxSeq");  
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

if("saveBox".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);  
        OUTVAR.put("INVAR",INVAR);
        String qry= getQuery(pgmid,"saveBox");
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun);
        JSONObject rst = executeSVC(conn, qryRun); 
        
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else { 
            conn.commit();
            OUTVAR.put("text",rst);
        } 
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}

//박스 삭제
if("deleteBox".equals(func)) { 
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);

        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID); 
        String qry = getQuery(pgmid, "deleteBox"); 
        String qryRun = bindVAR(qry,INVAR);
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
//박스 선택 - 박스상품 조회
if("selectBoxGoods".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "selectBoxGoods"); 
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
//상품스캔
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
            OUTVAR.put("list",list); 
        }   
    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}
//상품저장(delete-insert방식)   
if("saveGoods".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);  
        String qryClear = getQuery(pgmid, "clearBoxGoods");
        qryClear = bindVAR(qryClear,INVAR);
        JSONObject rst = executeSVC(conn, qryClear);  
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else { 
            String qry = getQuery(pgmid, "insertBoxGoods");
            String qryRun = "";
            
            JSONArray arrList = getArray(INVAR,"list");
            for(int i = 0; i < arrList.size(); i++) {
                JSONObject row = getRow(arrList,i); 
                row.put("usid",USERID);
                row.put("comcd",ORGCD);
                row.put("box_no",getVal(INVAR,"box_no"));
                row.put("goods_seq",""+(i+1));
                /*                    
                    goods_cd	상품코드
                    minus	-
                    plus	+
                    qty	수량
                    delete	줄삭제
                    box_no	박스번호
                    goods_seq	상제품순번
                    
                   {comcd}
                 , {box_no}
                 , {goods_seq}
                 , {goods_cd}
                 , null
                 , {qty}
                 , {usid}
                 , SYSDATE
                 , {usid}
                */ 
                qryRun += bindVAR(qry,row) + "\n";
            } 
            OUTVAR.put("qry",qryRun);  
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
