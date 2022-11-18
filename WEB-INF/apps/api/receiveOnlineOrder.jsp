<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject();  
String pgmid   = "receiveOnlineOrder"; 
Boolean success = true;
int     code    = 200;
String  message  = "";
try{
String invar = (String)request.getAttribute("INVAR"); //변수명 invar에 변수명 INVAR로 넘어온 값 받기
JSONObject INVAR  = getObject(invar); // 넘어온 invar값을 변수 (JSONObject)INVAR에 저장 
//OUTVAR.put("debug_INVAR",INVAR); 
/***************************************************************************************************/

    Connection conn = null; 
    try {  
        INVAR.put("comcd","LFN");
        conn = getConn("LFN");  
        conn.setAutoCommit(false);
        
        String qry = getQuery(pgmid, "qryInsert");
        String qryRun = "";
        JSONArray arrList = getArray(INVAR,"list"); 
        
        int txCnt = 0;  int oneTx = 50;
        JSONObject rst = new JSONObject();
        rst.put("rtnCd","OK");
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            row.put("comcd","LFN");
            row.put("usid","receiveOnlineOrder"); 
            qryRun += bindVAR(qry,row) + "\n";
            if(txCnt > oneTx) { 
                rst = executeSVC(conn, qryRun);  
                qryRun="";
                if(!"OK".equals(getVal(rst,"rtnCd"))) break;
                txCnt = 0;
            } else {
                txCnt++;
            }
        } 
        if(!"".equals(qryRun)) rst = executeSVC(conn, qryRun);      
        
        /******************************************/
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            success = false;
            code    = 207;
            message = getVal(rst,"rtnMsg");
        } else {  
            message = arrList.size()+" record(s) received successfully";
            conn.commit();
        }  

    } catch (Exception e) { 
        success = false;
        code    = 208;
        message = e.toString();
			
    } finally {
        closeConn(conn);
    }   
        
// *********************************************************************************************/
} catch (Exception e) {
	logger.error("api error occurred:",e);
	success = false;
    code    = 209;
    message = e.toString();
} finally {
	OUTVAR.put("message",message); //OUTVAR에 message 넣기
    OUTVAR.put("success",success); //OUTVAR에 success 넣기
    OUTVAR.put("code",code);
	out.println(OUTVAR.toJSONString());
}
%>
