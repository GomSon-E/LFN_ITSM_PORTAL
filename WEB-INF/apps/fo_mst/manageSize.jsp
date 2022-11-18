<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_mst";
String pgmid   = "manageSize"; 
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
        String qry = getQuery(pgmid, "qrysearch"); 
        String qryRun = bindVAR(qry,INVAR); 
        JSONArray list = selectSVC(conn, qryRun);
        OUTVAR.put("list",list);
        
        
        String qryRange = getQuery(pgmid, "searchRange"); 
        qryRange = bindVAR(qryRange,INVAR); 
        JSONArray rangelist = selectSVC(conn, qryRange);
        OUTVAR.put("rangelist",rangelist); 

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}
//mapSearch: 조회 이벤트처리(DB_Read)     
if("mapSearch".equals(func)) {
    Connection conn = null; 
    try {   
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "searchMap");  
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

//save:저장 이벤트처리(DB_Write)
if("save".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "qrysave");
        String qryRun = "";
        JSONArray arrList = getArray(INVAR,"list");
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            if("D".equals(getVal(row,"crud"))) row.put("cd_stat","N");
            else row.put("cd_stat","Y");
            row.put("comcd", getVal(INVAR,"comcd") );  //조회조건에 입력된 값을 사용
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

//save:map저장 이벤트처리(DB_Write)
if("saveMap".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "mergeMapSZ");
        String qryRun = "";
        JSONArray arrList = getArray(INVAR,"map");
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            if("D".equals(getVal(row,"crud"))) row.put("cd_stat","N");
            else row.put("cd_stat","Y");
            row.put("grpcd", getVal(INVAR,"grpcd") );  
            row.put("keycd", getVal(INVAR,"keycd") );
            row.put("nm", getVal(INVAR,"nm"));
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

//searchDet: 조회 이벤트처리(DB_Read)     
if("searchDet".equals(func)) {
    Connection conn = null; 
    try {   
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

//save:저장 이벤트처리(DB_Write)
if("saveDet".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "saveRange"); 
        String qryRun = "";
        
        INVAR.put("usid",USERID);
        qryRun += bindVAR(qry,INVAR); 
        
        String qryDet = getQuery(pgmid, "saveDet"); 
        JSONArray arrList = getArray(INVAR,"det"); 
        String[] items = getVal(INVAR,"apply_itemcd").split(" ");
        for(int j = 0; j < items.length; j++) {
            if(!isNull(items[j].trim())) {
                for(int i = 0; i < arrList.size(); i++) {
                    JSONObject row = getRow(arrList,i); 
                    row.put("comcd", getVal(INVAR,"comcd") );  //조회조건에 입력된 값을 사용
                    row.put("itemcd", items[j]);
                    row.put("usid",USERID); 
                    qryRun += bindVAR(qryDet,row) + "\n";
                } 
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
        
        String qryRange = getQuery(pgmid, "searchRange"); 
        qryRange = bindVAR(qryRange,INVAR); 
        JSONArray rangelist = selectSVC(conn, qryRange);
        OUTVAR.put("rangelist",rangelist); 
        
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}

//deleteRange
if("deleteRange".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "deleteRange"); 
        String qryRun = bindVAR(qry,INVAR); 
        JSONObject rst = executeSVC(conn, qryRun);  
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else { 
            conn.commit();
        } 
        
        String qryRange = getQuery(pgmid, "searchRange"); 
        qryRange = bindVAR(qryRange,INVAR); 
        JSONArray rangelist = selectSVC(conn, qryRange);
        OUTVAR.put("rangelist",rangelist); 
        
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
