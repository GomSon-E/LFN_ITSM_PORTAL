<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    import="java.util.*, 
	        java.net.*,
			javax.servlet.http.*, 
        	org.json.simple.*,
          org.json.simple.parser.*,
          java.sql.*,  
        	java.text.SimpleDateFormat,
        	javax.sql.DataSource,
        	javax.naming.Context,
        	javax.naming.InitialContext,  
	    	java.io.BufferedReader,
	    	java.io.Reader,
	    	java.io.Writer,
	    	java.io.CharArrayReader,
	    	oracle.sql.CLOB,
	    	oracle.sql.BLOB,
	    	oracle.jdbc.OracleResultSet, 
        	java.io.*,
        	java.nio.charset.StandardCharsets,
        	java.nio.file.*,
        	java.nio.file.Files,
        	java.security.*"

 %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "aweportal";
String pgmid   = "frameset"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar);

/***************************************************************************************************/
if("checkGfnTx".equals(func)) {
     Connection conn = null;     
    try {
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        String qry = "SELECT * FROM USER_TAB_COMMENTS";  
        JSONArray rst = selectSVC(conn,qry);   
        OUTVAR.put("rst",rst);
    } catch(Exception e) {
        rtnCode = "ERR";
        rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    }    
}

if("getReq".equals(func)) {
    try {
        OUTVAR.put("httpReqLog", httpReqLog(request));
        OUTVAR.put("httpReqAttr", httpReqAttr(request));
        OUTVAR.put("httpReqHeader", httpReqHeader(request));        
    } catch(Exception e) {
        rtnCode = "ERR";
        rtnMsg  = e.toString();
    }
}
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

        qry = getQuery(pgmid,"retrieveNotice");   
        qry = bindVAR(qry,INVAR);
        //OUTVAR.put("qry",qry);        
        JSONArray notice = selectSVC(conn,qry);   
        OUTVAR.put("notice",notice);

        OUTVAR.put("server",request.getServerName());
        
    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    }        
}
else if("retrieveChat".equals(func)) {
    Connection conn = null;
     try {  
            conn = getConn("LFN"); 

            INVAR.put("usid", USERID);

            String qry = getQuery(pgmid, "retrieveChat");  

            qry = bindVAR(qry, INVAR);

            JSONArray listChat = selectSVC(conn, qry);

            OUTVAR.put("listChat", listChat);

        } catch(Exception e) {
            rtnCode = "ERR";
            rtnMsg  = e.toString();

        } finally {
            closeConn(conn);
        }

} else if("retrieveAlert".equals(func)) {
    Connection conn = null;
     try {  
            conn = getConn("LFN"); 

            INVAR.put("usid", USERID);

            String qry1 = getQuery(pgmid, "retrieveAlert");
            qry1 = bindVAR(qry1, INVAR);
            JSONArray listAlert = selectSVC(conn, qry1);
            OUTVAR.put("listAlert", listAlert);

            String qry2 = getQuery(pgmid, "retrieveAlertCountN");
            qry2 = bindVAR(qry2, INVAR);
            JSONArray countAlertN = selectSVC(conn, qry2);
            OUTVAR.put("countAlertN", countAlertN);

        } catch(Exception e) {
            rtnCode = "ERR";
            rtnMsg  = e.toString();

        } finally {
            closeConn(conn);
        }

} else if("alertIU".equals(func)) {
    Connection conn = null;
    try {
        conn = getConn("LFN");
        conn.setAutoCommit(false);

        boolean bError = false;
        int RunCnt     = 0;
        String qryRun  = "";        

        JSONArray listAlert = getArray(INVAR, "listAlert");

        for(int i = 0; i < listAlert.size(); i++) {
            JSONObject alert = getRow(listAlert, i);
            
            String qry = getQuery(pgmid, "alertIU");
            qry = bindVAR(qry, alert);
            qryRun += qry;
            RunCnt++;

            if(RunCnt == 10) {
                JSONObject rst = executeSVC(conn, qryRun);
                RunCnt = 0;
                qryRun = "";

                if(!"OK".equals (getVal(rst, "rtnCd"))) {
                    rtnCode = getVal(rst, "rtnCd");
                    rtnMsg  = getVal(rst, "rtnMsg");
                    bError  = true;
                    break;
                }
            }
        }

        if(RunCnt > 0) {
            JSONObject rst = executeSVC(conn, qryRun);
            if(!"OK".equals(getVal(rst, "rtnCd"))) {
                rtnCode = getVal(rst, "rtnCd");
                rtnMsg  = getVal(rst, "rtnMsg");
                bError  = true;
            }
        }

        if(bError) conn.rollback();
        else conn.commit();

    } catch(Exception e) {
        rtnCode = "ERR";
        rtnMsg  = e.toString();

    } finally {
        closeConn(conn);
    }

} else if("alertD".equals(func)) {
    Connection conn = null;
    try {
        conn = getConn("LFN");
        conn.setAutoCommit(false);

        String qry = getQuery(pgmid, "alertD");
        qry = bindVAR(qry, INVAR);

        JSONObject rst = executeSVC(conn, qry);

        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg");
        } else {
            conn.commit(); 
        } 

    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    }    

} else if("alertDALL".equals(func)) {
    Connection conn = null;
    try {
        conn = getConn("LFN");
        conn.setAutoCommit(false);

        boolean bError = false;
        int RunCnt     = 0;
        String qryRun  = "";


        JSONArray listAlert = getArray(INVAR, "listAlert");
        //System.out.println(listAlert);
        for(int i = 0; i < listAlert.size(); i++) {
            JSONObject alert = getRow(listAlert, i);
            
            String qry = getQuery(pgmid, "alertD");
            qry = bindVAR(qry, alert);
            //System.out.println(qry);
            qryRun += qry;
            RunCnt++;

            if(RunCnt == 10) {
                JSONObject rst = executeSVC(conn, qryRun);
                RunCnt = 0;
                qryRun = "";

                if(!"OK".equals (getVal(rst, "rtnCd"))) {
                    rtnCode = getVal(rst, "rtnCd");
                    rtnMsg  = getVal(rst, "rtnMsg");
                    bError  = true;
                    break;
                }
            }
        }

        if(RunCnt > 0) {
            JSONObject rst = executeSVC(conn, qryRun);
            if(!"OK".equals(getVal(rst, "rtnCd"))) {
                rtnCode = getVal(rst, "rtnCd");
                rtnMsg  = getVal(rst, "rtnMsg");
                bError  = true;
            }
        }

        if(bError) conn.rollback();
        else conn.commit();

    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    }
    
} else if("alertCheckId".equals(func)) {
    Connection conn = null;
    
    try {
        conn = getConn("LFN");
        
        String qry = getQuery(pgmid, "alertCheckId");
        qry = bindVAR(qry, INVAR);
        JSONArray list = selectSVC(conn,qry);   
        OUTVAR.put("list",list); 
        
    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
        closeConn(conn);
    }

} else if("retrieveBanner".equals(func)) {
    Connection conn = null;  
    try {        
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  

        INVAR.put("usid",USERID);
        String qry = getQuery(pgmid,"retrieveBanner");   
        qry = bindVAR(qry,INVAR);
        //OUTVAR.put("qry",qry);        
        JSONArray list = selectSVC(conn,qry);   
        OUTVAR.put("list",list); 

    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    }    
} else if ("updateBannerRead".equals(func)) {
    Connection conn = null;  
    try {   
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        conn.setAutoCommit(false); 
        //INVAR {docid, usid, proc_stat} 
        INVAR.put("usid",USERID);
        String qry = getQuery(pgmid,"updateBannerRead");
        qry = bindVAR(qry,INVAR);
        OUTVAR.put("qry",qry);        
        JSONObject rst = executeSVC(conn, qry);
    		 
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg");
        } else {
            conn.commit(); 
        } 

    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    } 
} else if ("checkChangePwd".equals(func)) {
    Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        conn.setAutoCommit(false); 
        INVAR.put("usid",USERID);
        //System.out.println(INVAR); 

        String qry = getQuery(pgmid, "checkChangePwd"); 
        qry = bindVAR(qry,INVAR); 
        //System.out.println(qry); 
        OUTVAR.put("qry",qry);
        JSONArray list = selectSVC(conn, qry);
        OUTVAR.put("list",list); 

    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    } 
    
} else if ("updateMenuFav".equals(func)) {
    Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        conn.setAutoCommit(false); 
 
        INVAR.put("usid",USERID);
        String usid = getVal(INVAR,"usid"); // = (String)INVAR.get("usid");
        //System.out.println(INVAR.toJSONString()); 
        String qry = getQuery(pgmid, "updateMenuFav"); 
        qry = bindVAR(qry,INVAR); 
        OUTVAR.put("qry",qry);
        JSONObject rst = executeSVC(conn, qry);
    		 
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg");
        } else {
            conn.commit(); 
        } 

    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    } 
    
} else if ("updatePgmExecCnt".equals(func)) {
    Connection conn = null;  
    try {      
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        conn.setAutoCommit(false); 
 
        INVAR.put("usid",USERID);
        String usid = getVal(INVAR,"usid"); // = (String)INVAR.get("usid");
        //System.out.println(INVAR.toJSONString()); 
        String qry = getQuery(pgmid, "updatePgmExecCnt"); 
        qry = bindVAR(qry,INVAR); 
        OUTVAR.put("qry",qry);
        JSONObject rst = executeSVC(conn, qry);
    		 
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg");
        } else {
            conn.commit(); 
        } 

    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    }     
    
    
} else if ("retrieveImgUrl".equals(func)) {
    String fileno = getVal(INVAR,"imgno");
    //To-Do: T_FILE에서 조회하여 경로 및 이미지정보 리턴 
    OUTVAR.put("url","./images/noimg.png"); 
    OUTVAR.put("file_nm",fileno); 
} else if ("retrieveComcd".equals(func)) {
    //JSONArray list = selectSVC(pgmid,"retrieveComcd",INVAR);
    //OUTVAR.put("comcd",list);  //공통코드
} else if ("getUUID".equals(func)) {
    int digit = 20;
    try {
        digit = Integer.parseInt((String)getVal(INVAR,"digit"));
    } catch (Exception e) {
        digit = 20;
    }        
    String uuid = getUUID(digit);  
    OUTVAR.put("uuid",uuid);     
} 

else if ("checkMsg".equals(func)) {
    Connection conn = null;
        
        try  {
            conn = getConn("LFN");
            
            String qry = "SELECT COUNT(*) AS NUM FROM T_CHAT WHERE GRPID = {usid} AND READ_YN = 'N'";
            qry = bindVAR(qry, INVAR);
            JSONArray num = selectSVC(conn, qry);
            OUTVAR.put("num", num);
            OUTVAR.put("qry", qry);
            
        } catch(Exception e) {
            rtnCode = "ERR";
            rtnMsg  = e.toString();
        } finally {
            closeConn(conn);
        }
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