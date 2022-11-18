<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, 
                 java.io.*,
                 com.oreilly.servlet.MultipartRequest, 
                 com.oreilly.servlet.multipart.DefaultFileRenamePolicy " %>
                 
<% 
JSONObject OUTVAR = new JSONObject(); 
String appid = "aweportal";  
String pgmid = "popupUpload"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";
String serverDir = "https://fo.lfnetworks.co.kr";
try { 
/***************************************************************************************************/
if("getFile".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        String invar = request.getParameter("INVAR");
        JSONObject INVAR  = getObject(invar);
        String qry = getQuery(pgmid, "getFile");
        qry = bindVAR(qry, INVAR);
        JSONArray list = selectSVC(conn, qry);
        OUTVAR.put("list",list);  
    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
} else if("getFileReq".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        String invar = request.getParameter("INVAR");
        JSONObject INVAR  = getObject(invar);
        String qry = getQuery(pgmid, "getFileReq");
        qry = bindVAR(qry, INVAR);
        JSONArray list = selectSVC(conn, qry);
        OUTVAR.put("list",list);  
    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
} else if("getFileRes".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        String invar = request.getParameter("INVAR");
        JSONObject INVAR  = getObject(invar);
        String qry = getQuery(pgmid, "getFileRes");
        qry = bindVAR(qry, INVAR);
        JSONArray list = selectSVC(conn, qry);
        OUTVAR.put("list",list);  
    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
} else if("deleteFile".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        String invar = request.getParameter("INVAR");
        JSONObject INVAR  = getObject(invar);
        String qry = getQuery(pgmid, "deleteFile");
        qry = bindVAR(qry,INVAR);
        JSONObject rst = executeSVC(conn, qry);
    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
} else if("searchFileid".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        String invar = request.getParameter("INVAR");
        JSONObject INVAR  = getObject(invar);
        OUTVAR.put("INVAR",INVAR);
        String qry = "SELECT * FROM T_FILE WHERE fileid={fileid}";
        qry = bindVAR(qry,INVAR); 
        JSONArray list = selectSVC(conn, qry);
        OUTVAR.put("list",list);  
    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
} else if("updateSortseq".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false); 
        String invar = request.getParameter("INVAR"); 
        JSONObject INVAR  = getObject(invar);
        INVAR.put("usid",USERID);
        String qry = getQuery(pgmid, "updateSortseq");
        String qryRun = "";
        
        JSONArray arrList = getArray(INVAR,"list");
        for(int i = 0; i < arrList.size(); i++) {
            JSONObject row = getRow(arrList,i); 
            row.put("comcd",ORGCD); 
            row.put("usid",USERID);  
            qryRun += bindVAR(qry,row) + "\n"; 
        } 
        
        if(!isNull(qryRun)) {
            JSONObject rst = executeSVC(conn, qryRun);  
            if(!"OK".equals(getVal(rst,"rtnCd"))) {
                conn.rollback();
                rtnCode = getVal(rst,"rtnCd"); 
                rtnMsg  = getVal(rst,"rtnMsg"); 
            } else {  
                conn.commit();
            } 
        }  
    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }   
} else {
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
        int maxSize = 1024*1024*100; // 최대 100mb
        String encType = "utf-8";
        DefaultFileRenamePolicy policy = new DefaultFileRenamePolicy();
        MultipartRequest multi = new MultipartRequest(request, saveDir, maxSize, encType, policy);
        
        /********************* INVAR를 여기서 선언 *********************/
        String invar = multi.getParameter("INVAR");
        JSONObject INVAR  = getObject(invar);
        
        String filename   = multi.getFilesystemName("file");
        String fileid     = getUUID(20);
        String file_tp    = getVal(INVAR, "file_tp");
        String ref_file_tp= getVal(INVAR, "ref_file_tp");
        String fileno     = getVal(INVAR, "fileno");
        String fileSize   = getVal(INVAR, "fileSize");
        String ref_id     = getVal(INVAR, "ref_id");
        String dateDir    = getVal(INVAR, "dateDir");
        String filename2  = fileid;
        
        OUTVAR.put("filetp",file_tp);   
        OUTVAR.put("filename",filename);
        OUTVAR.put("fileid",fileid);    
        OUTVAR.put("fileno",fileno);  
        OUTVAR.put("dateDir",dateDir);    
    
        String fullpath = saveDir + "/" + filename;
        File orgFile = new File(fullpath);
        String filedir = saveDir+"/"+ORGCD+"/"+file_tp+"/"+dateDir;
        INVAR.put("filedir", filedir);
        File saveFolder2 = new File(filedir);
        if (!saveFolder2.exists()) {
            try {
                saveFolder2.mkdirs();
                //System.out.println("날짜 폴더가 생성되었습니다.");
            } catch(Exception e) {
                e.getStackTrace();
            }        
        } 
        if (!"".equals(filename) && orgFile != null ) {
            int pos = filename.lastIndexOf(".");
            String ext = nvl(filename.substring(pos+1),"");
            INVAR.put("ext", ext);
            if (!"".equals(ext)) {
                ext = ext.toLowerCase();
                filename2 = filename2 +"." + ext;
                INVAR.put("filename2", filename2);
            }
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
        String qry = getQuery(pgmid, "uploadFile");
        INVAR.put("userid", USERID);
        INVAR.put("fileid", fileid);
        INVAR.put("filename", filename);
        INVAR.put("file_url", file_url);
        qry = bindVAR(qry,INVAR); 
        JSONObject rst = executeSVC(conn, qry);
        OUTVAR.put("uploadQuery",qry);
        OUTVAR.put("file_url",file_url);  
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg");
            //System.out.println(rtnCode + ", " + rtnMsg);
        } else {
            conn.commit(); 
        }
    } catch (Exception e) {
        e.printStackTrace();
        rtnCode    = "ERR";
        rtnMsg = e.getMessage();
        //System.out.print("<h2>Exception이 발생했습니다 </h2> <br> <pre>" + e.getMessage() + "</pre>");
        log.error("<h2>Exception이 발생했습니다 </h2> <br> <pre>" + e.getMessage() + "</pre>",e);
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