<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" 
    import="java.time.LocalDateTime,
            java.time.format.DateTimeFormatter,
            java.util.*, 
            java.io.*,
            com.oreilly.servlet.MultipartRequest, 
            com.oreilly.servlet.multipart.DefaultFileRenamePolicy"
%>
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR   = new JSONObject(); 
String appid        = "aweportal";
String pgmid        = "manageChat"; 
String func         = request.getParameter("func"); 
String rtnCode      = "OK";
String rtnMsg       = "";
String qryRun       = "";
boolean bError      = false;
String serverDir    = "https://fo.lfnetworks.co.kr";
try { 
String invar        = request.getParameter("INVAR");
JSONObject INVAR    = getObject(invar);
/***************************************************************************************************/
    //부서별 유저 리스트
    if("selectEmpInfo".equals(func)) {
        Connection conn = null;

        try {
            conn = getConn("LFN");

            String qry = getQuery(pgmid, "selectEmpInfo");
            qry = bindVAR(qry, INVAR);
            JSONArray selectEmpInfo = selectSVC(conn, qry);
            OUTVAR.put("selectEmpInfo", selectEmpInfo);

        } catch(Exception e) {
            rtnCode = "ERR";
            rtnMsg  = e.toString();

        } finally {
            closeConn(conn);           
        }
    }

    //검색 유저 리스트
    else if("empInfo".equals(func)) {
        Connection conn = null;

        try {
            conn = getConn("LFN");

            String qry = getQuery(pgmid, "empInfo");
            qry = bindVAR(qry, INVAR);
            JSONArray empInfo = selectSVC(conn, qry);
            OUTVAR.put("empInfo", empInfo);

        } catch(Exception e) {
            rtnCode = "ERR";
            rtnMsg  = e.toString();

        } finally {
            closeConn(conn);   
        }
    }
    
    //메세지 채널 기본 정보
    else if("chatInfo".equals(func)) {
        Connection conn = null;

        try {
            conn = getConn("LFN");

            //모든 부서 리스트
            String qry0 = getQuery(pgmid, "deptInfo");
            JSONArray deptInfo = selectSVC(conn, qry0);
            OUTVAR.put("deptInfo", deptInfo);

            //모든 유저 리스트
            String qry1 = getQuery(pgmid, "empInfo");
            JSONArray empInfo = selectSVC(conn, qry1);
            OUTVAR.put("empInfo", empInfo);

            //기존 채널
            Boolean bCheck = Boolean.parseBoolean(getVal(INVAR, "bCheck"));

            if(bCheck) {      
                //로그인 유저 정보
                String qry2 = getQuery(pgmid, "selectChatUserInfo");
                qry2 = bindVAR(qry2, INVAR);
                JSONArray userInfo = selectSVC(conn, qry2);
                OUTVAR.put("userInfo", userInfo);                

                //채널 정보
                String qry3 = getQuery(pgmid, "selectChatInfo");
                qry3 = bindVAR(qry3, INVAR);
                JSONArray roomInfo = selectSVC(conn, qry3);
                OUTVAR.put("roomInfo", roomInfo);

                //채널 유저 리스트
                String qry4 = getQuery(pgmid, "selectChatEmpInfo");
                qry4 = bindVAR(qry4, INVAR);
                JSONArray selectedEmp = selectSVC(conn, qry4);
                OUTVAR.put("selectedEmp", selectedEmp);
            }

        } catch(Exception e) {
            rtnCode = "ERR";
            rtnMsg  = e.toString();
            
        } finally {
            closeConn(conn);
        }
    } 

    //신규, 기존 채널 정보 등록 (수정) [(MNGR), MEMBER]
    //신규, 기존 채널 유저 초대, (내보내기) [(MNGR), MEMBER]
    else if("chatInfoIUEmpID".equals(func)) {
        Connection conn = null;

        try {
            conn = getConn("LFN");
            conn.setAutoCommit(false);

            String grpid   = "";

            //신규 채널 구분
            Boolean bCheck = Boolean.parseBoolean(getVal(INVAR, "bCheck"));
            
            //유저 리스트 유무 구분
            Boolean bEmp   = Boolean.parseBoolean(getVal(INVAR, "bEmp"));
            
            //매니저 변경 모드 구분
            Boolean bType = Boolean.parseBoolean(getVal(INVAR, "bType"));            

            //신규 채널 grpid 생성
            if(bCheck) { 
                grpid = getUUID(20);
                OUTVAR.put("grpid", grpid);
            
            //기존 채널 로그인 유저 정보
            } else {
                String qry0 = getQuery(pgmid, "chatEmpU");
                JSONObject userInfo = getRow(getArray(INVAR, "userInfo"), 0);

                qryRun = bindVAR(qry0, userInfo);
                JSONObject rst = executeSVC(conn, qryRun);

                if(!"OK".equals(getVal(rst, "rtnCd"))) {
                    rtnCode = getVal(rst, "rtnCd");
                    rtnMsg  = getVal(rst, "rtnMsg");
                    bError  = true;
                }
            }

            //채널 정보
            String qry1 = getQuery(pgmid, "chatInfoIU");

            JSONObject roomInfo = getRow(getArray(INVAR, "roomInfo"), 0);

            if(bCheck) roomInfo.put("grpid", grpid);

            qryRun = bindVAR(qry1, roomInfo);

            JSONObject rst = executeSVC(conn, qryRun);

            if(!"OK".equals(getVal(rst, "rtnCd"))) {
                rtnCode = getVal(rst, "rtnCd");
                rtnMsg  = getVal(rst, "rtnMsg");
                bError  = true;
            }

            //채널 유저
            if(!bError) {
                if(!bEmp) {
                    
                    //일반 유저 등록 모드, 매니저 변경 모드에 따라 쿼리문 변경
                    String type = "";
                    if(!bType) type = "chatEmpID"; 
                    else type = "chatEmpTypeU";
                    
                    String qry2 = getQuery(pgmid, type);
                    JSONArray selectEmpList = getArray(INVAR, "selectEmp");

                    int RunCnt = 0;
                    qryRun = "";

                    for(int i = 0; i < selectEmpList.size(); i++) {
                        JSONObject selectEmp = getRow(selectEmpList, i);

                        if(bCheck) { selectEmp.put("grpid", grpid); };
                        
                        qryRun += bindVAR(qry2, selectEmp) + "\n";
                        RunCnt++;

                        if(RunCnt == 10) {
                            rst = executeSVC(conn, qryRun);
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
                        rst = executeSVC(conn, qryRun);
                        if(!"OK".equals(getVal(rst, "rtnCd"))) {
                            rtnCode = getVal(rst, "rtnCd");
                            rtnMsg  = getVal(rst, "rtnMsg");
                            bError  = true;
                        }
                    }
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
    }

    //채널 로그인 유저 정보 변경(MEMBER) 
    else if("chatEmpUpdate".equals(func)) {
        Connection conn = null;

        try {
            conn = getConn("LFN");
            conn.setAutoCommit(false);

            String qry = getQuery(pgmid, "chatEmpU");

            JSONObject userInfo = getRow(getArray(INVAR, "userInfo"), 0);

            qryRun = bindVAR(qry, userInfo);      

            JSONObject rst = executeSVC(conn, qryRun);

            if(!"OK".equals(getVal(rst, "rtnCd"))) {
                conn.rollback();
                rtnCode = getVal(rst, "rtnCd");
                rtnMsg  = getVal(rst, "rtnMsg");

            } else {
                conn.commit();
            }
        } catch(Exception e) {
            rtnCode = "ERR";
            rtnMsg  = e.toString();
        } finally {
            closeConn(conn);
        }
    } 

    //채널 로그 조회 
    else if("selectChatInfo".equals(func)) {
        Connection conn = null;

        try {
            conn = getConn("LFN");
            conn.setAutoCommit(false);

            //로그인 유저 정보
            String qry0 = getQuery(pgmid, "selectChatUserInfo");
            qry0 = bindVAR(qry0, INVAR);
            JSONArray userInfo = selectSVC(conn, qry0);
            OUTVAR.put("userInfo", userInfo);

            //채널 정보 
            String qry1 = getQuery(pgmid, "selectChatInfo");    
            qry1 = bindVAR(qry1, INVAR);
            JSONArray chatInfo = selectSVC(conn, qry1);
            OUTVAR.put("chatInfo", chatInfo);

            //채널 유저 정보
            String qry2 = getQuery(pgmid, "selectChatEmpInfo");
            qry2 = bindVAR(qry2, INVAR);
            JSONArray empInfo = selectSVC(conn, qry2);
            OUTVAR.put("empInfo", empInfo);

            //채널 로그
            String qry3 = getQuery(pgmid, "selectChatLog");
            qry3 = bindVAR(qry3, INVAR);
            JSONArray chatLog = selectSVC(conn, qry3);
            OUTVAR.put("chatLog", chatLog);

            //채널 로그인 유저 마지막 접속 시간 갱신
            String qry4 = getQuery(pgmid, "chatEmpLastConnU");
            qry4 = bindVAR(qry4, INVAR);
            JSONObject rst = executeSVC(conn, qry4);

            if(!"OK".equals(getVal(rst, "rtnCd"))) {
                conn.rollback();
                rtnCode = getVal(rst, "rtnCd");
                rtnMsg  = getVal(rst, "rtnMsg");

            } else {
                conn.commit();
            }

        } catch(Exception e) {
            rtnCode = "ERR";
            rtnMsg  = e.toString();

        } finally {
            closeConn(conn);
        }
    } 

    //채널 로그인 유저 마지막 접속 시간 갱신
    else if("chatEmpLastConnU".equals(func)) {
        Connection conn = null;

        try {
            String qry = getQuery(pgmid, "chatEmpLastConnU");
            qry = bindVAR(qry, INVAR);
            JSONObject rst = executeSVC(conn, qry);

            if(!"OK".equals(getVal(rst, "rtnCd"))) {
                conn.rollback();
                rtnCode = getVal(rst, "rtnCd");
                rtnMsg  = getVal(rst, "rtnMsg");

            } else {
                conn.commit();
            }

        } catch(Exception e) {
            rtnCode = "ERR";
            rtnMsg  = e.toString();
            
        } finally {
            closeConn(conn);
        }
    }

    //채널 기록 등록
    else if("insertChatLog".equals(func)) {
        Connection conn = null;

        try {
            conn = getConn("LFN");
            conn.setAutoCommit(false);

            //채널 기록 시간(Oracle용 포맷 지정)
            LocalDateTime date = LocalDateTime.now();
            String date1 = date.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
            String date2 = date.format(DateTimeFormatter.ofPattern("HH:mm"));

            INVAR.put("reg_dt", date1);
            OUTVAR.put("reg_dt", date2);

            String qry = getQuery(pgmid, "insertChatLog");

            qry = bindVAR(qry, INVAR);
            JSONObject rst = executeSVC(conn, qry);

            if(!"OK".equals(getVal(rst, "rtnCd"))) {
                conn.rollback();
                rtnCode = getVal(rst, "rtnCd");
                rtnMsg  = getVal(rst, "rtnMsg");
            } else {
                conn.commit();
            }

        } catch(Exception e) {
            rtnCode = "ERR";
            rtnMsg  = e.toString();

        } finally {
            closeConn(conn);
        }
    }

    //채널 파일 기록 등록
    else if("insertChatFile".equals(func)) {
        Connection conn = null;

        try {
            conn = getConn("LFN");
            conn.setAutoCommit(false);

            String qry = getQuery(pgmid, "insertChatLog");

            LocalDateTime date = LocalDateTime.now();
            String date1 = date.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
            INVAR.put("reg_dt", date1);
            
            qry = bindVAR(qry, INVAR);
            System.out.println(qry);
            JSONObject rst = executeSVC(conn, qry);

            if(!"OK".equals(getVal(rst, "rtnCd"))) {
                conn.rollback();
                rtnCode = getVal(rst, "rtnCd");
                rtnMsg  = getVal(rst, "rtnMsg");
            } else {
                conn.commit();
            }

        } catch(Exception e) {
            rtnCode = "ERR";
            rtnMsg  = e.toString();
        } finally {
            closeConn(conn);
        }
    }

    //1:1 채널 유무 확인
    else if("selectChatInfoDual".equals(func)) {
        Connection conn = null;

        try {
            conn = getConn("LFN");

            String qry = getQuery(pgmid, "selectChatInfoDual");
            qry = bindVAR(qry, INVAR);

            JSONArray grpInfo = selectSVC(conn, qry);
            OUTVAR.put("grpInfo", grpInfo);

        } catch(Exception e) {
            rtnCode = "ERR";
            rtnMsg  = e.toString();

        } finally {
            closeConn(conn);
        }
    }

    //파일 업로드
    else {
        Connection conn = null;
        
        try {
            conn = getConn("LFN");
            conn.setAutoCommit(false);

            //MultipartRequest 파일 저장 매개변수 정의
            DefaultFileRenamePolicy policy = new DefaultFileRenamePolicy();
            String encrypt     = "utf-8";
            String serverURL   = "http://localhost:8080";
            String fileDir     = application.getRealPath("pds");
            int fileSizeLimit  = 1024 * 1024 * 10;
            
            //루트 저장 폴더가 없는 경우 생성
            File fileNewDir = new File(fileDir);
            if(!fileNewDir.exists()) {
                try { fileNewDir.mkdir(); } 
                catch(Exception e) { e.getStackTrace(); }
            }

            //fileDir로 파일 저장
            MultipartRequest multipart = new MultipartRequest(request, fileDir, fileSizeLimit, encrypt, policy);

            //miltipart로 전달받은 fileInfo JSON string을 invarFile
            String invarFile       = multipart.getParameter("INVAR");

            //JSONArray 리스트에 fileInfo 데이터를 배열로 전환
            JSONArray fileInfoList = getArray(invarFile, "fileInfo");
            
            int RunCnt = 0;
            qryRun     = "";

            //채널 기록 시간(Oracle용 포맷 지정)
            LocalDateTime date = LocalDateTime.now();
            String date1 = date.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
            String date2 = date.format(DateTimeFormatter.ofPattern("HH:mm"));

            JSONArray fileInfoExt = new JSONArray();

            //JSONArray의 배열을 JSONObject로 row값 추출
            for(int i = 0; i < fileInfoList.size(); i++) {
                JSONObject fileInfo = getRow(fileInfoList, i);

                //각 배열 최적 값을 임시로 담는 재사용 INVAR 초기화
                INVAR.toString().equals("{}");
                
                //DB 반영 데이터 수집 및 가공
                String orgn_nm     = getVal(fileInfo, "orgn_nm");       //원본 파일 이름
                String fileid      = getUUID(20);                       //파일ID && 수정 파일 이름
                String file_nm     = fileid;                            //수정 파일 이름
                String file_tp     = getVal(fileInfo, "file_tp");
                String ref_file_tp = getVal(fileInfo, "ref_file_tp");
                String fileDateDir = getVal(fileInfo, "fileDateDir");
                String file_ext    = getVal(fileInfo, "file_ext");
                
                INVAR.put("fileid", fileid);
                INVAR.put("userid", USERID);
                INVAR.put("reg_dt", date1);

                //파일 타겟 지정
                String filePath    = fileDir + "/" + orgn_nm;
                File fileOrigin    = new File(filePath);

                //파일 경로 저장
                String file_dir    = fileDir + "/" + ORGCD + "/" + file_tp + "/" + fileDateDir;
                INVAR.put("file_dir", file_dir);

                //서버 파일 저장 폴더가 없는 경우 생성(yyyymm)
                File fileDirServer =  new File(fileDir);
                if(!fileDirServer.exists()) {
                    try { fileDirServer.mkdirs(); } 
                    catch(Exception e) { e.getStackTrace(); }
                }

                //파일 이름이 비지 않았거나 원본 파일 타겟이 null이 아닌 경우, 파일 이름 변경
                if(!"".equals(orgn_nm) && fileOrigin != null) {
                    file_nm = file_nm + "." + file_ext;
                    INVAR.put("file_nm", file_nm);

                    //파일 경로 변경
                    String filePathChange = fileDir + "/" + ORGCD + "/" + file_tp + "/" + fileDateDir + "/";
                    File pathChange = new File(filePathChange);
                    if(!pathChange.exists()) {
                        pathChange.mkdirs();
                    }

                    //이미 있는 경우 삭제
                    File fileDuplicate = new File(filePathChange + file_nm);
                    if(fileDuplicate.exists()) { fileDuplicate.delete(); }

                    //원본 파일 이름 변경
                    fileOrigin.renameTo(new File(filePathChange + file_nm));
                }

                //서버 파일 경로
                String file_url = serverDir + "/pds/" + ORGCD + "/" + file_tp + "/" + fileDateDir + "/" + file_nm;
                INVAR.put("file_url", file_url);

                //데이터 바인딩
                String qry = getQuery(pgmid, "chatFileUpLoad");
                qry = bindVAR(qry, INVAR);
                qry = bindVAR(qry, fileInfo);

                //OUTVAR 데이터 바인딩
                JSONObject file = new JSONObject();
                file.put("orgn_nm", orgn_nm);
                file.put("fileid", fileid);
                file.put("file_dir", file_dir);
                file.put("file_url", file_url);
                file.put("reg_dt", date2);
                fileInfoExt.add(file);

                qryRun += qry;
                RunCnt++;

                if(RunCnt == 10) {
                    JSONObject rst = executeSVC(conn, qry);
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

            
            
            if(bError) {
                conn.rollback();
            
            } else {
                conn.commit();
                OUTVAR.put("fileInfoExt", fileInfoExt);
            }
        } catch(Exception e) {
            rtnCode = "ERR";
            rtnMsg  = e.toString();

        } finally {
            closeConn(conn);
        }
    }
/***************************************************************************************************/
} catch (Exception e) {
	logger.error(pgmid + " error occurred:" + rtnCode,e);
	rtnCode    = "ERR";
	rtnMsg     = e.toString();

} finally {
	OUTVAR.put("rtnCd", rtnCode);
	OUTVAR.put("rtnMsg", rtnMsg); 
	out.println(OUTVAR.toJSONString());
}
%>