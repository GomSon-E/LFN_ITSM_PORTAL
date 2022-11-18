<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_mst";
String pgmid   = "manageSeason"; 
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
        String qry = getQuery(pgmid, "search"); 
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
        String qry = getQuery(pgmid, "save");
        String qryDel = getQuery(pgmid, "delete");
        String qryRun = "";
        JSONArray arrList = getArray(INVAR,"list");
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            if("D".equals(getVal(row,"crud"))) {
                row.put("comcd", getVal(INVAR,"comcd"));
                row.put("usid",  USERID); 
                qryRun += bindVAR(qryDel,row) + "\n";
            }
        } 
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            if(!"D".equals(getVal(row,"crud"))) {
                row.put("comcd",getVal(INVAR,"comcd"));
                row.put("usid",USERID);
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
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray det = selectSVC(conn, qryRun);
        OUTVAR.put("det",det); 

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}

//saveDet: 운영시즌 저장 이벤트처리(DB_Write)     
if("saveDet".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "save");
        String qryDet = getQuery(pgmid, "qrysaveDet");
        String qryUpdDet = getQuery(pgmid, "qryupdateDet");
        String qryDelDet = getQuery(pgmid, "qrydeleteDet");
        String qryRun = "";
        /* 운영시즌 저장 */
        INVAR.put("usid",USERID);
        INVAR.put("yyyy_cd", getVal(INVAR,"yyyy"));
        qryRun += bindVAR(qry,INVAR); 
        
        JSONArray arrList = getArray(INVAR,"det");
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            if("D".equals(getVal(row,"crud"))) {
                row.put("comcd", getVal(INVAR,"comcd"));
                row.put("sssn_cd", getVal(INVAR,"sssn_cd"));
                row.put("usid",  USERID);  
                qryRun += bindVAR(qryDelDet,row) + "\n";
            }
        } 
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            if(!"D".equals(getVal(row,"crud"))) {
                row.put("comcd", getVal(INVAR,"comcd"));
                row.put("sssn_cd", getVal(INVAR,"sssn_cd"));
                row.put("usid",  USERID); 
                qryRun += bindVAR(qryDet,row) + "\n";
            }
        }
        /*
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            if("U".equals(getVal(row,"crud"))) {
                row.put("comcd", getVal(INVAR,"comcd"));
                row.put("sssn_cd", getVal(INVAR,"sssn_cd"));
                row.put("usid",  USERID); 
                qryRun += bindVAR(qryUpdDet,row) + "\n";
            }
        }
        */
        
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
