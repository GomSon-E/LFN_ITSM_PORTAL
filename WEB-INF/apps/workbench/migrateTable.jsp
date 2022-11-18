<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "workbench";
String pgmid   = "migrateTable"; 
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
 
//export:테이블 운영반영(DB_Write)
if("export".equals(func)) {
    Connection conn = null;
    Connection connProd = null; 
    try {  
        conn = getConn("LFN");
        connProd = getConn("LFFODB");
        conn.setAutoCommit(false); //DDL문 실행이라 자동커밋됨! 데이터 복사시 커밋처리용 
        connProd.setAutoCommit(false); //DDL문 실행이라 자동커밋됨! 데이터 복사시 커밋처리용 
        
        String t_id = getVal(INVAR,"t_id");
        String uuid = getUUID(30);
        String bak_tbl_id = ("ZAK_"+t_id+uuid).substring(0,30); 

        //운영에 기존테이블이 존재하지 않으면 오류 
        String qryChk = "SELECT COUNT(*) cnt FROM USER_TABLES WHERE TABLE_NAME='"+t_id+"' ";
        JSONArray arrChk = selectSVC(connProd,qryChk); //connProd!
        JSONObject rstChk = getRow(arrChk,0);
        if("0".equals(getVal(rstChk,"cnt"))) {
            rtnCode = "ERR";
            rtnMsg = "운영환경에 테이블["+t_id+"]이 존재하지 않습니다.";
        } else {
            //운영 백업테이블 생성
            String qry1 = "EXECUTE IMMEDIATE 'CREATE TABLE "+bak_tbl_id+" AS SELECT * FROM "+t_id+" ';\n";
            String qry2 = "EXECUTE IMMEDIATE 'TRUNCATE TABLE "+t_id+" ';\n";
            String qryRun = qry1 + qry2;
            JSONObject rst = executeSVC(connProd, qryRun);  //connProd!
            if(!"OK".equals(getVal(rst,"rtnCd"))) { 
                connProd.rollback();
                rtnCode = getVal(rst,"rtnCd"); 
                rtnMsg  = getVal(rst,"rtnMsg"); 
            } else {  
                //개발->운영 테이블 복사 
                String qryCopy = "INSERT INTO "+t_id+"@LFFODB SELECT * FROM "+t_id+";";
                rst = executeSVC(conn,qryCopy); 
                if(!"OK".equals(getVal(rst,"rtnCd"))) {
                    conn.rollback();
                    rtnCode = getVal(rst,"rtnCd"); 
                    rtnMsg  = getVal(rst,"rtnMsg"); 
                } else {
                    conn.commit(); 
                    connProd.commit(); 
                }
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


//import:테이블 운영반영(DB_Write)
if("import".equals(func)) {
    Connection conn = null;
    Connection connProd = null; 
    try {  
        conn = getConn("LFN");
        connProd = getConn("LFFODB");
        conn.setAutoCommit(false); //DDL문 실행이라 자동커밋됨! 데이터 복사시 커밋처리용 
        
        String t_id = getVal(INVAR,"t_id");
        String uuid = getUUID(30);
        String bak_tbl_id = ("ZAK_"+t_id+uuid).substring(0,30); 

        //운영에 기존테이블이 존재하지 않으면 오류 
        String qryChk = "SELECT COUNT(*) cnt FROM USER_TABLES WHERE TABLE_NAME='"+t_id+"' ";
        JSONArray arrChk = selectSVC(conn,qryChk); //conn!
        JSONObject rstChk = getRow(arrChk,0);
        if("0".equals(getVal(rstChk,"cnt"))) {
            rtnCode = "ERR";
            rtnMsg = "개발환경에 테이블["+t_id+"]이 존재하지 않습니다.";
        } else {
            //개발 백업테이블 생성
            String qry1 = "EXECUTE IMMEDIATE 'CREATE TABLE "+bak_tbl_id+" AS SELECT * FROM "+t_id+" ';\n";
            String qry2 = "EXECUTE IMMEDIATE 'TRUNCATE TABLE "+t_id+" ';\n";
            String qryRun = qry1 + qry2;
            JSONObject rst = executeSVC(conn, qryRun);   
            if(!"OK".equals(getVal(rst,"rtnCd"))) { 
                conn.rollback();
                rtnCode = getVal(rst,"rtnCd"); 
                rtnMsg  = getVal(rst,"rtnMsg"); 
            } else { 
                //운영->개발 테이블 복사 
                String qryCopy = "INSERT INTO "+t_id+" SELECT * FROM "+t_id+"@LFFODB;";
                rst = executeSVC(conn,qryCopy); 
                if(!"OK".equals(getVal(rst,"rtnCd"))) {
                    conn.rollback();
                    rtnCode = getVal(rst,"rtnCd"); 
                    rtnMsg  = getVal(rst,"rtnMsg"); 
                } else {
                    conn.commit(); 
                }
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
