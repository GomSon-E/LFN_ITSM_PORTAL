<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" 
    trimDirectiveWhitespaces="true"
    import="java.io.BufferedReader,
		    java.io.File,
			java.io.FileInputStream,
			java.io.FileOutputStream,
			java.io.IOException,
			java.io.InputStream,
			java.io.InputStreamReader,
			java.io.OutputStream,
			java.net.SocketException,
			java.util.Scanner,
			org.apache.commons.net.ftp.FTP,
			org.apache.commons.net.ftp.FTPClient,
			org.apache.commons.net.ftp.FTPFile,
			org.apache.commons.net.ftp.FTPReply,
			java.util.concurrent.locks.Lock,
            java.util.concurrent.locks.ReentrantLock, 
            java.net.URL,
            java.awt.image.*,
            javax.imageio.ImageIO,
            net.coobird.thumbnailator.*,
            java.awt.Graphics,
            java.awt.Image,
            java.awt.image.BufferedImage"
%><%  
//if (!aweCheck(session)) return;   
JSONObject OUTVAR = new JSONObject(); 
String pgmid = "fileDownloader"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = ""; 
StringBuffer sb = null;
try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar);
String url = getVal(INVAR,"url");
String filename = getVal(INVAR,"filename"); //orgn_nm
/***************************************************************************************************/
OUTVAR.put("INVAR",INVAR);
OUTVAR.put("url",url);
OUTVAR.put("filename",filename);

String fileType = url.substring(url.lastIndexOf(".")+1); 
if (fileType.equals("hwp")){
  response.setContentType("application/x-hwp");
} else if (fileType.equals("pdf")){
  response.setContentType("application/pdf");
} else if (fileType.equals("ppt") || fileType.equals("pptx")){
  response.setContentType("application/vnd.ms-powerpoint");
} else if (fileType.equals("doc") || fileType.equals("docx")){
  response.setContentType("application/msword");
} else if (fileType.equals("xls") || fileType.equals("xlsx")){
  response.setContentType("application/vnd.ms-excel");
} else {
  response.setContentType("application/octet-stream");
}
response.setHeader("Content-Disposition","attachment;filename="+filename); 

URL infoURL = new URL(url);
URLConnection connection = infoURL.openConnection();
int contentLength = connection.getContentLength();
BufferedOutputStream bos = null;
if (contentLength > 0) {
    InputStream raw = null;
    InputStream bin  = null;
    try{  
        raw = connection.getInputStream();
        bin = new BufferedInputStream(raw);
        byte[] data = new byte[contentLength];
        int bytesRead = 0;
        int offset = 0;  
        while (offset < contentLength) {
            bytesRead = bin.read(data, offset, data.length - offset);
            if (bytesRead == -1) break;
            offset += bytesRead;
        }
        // 바이너리 데이터 준비 완료 ! 
        if (offset == contentLength) {
            bos = new BufferedOutputStream(response.getOutputStream());
            bos.write(data);
            bos.flush();
            bos.close();
            return;
        }  
    }catch (Exception e){                  
        rtnCode = "ERR";
        rtnMsg = e.toString();
    }finally{
        try {
            if(raw != null) raw.close();
            if(bin != null) bin.close();
            if(bos != null) bos.close();
        }
        catch(Exception e1){
            rtnCode = "ERR";
            rtnMsg  = e1.toString(); 
        }
    }    
}   
//out.clearBuffer();
// response.setContentType("text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8; charset=utf-8"); // 생략가능
//out.print(sb.toString());
//OUTVAR.put("content",sb.toString());
 
/***************************************************************************************************/
} catch (Exception e) { 
	rtnCode    = "ERR";
	rtnMsg     = e.toString();
} finally { 
    if(!"OK".equals(rtnCode)) {
    	OUTVAR.put("rtnCd",rtnCode);
    	OUTVAR.put("rtnMsg",rtnMsg); 
      out.clear();      
    	out.println(OUTVAR.toJSONString());
    }
}
%>