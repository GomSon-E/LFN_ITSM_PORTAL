<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_mst";
String pgmid   = "manageShop"; 
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
        String qry = getQuery(pgmid, "selectshop"); 
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
        String qry = getQuery(pgmid, "mergeshop");
        String qryRun = "";
        JSONArray arrList = getArray(INVAR,"list");
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i);  
            row.put("comcd", getVal(INVAR,"comcd") );
            row.put("usid",USERID);
            qryRun += bindVAR(qry,row) + "\n";
        } 
        OUTVAR.put("qryRun",qryRun);
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
//매장정보 조회    
if("searchMst".equals(func)) {    
    Connection conn = null; 
    try {  
        conn = getConn("LFN");  
        String qryMst = getQuery(pgmid, "selectshop"); 
        qryMst = bindVAR(qryMst,INVAR);
        JSONArray mst = selectSVC(conn, qryMst);
        OUTVAR.put("mst",mst); 
        
        String qryPos = getQuery(pgmid, "qrysearchPos"); 
        qryPos = bindVAR(qryPos,INVAR);
        JSONArray pos = selectSVC(conn, qryPos);
        OUTVAR.put("pos",pos); 
        
        String qryDet = getQuery(pgmid, "qrysearchDet"); 
        qryDet = bindVAR(qryDet,INVAR);
        JSONArray det = selectSVC(conn, qryDet);
        OUTVAR.put("det",det);  

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}  

//saveMst: 매장정보 저장
if("saveMst".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "mergeshop");
        String qryDet = getQuery(pgmid, "qrysaveDet");
        String qryUpdDet = getQuery(pgmid, "qryupdateDet");
        String qryDelDet = getQuery(pgmid, "qrydeleteDet");
        String qryMergePos = getQuery(pgmid, "qryMergePos");
        String qryRun = "";
        
        /* 경영인마스터 저장 */
        INVAR.put("usid",USERID);
        qryRun += bindVAR(qry,INVAR);
        JSONArray arrList = getArray(INVAR,"det");
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            if("D".equals(getVal(row,"crud"))) {
                row.put("comcd", getVal(INVAR,"comcd"));
                row.put("shopcd", getVal(INVAR,"shopcd"));
                row.put("usid",  USERID); 
                /* 매장이력 삭제 */
                qryRun += bindVAR(qryDelDet,row) + "\n";
            }
        } 
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            if("C".equals(getVal(row,"crud"))) {
                row.put("comcd", getVal(INVAR,"comcd"));
                row.put("shopcd", getVal(INVAR,"shopcd"));
                row.put("usid",  USERID);
                /* 매장이력 저장 */
                qryRun += bindVAR(qryDet,row) + "\n";
            }
        }
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            if("U".equals(getVal(row,"crud"))) {
                row.put("comcd", getVal(INVAR,"comcd"));
                row.put("shopcd", getVal(INVAR,"shopcd"));
                row.put("usid",  USERID);
                /* 매장이력 저장 */
                qryRun += bindVAR(qryUpdDet,row) + "\n";
            }
        }
        /* POS정보 저장 */
        JSONArray arrListPos = getArray(INVAR,"pos");
        for(int i = 0; i < arrListPos.size(); i++) {
            JSONObject row = getRow(arrListPos,i); 
            row.put("comcd", getVal(INVAR,"comcd"));
            row.put("shopcd", getVal(INVAR,"shopcd"));
            row.put("usid",  USERID); 
            qryRun += bindVAR(qryMergePos,row) + "\n"; 
        } 
        OUTVAR.put("qry",qryRun);
        //실행
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
