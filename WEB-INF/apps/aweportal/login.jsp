<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%  
//if (!aweCheck(session)) return;   
JSONObject OUTVAR = new JSONObject(); 
String appid = "aweportal";
String pgmid   = "login"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar);
/***************************************************************************************************/
if("sessionCheck".equals(func)) {
    //common.jsp에 전역변수로 세션user정보를 담고 있음
    //String USERID = (String)session.getAttribute("USERID");
    log.error("USERSESSION:"+USERSESSION);
    if( isNull(USERSESSION) ) {
        String sessionToken = getVal(INVAR,"usersession");
        log.error("sessionToken:"+sessionToken);
        if(!isNull(sessionToken)) {
            /* To-do: 유효한 세션토큰인지 확인하고 사용자 계정정보를 생성함(아래 loginCheck 참조)
                세션유효체크/사용자정보 조회 
                OUTVAR 
                세션할당              
            */
        } else {
            OUTVAR.put("session","N");
        } 
    } else {
        OUTVAR.put("session","Y");
        OUTVAR.put("userid",USERID);
        OUTVAR.put("usernm",USERNM);
        OUTVAR.put("usermail",USERMAIL);
        OUTVAR.put("usernicknm", USERNICKNM);
        OUTVAR.put("usersession",USERSESSION); //다중WAS로 구성될 경우 USERSESSION key를 담아놓고 session sharing할 필요 있음
        OUTVAR.put("orgcd",ORGCD);
        OUTVAR.put("orgnm",ORGNM);
        OUTVAR.put("deptcd",DEPTCD);
        OUTVAR.put("deptnm",DEPTNM);
        OUTVAR.put("userauth",USERAUTH);
        OUTVAR.put("multiorgyn",MULTIORGYN); 
    }
} 
else if ("loginCheck".equals(func)) {
    Connection conn = null;  
 
    try {
        //INVAR={userid, loginpwd}

        boolean bError = false;
        String userid = getVal(INVAR,"userid");
        String loginpwd = getVal(INVAR,"loginpwd");

        INVAR.put("usersession", session.getId());
        
        String qry1 = getQuery(pgmid,"loginCheck");
	    qry1 = bindVAR(qry1,INVAR);
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅
        conn.setAutoCommit(false);

        //OUTVAR.put("qry1",qry); 
        JSONArray mRtn = selectSVC(conn,qry1);   

        //OUTVAR
        if(mRtn.size() >= 1) {
            JSONObject row = new JSONObject();
            row = getRow(mRtn, 0); 
            ORGCD  = getCol(row,"orgcd");
            ORGNM  = getCol(row,"orgnm");
            DEPTCD = getCol(row,"deptcd");
            DEPTNM = getCol(row,"deptnm");
            USERID      = getCol(row,"userid");
            USERNM      = getCol(row,"usernm");
            USERNICKNM  = getCol(row,"usernicknm");
            if(mRtn.size() == 1) { //겸직자 여부 
                MULTIORGYN = "N";  
            } else {
                MULTIORGYN = "Y"; 
            } 
            USERAUTH = getCol(row,"rolecds");
            USERSESSION = getCol(row,"usersession");
            OUTVAR.put("userinfo",row);
            log.error("Logged in - USERSESSION:"+USERSESSION); //****다중WAS운영을 위해서는 이 값을 저장해 놓아야 한다.*****
            rtnCode    = "OK";
            rtnMsg     = USERNM+"님 환영합니다."; 
            //insertLog(USERID,"login","AUTO",USERID,"");
        } else {
            ORGCD  = null;
            ORGNM  = null;
            DEPTCD = null;
            DEPTNM = null;
            USERID      = null;
            USERNM      = null;
            USERNICKNM  = null;
            MULTIORGYN = null;
            USERAUTH    = null;
            USERSESSION = null;
            rtnCode    = "X";
            rtnMsg     = "사용자ID와 패스워드를 확인하세요";
            bError     = true;
        }
        //세션할당
        session.setAttribute("ORGCD",  ORGCD );
        session.setAttribute("ORGNM",  ORGNM );
        session.setAttribute("DEPTCD", DEPTCD );
        session.setAttribute("DEPTNM", DEPTNM );
        session.setAttribute("USERID",      USERID );
        session.setAttribute("USERNM",      USERNM );
        session.setAttribute("USERNICKNM",  USERNICKNM);
        session.setAttribute("USERAUTH",   USERAUTH );
        session.setAttribute("MULTIORGYN", MULTIORGYN );  
        session.setAttribute("USERSESSION", USERSESSION );

        //IP 체크
        String ip = null;
        ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) { ip = request.getHeader("Proxy-Client-IP"); } 
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) { ip = request.getHeader("WL-Proxy-Client-IP"); } 
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) { ip = request.getHeader("HTTP_CLIENT_IP"); } 
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) { ip = request.getHeader("HTTP_X_FORWARDED_FOR"); }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) { ip = request.getHeader("X-Real-IP"); }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) { ip = request.getHeader("X-RealIP"); }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) { ip = request.getHeader("REMOTE_ADDR"); }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) { ip = request.getRemoteAddr(); }
        
        INVAR.put("ipaddr", ip);
        
        String loginInfo = getQuery(pgmid, "loginInfo");
        loginInfo = bindVAR(loginInfo, INVAR);
        JSONObject rst = executeSVC(conn, loginInfo);
        
        if(!"OK".equals(getVal(rst, "rtnCd"))) {
            rtnCode = getVal(rst, "rtnCd");
            rtnMsg  = getVal(rst, "rtnMsg");
            bError  = true;
        }
        
        if(!bError) {
            String loginLog = getQuery(pgmid, "loginLog");
            loginLog = bindVAR(loginLog, INVAR);
            rst = executeSVC(conn, loginLog);
            
            if(!"OK".equals(getVal(rst, "rtnCd"))) {
                rtnCode = getVal(rst, "rtnCd");
                rtnMsg  = getVal(rst, "rtnMsg");
                bError  = true;
            }
        }
            
        if(bError) {
            conn.rollback();
            
        } else {
            conn.commit();
        }
        
        String qry3 = "SELECT TEMP_YN FROM T_USER_PWD WHERE USID = {userid}";
        String qryRun3 = bindVAR(qry3,INVAR);
        OUTVAR.put("qryRun3",qryRun3); //for debug
        JSONArray list = selectSVC(conn, qryRun3);
        OUTVAR.put("list",list);
        
    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    } 
} 
//이메일 인증 진행중
else if ("pwdclearReq".equals(func)) {
    
    //INVAR={email} 
    /* To-do:
        사용자정보 이메일 존재 체크
        암호초기화키 생성
        메일발송/메시지발송
        시스템관리자 메시지 발송 
    */   
    //사용자 정보 이메일 존재 체크
    Connection conn = null;  
    try {
        //INVAR={userid, loginpwd}
        
        conn = getConn("LFN");
        String qry = getQuery(pgmid,"selectEmail"); //T_PGM_SRC.content 
        String qryRun = bindVAR(qry,INVAR);

        //OUTVAR.put("qry",qry); 
        JSONArray list = selectSVC(conn,qry);  
        OUTVAR.put("list",list); 

    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    } 
     
} 
else if ("logout".equals(func)) {
    //변수 Clear
    ORGCD  = null;
    ORGNM  = null;
    DEPTCD = null;
    DEPTNM = null;
    USERID      = null;
    USERNM      = null;
    USERNICKNM  = null;
    MULTIORGYN = null;
    USERAUTH    = null;
    USERSESSION = null; 
    //세션할당
    session.setAttribute("ORGCD",  ORGCD );
    session.setAttribute("ORGNM",  ORGNM );
    session.setAttribute("DEPTCD", DEPTCD );
    session.setAttribute("DEPTNM", DEPTNM );
    session.setAttribute("USERID",      USERID );
    session.setAttribute("USERNM",      USERNM );
    session.setAttribute("USERNICKNM",  USERNICKNM);
    session.setAttribute("USERAUTH",   USERAUTH );
    session.setAttribute("MULTIORGYN", MULTIORGYN );  
    session.setAttribute("USERSESSION", USERSESSION );     
    session.setAttribute("DOCID", null );    
} 

/***************************************************************************************************/
} catch (Exception e) {
	logger.error(pgmid+" error occurred:"+rtnCode,e);
	rtnCode    = "ERR";
	rtnMsg     = e.toString();
} finally {
	OUTVAR.put("rtnCd",rtnCode);
	OUTVAR.put("rtnMsg",rtnMsg); 
	out.println(OUTVAR.toJSONString());
}
%> 