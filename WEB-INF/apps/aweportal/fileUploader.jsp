<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, 
                 java.io.*,
                 com.oreilly.servlet.MultipartRequest, 
                 com.oreilly.servlet.multipart.DefaultFileRenamePolicy " %> 

<% 
JSONObject OUTVAR = new JSONObject(); 
String appid = "aweportal";  
String pgmid = "fileUploader"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";
String serverDir = "https://localhost:9090";
try { 
/***************************************************************************************************/
Connection conn = null;
try {   
    conn = getConn("LFN");
    conn.setAutoCommit(false);
    String saveDir = application.getRealPath("pds");

    int maxSize = 1024*1024*10; // 최대 10mb
    String encType = "utf-8";
    DefaultFileRenamePolicy policy = new DefaultFileRenamePolicy();
    MultipartRequest multi = new MultipartRequest(request, saveDir, maxSize, encType, policy);
    
    String invar = multi.getParameter("INVAR");
    JSONObject INVAR  = getObject(invar);
    
    String filename   = multi.getFilesystemName("file");
    String fileid     = getUUID(20);
    String file_tp    = getVal(INVAR, "file_tp");
    String ref_file_tp= getVal(INVAR, "ref_file_tp");
    String fileno     = getVal(INVAR, "fileno");
    String fileSize   = getVal(INVAR, "fileSize");
    String ref_id     = getVal(INVAR, "ref_id");
    String dateDir     = getVal(INVAR, "dateDir");
    String filename2  = "";
    
    OUTVAR.put("filetp",file_tp);   
    OUTVAR.put("filename",filename);
    OUTVAR.put("fileid",fileid);    
    OUTVAR.put("fileno",fileno);  
    OUTVAR.put("dateDir",dateDir);    

    String fullpath = saveDir + "/" + filename;
    File orgFile = new File(fullpath);
    String filedir = saveDir;
    INVAR.put("filedir", filedir);
    if (!"".equals(filename) && orgFile != null ) {
        int pos = filename.lastIndexOf(".");
        String ext = nvl(filename.substring(pos+1),"");
        INVAR.put("ext", ext);
        if (!"".equals(ext)) {
            ext = ext.toLowerCase();
            filename2 = fileno + "." + ext;
            INVAR.put("filename2", filename2);
        }
        else filename2 = fileno;
        INVAR.put("filename2", filename2);
        String sNewpath = saveDir+"/"+ORGCD+"/"+file_tp+"/"+dateDir+"/";  
        File newpath = new File(sNewpath);
        if (!newpath.exists()) {
            newpath.mkdirs();
        }
        //이미 존재하는 경우 삭제
        File bfFile = new File(sNewpath+filename2);
        if (bfFile.exists()) {
            bfFile.delete();
        } 
        orgFile.renameTo(new File(sNewpath+filename2));
        
    }
    String file_url = serverDir+"/pds/"+ORGCD+"/"+file_tp+"/"+dateDir+"/"+filename2;
    String qry = "INSERT INTO T_FILE (FILEID, FILE_TP, REF_FILE_TP, REF_ID, FILE_NM, ORGN_NM, FILE_EXT, FILE_URL, FILE_DIR, FILE_SZ, SORT_SEQ, FILE_STAT, REG_USID, REG_DT, UPD_USID, UPD_DT) VALUES ({fileid}, {file_tp}, {ref_file_tp}, {ref_id}, {filename2}, {filename}, {ext}, {file_url}, {filedir}, {fileSize}, '', 'Y', {userid}, SYSDATE, {userid}, SYSDATE);";
    INVAR.put("userid", USERID);
    INVAR.put("fileid", fileid);
    INVAR.put("filename",filename);
    INVAR.put("file_url", file_url);
    qry = bindVAR(qry,INVAR); 
    JSONObject rst = executeSVC(conn, qry);
    OUTVAR.put("file_url",file_url);  
    OUTVAR.put("qry",qry);
    if(!"OK".equals(getVal(rst,"rtnCd"))) {
        conn.rollback();
        rtnCode = getVal(rst,"rtnCd"); 
        rtnMsg  = getVal(rst,"rtnMsg");
        System.out.println(rtnCode + ", " + rtnMsg);
    } else {
        conn.commit(); 
    }
} catch (Exception e) {
    e.printStackTrace();
    rtnCode    = "ERR";
    rtnMsg = e.getMessage();
    System.out.print("<h2>Exception이 발생했습니다 </h2> <br> <pre>" + e.getMessage() + "</pre>");
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