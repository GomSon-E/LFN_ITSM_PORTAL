<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_lg";
String pgmid   = "diligenceSTKM"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/
//search:조회 이벤트처리(DB_Read)     
if("retrieveMst".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "retrieveMst"); 
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

//박스 삭제
if("deleteMst".equals(func)) { 
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID); 
        String qry = getQuery(pgmid, "deleteMst"); 
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
}if("deleteDet".equals(func)) { 
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID); 
        String qry = getQuery(pgmid, "deleteDet"); 
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
if("selectGoods".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "retrieveDet"); 
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


if("insertMst".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);  
        OUTVAR.put("INVAR",INVAR);
        String qry= getQuery(pgmid,"insertMst");
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

if("saveGoods".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        System.out.println(INVAR);
        String qry = getQuery(pgmid, "mergeDet");
        String qryRun = "";
        /* 운영시즌 저장 */
        JSONArray arrList = getArray(INVAR,"list");

        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            row.put("usid",USERID);
            row.put("comcd",ORGCD);
            row.put("lg_ord_no",getVal(INVAR,"lg_ord_no"));
            qryRun += bindVAR(qry,row) + "\n";
        }  
        OUTVAR.put("qry",qryRun);
        JSONObject rst = executeSVC(conn, qryRun);  
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg");
            System.out.println(rtnMsg);

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
