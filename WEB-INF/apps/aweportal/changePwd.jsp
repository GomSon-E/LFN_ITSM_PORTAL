<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "aweportal";
String pgmid   = "changePwd"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar);
//System.out.println(INVAR);
//log.error(INVAR, e);
JSONArray key = (JSONArray)INVAR.get("list");
JSONObject keylist = (JSONObject)key.get(0);
String keyvalue = (String)keylist.get("nowpwd");
/***************************************************************************************************/
    //save:저장 이벤트처리(DB_Write)
    if("save".equals(func)) {
        Connection conn = null; 
        try {  
            conn = getConn("LFN");
            conn.setAutoCommit(false);
            INVAR.put("usid",USERID);
            String qry2 = "SELECT PWD FROM T_USER_PWD WHERE USID = {usid}";
            String qryRun2 = bindVAR(qry2,INVAR);
            JSONArray pwdlist = selectSVC(conn, qryRun2);
            JSONObject pwdval = (JSONObject)pwdlist.get(0);
            String pwdvalue = (String)pwdval.get("pwd");
            //System.out.println(pwdvalue);
            log.error(pwdvalue);
            //System.out.println(keyvalue);
            log.error(keyvalue);
            if(pwdvalue.equals(keyvalue)){
                String qry = "UPDATE T_USER_PWD SET PWD = {pwd}, TEMP_YN = 'N' WHERE USID = {usid};";
                String qryRun = "";
                JSONArray arrList = getArray(INVAR,"list");
                for(int i = 0; i < arrList.size(); i++) {
                    JSONObject row = getRow(arrList,i); 
                    row.put("usid",USERID);
                    qryRun += bindVAR(qry,row) + "\n";
                }
                //System.out.println(qryRun);
                log.error(qryRun);
                OUTVAR.put("qryRun",qryRun);
                JSONObject rst = executeSVC(conn, qryRun);  
                if(!"OK".equals(getVal(rst,"rtnCd"))) {
                    conn.rollback();
                    rtnCode = getVal(rst,"rtnCd"); 
                    rtnMsg  = getVal(rst,"rtnMsg"); 
                } else { 
                    conn.commit();
                } 
            }else{
                OUTVAR.put("rtnCd",rtnCode);
                OUTVAR.put("rtnMsg",rtnMsg);
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
