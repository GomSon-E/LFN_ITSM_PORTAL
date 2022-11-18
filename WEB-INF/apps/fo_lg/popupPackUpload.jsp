<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_lg";
String pgmid   = "popupPackUpload"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 

if("savePack".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);  
        String whcd = getVal(INVAR,"whcd");
        
        String qry = getQuery(pgmid, "savePack");
        String qryRun = "";
        
        int txCnt = 0;  int oneTx = 50;
        JSONObject rst = executeSVC(conn, qryRun);  
        rst.put("rtnCd","OK");
        
        JSONArray arrList = getArray(INVAR,"list");

        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            row.put("usid",USERID);
            row.put("comcd",ORGCD);
            row.put("whcd",whcd);
            //row.put("tab_tp",getVal(INVAR,"tab_tp"));
            qryRun += bindVAR(qry,row) + "\n";
            
            if(txCnt > oneTx) { 
                rst = executeSVC(conn, qryRun);   
                qryRun="";
                if(!"OK".equals(getVal(rst,"rtnCd"))) break;
                txCnt = 0;
            } else {
                txCnt++;
            }
            
        }  
        OUTVAR.put("qry",qryRun);
        if(!"".equals(qryRun)) rst = executeSVC(conn, qryRun);
        
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

if("selectBoxSeq".equals(func)) {
    Connection conn = null;     
    try {
        conn = getConn("LFN");
        conn.setAutoCommit(false);

        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        OUTVAR.put("INVAR",INVAR);
        
        String qry = getQuery(pgmid, "selectBoxSeq");  
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray arrBox = selectSVC(conn, qryRun);
        String box_barcd = getVal(arrBox,0,"box_barcd");
        String box_seq = getVal(arrBox,0,"box_seq");
        OUTVAR.put("box_barcd",box_barcd);
        OUTVAR.put("box_seq",box_seq);
        JSONObject rst = executeSVC(conn, qryRun);  //채번저장
        
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}   

/***************************************************************************************************/// *********************************************************************************************/
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
