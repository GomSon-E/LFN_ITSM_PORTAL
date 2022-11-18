<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_mst";
String pgmid   = "manageColor"; 
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
            //OUTVAR.put("INVAR",INVAR); //for debug
            conn = getConn("LFN");  
            String qry = getQuery(pgmid, "search"); 
            INVAR.put("up_colorcd"," ");
            INVAR.put("color_lv","REP");
            String qryRun = bindVAR(qry,INVAR);
            //OUTVAR.put("qryRun",qryRun); //for debug
            JSONArray list = selectSVC(conn, qryRun);
            OUTVAR.put("list",list); 

        } catch (Exception e) { 
            rtnCode = "ERR";
            rtnMsg = e.toString();				
        } finally {
            closeConn(conn);
        }  
    }else if("save".equals(func)) { //save:저장 이벤트처리(DB_Write)
        Connection conn = null; 
        try {  
            conn = getConn("LFN");
            conn.setAutoCommit(false);
            String qry = getQuery(pgmid, "save");
            String qryRun = "";
            JSONArray arrList = getArray(INVAR,"list");
            for(int i = 0; i < arrList.size(); i++) {
                JSONObject row = getRow(arrList,i);
                if("D".equals(getVal(row,"crud"))) row.put("cd_stat","N");
                else row.put("cd_stat","Y");
                row.put("comcd", getVal(INVAR,"comcd") );  //조회조건에 입력된 값을 사용
                row.put("color_lv","REP");
                row.put("up_colorcd"," ");
                row.put("usid",USERID);  //현재접속한 사용자ID = USERID 
                qryRun += bindVAR(qry,row) + "\n";         //쿼리문에 row정보를 바인딩
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
        String qry = getQuery(pgmid, "search"); 
        INVAR.put("color_lv","NOR"); 
        INVAR.put("up_colorcd",getVal(INVAR,"colorcd"));
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

//searchMap : 공급사 코드 매칭 조회 이벤트처리(DB_Read)    
if("searchMap".equals(func)) {
    Connection conn = null; 
    try {   
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "searchMapCOLOR"); 
        //INVAR.put("keycd",getVal(INVAR,"colorcd"));
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

//saveDet:  
if("saveDet".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "save");
        String qryDet = getQuery(pgmid, "save");  
        String qryRun = "";
        
        INVAR.put("usid",USERID);
        INVAR.put("color_lv","REP");
        INVAR.put("cd_stat","Y");
        INVAR.put("up_colorcd"," ");
        qryRun += bindVAR(qry,INVAR); 
        
        JSONArray arrList = getArray(INVAR,"det");
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            if("D".equals(getVal(row,"crud"))) row.put("cd_stat","N");
            else row.put("cd_stat","Y"); 
            row.put("comcd", getVal(INVAR,"comcd"));
            row.put("up_colorcd", getVal(INVAR,"colorcd"));
            row.put("color_lv", "NOR");
            row.put("usid",  USERID);  
            qryRun += bindVAR(qryDet,row) + "\n"; 
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


//saveMap:  공급사 코드매칭 저장 이벤트처리(DB_Write)    
if("saveMap".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "mergeMapCOLOR");
        String qryDel = getQuery(pgmid, "deleteMapCOLOR");
        //String qryMap = getQuery(pgmid, "mergeMapCOLOR");  
        String qryRun = "";
        
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
            if("D".equals(getVal(row,"crud"))) row.put("cd_stat","N");
            else row.put("cd_stat","Y");
            row.put("grpcd", getVal(INVAR,"grpcd") );  
            row.put("keycd", getVal(INVAR,"keycd") );
            row.put("nm", getVal(INVAR,"nm"));
            row.put("usid",USERID); 
            qryRun += bindVAR(qry,row) + "\n";
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
