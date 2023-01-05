<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "workbench";
String pgmid   = "manageTable"; 
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
        String qry = getQuery(pgmid, "searchList"); 
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

//searchTbl:조회 이벤트처리(DB_Read)     
if("searchTbl".equals(func)) {
    Connection conn = null; 
    Connection connProd = null; 
    try {  
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        connProd = getConn("LFFODB");  
        
        String qry = getQuery(pgmid, "searchTbl"); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray tbl = selectSVC(conn, qryRun);
        OUTVAR.put("tbl",tbl); 
        String qry2 = getQuery(pgmid, "searchColist"); 
        String qry2Run = bindVAR(qry2,INVAR);
        OUTVAR.put("qry2Run",qry2Run); //for debug
        JSONArray colist = selectSVC(conn, qry2Run);
        OUTVAR.put("colist",colist);  
        
        String qryCol = "SELECT COUNT(*) cnt FROM USER_TAB_COLUMNS WHERE table_name = '"+getVal(INVAR,"t_id")+"'";
        String qryRow = "SELECT COUNT(*) cnt FROM "+getVal(INVAR,"t_id");        
        JSONArray temp = selectSVC(conn, qryCol); 
        OUTVAR.put("dev_col_cnt",getVal(temp,0,"cnt")); 
        temp = selectSVC(connProd, qryCol); 
        OUTVAR.put("prod_col_cnt",getVal(temp,0,"cnt"));
        
        try {
            temp = selectSVC(conn, qryRow); 
            OUTVAR.put("dev_row_cnt",getVal(temp,0,"cnt"));  
        } catch (Exception e) {
            OUTVAR.put("dev_row_cnt",null);  
        }
        try {
            temp = selectSVC(connProd, qryRow); 
            OUTVAR.put("prod_row_cnt",getVal(temp,0,"cnt"));
        } catch (Exception e) {
            OUTVAR.put("prod_row_cnt",null);  
        }
    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
        closeConn(connProd);
    }  
}

