<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_mst";
String pgmid   = "manageItem"; 
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
            conn = getConn("LFN");  
            String qry = getQuery(pgmid, "searchItem"); 
            String qryRun = bindVAR(qry,INVAR);
            JSONArray list = selectSVC(conn, qryRun);
            OUTVAR.put("list",list); 

        } catch (Exception e) { 
            rtnCode = "ERR";
            rtnMsg = e.toString();				
        } finally {
            closeConn(conn);
        }  
    }

    //save:저장 이벤트처리(DB_Write)
    else if("save".equals(func)) {
        Connection conn = null; 
        try {  
            conn = getConn("LFN");
            conn.setAutoCommit(false);
            
            String qry = getQuery(pgmid, "saveItem");
            String qryDel = getQuery(pgmid, "deleteItem");
            String qryRun = "";
            JSONArray arrList = getArray(INVAR,"list");
            OUTVAR.put("arrList", arrList);
            for(int i = 0; i < arrList.size(); i++) {
                JSONObject row = getRow(arrList,i); 
                if("D".equals(getVal(row,"crud"))) {
                    row.put("comcd", getVal(INVAR,"comcd"));
                    row.put("item_lv", getVal(INVAR,"item_lv"));
                    row.put("usid",  USERID); 
                    qryRun += bindVAR(qryDel,row) + "\n";
                } 
            }
            for(int i = 0; i < arrList.size(); i++) {
                JSONObject row = getRow(arrList,i); 
                if(!"D".equals(getVal(row,"crud"))) {
                    row.put("comcd", getVal(INVAR,"comcd"));
                    row.put("item_lv", getVal(INVAR,"item_lv"));
                    row.put("usid",  USERID); 
                    qryRun += bindVAR(qry,row) + "\n";
                } 
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


//searchDet: 조회 이벤트처리(DB_Read)     
if("searchDet".equals(func)) {
    Connection conn = null; 
    try {   
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "qrysearchDet"); 
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

//saveDet:  
if("saveDet".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "saveItem");
        String qryDet = getQuery(pgmid, "qrysaveDet"); 
        String qryDelDet = getQuery(pgmid, "qrydeleteDet");
        String qryRun = "";
        
        INVAR.put("usid",USERID);
        qryRun += bindVAR(qry,INVAR);
        
        String item_lv = "DET";;
        if("REP".equals(getVal(INVAR,"item_lv"))) item_lv = "NOR"; 
        
        JSONArray arrList = getArray(INVAR,"det");
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            if("D".equals(getVal(row,"crud"))) {
                row.put("comcd", getVal(INVAR,"comcd"));
                row.put("up_itemcd", getVal(INVAR,"itemcd"));
                row.put("item_lv", item_lv);
                row.put("usid",  USERID);  
                qryRun += bindVAR(qryDelDet,row) + "\n";
            }
        } 
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            if(!"D".equals(getVal(row,"crud"))) {
                row.put("comcd", getVal(INVAR,"comcd"));
                row.put("up_itemcd", getVal(INVAR,"itemcd"));
                row.put("item_lv", item_lv);
                row.put("usid",  USERID);  
                qryRun += bindVAR(qryDet,row) + "\n";
            }
        } 
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

//searchMap: 조회 이벤트처리(DB_Read)     
if("searchMap".equals(func)) {
    Connection conn = null; 
    try {   
        conn = getConn("LFN"); 
        String qry = getQuery(pgmid, "searchMapITEM");  
        String qryRun = bindVAR(qry,INVAR); 
        JSONArray map = selectSVC(conn, qryRun);
        OUTVAR.put("map",map); 

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}

//save:map저장 이벤트처리(DB_Write)
if("saveMap".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        String qryMst = getQuery(pgmid, "saveItem"); 
        String qry = getQuery(pgmid, "mergeMapITEM");
        String qryDel = getQuery(pgmid, "deleteMapITEM");
        String qryRun = "";
        
        //품목정보 먼저 저장
        INVAR.put("usid",  USERID); 
        qryRun += bindVAR(qryMst, INVAR) + "\n";

        
        JSONArray arrList = getArray(INVAR,"map");
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i);
            if("D".equals(getVal(row,"crud"))) { 
                row.put("grpcd", getVal(INVAR,"grpcd") );  
                row.put("keycd", getVal(INVAR,"keycd") );
                row.put("nm", getVal(INVAR,"nm"));
                row.put("usid",USERID); 
                qryRun += bindVAR(qryDel,row) + "\n";
            }
        }
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i);
            if(!"D".equals(getVal(row,"crud"))) { 
                row.put("grpcd", getVal(INVAR,"grpcd") );  
                row.put("keycd", getVal(INVAR,"keycd") );
                row.put("nm", getVal(INVAR,"nm"));
                row.put("usid",USERID); 
                qryRun += bindVAR(qry,row) + "\n";
            }
        } 
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
