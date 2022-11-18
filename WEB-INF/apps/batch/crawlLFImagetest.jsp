<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" 
    import="java.net.*" %> 
<%@page import="java.io.File"%>

<%@page import="java.net.URL"%>

<%@page import="javax.imageio.ImageIO"%>
<%@page import="java.awt.image.BufferedImage"%>
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "batch";
String pgmid   = "crawlLFImagetest"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/
//search:조회 이벤트처리(DB_Read)     
if("search".equals(func)) {
    Connection conn = null; 
    try {  
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        INVAR.put("comcd",ORGCD);
        String qry = getQuery(pgmid, "qrysearch"); 
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

if("download".equals(func)) {
    Connection conn = null; 
    try
    {
    OUTVAR.put("INVAR",INVAR); //for debug
    conn = getConn("LFN");  
    INVAR.put("comcd",ORGCD);
        //String qry = getQuery(pgmid,"qryselect");
        //String qryRun = bindVAR(qry,INVAR);
        //OUTVAR.put("qryRun",qryRun); //for debug
        //JSONArray list = selectSVC(conn, qryRun);
        //OUTVAR.put("list",list); 
        
        JSONArray image_yn = new JSONArray();
        
        
        JSONArray list = getArray(INVAR,"list"); //list
        for(int i=0;i<list.size();i++){
            //String imgUrl = "https://nimg.lfmall.co.kr/file/product/prd/AE/2020/1500/AEDR0E015WT_02.jpg"; 
            String imgUrl = getVal(list,i,"url");
            String[] arrImgName = imgUrl.split("/");
            String imgName = arrImgName[arrImgName.length-1];
            String imgFilePath = "\\"+imgName;
            //String imgFilePath = "C:\\test\\test.jpg";
            String imgFormat = "jpg";                         // 저장할 이미지 포맷. jpg, gif 등
            
            String rootDir = application.getRealPath("/");
            //System.out.println(rootDir);  //C:\LFN\workspace\lfn_ep\
            String stcl = getVal(list,i,"stcl");
            File Folder = new File(rootDir + stcl);
        	// 해당 디렉토리가 없을경우 디렉토리를 생성합니다.
        	if (!Folder.exists()) {
        	    Folder.mkdir(); //폴더 생성합니다.
        		System.out.println("폴더가 생성되었습니다.");
            }else {
        		System.out.println("이미 폴더가 생성되어 있습니다.");
        	}
            
            System.out.println(arrImgName);
            System.out.println(imgUrl);
            System.out.println(imgFilePath);
            System.out.println(imgFormat);
            //String FILE_URL = "리소스 경로"; 
            conn = getConn("LFN");
            
            URL url = new URL(imgUrl);
            HttpURLConnection conn = (HttpURLConnection)url.openConnection();
            //conn.setRequestMethod("GET");
            ////connection.connect();
            
            int code = conn.getResponseCode();
            System.out.println(code);
            
            if(code != 200){
                //404 에러일때
                image_yn.add("N");
                continue;
            } else {
                image_yn.add("Y");
            }
            
            //수정
            InputStream is = conn.getInputStream();
            BufferedInputStream bis = new BufferedInputStream(is);
            FileOutputStream os = new FileOutputStream(rootDir+ "\\" + stcl + imgFilePath);
            BufferedOutputStream bos = new BufferedOutputStream(os);
            int byteImg;
            
            byte[] buf = new byte[conn.getContentLength()];
            while((byteImg = bis.read(buf)) != -1){
                bos.write(buf,0,byteImg);
            }
            
            bos.close();
            os.close();
            bis.close();
            is.close();
            
            //// ImageIO 사용시 , Image 가져오기
            //BufferedImage image = ImageIO.read(new URL(imgUrl));
            //System.out.println(image);
            //// Image 저장할 파일
            ////File imgFile = new File(imgFilePath);
            //File imgFile = new File(rootDir+ "\\" + stcl + imgFilePath);
            //// Image 저장
            //ImageIO.write(image, imgFormat, imgFile);    
        }
        OUTVAR.put("image_yn",image_yn); 
        
    }
    catch (Exception e)
    {
        e.printStackTrace();
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