//save:저장 이벤트처리(DB_Write)
if("save".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qryH = getQuery(pgmid, "saveTbl");
        String qryD = getQuery(pgmid, "saveColumn");
        String qryRun = "";
        JSONObject tbl = getObject(INVAR,"tbl");
        tbl.put("usid",USERID);
        qryRun = bindVAR(qryH,tbl);
        JSONArray arrList = getArray(INVAR,"colist");
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            row.put("t_id", getVal(tbl,"t_id"));
            row.put("usid", USERID);
            if(!"D".equals(getVal(row,"crud"))) qryRun += bindVAR(qryD,row) + "\n";
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

//alter:테이블 생성처리(DB_Write)
if("alter".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        //conn.setAutoCommit(false); //DDL문 실행이라 자동커밋됨! 데이터 복사시 커밋처리용 
        
        String t_id = getVal(INVAR,"t_id");
        String uuid = getUUID(30);
        String bak_tbl_id = ("ZAK_"+t_id+uuid).substring(0,30);
        String bZAK = getVal(INVAR,"bZAK");
        String bCopy = getVal(INVAR,"bCopy"); 
        
        //ZAK처리 
        String qry1 = "EXECUTE IMMEDIATE 'CREATE TABLE "+bak_tbl_id+" AS SELECT * FROM "+t_id+" ';\n";
        String qry2 = "EXECUTE IMMEDIATE 'DROP TABLE "+t_id+" ';\n";          
        
        //기존테이블이 존재하지 않으면 ZAK, DROP하지 않음
        String qryChk = "SELECT COUNT(*) cnt FROM USER_TABLES WHERE TABLE_NAME='"+t_id+"' ";
        JSONArray arrChk = selectSVC(conn,qryChk);
        JSONObject rstChk = getRow(arrChk,0);
        if("0".equals(getVal(rstChk,"cnt"))) {
            qry1 = ""; qry2 = ""; 
        } 
        
        //기존테이블 컬럼을 조회함
        String qryOld = "SELECT lower(column_name) col_id FROM USER_TAB_COLUMNS WHERE table_name = '"+t_id+"' ";
        JSONArray arrOld = selectSVC(conn,qryOld); 
        JSONArray arrCol = new JSONArray();
        
        //테이블생성
        String qry3 = "EXECUTE IMMEDIATE 'CREATE TABLE "+t_id+" ( \n";
        String qry4 = "EXECUTE IMMEDIATE 'COMMENT ON TABLE "+t_id+" IS ''"+getVal(INVAR,"tbl_nm")+"'' ';\n";
        JSONArray colist = getArray(INVAR,"colist");
        String pkcols = "";
        for(int i=0; i < colist.size(); i++) {
            JSONObject row = getRow(colist,i);
            if(!isNull(getVal(row,"pk_seq"))) {  //PK컬럼 조립
                if("".equals(pkcols)) { pkcols = getVal(row,"col_id"); } 
                else { pkcols += ","+getVal(row,"col_id"); }
            }
            String not_null = " ";
            if("Y".equals(getVal(row,"not_null"))) not_null = " NOT NULL ";
            String def_val = " ";
            if(!isNull(getVal(row,"def_val").trim())) def_val = " default "+getVal(row,"def_val");
            qry3 += getVal(row,"col_id")+" "+getVal(row,"datatype")+not_null+def_val; //컬럼조립 
            if( i < colist.size()-1 ) { 
                qry3 += ", \n";  
            } else { //마지막컬럼일때 
                if("".equals(pkcols)) qry3 += " )'; \n"; // pk없는 테이블
                else qry3 += ", \n" + " CONSTRAINTS PK_"+t_id+" PRIMARY KEY ("+pkcols+") )'; \n"; // pk추가 
            }
            //컬럼코멘트 조립 
            qry4 += "EXECUTE IMMEDIATE 'COMMENT ON COLUMN "+t_id+"."+getVal(row,"col_id")+" IS ''"+getVal(row,"col_nm")+"'' ';\n"; 
            //기존컬럼여부체크
            for(int j=0; j < arrOld.size(); j++ ) {
                if(getVal(row,"col_id").equals(getVal(arrOld,j,"col_id"))) {
                    arrCol.add( getVal(row,"col_id") );
                    break;
                }
            }
        } 
        
        //테이블 생성실행 
        String qryRun = qry1 + qry2 + qry3 + qry4; 
        OUTVAR.put("qryRun",qryRun);
        JSONObject rst = executeSVC(conn, qryRun);  
        if(!"OK".equals(getVal(rst,"rtnCd"))) { 
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else { 
            rtnMsg  = bak_tbl_id;  
            //존재하는 컬럼은 복사
            String qryCopy = "INSERT INTO "+t_id+" (";
            String qryCols = "";
            for(int k=0; k < arrCol.size(); k++) {
                if(k==0) qryCols = (String)arrCol.get(k);
                else qryCols += ","+(String)arrCol.get(k); 
            }
            qryCopy += qryCols + ") SELECT "+qryCols+" FROM "+bak_tbl_id+"; commit; \n";
            String qryDropZAK = "";
            if(!"Y".equals(bCopy)) qryCopy = "";
            if(!"Y".equals(bZAK)) qryDropZAK = "EXECUTE IMMEDIATE 'DROP TABLE "+bak_tbl_id+" ';\n";
            qryRun = qryCopy + qryDropZAK;
            OUTVAR.put("qryRun2",qryRun);
            if(!"".equals(qryRun)) rst = executeSVC(conn, qryRun);   
        }   
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}

//index: 인덱스 drop/create 
if("index".equals(func)) {
    Connection conn = null;
    try {  
        String sCon =  getVal(INVAR,"conn");
        String t_id =  getVal(INVAR,"t_id");
        String ix_01 = getVal(INVAR,"ix_01");
        String ix_02 = getVal(INVAR,"ix_02");
        String ix_03 = getVal(INVAR,"ix_03");
        String qryD1 = "BEGIN EXECUTE IMMEDIATE 'DROP INDEX IX_"+t_id+"_01'; EXCEPTION WHEN OTHERS THEN lv_rtn := 'IX_01 not exists'; END; \n";
        String qryD2 = "BEGIN EXECUTE IMMEDIATE 'DROP INDEX IX_"+t_id+"_02'; EXCEPTION WHEN OTHERS THEN lv_rtn := 'IX_02 not exists'; END; \n";
        String qryD3 = "BEGIN EXECUTE IMMEDIATE 'DROP INDEX IX_"+t_id+"_03'; EXCEPTION WHEN OTHERS THEN lv_rtn := 'IX_03 not exists'; END; \n";
        String qry1 = "EXECUTE IMMEDIATE 'CREATE INDEX IX_"+t_id+"_01 ON "+t_id+" ("+ix_01+")';\n"; if(isNull(ix_01)) qry1 = "";
        String qry2 = "EXECUTE IMMEDIATE 'CREATE INDEX IX_"+t_id+"_02 ON "+t_id+" ("+ix_02+")';\n"; if(isNull(ix_02)) qry2 = "";
        String qry3 = "EXECUTE IMMEDIATE 'CREATE INDEX IX_"+t_id+"_03 ON "+t_id+" ("+ix_03+")';\n"; if(isNull(ix_03)) qry3 = "";
        String qryRun = qryD1 + qryD2 + qryD3 + qry1 + qry2 + qry3;
        OUTVAR.put("qryRun",qryRun);
        
        conn = getConn(sCon);
        JSONObject rst = executeSVC(conn, qryRun);  
        if(!"OK".equals(getVal(rst,"rtnCd"))) { 
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else { 
            rtnMsg  = ""; 
        }  
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn); 
    }
}

//deploy:테이블 운영반영(DB_Write)
if("deploy".equals(func)) {
    Connection conn = null;
    Connection connProd = null; 
    try {  
        conn = getConn("LFN");
        connProd = getConn("LFFODB");
        //conn.setAutoCommit(false); //DDL문 실행이라 자동커밋됨! 데이터 복사시 커밋처리용 
        
        String t_id = getVal(INVAR,"t_id");
        String uuid = getUUID(30);
        String bak_tbl_id = ("ZAK_"+t_id+uuid).substring(0,30);
        String bZAK = getVal(INVAR,"bZAK");
        String bCopy = getVal(INVAR,"bCopy"); 
        
        //ZAK처리 
        String qry1 = "EXECUTE IMMEDIATE 'CREATE TABLE "+bak_tbl_id+" AS SELECT * FROM "+t_id+" ';\n";
        String qry2 = "EXECUTE IMMEDIATE 'DROP TABLE "+t_id+" ';\n";          
        
        //기존테이블이 존재하지 않으면 ZAK, DROP하지 않음
        String qryChk = "SELECT COUNT(*) cnt FROM USER_TABLES WHERE TABLE_NAME='"+t_id+"' ";
        JSONArray arrChk = selectSVC(connProd,qryChk); //connProd!
        JSONObject rstChk = getRow(arrChk,0);
        if("0".equals(getVal(rstChk,"cnt"))) {
            qry1 = ""; qry2 = ""; 
        } 
        
        //기존테이블의 컬럼리스트를 조회함
        String qryOld = "SELECT lower(column_name) col_id FROM USER_TAB_COLUMNS WHERE table_name = '"+t_id+"' ";
        JSONArray arrOld = selectSVC(connProd,qryOld); //connProd!
        JSONArray arrCol = new JSONArray();
        
        //운영 TBL 정보 저장
        String qryH = getQuery(pgmid, "saveTbl");
        String qryD = getQuery(pgmid, "saveColumn");
        String qryRunLast = "";
        JSONObject tbl = getObject(INVAR,"tbl");
        tbl.put("usid",USERID);
        qryRunLast = bindVAR(qryH,tbl);
        JSONArray arrList = getArray(INVAR,"colist");
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            row.put("t_id", getVal(tbl,"t_id"));
            row.put("usid", USERID);
            if(!"D".equals(getVal(row,"crud"))) qryRunLast += bindVAR(qryD,row) + "\n";
        } 
        
        //테이블생성
        String qry3 = "EXECUTE IMMEDIATE 'CREATE TABLE "+t_id+" ( \n";
        String qry4 = "EXECUTE IMMEDIATE 'COMMENT ON TABLE "+t_id+" IS ''"+getVal(INVAR,"tbl_nm")+"'' ';\n";
        JSONArray colist = getArray(INVAR,"colist");
        String pkcols = "";
        for(int i=0; i < colist.size(); i++) {
            JSONObject row = getRow(colist,i);
            if(!isNull(getVal(row,"pk_seq"))) {  //PK컬럼 조립
                if("".equals(pkcols)) { pkcols = getVal(row,"col_id"); } 
                else { pkcols += ","+getVal(row,"col_id"); }
            }
            String not_null = " ";
            if("Y".equals(getVal(row,"not_null"))) not_null = " NOT NULL ";
            String def_val = " ";
            if(!isNull(getVal(row,"def_val").trim())) { 
                def_val = " default "+ getVal(row,"def_val");
            }
            qry3 += getVal(row,"col_id")+" "+getVal(row,"datatype")+not_null+def_val; //컬럼조립 
            if( i < colist.size()-1 ) { 
                qry3 += ", \n";  
            } else { //마지막컬럼일때 
                if("".equals(pkcols)) qry3 += " )'; \n"; // pk없는 테이블
                else qry3 += ", \n" + " CONSTRAINTS PK_"+t_id+" PRIMARY KEY ("+pkcols+") )'; \n"; // pk추가 
            }
            //컬럼코멘트 조립 
            qry4 += "EXECUTE IMMEDIATE 'COMMENT ON COLUMN "+t_id+"."+getVal(row,"col_id")+" IS ''"+getVal(row,"col_nm")+"'' ';\n"; 
            //기존컬럼여부체크
            for(int j=0; j < arrOld.size(); j++ ) {
                if(getVal(row,"col_id").equals(getVal(arrOld,j,"col_id"))) {
                    arrCol.add( getVal(row,"col_id") );
                    break;
                }
            }
        } 
        
        //테이블 생성실행 
        String qryRun = qry1 + qry2 + qry3 + qry4 + qryRunLast; 
        OUTVAR.put("qryRun",qryRun);
        JSONObject rst = executeSVC(connProd, qryRun);  
        if(!"OK".equals(getVal(rst,"rtnCd"))) { 
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else { 
            rtnMsg  = bak_tbl_id;  
            //데이터 복제
            if("PROD".equals(bCopy)) { //기존테이블에서 읽어서 컬럼명이 같은 건은 복사해 넣는다. 
                String copyCols = "";
                int iStartCol = 0;
                for(int i=0; i < arrOld.size(); i++) { 
                    JSONObject oldRow = getRow(arrOld,i);
                    for(int j=0; j < colist.size(); j++) {
                        JSONObject newRow = getRow(colist,j);
                        if(getVal(oldRow,"col_id").equals(getVal(newRow,"col_id"))) {
                            if(iStartCol==0) copyCols = getVal(oldRow,"col_id"); 
                            else copyCols += ","+getVal(oldRow,"col_id");
                            iStartCol++;
                        }
                    }
                }
                String qryCopy = "INSERT INTO "+t_id+"("+ copyCols + ") SELECT "+ copyCols + " FROM "+bak_tbl_id+";";
                rst = executeSVC(connProd,qryCopy); 
                
            } else if("DEV".equals(bCopy)) { //개발에서 읽어서 실환경에 넣는다. 
                String qryCopy = "INSERT INTO "+t_id+"@LFFODB SELECT * FROM "+t_id+";";
                rst = executeSVC(conn,qryCopy); 
            } 
            //ZAK테이블은 일단 만들었다가 Drop한다. 
            String qryDropZAK = "";
            if(!"Y".equals(bZAK)) {
                qryDropZAK = "EXECUTE IMMEDIATE 'DROP TABLE "+bak_tbl_id+" ';\n";
                rst = executeSVC(connProd, qryDropZAK);   
            }
        }   
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
        closeConn(connProd);
    }
}

//delete:삭제저장 이벤트처리(DB_Write)
if("delete".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry = getQuery(pgmid, "deleteTbl"); 
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

//drop:테이블 Drop처리(DB_Write)
if("drop".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        //conn.setAutoCommit(false); DDL문 실행이라 자동커밋됨!
        
        String t_id = getVal(INVAR,"t_id");
        String uuid = getUUID(30);
        String bak_tbl_id = ("ZAK_"+t_id+uuid).substring(0,30);
        
        String qry1 = "EXECUTE IMMEDIATE 'CREATE TABLE "+bak_tbl_id+" AS SELECT * FROM "+t_id+"';";
        String qry2 = "EXECUTE IMMEDIATE 'DROP TABLE "+t_id+"';";
        String qryRun = qry1 + "\n"+ qry2; 
        JSONObject rst = executeSVC(conn, qryRun);  
        if(!"OK".equals(getVal(rst,"rtnCd"))) { 
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else { 
            rtnMsg  = bak_tbl_id; 
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
