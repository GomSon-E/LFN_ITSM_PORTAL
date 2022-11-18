<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "batch";
String pgmid   = "migrateInitSTK"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/
//search:조회 이벤트처리(DB_Read)     
if("searchMst".equals(func)) {
    Connection conn = null; 
    try {  
        // OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");   
        
        String qrymst_brand = getQuery(pgmid, "mst_brand"); 
        qrymst_brand = bindVAR(qrymst_brand,INVAR); 
        JSONArray mst_brand = selectSVC(conn, qrymst_brand);
        OUTVAR.put("mst_brand",mst_brand); 
        
        String qrymst_yyss = getQuery(pgmid, "mst_yyss"); 
        qrymst_yyss = bindVAR(qrymst_yyss,INVAR); 
        JSONArray mst_yyss = selectSVC(conn, qrymst_yyss);
        OUTVAR.put("mst_yyss",mst_yyss); 

        String qrymst_item = getQuery(pgmid, "mst_item"); 
        qrymst_item = bindVAR(qrymst_item,INVAR); 
        JSONArray mst_item = selectSVC(conn, qrymst_item);
        OUTVAR.put("mst_item",mst_item);  

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
        
        String qryNm = getVal(INVAR,"component"); 
        //list: 스타일생성(TM_GOODS, TM_GOODS_LISTING), 입고수량(TL_MOV)
        //list2: 원가(TM_GOODS_COSTING), 입고금액(TL_MOV)
        String qry = getQuery(pgmid, qryNm); 
        String qryRun = "";
        JSONArray arrList = getArray(INVAR,"list");
        
        String mov_no = getUUID(10);
        
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            row.put("comcd",ORGCD);
            row.put("mov_no",mov_no);
            row.put("mov_seq",(i+1));
            row.put("sssn_cd",getVal(INVAR,"sssn_cd"));
            row.put("sssn",getVal(INVAR,"sssn"));
            row.put("sale_start_dt",getVal(INVAR,"sale_start_dt"));
            row.put("sale_end_dt",getVal(INVAR,"sale_end_dt"));
            row.put("usid",USERID);
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

//search:조회 이벤트처리(DB_Read)     
if("search".equals(func)) {
    Connection conn = null; 
    try {  
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "qrysearch"); 
        INVAR.put("comcd",ORGCD);
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray rst = selectSVC(conn, qryRun);
        OUTVAR.put("rst",rst); 

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}

//searchCost:조회 이벤트처리(DB_Read)     
if("searchCost".equals(func)) {
    Connection conn = null; 
    try {  
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "qrysearchCost"); 
        INVAR.put("comcd",ORGCD);
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray list2 = selectSVC(conn, qryRun);
        OUTVAR.put("list2",list2); 

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
