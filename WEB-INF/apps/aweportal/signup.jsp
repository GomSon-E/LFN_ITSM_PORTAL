<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "aweportal";
String pgmid   = "signup"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 

if("save".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qry ="INSERT INTO T_USER (USID, NM, NICK_NM, PROFILE_FILEID, EMAIL, USER_STAT, REG_USID, REG_DT, UPD_USID, UPD_DT, COMPANY, DEPART, PHONENUM) VALUES ({usid}, {nm}, {nick_nm}, null, {email}, 'Y', {usid}, SYSDATE, {usid}, SYSDATE, {company}, {depart}, {phonenum});";
        // String qrypwd = getQuery(pgmid, "savePwd");
        String qryRun = "";
        // qryRun += bindVAR(qrypwd,INVAR) + "\n";
        qryRun += bindVAR(qry,INVAR);
        OUTVAR.put("qry",qryRun);
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
else if("savePwd".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        // String qry = "INSERT INTO T_USER_PWD (USID,PWD,TEMP_YN,SECU_CD,IPADDR,REG_USID,REG_DT,UPD_USID,UPD_DT) VALUES ( {usid},'6cbefd8960d511540f34779628ef4e5a55b758d3be5749cd8878a09b348c052b','Y',NULL,NULL,'admin',SYSDATE,'admin', SYSDATE);";
        String qry = "INSERT INTO T_USER_PWD (USID,PWD,TEMP_YN,SECU_CD,IPADDR,REG_USID,REG_DT,UPD_USID,UPD_DT) VALUES ( {usid},{pwd},'Y',NULL,NULL,'admin',SYSDATE,'admin', SYSDATE);";
        String qryRun = "";
        INVAR.put("userid",USERID);
        qryRun += bindVAR(qry,INVAR);
        OUTVAR.put("qry",qryRun);
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
else if("saveGrp".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        String qryGrp = "INSERT INTO T_USER_GRP (USID, ROLE_STAT, ROLE_TP, USER_NICK_NM, GRPID, GRP_NICK_NM, SORT_SEQ, REG_USID, REG_DT, UPD_USID, UPD_DT) VALUES ({usid}, 'Y', 'ANY', null, 'aweportal', null, null, {usid}, SYSDATE, {usid}, SYSDATE );";
        String qryRun = "";
        qryRun += bindVAR(qryGrp,INVAR);
        OUTVAR.put("qryGrp",qryRun);
        JSONObject rst = executeSVC(conn, qryRun);  
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg");
            //System.out.println(rtnMsg);

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
