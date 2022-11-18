<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "plas";
String pgmid   = "plasDocUpd"; 
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
        INVAR.put("usid",USERID);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "qry_doc"); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qry_doc",qryRun); //for debug
        JSONArray mst = selectSVC(conn, qryRun);
        OUTVAR.put("mst",mst);
        
        qry = getQuery(pgmid, "qry_doc_rcv"); 
        qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qry_doc_rcv",qryRun); //for debug
        JSONArray rcv = selectSVC(conn, qryRun);
        OUTVAR.put("rcv",rcv); 
        
        qry = getQuery(pgmid, "qry_doc_file"); 
        qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qry_doc_file",qryRun); //for debug
        JSONArray attach = selectSVC(conn, qryRun);
        OUTVAR.put("attach",attach); 
        
        qry = getQuery(pgmid, "qry_ref_doc"); 
        qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qry_ref_doc",qryRun); //for debug
        JSONArray ref_doc = selectSVC(conn, qryRun);
        OUTVAR.put("ref_doc",ref_doc); 
        
        qry = getQuery(pgmid, "qry_doc_data_src"); 
        qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qry_doc_data_src",qryRun); //for debug
        JSONArray doc_data_src = selectSVC(conn, qryRun);
        OUTVAR.put("doc_data_src",doc_data_src);  
        
        qry = getQuery(pgmid, "qry_doc_data_pay"); 
        qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qry_doc_data_pay",qryRun); //for debug
        JSONArray doc_data_pay = selectSVC(conn, qryRun);
        OUTVAR.put("doc_data_pay",doc_data_pay);  
        
        qry = getQuery(pgmid, "qry_doc_data_pjt"); 
        qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qry_doc_data_pjt",qryRun); //for debug
        JSONArray doc_data_pjt = selectSVC(conn, qryRun);
        OUTVAR.put("doc_data_pjt",doc_data_pjt);  
        
        qry = getQuery(pgmid, "qry_doc_plas_frm"); 
        qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qry_doc_plas_frm",qryRun); //for debug
        JSONArray doc_plas_frm = selectSVC(conn, qryRun);
        OUTVAR.put("doc_plas_frm",doc_plas_frm);  
        
        qry = getQuery(pgmid, "qry_doc_plas_chit"); 
        qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qry_doc_plas_chit",qryRun); //for debug
        JSONArray doc_plas_chit = selectSVC(conn, qryRun);
        OUTVAR.put("doc_plas_chit",doc_plas_chit);  
        
        INVAR.put("doc_template_id",getVal(mst,0,"doc_template_id"));
        INVAR.put("co_cd",getVal(mst,0,"doc_co_cd"));
        qry = getQuery(pgmid, "qry_doc_template"); 
        qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qry_doc_template",qryRun); //for debug
        JSONArray doc_template = selectSVC(conn, qryRun);
        OUTVAR.put("doc_template",doc_template);  
        
        //문서읽을때 한번 읽은 문서는 세션에서 DOCID삭제
        session.setAttribute("DOCID", null ); 
        
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


//cfm:상신 이벤트처리(DB_Write)
if("cfm".equals(func)) {
    Connection conn = null; 
    try {   
        INVAR.put("usid",USERID);
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        String qry = getQuery(pgmid, "qryCfm");
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryCfm",qryRun);
        JSONObject rst = executeSVC(conn, qryRun);
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else {   
            OUTVAR.put("emails",getVal(rst,"rtnMsg"));        //rcv=Y proc=N 전체(문서작성자,소유자,승인대기자,사후참조자)
            conn.commit(); 
        }
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}

//apv:승인 이벤트처리(DB_Write)
if("apv".equals(func)) {
    Connection conn = null; 
    try {   
        INVAR.put("usid",USERID);
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        String qry = getQuery(pgmid, "qryApv");
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryApv",qryRun);
        JSONObject rst = executeSVC(conn, qryRun);
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else {  
            OUTVAR.put("ap_email",getVal(rst,"rtnSvcMsg"));  //rcv=Y proc=N 승인대기자
            OUTVAR.put("emails",getVal(rst,"rtnMsg"));
            conn.commit(); 
        }
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}

//return: 승인 이벤트처리(DB_Write)
if("return".equals(func)) {
    Connection conn = null; 
    try {   
        INVAR.put("usid",USERID);
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        String qry = getQuery(pgmid, "qryReturn");
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryReturn",qryRun);
        JSONObject rst = executeSVC(conn, qryRun);
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else {  
            OUTVAR.put("emails",getVal(rst,"rtnMsg"));
            conn.commit(); 
        }
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
} 

//reject : 반려
if("reject".equals(func)) {
    Connection conn = null; 
    try {   
        INVAR.put("usid",USERID);
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        String qry = getQuery(pgmid, "qryReject");
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryReject",qryRun);
        JSONObject rst = executeSVC(conn, qryRun);
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else {  
            OUTVAR.put("emails",getVal(rst,"rtnMsg"));
            conn.commit(); 
        }
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}

//review : 문서상태변경 
if("revive".equals(func)) {
    Connection conn = null; 
    try {   
        INVAR.put("usid",USERID);
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        String qry = getQuery(pgmid, "qryRevive");
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRevive",qryRun);
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


//delete : 문서상태변경 
if("delete".equals(func)) {
    Connection conn = null; 
    try {   
        INVAR.put("usid",USERID);
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        String qry = getQuery(pgmid, "qryDelete");
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryDelete",qryRun);
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

//saveRcvcc : 문서공유(사후참조자 추가)
if("saveRcvcc".equals(func)) {
    Connection conn = null;  
    try {  
        INVAR.put("reg_usid",USERID);
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        String qry = getQuery(pgmid, "qryShare_rcv_cc");
        String qryRun = "";
        JSONArray arrList = getArray(INVAR,"list");
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i);
            row.put("docid", getVal(INVAR,"docid")); 
            //row.put("rcv_seq",(i+1));
            row.put("reg_usid",USERID);
            qryRun += bindVAR(qry,row) + "\n";
        } 
        OUTVAR.put("qryShare_rcv_cc",qryRun);
        //if(!"".equals(qryRun)) 
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
