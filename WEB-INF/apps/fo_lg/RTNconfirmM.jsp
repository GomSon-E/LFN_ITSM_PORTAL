<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_lg";
String pgmid   = "RTNconfirmM"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/
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
        JSONArray det = selectSVC(conn, qryRun);
        OUTVAR.put("det",det); 
        
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}
/*
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
}*/

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
            row.put("box_no",getVal(INVAR,"box_no"));
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
