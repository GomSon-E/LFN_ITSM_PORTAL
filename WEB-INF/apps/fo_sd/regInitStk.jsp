<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_sd";
String pgmid   = "regInitStk"; 
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
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "qrysearchList"); 
        INVAR.put("comcd",ORGCD);
        String cancel = "";
        if("Y".equals(getVal(INVAR,"cancel_yn"))) cancel="CANCEL"; //취소문서 포함조회
        INVAR.put("cancel",cancel);

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

//searchDet:조회 이벤트처리(DB_Read)     
if("searchMst".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);        
        OUTVAR.put("INVAR",INVAR); //for debug

        conn = getConn("LFN");  

        String qryMst = getQuery(pgmid, "qrysearchMst"); 
        qryMst = bindVAR(qryMst,INVAR);
        OUTVAR.put("qryMst",qryMst); //for debug
        JSONArray mst = selectSVC(conn, qryMst);
        OUTVAR.put("mst",mst); 

        String qryDet = getQuery(pgmid, "qrysearchDet"); 
        qryDet = bindVAR(qryDet,INVAR);
        OUTVAR.put("qryDet",qryDet); //for debug
        JSONArray det = selectSVC(conn, qryDet);
        OUTVAR.put("det",det);  

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}

//calc: 품번점검 조회 이벤트처리(DB_Read)     
if("calc".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);        
        String[] goods_cds = getVal(INVAR,"goods_cds").split(",");
        String where = "( A.goods_cd IN (";
        int cnt = 0;
        for(int i=0; i < goods_cds.length; i++) {
            where += "'"+goods_cds[i]+"',"; cnt++;
            if(goods_cds[i].length() > 11) {
                where += "'"+(goods_cds[i].substring(0,11))+"',"; cnt++;
            }
            if(goods_cds[i].length() > 10) {
                where += "'"+(goods_cds[i].substring(0,10))+"',"; cnt++;
            }
            if(goods_cds[i].length() > 9) {
                where += "'"+(goods_cds[i].substring(0,9))+"',"; cnt++;
            } 
            if(cnt > 900) {
                where += "'') OR A.goods_cd IN (";
                cnt = 0;
            } 
        }
        where += "''))";
        INVAR.put("where",where);
        OUTVAR.put("INVAR",INVAR); //for debug

        conn = getConn("LFN");  

        String qryCalc = getQuery(pgmid, "qrysearchCalc"); 
        qryCalc = bindVAR(qryCalc,INVAR);
        OUTVAR.put("qryCalc",qryCalc); //for debug
        JSONArray calc = selectSVC(conn, qryCalc);
        OUTVAR.put("calc",calc);  

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

        String mov_no = getVal(INVAR,"mov_no");
        if("".equals(mov_no)) {  //첫번째 저장시 수불전표번호 채번
            JSONArray arrMovNo = selectSVC(conn,"SELECT SEQ_MOV_NO.NEXTVAL MOV_NO FROM DUAL");
            mov_no = getVal(arrMovNo,0,"mov_no");
        }
        OUTVAR.put("mov_no",mov_no);
        String qry = getQuery(pgmid, "qrysave");
        String qryRun = "";
        JSONArray arrList = getArray(INVAR,"detreg");
        
        int txCnt = 0;  int oneTx = 50;
        JSONObject rst = new JSONObject();
        rst.put("rtnCd","OK");
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            row.put("comcd",ORGCD);
            row.put("mov_no",mov_no);
            row.put("mov_dt",getVal(INVAR,"mov_dt"));
            row.put("whcd",getVal(INVAR,"whcd"));
            row.put("doc_tp",getVal(INVAR,"doc_tp"));
            row.put("doc_no",getVal(INVAR,"doc_no")); 
            row.put("usid",USERID);
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
        if(!"".equals(qryRun)) rst = executeSVC(conn, qryRun);          
        /******************************************/
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
 
//cancel:문서삭제 저장 이벤트처리(DB_Write)
if("cancel".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);

        JSONArray arrMovNo = selectSVC(conn,"SELECT SEQ_MOV_NO.NEXTVAL MOV_NO FROM DUAL");
        String mov_no_to = getVal(arrMovNo,0,"mov_no"); //취소문서 수불전표번호 채번
        OUTVAR.put("mov_no",mov_no_to);
        
        String qry = getQuery(pgmid, "qrycancel");
        String qryRun = "";
        INVAR.put("comcd",ORGCD);
        INVAR.put("mov_no_to",mov_no_to);
        INVAR.put("usid",USERID);
        qryRun = bindVAR(qry,INVAR);
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
