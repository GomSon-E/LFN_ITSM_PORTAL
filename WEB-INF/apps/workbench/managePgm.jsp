<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "workbench";
String pgmid   = "managePgm"; 
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
            String qry = getQuery(pgmid, "retrievePgmList"); 
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

    //save:저장 이벤트처리(DB_Write)
    if("save".equals(func)) {
        Connection conn = null; 
        try { 
            conn = getConn("LFN");
            conn.setAutoCommit(false);
            String qry = getQuery(pgmid, "mergePgm");
            qry += " merge into his_pgm using dual on ( pgmid = {pgmid}) when matched then update set pgm_nm = {pgm_nm} , pgm_tp = {pgm_tp} , app_pgmid = {app_pgmid} , pgm_grp_nm =  {pgm_grp_nm} , shortcut = {shortcut} , sort_seq = {sort_seq} , remark = {remark} , /*ver = {ver}, */  pgm_stat = {pgm_stat} , upd_usid = {usid} , upd_dt = SYSDATE WHERE VER= (SELECT MAX(VER) FROM HIS_PGM WHERE pgmid = {pgmid}) WHEN NOT MATCHED THEN INSERT ( pgmid , pgm_nm , pgm_tp , app_pgmid , pgm_grp_nm ,  shortcut, sort_seq, remark, ver, pgm_stat, reg_usid, reg_dt, upd_usid, upd_dt ) VALUES ( {pgmid} , {pgm_nm} , {pgm_tp} , {app_pgmid} , {pgm_grp_nm} , {shortcut} , {sort_seq} , {remark} , {ver} , {pgm_stat} , {usid} , SYSDATE , {usid} , SYSDATE );";
            String qryDel = getQuery(pgmid, "deletePgm");
            qryDel += "delete from his_pgm WHERE pgmid = {pgmid};  delete from his_pgm_data WHERE pgmid = {pgmid};  delete from his_pgm_func WHERE pgmid = {pgmid};  delete from his_pgm_src WHERE pgmid = {pgmid};";
            String qryRun = "";
            JSONArray arrList = getArray(INVAR,"list");
            for(int i = 0; i < arrList.size(); i++) {
                JSONObject row = getRow(arrList,i);
                if("D".equals(getVal(row,"crud"))) {
                    row.put("usid",USERID);
                    qryRun += bindVAR(qryDel,row) + "\n";
                }
            } 
            for(int i = 0; i < arrList.size(); i++) {
                JSONObject row = getRow(arrList,i); 
                // 새로 생긴 내용이나, 업데이트된 내용만 쿼리를 실행한다.
                if(("C".equals(getVal(row,"crud"))) ||  ("U".equals(getVal(row,"crud")))){
                    row.put("usid",USERID);
                    qryRun += bindVAR(qry,row) + "\n";
                } 
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
