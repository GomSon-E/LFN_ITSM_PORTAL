<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_sd";
String pgmid   = "solidReplenish"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/
//search:패킹조회 이벤트처리(DB_Read)     
if("search".equals(func)) {
    Connection conn = null; 
    try {  
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        INVAR.put("comcd",ORGCD);
        String qry = getQuery(pgmid, "qrysearchpack"); 
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

//searchDet:상세조회 이벤트처리(DB_Read)     
if("searchDet".equals(func)) {
    Connection conn = null; 
    try {  
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        INVAR.put("comcd",ORGCD);
        String qry = getQuery(pgmid, "qrysearchDet"); 
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

//searchDet2:상세조회 이벤트처리(DB_Read)     
if("searchDet2".equals(func)) {
    Connection conn = null; 
    try {  
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        INVAR.put("comcd",ORGCD);
        String qry = getQuery(pgmid, "qrysearchDet2"); 
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


//searchres:배분현황 이벤트처리(DB_Read)     
if("searchres".equals(func)) {
    Connection conn = null; 
    try {  
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        INVAR.put("comcd",ORGCD);
        
        String qry = getQuery(pgmid, "qrysearchres"); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray list = selectSVC(conn, qryRun);
        OUTVAR.put("list",list); 
        
        qry = getQuery(pgmid, "qrysearchres2");
        qryRun = bindVAR(qry,INVAR);
        JSONArray list2 = selectSVC(conn, qryRun);
        OUTVAR.put("list2",list2);

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}


if("save".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        
        String qryMst = getQuery(pgmid, "qrysavedel");
        String qryDet = getQuery(pgmid, "qrysave");
        String qryRun = "";
        qryRun = bindVAR(qryMst,INVAR);
        OUTVAR.put("qryMst",qryRun);
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
                
                INVAR.put("box_no",getVal(row,"box_no"));
                INVAR.put("shopcd",getVal(row,"shopcd"));
                INVAR.put("stat_cd",getVal(row,"stat_cd"));
                INVAR.put("qty",getVal(row,"qty"));
                INVAR.put("goods_cd",getVal(row,"goods_cd"));
                INVAR.put("sp_qty",getVal(row,"sp_qty"));
                //String qryDetRun = bindVAR(qryDet,row);
                String qryDetRun = bindVAR(qryDet,INVAR);
                qryRun += qryDetRun + "\n"; 
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

if("saveDet".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        
        String qryDet = getQuery(pgmid, "qrysaveDet");
        String qryRun = "";

        JSONArray arrList = getArray(INVAR,"det");
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            INVAR.put("box_no",getVal(row,"box_no"));
            INVAR.put("shopcd",getVal(row,"shopcd"));

            String qryDetRun = bindVAR(qryDet,INVAR);
            qryRun += qryDetRun + "\n"; 
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


//cance:배분취소 이벤트처리(DB_Write)
if("cancel".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        INVAR.put("comcd",ORGCD);
        String qry = getQuery(pgmid, "qrycancel"); 

        String qryRun = "";
        //JSONArray arrList = getArray(INVAR,"list");
        
        JSONArray arrList = getArray(INVAR,"box_no");
        String box_nos = "";
        for(int i=0; i < arrList.size(); i++) {
            box_nos +=  "'"+getVal(arrList,i,"no")+"',";
        }
        box_nos += "''";
        INVAR.put("box_nos",box_nos);
        OUTVAR.put("INVAR",INVAR); //for debug
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


//saveD:대상확정 이벤트처리(DB_Write)
if("saveDone".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        
        String qryMst = getQuery(pgmid, "qrysaveMst");
        //String qryDet = getQuery(pgmid, "qryupdate");
        String qryRun = "";

        
        qryRun = bindVAR(qryMst,INVAR);  
        OUTVAR.put("qryMst",qryRun);
        JSONObject rst = executeSVC(conn, qryRun);  
        
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else {  
            conn.commit();
            /*
            String upd_dist_no = getVal(rst,"rtnMsg"); 
            
            qryRun = "";
            JSONArray arrList = getArray(INVAR,"det");
            //차수묶음
            for(int i = 0; i < arrList.size(); i++) {
            
                JSONObject row = getRow(arrList,i); 
                row.put("comcd",ORGCD); 
                row.put("usid",USERID);
                row.put("upd_dist_no",upd_dist_no);
                row.put("dist_seq",(i+1));
                row.put("dist_no",getVal(INVAR,"dist_no"));
                String qryDetRun = bindVAR(qryDet,row);
                qryRun += qryDetRun + "\n"; 
            }          
            rst = executeSVC(conn, qryRun);  
            if(!"OK".equals(getVal(rst,"rtnCd"))) {
                conn.rollback();
                rtnCode = getVal(rst,"rtnCd"); 
                rtnMsg  = getVal(rst,"rtnMsg"); 
            } else { 
            OUTVAR.put("upd_dist_no",upd_dist_no); 
                conn.commit();
            } */
        }

    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}

//autoSP
if("autoSP".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        String qry = getQuery(pgmid, "qryautosp"); 
        qry = bindVAR(qry,INVAR);

        JSONObject rst = executeSVC(conn, qry);  
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
