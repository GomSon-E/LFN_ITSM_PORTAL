<%@ include file="../common/common.jsp" %> 
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"  
         import="java.util.*, 
                 java.io.*, 
                 org.apache.commons.codec.binary.* ,
                 com.oreilly.servlet.multipart.DefaultFileRenamePolicy,
                 com.oreilly.servlet.MultipartRequest,
                 net.coobird.thumbnailator.*,
                 java.io.BufferedReader,
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
				 org.apache.commons.net.ftp.FTPClientConfig,
				 org.apache.commons.net.ftp.FTPFile,
				 org.apache.commons.net.ftp.FTPReply,
				 java.util.concurrent.locks.Lock,
	             java.util.concurrent.locks.ReentrantLock, 
	             java.net.URL,
	             java.awt.image.*,
	             javax.imageio.ImageIO, 
	             java.awt.Graphics,
	             java.awt.Image,
	             java.awt.image.BufferedImage" %> 
<% 
JSONObject OUTVAR = new JSONObject(); 
String pgmid = "fileuploaderAJAX"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = ""; 
 
try{
	
	MyFTPClient cdn = new MyFTPClient();
	try {   
			String saveDir = application.getRealPath("pds"); //일단 pds경로에 받는다.  
		    int maxSize = 1024*1024*50; //최대 100MB
			String encType = "utf-8";   
			MultipartRequest multi = new MultipartRequest(request, saveDir, maxSize, encType, new DefaultFileRenamePolicy());
			String filetype = nvl(multi.getParameter("filetype"),"doc");  //jejiimg, jejifile
OUTVAR.put("filetype",filetype);
			String fileno    = getUUID(20);
			String docno    = nvl(multi.getParameter("docno"),fileno);
OUTVAR.put("docno",docno);			
			String filename = multi.getFilesystemName("file");
OUTVAR.put("filename",filename);			
			String fullpath = saveDir + "/" + filename; //pds 폴더로 업로드된 파일의 Fullpath 
			File orgFile = new File(fullpath);  
			//logger.error(fullpath);	
			if (!"".equals(filename) && orgFile != null ) {
				int pos = filename.lastIndexOf(".");
				String ext = nvl(filename.substring(pos+1),"");
				if (!"".equals(ext)) ext = ext.toLowerCase();
				
				/* 기존 WAS서버의 pds폴더에 저장하였으나 CDN으로 ftp전송하고 pds폴더에 있는 파일은 삭제함.
				//저장경로 확인하여 생성
				String sNewpath = saveDir+"/"+ORGCD+"/"+filetype+"/"+docno+"/";  
				File newpath = new File(sNewpath);
			    if (!newpath.exists()) {
			    	newpath.mkdirs();
			    }
			    //이미 존재하는 경우 삭제
			    File bfFile = new File(sNewpath+filename);
			    if (bfFile.exists()) {
			    	bfFile.delete();
			    } 
		    	orgFile.renameTo(new File(sNewpath+filename));
                */
                //ftp연결
                cdn.doConnect();
		   		cdn.doLogin(); 
		   		/* 목표저장경로와 파일명 : /mdpjeji/jejiimg/DGP1ACB1101/20200520171602abcd.png */
		   		String tgtpath = "/mdpjeji"; 
		   		boolean bChk = cdn.doCd(tgtpath);
		   		if(!bChk) {  /* cd가 안되면 경로를 만들어서 cd함 */
		   			cdn.doMkdir(tgtpath);
		   			cdn.doCd(tgtpath);
		   		}
		   		bChk = cdn.doCd(tgtpath+"/"+filetype);
		   		if(!bChk) {  /* cd가 안되면 경로를 만들어서 cd함 */
		   			cdn.doMkdir(filetype);
		   			cdn.doCd(tgtpath+"/"+filetype);
		   		}
		   		bChk = cdn.doCd(tgtpath+"/"+filetype+"/"+docno);
		   		if(!bChk) {  /* cd가 안되면 경로를 만들어서 cd함 */
		   			cdn.doMkdir(docno);
		   			cdn.doCd(tgtpath+"/"+filetype+"/"+docno);
		   		}
		   		
		   		String newfileNm = fileno;
		   		if (!"".equals(ext)) newfileNm = fileno+"."+ext; 
		   		cdn.doDelete(newfileNm);
                bChk = cdn.doPut(orgFile, newfileNm); 
                
			    //TFILELOG
			    String qry = "";
			    qry  = "	INSERT INTO TFILE	\n";
			    qry += "	     ( fileno, orgcd, filetype, docno, filenm, pgmid, svrpath, url, reguserid, regdt, upduserid, upddt )	\n";
			    qry += "	VALUES	\n";
			    qry += "	     ( '"+fileno+"'	\n";
			    qry += "	     , '"+ORGCD+"'	\n";
			    qry += "	     , '"+filetype+"'	\n";
			    qry += "	     , '"+docno+"'	\n";
			    qry += "	     , '"+filename+"'	\n";
			    qry += "	     , 'fileupload'	\n";
			    qry += "	     , '"+tgtpath+"/"+filetype+"/"+docno+"'	\n";
			    qry += "	     , 'https://img.pastelmall.com"+tgtpath+"/"+filetype+"/"+docno+"/"+newfileNm+"'	\n";
			    qry += "	     , '"+USERID+"'	\n";
			    qry += "	     , SYSDATE  	\n";
			    qry += "	     , '"+USERID+"'	\n";
			    qry += "	     , SYSDATE )	\n";
			    executeUpdate(qry); 
			    
			    orgFile.delete();
 
                OUTVAR.put("fileno", fileno ); 
  	  		} else {
 
  	  		    OUTVAR.put("fileno", "no file sent" ); 
            }
	} catch (Exception e) {
	    rtnCode = "ERR0";
	    rtnMsg  = e.toString();
	} finally { 
    	cdn.doQuit();
	}  
/***************************************************************************************************/
} catch (Exception e) { 
	rtnCode    = "ERR";
	rtnMsg     = e.toString();
} finally {
	OUTVAR.put("rtnCd",rtnCode);
	OUTVAR.put("rtnMsg",rtnMsg); 
	out.println(OUTVAR.toJSONString());
}	
%> 

