<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "plas";
String pgmid   = "plasDocReg"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/
//readInit:조회 이벤트처리(DB_Read)     
if("readInit".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        OUTVAR.put("INVAR",INVAR); //for debug 
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "qryreadInit_mst"); 
        String qryRun = bindVAR(qry,INVAR); 
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray mst = selectSVC(conn, qryRun);
        OUTVAR.put("docid", getUUID(20));
        OUTVAR.put("mst",mst);  

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}

//searchAPline:조회 이벤트처리(DB_Read)     
if("searchAPline".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        OUTVAR.put("INVAR",INVAR); //for debug 
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "qryAPline"); 
        String qryRun = bindVAR(qry,INVAR); 
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray apline = selectSVC(conn, qryRun); 
        OUTVAR.put("apline",apline);  

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
        INVAR.put("usid",USERID);
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        String qry = getQuery(pgmid, "qrysave_mst");
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qrysave_mst",qryRun);
        JSONObject rst = executeSVC(conn, qryRun);
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else { 

            executeUpdateClob(conn, 
                 "T_DOC",
                 "CONTENT",
                 getVal(INVAR,"content"),
                 "WHERE docid='"+getVal(INVAR,"docid") + "'");

            /* 수신자정보: rcv와 rcv_cc 는 밖에서 합쳐서 들어옴 */
            qry = getQuery(pgmid, "qrysave_rcv");
            qryRun = "";
            JSONArray arrList = getArray(INVAR,"rcv");
            for(int i = 0; i < arrList.size(); i++) {
                JSONObject row = getRow(arrList,i);
                row.put("docid", getVal(INVAR,"docid")); 
                row.put("rcv_seq",(i+1));
                row.put("usid",USERID);
                qryRun += bindVAR(qry,row) + "\n";
            } 
            OUTVAR.put("qrysave_rcv",qryRun);
            if(!"".equals(qryRun)) rst = executeSVC(conn, qryRun);  
            if(!"OK".equals(getVal(rst,"rtnCd"))) {
                conn.rollback();
                rtnCode = getVal(rst,"rtnCd"); 
                rtnMsg  = getVal(rst,"rtnMsg"); 
            } else { 
                
                /* 첨부파일 업데이트 */
                qry = getQuery(pgmid, "qrysave_attach");
                qryRun = "";
                arrList = getArray(INVAR,"attach");
                for(int i = 0; i < arrList.size(); i++) {
                    JSONObject row = getRow(arrList,i);
                    row.put("docid",getVal(INVAR,"docid")); 
                    row.put("attach_seq",(i+1));
                    row.put("usid",USERID);
                    qryRun += bindVAR(qry,row) + "\n";
                } 
                OUTVAR.put("qrysave_attach",qryRun);
                if(!"".equals(qryRun)) rst = executeSVC(conn, qryRun);  
                if(!"OK".equals(getVal(rst,"rtnCd"))) {
                    conn.rollback();
                    rtnCode = getVal(rst,"rtnCd"); 
                    rtnMsg  = getVal(rst,"rtnMsg"); 
                } else { 
                
                    /* 참조문서 저장 */
                    qry = getQuery(pgmid, "qrysave_ref_doc");
                    qryRun = "";
                    arrList = getArray(INVAR,"ref_doc");
                    for(int i = 0; i < arrList.size(); i++) {
                        JSONObject row = getRow(arrList,i);
                        row.put("docid",getVal(INVAR,"docid")); 
                        row.put("content_seq",(i+1));
                        row.put("usid",USERID);
                        qryRun += bindVAR(qry,row) + "\n";
                    } 
                    OUTVAR.put("qrysave_ref_doc",qryRun);
                    if(!"".equals(qryRun)) rst = executeSVC(conn, qryRun);  
                    if(!"OK".equals(getVal(rst,"rtnCd"))) {
                        conn.rollback();
                        rtnCode = getVal(rst,"rtnCd"); 
                        rtnMsg  = getVal(rst,"rtnMsg"); 
                    } else { 
                    
                        /* 원천데이터 거래내역  */
                        qry = getQuery(pgmid, "qrysave_doc_data_src");
                        qryRun = "";
                        arrList = getArray(INVAR,"doc_data_src");
                        for(int i = 0; i < arrList.size(); i++) {
                            JSONObject row = getRow(arrList,i);
                            row.put("docid",getVal(INVAR,"docid")); 
                            row.put("src_tp","거래내역"); 
                            row.put("content_seq",(i+1));
                            row.put("usid",USERID);
                            qryRun += bindVAR(qry,row) + "\n";
                        } 
                        OUTVAR.put("qrysave_doc_data_src",qryRun);
                        if(!"".equals(qryRun)) rst = executeSVC(conn, qryRun);  
                        if(!"OK".equals(getVal(rst,"rtnCd"))) {
                            conn.rollback();
                            rtnCode = getVal(rst,"rtnCd"); 
                            rtnMsg  = getVal(rst,"rtnMsg"); 
                        } else { 
                        
                            /* 원천데이터 지급내역  */
                            qry = getQuery(pgmid, "qrysave_doc_data_src");
                            qryRun = "";
                            arrList = getArray(INVAR,"doc_data_pay");
                            for(int i = 0; i < arrList.size(); i++) {
                                JSONObject row = getRow(arrList,i);
                                row.put("docid",getVal(INVAR,"docid")); 
                                row.put("src_tp","지급조건"); 
                                row.put("content_seq",(i+1));
                                row.put("usid",USERID);
                                qryRun += bindVAR(qry,row) + "\n";
                            } 
                            OUTVAR.put("qrysave_doc_data_pay",qryRun);
                            if(!"".equals(qryRun)) rst = executeSVC(conn, qryRun);  
                            if(!"OK".equals(getVal(rst,"rtnCd"))) {
                                conn.rollback();
                                rtnCode = getVal(rst,"rtnCd"); 
                                rtnMsg  = getVal(rst,"rtnMsg"); 
                            } else { 
                            
                                /* 원천데이터 금액배부  */
                                qry = getQuery(pgmid, "qrysave_doc_data_src");
                                qryRun = "";
                                arrList = getArray(INVAR,"doc_data_pjt");
                                for(int i = 0; i < arrList.size(); i++) {
                                    JSONObject row = getRow(arrList,i);
                                    row.put("docid",getVal(INVAR,"docid"));
                                    row.put("src_tp","금액배부");  
                                    row.put("content_seq",(i+1));
                                    row.put("usid",USERID);
                                    qryRun += bindVAR(qry,row) + "\n";
                                } 
                                OUTVAR.put("qrysave_doc_data_pjt",qryRun);
                                if(!"".equals(qryRun)) rst = executeSVC(conn, qryRun);  
                                if(!"OK".equals(getVal(rst,"rtnCd"))) {
                                    conn.rollback();
                                    rtnCode = getVal(rst,"rtnCd"); 
                                    rtnMsg  = getVal(rst,"rtnMsg"); 
                                } else { 
                                
                                    /* 회계분개   */
                                    qry = getQuery(pgmid, "qrysave_doc_plas_frm");
                                    qryRun = "";
                                    arrList = getArray(INVAR,"doc_plas_frm");
                                    for(int i = 0; i < arrList.size(); i++) {
                                        JSONObject row = getRow(arrList,i);
                                        row.put("comcd",ORGCD); 
                                        row.put("docid",getVal(INVAR,"docid")); 
                                        row.put("content_seq",(i+1));
                                        row.put("usid",USERID);
                                        qryRun += bindVAR(qry,row) + "\n";
                                    } 
                                    OUTVAR.put("qrysave_doc_plas_frm",qryRun);
                                    if(!"".equals(qryRun)) rst = executeSVC(conn, qryRun);  
                                    if(!"OK".equals(getVal(rst,"rtnCd"))) {
                                        conn.rollback();
                                        rtnCode = getVal(rst,"rtnCd"); 
                                        rtnMsg  = getVal(rst,"rtnMsg"); 
                                    } else { 
                                    
                                        /* 회계분개   */
                                        qry = getQuery(pgmid, "qrysave_doc_plas_chit");
                                        qryRun = "";
                                        arrList = getArray(INVAR,"doc_plas_chit");
                                        for(int i = 0; i < arrList.size(); i++) {
                                            JSONObject row = getRow(arrList,i);
                                            row.put("docid",getVal(INVAR,"docid")); 
                                            row.put("src_tp","회계분개");  
                                            row.put("content_seq",(i+1));
                                            row.put("usid",USERID);
                                            qryRun += bindVAR(qry,row) + "\n";
                                        } 
                                        OUTVAR.put("qrysave_doc_plas_chit",qryRun);
                                        if(!"".equals(qryRun)) rst = executeSVC(conn, qryRun);  
                                        if(!"OK".equals(getVal(rst,"rtnCd"))) {
                                            conn.rollback();
                                            rtnCode = getVal(rst,"rtnCd"); 
                                            rtnMsg  = getVal(rst,"rtnMsg"); 
                                        } else { 
                                            conn.commit();
                                        }  
                                    }  
                                }  
                            }  
                        }   
                    }  
                }  
            }  
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
