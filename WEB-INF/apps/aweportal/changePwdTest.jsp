<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page import="java.util.*, javax.mail.*, javax.mail.internet.*"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%  
//if (!aweCheck(session)) return;   
JSONObject OUTVAR = new JSONObject(); 
String appid = "aweportal";    //<===== 수정할 것!
String pgmid   = "changePwdTest"; //<===== 수정할 것!
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";
try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar);


/***************************************************************************************************/
if ("save".equals(func)) { 
    Connection conn = null;  
    try {   
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        conn.setAutoCommit(false); 
        INVAR.put("usid",USERID);
        //INVAR {list:[{cd: "PGM", remark: "프로그램", sort_seq: "1", nm: "프로그램"}]} 
        String qry = "UPDATE T_USER_PWD SET PWD = {pwd} WHERE usid = {usid} AND PWD = {pwd} AND {changepwd} = {checkpwd};"; //T_PGM_SRC.content 
        String qryRun = bindVAR(qry,INVAR);
        System.out.println(qryRun);
        JSONObject rst = executeSVC(conn, qryRun);
        System.out.println(rst);
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
} else if ("mailsearch".equals(func)){

    Connection conn = null;  
    try {
        String email = getVal(INVAR,"email");
        System.out.println("email: " + email);

        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
        String qry = getQuery(pgmid,"selectEmail"); //T_PGM_SRC.content 
        String qryRun = bindVAR(qry,INVAR);
        JSONArray list = selectSVC(conn,qryRun);
        if(list.size() > 0){
            rtnCode = "OK";
        }else{
            rtnCode = "X";
            rtnMsg = "이메일을 다시 확인하세요";
        }
        OUTVAR.put("list",list);
        System.out.println(OUTVAR.toJSONString());  

    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    }        

}else if ("sendmail".equals(func)){
    Connection conn = null;  
    try {
        System.out.println(INVAR);
        String subject = getVal(INVAR,"subject");
        String content = getVal(INVAR,"content");
        String from = getVal(INVAR,"from"); //보내는 사람
        String to = getVal(INVAR,"to"); //받는 사람 


        if(from.equals("") || to.equals("") || content.equals("") || subject.equals("")){

            System.out.println("메일 전송 실패");

        }else{
            

            // 프로퍼티 값 인스턴스 생성과 기본세션(SMTP 서버 호스트 지정)

            Properties props = new Properties();
                        // Assuming you are sending email from localhost
            String host = "192.168.0.87";
            // Setup mail server
            props.setProperty("mail.smtp.host", host);
            Session sess= Session.getDefaultInstance(props, null);

            Message msg = new MimeMessage(sess);

            msg.setFrom(new InternetAddress(from));//보내는 사람 설정

            InternetAddress address = new InternetAddress(to);

            msg.setRecipient(Message.RecipientType.TO, address);//받는 사람설정

            msg.setSubject(subject);//제목 설정

            msg.setSentDate(new java.util.Date());//보내는 날짜 설정

            msg.setContent(content,"text/html;charset=euc-kr"); // 내용 설정 (HTML 형식)

            Transport.send(msg);//메일 보내기
        }
        
    }  catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    } 
}  

/***************************************************************************************************/
}catch (Exception e) {
	logger.error(pgmid+" error occurred:"+rtnCode,e);
	rtnCode    = "ERR";
	rtnMsg     = e.toString();
} finally {
	OUTVAR.put("rtnCd",rtnCode);
	OUTVAR.put("rtnMsg",rtnMsg); 
	out.println(OUTVAR.toJSONString());
}
%> 