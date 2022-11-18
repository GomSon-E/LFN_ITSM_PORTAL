<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "retail";
String pgmid   = "retailHome"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/
if("retrieveInit".equals(func)) {
    Connection conn = null;  
    try {
    /*
					gds.comcd         = OUTVAR.comcd;   //공통코드
					gUserinfo.defval  = OUTVAR.defval;  //사용자기본값
					gUserinfo.usergrp = OUTVAR.usergrp; //사용자그룹
					gds.menu          = OUTVAR.menu;    //권한화면목록 
					gds.notice        = OUTVAR.notice;  //사용자알림
    */         
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  

        String qry = getQuery(pgmid,"retrieveComcd"); //T_PGM_SRC.content 
        //OUTVAR.put("qry",qry);
        JSONArray comcd = selectSVC(conn,qry);   
        OUTVAR.put("comcd",comcd);

        INVAR.put("usid",USERID); 
        qry = getQuery(pgmid,"retrievePLAS_USER");   
        qry = bindVAR(qry,INVAR);
        JSONArray plas_user = selectSVC(conn,qry);   
        OUTVAR.put("plas_user",plas_user);

        qry = getQuery(pgmid,"retrieveDefval");   
        qry = bindVAR(qry,INVAR);
        //OUTVAR.put("qry",qry);        
        JSONArray defval = selectSVC(conn,qry);   
        OUTVAR.put("defval",defval);

        qry = getQuery(pgmid,"retrieveUsergrp");   
        qry = bindVAR(qry,INVAR);
        //OUTVAR.put("qry",qry);        
        JSONArray usergrp = selectSVC(conn,qry);   
        OUTVAR.put("usergrp",usergrp);

        qry = getQuery(pgmid,"retrieveMenuT");   
        qry = bindVAR(qry,INVAR);
        //OUTVAR.put("qry",qry);        
        JSONArray menu = selectSVC(conn,qry);   
        OUTVAR.put("menu",menu); 
        
        OUTVAR.put("server",request.getServerName());
        
        String qry3 = "SELECT TEMP_YN FROM T_USER_PWD WHERE USID = '"+USERID+"'"; 
        JSONArray loginCheck = selectSVC(conn, qry3);
        OUTVAR.put("loginCheck", getVal(loginCheck,0,"temp_yn"));
        
    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    }        
}


//refresh:재조회 이벤트처리(DB_Read)     
if("refresh".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        OUTVAR.put("INVAR",INVAR); //for debug
        
        conn = getConn("LFN");  
        
        String qryNotice = getQuery(pgmid, "retrieveNotice"); 
        qryNotice = bindVAR(qryNotice,INVAR);
        OUTVAR.put("qryNotice",qryNotice); //for debug
        JSONArray notice = selectSVC(conn, qryNotice);
        OUTVAR.put("notice",notice); 
        
        String qryAlarm = getQuery(pgmid, "qryAlarm"); 
        qryAlarm = bindVAR(qryAlarm,INVAR);
        OUTVAR.put("qryAlarm",qryAlarm); //for debug
        JSONArray alarm = selectSVC(conn, qryAlarm);
        OUTVAR.put("alarm",alarm);  
        
        String qryAPDocs = getQuery(pgmid, "qryAPDocs"); 
        qryAPDocs = bindVAR(qryAPDocs,INVAR);
        OUTVAR.put("qryAPDocs",qryAPDocs); //for debug
        JSONArray apdocs = selectSVC(conn, qryAPDocs);
        OUTVAR.put("apdocs",apdocs);  

        String qryworkingdocs = getQuery(pgmid, "qryworkingdocs"); 
        qryworkingdocs = bindVAR(qryworkingdocs,INVAR);
        OUTVAR.put("qryworkingdocs",qryworkingdocs); //for debug
        JSONArray workingdocs = selectSVC(conn, qryworkingdocs);
        OUTVAR.put("workingdocs",workingdocs);  

        String qrydocs = getQuery(pgmid, "qrydocs"); 
        qrydocs = bindVAR(qrydocs,INVAR);
        OUTVAR.put("qrydocs",qrydocs); //for debug
        JSONArray docs = selectSVC(conn, qrydocs);
        OUTVAR.put("docs",docs);  

        String qrychits = getQuery(pgmid, "qrychits"); 
        qrychits = bindVAR(qrychits,INVAR);
        OUTVAR.put("qrychits",qrychits); //for debug
        JSONArray chits = selectSVC(conn, qrychits);
        OUTVAR.put("chits",chits);  

        String qrymdms = getQuery(pgmid, "qrymdms"); 
        qrymdms = bindVAR(qrymdms,INVAR);
        OUTVAR.put("qrymdms",qrymdms); //for debug
        JSONArray mdms = selectSVC(conn, qrymdms);
        OUTVAR.put("mdms",mdms);  

        String qrybizCal = getQuery(pgmid, "qrybizCal"); 
        qrybizCal = bindVAR(qrybizCal,INVAR);
        OUTVAR.put("qrybizCal",qrybizCal); //for debug
        JSONArray bizCal = selectSVC(conn, qrybizCal);
        OUTVAR.put("bizCal",bizCal);     

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