<%!   
public class MyFTPClient {
	FTPClient ftpClient = new FTPClient();
	public MyFTPClient() {
	}
	
	// FTP연결
	public void doConnect() {
		try {
			/*
			// 포트는 여기 메소드에서 밖에 쓰이지 않으므로 지역변수로 선언.
			int port = 21;
			String server = "upload8.krweb.nefficient.com";
			// FTPServer에 Connect서버 연결
			ftpClient.connect(server, port); 
			*/

			int port = 9921;
			String server = "pastelmall-upload.myskcdn.com";
			// FTPServer에 Connect서버 연결
			FTPClientConfig conf = null;
            conf = new FTPClientConfig(FTPClientConfig.SYST_UNIX);
            ftpClient.configure(conf);
            ftpClient.connect(server, port);
			ftpClient.enterLocalPassiveMode();  

			// 응답이 정상적인지 확인 하기 위해 응답 받아오기
			int replyCode = ftpClient.getReplyCode();		
			// 서버와의 응답이 정상인지 확인
			if (FTPReply.isPositiveCompletion(replyCode)) {
				System.out.println(server + "에 연결되었습니다.");
				System.out.println(ftpClient.getReplyCode() + " SUCCESS CONNECTION.");
			}
		} catch (SocketException e) {
			System.out.println("서버 연결 실패");
			System.exit(1);
		} catch (IOException e) {
			System.out.println("서버 연결 실패");
			System.exit(1);
		}
	}

	// FTP서버 로그인
	public boolean doLogin() {
		try {
			/*
			String id = "pastelmall";
			String pw = "pastelworld20@";
			*/
			String id = "pastelmall";
			String pw = "pastelmall.coKr#4";
			boolean success = ftpClient.login(id, pw);
			if (!success) {
				System.out.println(ftpClient.getReplyCode() + " Login incorrect.");
				System.exit(1);
			} else {
				ftpClient.setControlEncoding("EUC-KR"); //"UTF-8"
				ftpClient.setFileType(FTP.BINARY_FILE_TYPE);
				System.out.println(ftpClient.getReplyCode() + " Login successful.");
			}
		} catch (IOException e) {
			System.out.println(ftpClient.getReplyCode() + " Login incorrect.");
			return false;
		} finally {
			
		}
		return true;
	}// end doLogin() 
	public String[] doLs() {
		String[] files = null;
		try {
			files = ftpClient.listNames();
			for (int i = 0; i < files.length; i++) { System.out.println(files[i]); } 
		} catch (IOException e) {
			System.out.println("서버로 부터 파일목록을 가져오지 못했습니다.");
		}
		return files;
	}// end doLs()

	public FTPFile[] doDir() {
		FTPFile[] files = null;
		try {
			files = ftpClient.listFiles();
			//for (int i = 0; i < files.length; i++) { System.out.println(files[i]); }
		} catch (IOException e) {
			System.out.println("서버로 부터 디렉토리를 가져오지 못했습니다.");
		}
		return files;
	}// end doDir()

	public boolean doCd(String path) {
		boolean rtn = false;
		try {
			rtn = ftpClient.changeWorkingDirectory(path);
			System.out.println("디렉토리를 변경하였습니다:"+path+" "+rtn);
		} catch (IOException e) {
			System.out.println("디렉토리변경시 오류가 발생하였습니다:"+e.toString());
		}
		return rtn;
	}// end doCd()
	
	public boolean doPut(File putFile, String fileName) {
		boolean rtn = false;
		InputStream inputStream = null;
		try {
			// PUT할 파일명 입력
			inputStream = new FileInputStream(putFile);
			ftpClient.storeFile(fileName, inputStream);
			rtn = true;
		} catch (IOException e) {
			e.printStackTrace(); 
		} catch (NumberFormatException e) {
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		} catch (Throwable e) {
			e.printStackTrace();
		} finally {
			if (inputStream != null) {
				try {
					inputStream.close(); 
				} catch (IOException e1) {
				}
			}
		}
		return rtn;
	}// end doPut()
	
	public void doGet(String fileName, File getFile) {
		OutputStream outputStream = null;
		try {
			// GET할 파일명 입력
			outputStream = new FileOutputStream(getFile);
			ftpClient.retrieveFile(fileName, outputStream);
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			if (outputStream != null) {
				try {
					outputStream.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
	}// end doGet()

	public void doMkdir(String directoryName) {//디렉토리 생성 메소드
		try {
			System.out.print("생성할 디렉토리 이름 입력 :");
			ftpClient.makeDirectory(directoryName);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}// end doMkdir()
	
	public void doRmdir(String directoryName) {
		try {
			System.out.print("삭제할 디렉토리 이름 입력 :");
			ftpClient.removeDirectory(directoryName);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}// end rmMkdir()
	
	public void doDelete(String fileName) {
		try {
			//System.out.print("삭제할 파일 입력: "); 
			ftpClient.deleteFile(fileName);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}// end doDelete()
		
	public void doQuit() {
		try {
			ftpClient.disconnect();
			System.out.println(ftpClient.getReplyCode() + " Goodbye.");
		} catch (IOException e) {
			e.printStackTrace();
		}
	}// end doQuit()	 
}
%>  