<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    import="java.util.*, 
	        java.net.*,
			javax.servlet.http.*, 
        	org.json.simple.*,
            org.json.simple.parser.*,
            java.sql.*,  
        	java.text.SimpleDateFormat,
        	javax.sql.DataSource,
        	javax.naming.Context,
        	javax.naming.InitialContext,  
	    	java.io.BufferedReader,
	    	java.io.Reader,
	    	java.io.Writer,
	    	java.io.CharArrayReader,
	    	oracle.sql.CLOB,
	    	oracle.sql.BLOB,
	    	oracle.jdbc.OracleResultSet, 
        	java.io.*,
        	java.nio.charset.StandardCharsets,
        	java.nio.file.*,
        	java.nio.file.Files,
        	java.security.*
            "
 %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "mine";
String pgmid   = "ace"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar);

/***************************************************************************************************/
if("save".equals(func)) {

    FileWriter fw = null;
	String fileName = "C:/LFNDEV/workspace/LFN_EP/pds/[flnm].txt";
    fileName = bindVAR(fileName, INVAR);

    try { 

			fw = new FileWriter(fileName);			

			String data = "[ctt]";
            data = bindVAR(data, INVAR);

			fw.write(data);

		} catch (IOException e) {
		} finally {
			fw.close();	
		}

}

if("explore".equals(func)) {

	String fileName = "C:/LFNDEV/workspace/LFN_EP/pds/[flnm].txt";
    fileName = bindVAR(fileName, INVAR);

		File file = new File(fileName);			
		FileReader fr = null;					
		BufferedReader br = null;	
		
					

		if (file.exists()) {				

			try {
				fr = new FileReader(file);
				br = new BufferedReader(fr);
				String content = "";

				while (true) {

					String line = br.readLine();

					if (line == null) {
						break;
					}

					content += line;

				}
				OUTVAR.put("content", content);

			} catch (Exception e) {
			} finally {

				try { br.close(); } catch (IOException e) { e.printStackTrace(); }
				try { fr.close(); } catch (IOException e) { e.printStackTrace(); }

			}

		}

	}

if("list".equals(func)) {
	File dir = new File("C:/LFNDEV/workspace/LFN_EP/pds");
	String[] filenames = dir.list();
	String content = "";
	for (int i = 0; i < filenames.length; i++) {
		// System.out.println("file: " + filenames[i]);
		content += filenames[i] + "\n";
	}

	OUTVAR.put("content", content);
}

/***************************************************************************************************/
} catch (Exception e) {
	// logger.error(pgmid+" error occurred:"+rtnCode,e);
	rtnCode    = "ERR in editor";
	rtnMsg     = e.toString();
} finally {
	OUTVAR.put("rtnCd",rtnCode);
	OUTVAR.put("rtnMsg",rtnMsg); 
	out.println(OUTVAR.toJSONString());
}
%>