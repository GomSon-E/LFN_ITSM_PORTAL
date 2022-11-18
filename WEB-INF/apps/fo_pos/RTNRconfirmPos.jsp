<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_pos";
String pgmid   = "RTNRconfirmPos"; 
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
        OUTVAR.put("det",boxlist);  
        
    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
} 

//saveDet:입고등록 이벤트처리(DB_Write)
if("saveQty".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID); 
        
        conn = getConn("LFN");
        conn.setAutoCommit(false); 
        
        String qryupdateMst = getQuery(pgmid, "updateMst"); 
        String qrysaveDet = getQuery(pgmid, "saveDet"); 
        
        String qryRun = "";  
        qryRun = bindVAR(qryupdateMst,INVAR);

        JSONObject rst = executeSVC(conn, qryRun);  
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else { 
            qryRun = "";         
            JSONArray arrList = getArray(INVAR,"det");
            for(int i = 0; i < arrList.size(); i++) {
                JSONObject row = getRow(arrList,i);  
                row.put("comcd",ORGCD);
                row.put("usid",USERID);
                row.put("lg_ord_no",getVal(INVAR,"lg_ord_no"));
                qryRun += bindVAR(qrysaveDet,row) + "\n";
            }
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

//save:입고확정 이벤트처리(DB_Write)
if("save".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID); 
        
        conn = getConn("LFN");
        conn.setAutoCommit(false); 
        
        /* det우선 저장 */
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
            String qrysaveMst = getQuery(pgmid, "saveMst"); 
            qryRun = bindVAR(qrysaveMst,INVAR);  
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

//searchMovtp: 이동 유형 조회 이벤트처리(DB_Read)     
if("searchMovtp".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN"); 
        
        String qry = getQuery(pgmid, "searchMovtp");
        String qryRun = bindVAR(qry,INVAR); 
        JSONArray mov_tp = selectSVC(conn, qryRun);
        OUTVAR.put("mov_tp",mov_tp); 
        
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
