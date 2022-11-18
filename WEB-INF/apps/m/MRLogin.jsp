<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "m";
String pgmid   = "MRLogin"; 
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
        conn = getConn("DOUZONE");  
        INVAR.put("comcd",ORGCD);
        String qry = getQuery(pgmid, "qrysearch"); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        
        OUTVAR.put("conn",conn); //for debug
        
        JSONArray list = selectSVC(conn, qryRun);
        
        OUTVAR.put("list",list); 

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}

if("login".equals(func)) {
    Connection conn = null; 
    try {  
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN"); 
        String qry = getQuery(pgmid, "qrylogin"); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug 
        JSONArray list = selectSVC(conn, qryRun);
        JSONObject rtn = new JSONObject();

        ORGCD  = null;
        ORGNM  = null;  
        DEPTNM = null;
        USERID = null;
        USERNM = null;
        String EMAIL = null;
        String JOBGRADENM = null;
        String JOBROLENM = null;
        String TEL_NO = null; 
        String ADMIN_YN = "N";
        
        if(list.size() >= 1) {
            Boolean bUserExist = false;
            for(int i = 0; i < list.size(); i++) {
                JSONObject listrow = getRow(list,i);
                /*  usid,  --메일에서 @이후 빼고
                    nm, 
                    email,  --@이후 포함
                    pwd,    --단방향암호화비번
                    dz_key, 
                    comcd, --LFN TRIBONS PASTEL
                    deptnm, 
                    jobgradenm, 
                    jobrolenm 
                    tel_no, 
                    reg_usid, 
                    reg_dt, 
                    upd_usid, 
                    upd_dt, */ 
                if(getVal(INVAR,"pwd").equals(getVal(listrow,"pwd"))) {
                    if("BOT".equals(getVal(listrow,"usid"))) {
                        //패스워드 qwer1234!
                        rtn.put("ok","Y");
                        rtn.put("msg","로그인성공");
                        ORGCD       = "LFN";
                        ORGNM       = "LFN";
                        DEPTNM      = "정보전략실";
                        USERID      = "BOT";
                        USERNM      = "회의실관리 도우미봇";
                        EMAIL       = "kihyunlee@lfnetworks.co.kr";
                        JOBGRADENM  = "도우미";
                        JOBROLENM   = "회의실봇";
                        TEL_NO      = "I-LOVE-YOU";  
                        ADMIN_YN    = "N";
                    } else {
                        OUTVAR.put("pwdchk","OK");
                        //더존 사용자정보를 읽어와서 사용자정보 업데이트, 세션구성 
                        Connection connDZ = null; 
                        try {   
                            connDZ = getConn("LFN");  //getConn("DOUZONE");  
                            String qryDZ = getQuery(pgmid, "qrysearchDZ"); 
                            INVAR.put("dz_key",getVal(listrow,"dz_key")); 
                            String co_cd = "0101";
                            if("TRIBONS".equals(getVal(listrow,"comcd"))) {
                                co_cd = "0301";
                            } else if("PASTEL".equals(getVal(listrow,"comcd"))) {
                                co_cd = "0401";
                            }
                            INVAR.put("co_cd",co_cd);
                            String qryRunDZ = bindVAR(qryDZ,INVAR);
                            OUTVAR.put("qryRunDZ",qryRunDZ);  
                            JSONArray listDZ = selectSVC(connDZ, qryRunDZ);
                            /* nm, 
                               comcd
                             , dz_key 
                             , deptnm  
                             , jobgradenm
                             , telno
    	                     , jobrolenm  */
                            if(listDZ.size()==1) {
                                JSONObject dzrow = getRow(listDZ,0); 
                                String updUserinfo = getQuery(pgmid,"updateUserinfo");
                                dzrow.put("usid",getVal(INVAR,"usid")); 
                                updUserinfo = bindVAR(updUserinfo,dzrow); 
                                OUTVAR.put("updUserinfo",updUserinfo);
                                conn.setAutoCommit(false);
                                JSONObject rst = executeSVC(conn, updUserinfo);  
                                if(!"OK".equals(getVal(rst,"rtnCd"))) {
                                    conn.rollback(); 
                                    rtn.put("ok","N");
                                    rtn.put("msg","더존 사용자정보를 갱신하는데 오류가 발생하였습니다. IT팀에 문의해주세요.");
                                } else { 
                                    conn.commit(); 
                                    rtn.put("ok","Y");
                                    rtn.put("msg","로그인성공");
                                    ORGCD       = getVal(dzrow,"comcd");
                                    ORGNM       = getVal(dzrow,"comcd"); 
                                    DEPTNM      = getVal(dzrow,"deptnm");
                                    USERID      = getVal(dzrow,"usid");
                                    USERNM      = getVal(dzrow,"nm");
                                    EMAIL       = getVal(listrow,"email"); 
                                    JOBGRADENM  = getVal(dzrow,"jobgradenm");
                                    JOBROLENM   = getVal(dzrow,"jobrolenm");
                                    TEL_NO      = getVal(dzrow,"telno");  
                                    ADMIN_YN    = getVal(listrow,"admin_yn");
                                } 
                            } else {
                                rtn.put("ok","N");
                                rtn.put("msg","한 건 이상의 더존 사용자정보가 존재하는 오류가 발생하였습니다. IT팀에 문의해주세요.");
                            }
                        } catch (Exception e) { 
                            rtn.put("ok","N");
                            rtn.put("msg","더존 사용자정보를 가져오는데 오류가 발생하였습니다. IT팀에 문의해주세요.");
                        } finally {
                            closeConn(connDZ);
                        }   
                    }
                    bUserExist = true;
                    break;
                } else {
                    OUTVAR.put("pwdChk",getVal(INVAR,"pwd") +" vs " + getVal(listrow,"pwd") );
                }
            } /* end of for */
            if(bUserExist==false) {
                rtn.put("ok","N");
                rtn.put("msg","비밀번호가 일치하지 않습니다.");
            }
        } else {
            rtn.put("ok","N");
            rtn.put("msg","사용자정보를 찾을 수 없습니다. 사용자등록 후 로그인해주세요!");
        }

        session.setAttribute("ORGCD",  ORGCD );
        session.setAttribute("ORGNM",  ORGNM ); 
        session.setAttribute("DEPTNM", DEPTNM );
        session.setAttribute("USERID",      USERID );
        session.setAttribute("USERNM",      USERNM );    
        session.setAttribute("EMAIL",       EMAIL  );
        session.setAttribute("JOBGRADENM",  JOBGRADENM );    
        session.setAttribute("JOBROLENM",   JOBROLENM );     
        session.setAttribute("TEL_NO",      TEL_NO );  
        session.setAttribute("ADMIN_YN",    ADMIN_YN);
        
        rtn.put("orgcd",  ORGCD );
        rtn.put("orgnm",  ORGNM ); 
        rtn.put("deptnm", DEPTNM );
        rtn.put("userid",      USERID );
        rtn.put("usernm",      USERNM );    
        rtn.put("email",       EMAIL  );
        rtn.put("jobgradenm",  JOBGRADENM );    
        rtn.put("jobrolenm",   JOBROLENM );     
        rtn.put("tel_no",      TEL_NO ); 
        rtn.put("admin_yn",  ADMIN_YN);
        OUTVAR.put("rtn",rtn);
        
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
