<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "plas";
String pgmid   = "plasLogin"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/
//login:로그인 이벤트처리(DB_Read)     
if("login".equals(func)) {
    Connection conn = null;  
 
    try { 
        boolean bError = false;
        String userid = getVal(INVAR,"userid");
        String loginpwd = getVal(INVAR,"pwd");

        INVAR.put("usersession", session.getId());
        
        String qry1 = getQuery("aweportal","loginCheck");
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
            //System.out.println("Logged in - USERSESSION:"+USERSESSION); //****다중WAS운영을 위해서는 이 값을 저장해 놓아야 한다.*****
            log.error("Logged in - USERSESSION:"+USERSESSION);
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
        
        String loginInfo = getQuery("aweportal", "loginInfo");
        loginInfo = bindVAR(loginInfo, INVAR);
        JSONObject rst = executeSVC(conn, loginInfo);
        
        if(!"OK".equals(getVal(rst, "rtnCd"))) {
            rtnCode = getVal(rst, "rtnCd");
            rtnMsg  = getVal(rst, "rtnMsg");
            bError  = true;
        }
        
        if(!bError) {
            String loginLog = getQuery("aweportal", "loginLog");
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
