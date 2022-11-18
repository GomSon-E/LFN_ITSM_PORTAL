<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<% 

//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "m";
String pgmid   = "MRRegister"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar);
String serverDir = "https://fo.lfnetworks.co.kr";
/***************************************************************************************************/

if("save".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        String saveDir = application.getRealPath("pds");
        File saveFolder = new File(saveDir);
        if (!saveFolder.exists()) {
            try {
                saveFolder.mkdirs();
                //System.out.println("폴더가 생성되었습니다.");
            } catch(Exception e) {
                e.getStackTrace();
            }        
        } 
        
        String filename   = getUUID(20);
        String fileid   = getUUID(20);

        String fullpath = saveDir + "/" + filename;
        File orgFile = new File(fullpath);
        String filedir = saveDir+"/"+ORGCD;
        File saveFolder2 = new File(filedir);
        if (!saveFolder2.exists()) {
            try {
                saveFolder2.mkdirs();
                //System.out.println("날짜 폴더가 생성되었습니다.");
            } catch(Exception e) {
                e.getStackTrace();
            }        
        }
        String filename2 = fileid;
        String icon_url = serverDir+"/pds/"+ORGCD+"/"+filename2;
        //String icon_url = serverDir+"/mr/";
        
        INVAR.put("icon_url", icon_url);
        String qry = getQuery(pgmid, "qrysave");
        String qryRun = bindVAR(qry,INVAR);
        JSONObject rst = executeSVC(conn, qryRun);  
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else { 
            conn.commit();
        } 
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}else if("searchMr".equals(func)) {
    Connection conn = null; 
    try {  
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        INVAR.put("comcd",ORGCD);
        String qry = getQuery(pgmid, "searchMR"); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        
        JSONArray list = selectSVC(conn, qryRun);
        OUTVAR.put("list",list); 

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
