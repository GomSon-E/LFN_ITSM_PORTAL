<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_pos";
String pgmid   = "GIconfirmM"; 
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
        OUTVAR.put("boxlist",boxlist);  
        
    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}

//searchDet : 박스내 상품조회
if("searchDet".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID); 
    
        conn = getConn("LFN"); 
        
        String qry = getQuery(pgmid, "searchDet");
        String qryRun = bindVAR(qry,INVAR); 
        OUTVAR.put("qryRun",qryRun);
        JSONArray det = selectSVC(conn, qryRun);
        OUTVAR.put("det",det); 
        
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}


if("searchDetGIA".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID); 
    
        conn = getConn("LFN"); 
        
        String qry = getQuery(pgmid, "searchDetGIA");
        String qryRun = bindVAR(qry,INVAR); 
        JSONArray det = selectSVC(conn, qryRun);
        OUTVAR.put("det",det); 
        
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}

//searchDetExp : 박스내 상품조회_초도출하(GIA)
if("searchDetExp".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID); 
    
        conn = getConn("LFN"); 
        
        String qry = getQuery(pgmid, "searchDetExp");
        String qryRun = bindVAR(qry,INVAR); 
        JSONArray detexp = selectSVC(conn, qryRun);
        OUTVAR.put("detexp",detexp); 
        
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}

//searchSKU : GIA(초도출하) 14자리 SKU단위 상품코드 / 존재하지않은 sku단위상품코드 추가
if("searchSKU".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN"); 
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "searchSKU");
        String qryRun = bindVAR(qry,INVAR); 
        JSONArray sku = selectSVC(conn, qryRun);
        if(sku.size()==1) {
            String check_val = getVal(sku, 0, "check_val");
            if("ST".equals(check_val)) {
                JSONObject row = getRow(sku,0);
                String qryINS = getQuery(pgmid, "insertSKU");
                row.put("comcd",ORGCD);
                qryINS = bindVAR(qryINS,row); 
                JSONObject rst = executeSVC(conn, qryINS);  
                if(!"OK".equals(getVal(rst,"rtnCd"))) {
                    conn.rollback();
                    rtnCode = getVal(rst,"rtnCd"); 
                    rtnMsg  = getVal(rst,"rtnMsg"); 
                } else { 
                    conn.commit();
                } 
            } 
        }
        OUTVAR.put("sku",sku); 
        
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}

//saveDet:입고등록 이벤트처리(DB_Write)
if("saveDet".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID); 
        
        conn = getConn("LFN");
        conn.setAutoCommit(false);
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
            conn.commit();
        } 
         
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}

//saveSKU : 박스내 상품(SKU단위) 확정량 저장
if("saveSKU".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID); 
        
        JSONArray arrDetExp = getArray(INVAR,"detExp"); //예정정보
        String box_no = getVal(arrDetExp,0,"box_no");
        
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qrysaveSKU = getQuery(pgmid, "saveSKU");

        String qryRun = "";  
        
        JSONArray arrList = getArray(INVAR,"det"); //확정정보
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i);  
            row.put("box_no",box_no);
            row.put("comcd",ORGCD);
            row.put("usid",USERID);
            row.put("lg_ord_no",getVal(INVAR,"lg_ord_no"));
            qryRun += bindVAR(qrysaveSKU,row) + "\n";
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

//saveDetExp : 원래 예정정보에서 추가되는 애들만 저장
if("saveDetExp".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID); 
        
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String saveDetExp = getQuery(pgmid, "saveDetExp"); 
        String qryRun = "";
        
        JSONArray arrList = getArray(INVAR,"newlist"); 
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i);  
            row.put("comcd",ORGCD);
            row.put("usid",USERID);
            row.put("lg_ord_no",getVal(INVAR,"lg_ord_no"));
            qryRun += bindVAR(saveDetExp,row) + "\n";
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


//save:입고확정 이벤트처리(DB_Write)
if("save".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID); 
        
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qrysaveMst = getQuery(pgmid, "saveMst"); 
        
        String qryRun = bindVAR(qrysaveMst,INVAR); 
        
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

//searchDet2 : 박스내 상품조회
if("searchDet2".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID); 
    
        conn = getConn("LFN"); 
        
        String qry = getQuery(pgmid, "searchDet2");
        String qryRun = bindVAR(qry,INVAR); 
        JSONArray det = selectSVC(conn, qryRun);
        OUTVAR.put("det",det); 
        
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}

//searchDet : 박스내 상품조회
if("searchDocno".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID); 
    
        conn = getConn("LFN"); 
        
        String qry = getQuery(pgmid, "searchDocno");
        String qryRun = bindVAR(qry,INVAR); 
        JSONArray det = selectSVC(conn, qryRun);
        OUTVAR.put("det",det); 
        
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}

//saveNewDet:대상확정 이벤트처리(DB_Write)
if("saveNewDet".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        
        String qry = getQuery(pgmid, "saveNewDet");
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
