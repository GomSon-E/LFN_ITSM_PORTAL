<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject();  
String pgmid   = "syncPrice"; 
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
        String qryPageinfo = "SELECT COUNT(*) as rows_whole FROM ( [qryRun] )";
        String qryList     = "SELECT * FROM ( SELECT /*+ INDEX(A PK1) */ ROWNUM RN, A.* FROM ( [qryRun] ) A WHERE rownum <= {rows_per_page}*{req_page} ) WHERE RN > {rows_per_page}*({req_page}-1) ";
        String qry     = getQuery(pgmid,"qryselect");
        String qryRun  = bindVAR(qry,INVAR);
        JSONObject QRY = new JSONObject();
        QRY.put("qryRun",qryRun);

        JSONArray mPageinfo = selectSVC(conn, bindVAR(qryPageinfo,QRY));
        JSONObject pageinfo = new JSONObject();
        if(mPageinfo.size()==0 || "0".equals(getVal(mPageinfo,0,"rows_whole"))) {
            message = "no data found"; 
            pageinfo.put("rows_whole",0);
            pageinfo.put("rows_per_page",getVal(INVAR,"rows_per_page"));
            pageinfo.put("res_page",0);
        } else {
            pageinfo.put("rows_whole",   getVal(mPageinfo,0,"rows_whole"));        
            pageinfo.put("rows_per_page",getVal(INVAR,"rows_per_page"));
            pageinfo.put("res_page",     getVal(INVAR,"req_page"));            

            qryRun = bindVAR(qryList,INVAR);
            qryRun = bindVAR(qryRun,QRY); 
            JSONArray list = selectSVC(conn, qryRun);
            OUTVAR.put("list",list); 
        }
        
        OUTVAR.put("pageinfo",pageinfo);
        
        

    } catch (Exception e) { 
        success = false;
        code    = 208;
        message = e.toString();
			
    } finally {
        String qry2 = getQuery(pgmid, "qrysave"); 
        String qryRun2 = bindVAR(qry2,INVAR);
        JSONObject rst2 = executeSVC(conn, qryRun2);
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
