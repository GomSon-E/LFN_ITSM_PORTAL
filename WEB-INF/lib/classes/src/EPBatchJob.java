package ep;

import java.net.*;
import java.util.*; 
import javax.servlet.http.*; 
import org.json.simple.*;
import org.json.simple.parser.*;
import java.sql.*;  
import java.text.SimpleDateFormat;
import javax.sql.DataSource;
import javax.naming.Context;
import javax.naming.InitialContext; 
import javax.servlet.http.*;
import java.io.BufferedReader;
import java.io.Reader;
import java.io.Writer;
import java.io.CharArrayReader;
import oracle.sql.CLOB;
import oracle.sql.BLOB;
import oracle.jdbc.OracleResultSet;
import org.apache.commons.io.*;
import java.io.*;  
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.nio.file.Files;
import java.security.*; 

public class EPBatchJob implements Runnable {

	@Override
	public void run() {
        Connection conn = null;
        
        InputStreamReader isr = null;
		BufferedReader bin = null;
		HttpURLConnection huc = null;
		
		BufferedReader br = null;
	    StringBuffer sb = null;
        String sOUTVAR = "";
		JSONObject OUTVAR = null; 
		
		System.out.println("EPBatchJob starts at :"+ new java.util.Date() );
        System.out.println("deploy check v2.7");  
          
		try {
            //0.배치잡 수행시작 로그 인서트
			//String userid,String pgmid, String logtype, String keyval, String info) {
			insertLog(USERID, "EPBatchJob", "run", "START AT", (new java.util.Date()).toString() );
			
			//1.BatchJob 수행대상 1차 조회
			conn = getConn("COMMON");
			String qry = "SELECT * FROM TPGM ";
			qry += " WHERE module IN ( 'jandi', 'rpa', 'batch') ";  
			qry += "   AND pgmtype = 'jsp' ";
			qry += "   AND statcd = 'Y' "; 
			qry += "   AND SUBSTRB(SHORTCUT,1,8) <= TO_CHAR(SYSDATE,'YYYYMMDD') "; 
			qry += "   AND SUBSTRB(SHORTCUT,10,8) >= TO_CHAR(SYSDATE,'YYYYMMDD') ";
			JSONArray list = selectSVC(conn, qry);
			
			//2. 수행대상을 Loop돌리면서 호출 (remark를 조건으로 넣어서 현재 수행대상인지 체크)
			for(int i=0; i < list.size(); i++) {
				JSONObject row = getRow(list, i);
				qry = "SELECT * FROM TPGM ";
				qry += " WHERE pgmid = {pgmid} ";
				qry += "   AND statcd = 'Y' "; 
				qry += "   AND ([remark]) ";
				qry = bindVAR(qry,row);
		        System.out.println("joblist check :" + qry );  
				JSONArray jobs = selectSVC(conn, qry);
				
				if(jobs.size()==1) {
					JSONObject job = getRow(jobs, 0);
			        System.out.println("job start :" + getVal(job,"pgmid"));  
					
					//3.상태 업데이트
					qry = "UPDATE TPGM SET statcd = 'R', upddt=SYSDATE WHERE pgmid= {pgmid}";
					qry = bindVAR(qry, job); 
					JSONObject rst1 = executeSVC(conn, qry); 
					
					//4.잡 호출하여 실행(url호출)
					String sUrl = "http://localhost/ep/?dir=EPBatchJob&module="+getVal(row,"module")+"&pgm="+getVal(row,"pgmid")+"&func=run";
					URL url = new URL(sUrl);
					huc = (HttpURLConnection) url.openConnection();
			        huc.setRequestMethod("POST");  
			        huc.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
			        huc.setRequestProperty("Accept", "application/json");  
			        huc.setRequestProperty("Cache-Control","no-cache"); // 컨트롤 캐쉬 설정 
			        huc.setRequestProperty("Content-Length", "length"); // 타입길이 설정(Request Body 전달시 Data Type의 길이를 정함.) 
			        huc.setRequestProperty("User-Agent", "test");       // User-Agent 값 설정 
			        huc.setDoOutput(true); // OutputStream으로 서버에서 요청을 보내겠다는 옵션.
			        huc.setDoInput(true);  // InputStream으로 서버로 부터 응답을 받겠다는 옵션.  
			        huc.connect(); 
			        
			        //5.수행결과 받기
			        int responseCode = huc.getResponseCode(); 
			        //System.out.println("HourlyJob:"+ responseCode); 
			        br = new BufferedReader(new InputStreamReader(huc.getInputStream(), "UTF-8")); 
			        sb = new StringBuffer(); 
			        String temp = "";
			        while ((temp = br.readLine()) != null) {
			            sb.append(temp);
			        }
			        sOUTVAR = sb.toString();
			        JSONParser parser = new JSONParser();
			        OUTVAR = (JSONObject) parser.parse(sOUTVAR); 
			        //System.out.println(OUTVAR.toJSONString());
			        
					//7.상태 업데이트
					qry = "UPDATE TPGM SET statcd = 'Y', upddt=SYSDATE  WHERE pgmid= {pgmid}";
					qry = bindVAR(qry, job); 
					JSONObject rst2 = executeSVC(conn, qry); 
					
					//8.수행결과 Log쓰기 
					//String userid,String pgmid, String logtype, String keyval, String info) {
					String info = OUTVAR.toJSONString();
					if( info.length() > 3000 ) info = info.substring(0,2999);
					insertLog(USERID, getVal(row,"pgmid"), "run", "responseCode:"+responseCode, info );
				}
			}	

	        //9.배치잡 수행시작 로그 인서트
			//String userid,String pgmid, String logtype, String keyval, String info) {
			insertLog(USERID, "EPBatchJob", "run", "FINISHED AT", (new java.util.Date()).toString() );
			
			/*
	        // Request 용 JSON데이터 생성
			JSONObject INVAR = new JSONObject();
	        JSONObject oBody = new JSONObject();
	        oBody.put("url_webhook","https://wh.jandi.com/connect-api/webhook/20736797/0254859c476d6cd040d34ecbeacac8d6");
	        oBody.put("body", "test");
	        oBody.put("email","kihyunlee@tribons.co.kr"); 
	        oBody.put("connectColor", "#ff0000"); 
	        JSONArray connectInfo = new JSONArray(); 
	        JSONObject connectItem = new JSONObject();
	        connectItem.put("title","테스트");
	        connectItem.put("description","EP 워크벤치에서 고쳤음");
	        connectItem.put("imageUrl","http://url_to_text");
	        connectInfo.add(connectItem);  
	        oBody.put("connectInfo",connectInfo); 
            INVAR.put("INVAR",oBody);			
			
			
	        //커넥션 생성
	        String sUrl = "http://ep.tribons.co.kr/?dir=jandiwebhookteam&func=send";
	        sUrl += "&INVAR="+URLEncoder.encode( oBody.toJSONString(), "UTF-8");

	        URL url = new URL(sUrl);
			huc = (HttpURLConnection) url.openConnection();
	        huc.setRequestMethod("POST");  
	        huc.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
	        huc.setRequestProperty("Accept", "application/json");  
	        huc.setRequestProperty("Cache-Control","no-cache"); // 컨트롤 캐쉬 설정 
	        huc.setRequestProperty("Content-Length", "length"); // 타입길이 설정(Request Body 전달시 Data Type의 길이를 정함.) 
	        huc.setRequestProperty("User-Agent", "test");       // User-Agent 값 설정 
	        huc.setDoOutput(true); // OutputStream으로 서버에서 요청을 보내겠다는 옵션.
	        huc.setDoInput(true);  // InputStream으로 서버로 부터 응답을 받겠다는 옵션.  
	        huc.connect(); 
	        
	        // 실제 서버로 Request 요청 하는 부분. (응답 코드를 받는다. 200 성공, 나머지 에러)
	        int responseCode = huc.getResponseCode(); 
	        System.out.println("HourlyJob:"+ responseCode); 
	        br = new BufferedReader(new InputStreamReader(huc.getInputStream(), "UTF-8")); 
	        sb = new StringBuffer(); 
	        String temp = "";
	        while ((temp = br.readLine()) != null) {
	            sb.append(temp);
	        }
	        sOUTVAR = sb.toString();
	        JSONParser parser = new JSONParser();
	        OUTVAR = (JSONObject) parser.parse(sOUTVAR); 
	        System.out.println(OUTVAR.toJSONString());
	        */
			

			
		} catch (Exception e) {
			System.out.println("EPBatchJob error occurred:"+ e);
		} finally {
			if(bin!=null) try{ bin.close(); } catch(Exception ex1){ System.out.println(ex1);};	
			if(isr!=null) try{ isr.close();	} catch(Exception ex2){ System.out.println(ex2);};
			if(huc!=null) huc.disconnect();	
		}	     
	} 

	
String path = "./"; 
String root = "./WEB-INF/src"; 
String FILESL = "\\"; 
//전역변수 
String ORGCD = "TRIBONS";
String ORGNM = "TRIBONS";
String DEPTCD = "EP";
String DEPTNM = "EP";
String USERID = "EPBatchJob";
String USERNM = "EPBatchJob";
String USERAUTH = "ADM,";
String MULTIORGYN = "N"; 

/*** DB I/F **
private String db = "jdbc:oracle:thin:@211.168.252.75:1521:LFEIS";
private String usr = "EIS_BI";
private String pwd = "Eqldkdl_bi1!"; 
******/
String ctxLookup = "jdbc/oraTRIBONS";
public void setCtx(String userOrgCd ) {
	if("PASTEL".equals(userOrgCd)) {
		ctxLookup = "jdbc/oraPASTEL";
	} else if("TRIBONS".equals(userOrgCd)){
		ctxLookup = "jdbc/oraTRIBONS";
	} else if("DZICUBE".equals(userOrgCd)){
		ctxLookup = "jdbc/msDZICUBE";
	} else if("EBIZ".equals(userOrgCd)){
		ctxLookup = "jdbc/myPASTELMALL"; 
	} else {
		ctxLookup = "jdbc/oraEIS";
	} 
}

public Connection getConn(String orgcd) {
	setCtx(orgcd);
	return getConn();
}

public Connection getConn() {
	Connection conn = null;
	try {
		Context ctx = new InitialContext();
		Context envCtx = (Context)ctx.lookup("java:/comp/env");
		DataSource ds = (DataSource)envCtx.lookup(ctxLookup);
		conn = ds.getConnection();
	} catch(Exception e) {
		logger.error("getConn:"+e.toString());
	}
	return conn;
}

public void closeConn(Connection conn) {
	try {
		if (conn != null) conn.close();
	} catch(Exception e) {
		logger.error("closeConn:"+e.toString());
	}
}

public String getQuery(String qryID, String contentName) {
	Connection conn = null;
	String qry = "";
	try {
		//쿼리 가져옴
		conn = getConn("COMMON");
		String qry1 = "select content from tpgmclob where pgmid = '"+qryID+"' and contenttype ='"+contentName+"'";
		JSONArray mRtn = executeQueryClob(conn, qry1, "content");
        qry = getVal(mRtn,0,"content");
        closeConn(conn);
	} catch (Exception e) {
		qry = "";
	} 
	return qry;
}

public String getQuery(Connection conn, String qryID, String contentName) {
	String qry = "";
	try {
		//쿼리 가져옴
		String qry1 = "select content from tpgmclob where pgmid = '"+qryID+"' and contenttype ='"+contentName+"'";
		JSONArray mRtn = executeQueryClob(conn, qry1, "content");
        qry = getVal(mRtn,0,"content");
	} catch (Exception e) {
		qry = "";
	} 
	return qry;
}

public String bindVAR(String qry,JSONObject INVAR) {
	String rtn = new String(qry); 
    //변수할당 
    for(Object k : INVAR.keySet()) {
    	String key = (String)k;
    	Object v = INVAR.get(k);
    	if(v==null) v=""; 
    	
    	if(v instanceof org.json.simple.JSONObject) {
    		for(Object l: ((JSONObject)v).keySet()) {
    			String keyl = (String)l;
    			if(l instanceof java.lang.String) {
    				rtn = rtn.replace("{"+keyl+"}","'"+((String)l).replace("'","''")+"'");
    				rtn = rtn.replace("["+keyl+"]",(String)l);
    			}
    			else if(l instanceof java.lang.Long || l instanceof java.lang.Integer || l instanceof java.lang.Float || l instanceof java.lang.Double) {
    				rtn = rtn.replace("{"+keyl+"}",""+l);
    				rtn = rtn.replace("["+keyl+"]",""+l);
    			}
    			else System.out.println("common.bindVAR1: " + l + " : " + l.getClass() );
    		}
    	} else if(v instanceof org.json.simple.JSONArray) {
    		JSONObject row = (JSONObject)((JSONArray)v).get(0); //Array인 경우 1레벨의 첫번째 요소의 값만 사용
    		for(Object l: row.keySet()) {
    			String keyl = (String)l;
    			if(l instanceof java.lang.String) {
    				rtn = rtn.replace("{"+keyl+"}","'"+((String)l).replace("'","''")+"'"); 
    				rtn = rtn.replace("["+keyl+"]",(String)l);
    			}
    			else if(l instanceof java.lang.Long || l instanceof java.lang.Integer || l instanceof java.lang.Float || l instanceof java.lang.Double) {
    				rtn = rtn.replace("{"+keyl+"}",""+l);
    				rtn = rtn.replace("["+keyl+"]",""+l);
    			}
    			else System.out.println("common.bindVAR2: " + l + " : " + l.getClass() );  
    		}
    	} else if (v instanceof java.lang.String) {
    		rtn = rtn.replace("{"+key+"}","'"+((String)v).replace("'","''")+"'");         		
    		rtn = rtn.replace("["+key+"]", (String)v );
    	} else if (v instanceof java.lang.Long || v instanceof java.lang.Float || v instanceof java.lang.Integer  || v instanceof java.lang.Double) {
    		rtn = rtn.replace("{"+key+"}",""+v);
    		rtn = rtn.replace("["+key+"]",""+v);         		
    	} else { 
			System.out.println("common.bindVAR3: " + v + " : " + v.getClass() );
    	}
    }
    //logger.debug("bindVar:"+rtn); 
    return rtn; 
}


public JSONArray selectSVC(Connection conn, String qry) throws Exception {
	try {  
        //결과조회
	    return executeQuery(conn,qry); 
	} catch (Exception e) {
		throw e;
		
	}
}

public JSONArray selectSVC(Connection conn, String pgmid, String qryid, JSONObject INVAR) throws Exception {
	try {
		Connection cconn = getConn("common"); 
		String qry = getQuery(cconn, pgmid, qryid); //1)쿼리를 가져와서
        closeConn(cconn);
	    qry = bindVAR(qry,INVAR);                      //2)변수바이딩하고
        //결과조회
	    return executeQuery(conn,qry); 
		
	} catch (Exception e) {
		throw e;
		
	}
}

public JSONArray selectSVC(Connection conn, String pgmid, String qryid, JSONObject INVAR, String Clobcol) throws Exception {
	try {
		Connection cconn = getConn("common"); 
		String qry = getQuery(cconn, pgmid, qryid); //1)쿼리를 가져와서
        closeConn(cconn);
	    qry = bindVAR(qry,INVAR);                      //2)변수바이딩하고
        //결과조회
	    return executeQueryClob(conn,qry,Clobcol); 
		
	} catch (Exception e) {
		throw e;
		
	}
} 

public JSONArray selectSVCWithColOrder(Connection conn, String qry) throws Exception {
	try {  
        //결과조회
	    return executeQueryWithColOrder(conn,qry); 
	} catch (Exception e) {
		throw e;
		
	}
}
 

public JSONObject executeSVC(Connection conn, String sql) {
	JSONObject OUTVAR = new JSONObject();
	JSONObject VAR    = new JSONObject();
	String rtnCode = "OK";
	String rtnMsg = "";
	CallableStatement stmt = null;
	
	try {
		
		String qry = "DECLARE " +
	             "lv_rst varchar2(3000) := 'OK'; " +
		         "lv_rtn varchar2(3000) := 'OK'; " +
	             "BEGIN " +
	             "    BEGIN " +
		                  sql +
		         "    EXCEPTION WHEN OTHERS THEN " +
                 "        lv_rst := SQLCODE; " +
		         "        lv_rtn := SQLERRM; " +
		         "    END; " +
                 " ? := lv_rst; " +  
                 " ? := lv_rtn; " +  
                 "END;";
		stmt = conn.prepareCall(qry);
		stmt.registerOutParameter(1, Types.VARCHAR);
		stmt.registerOutParameter(2, Types.VARCHAR);
		stmt.execute();
		rtnCode = stmt.getString(1);
		rtnMsg = stmt.getString(2);
		if (stmt != null) stmt.close();  
	
	} catch (java.sql.SQLException oe) {
		logger.error("inc.db.executeUpdate:"+sql+":"+oe.getErrorCode()+" "+oe.getMessage());
		rtnCode = oe.getErrorCode()+"";
		rtnMsg = sql+"\n\n\n"+oe.getMessage();
	} catch (Exception e) { 
		logger.error("inc.db.executeUpdate:"+sql+":"+e.toString());
		rtnCode = "-9999";
		rtnMsg = sql+"\n\n\n"+e.toString();
	} finally {
		OUTVAR.put("rtnCd",rtnCode);
		OUTVAR.put("rtnMsg",rtnMsg);
	}
	return OUTVAR;
}



private JSONArray executeQuery(String sql) throws Exception {  
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	int i = 0;
	int j = 0; 
	JSONArray rtn = new JSONArray();
		
	try {
		//Class.forName("oracle.jdbc.driver.OracleDriver"); 
		//conn = DriverManager.getConnection(db,usr,pwd);
		Context ctx = new InitialContext();
		Context envCtx = (Context)ctx.lookup("java:/comp/env");
		DataSource ds = (DataSource)envCtx.lookup(ctxLookup);
		conn = ds.getConnection();
		
		stmt = conn.createStatement(); 
		//logger.error("inc.db.sql: "+sql); 
		rs = stmt.executeQuery(sql);

		ResultSetMetaData rsmd = rs.getMetaData();
		int colcnt = rsmd.getColumnCount();
		
		while(rs.next()) {  
			//logger.error("colcnt: "+colcnt);
			JSONObject cols = new JSONObject();
			for (i = 0; i < colcnt; i++) { 
				//System.out.print("colnm("+(i+1)+")="+rsmd.getColumnName(i+1));
				cols.put( rsmd.getColumnName(i+1).toLowerCase(), nvl(rs.getString(i+1),"") ); //.replaceAll("´", "'")
			}  
			rtn.add(cols);
		}
		if (rs   != null) rs.close(); 
		if (stmt != null) stmt.close(); 
		if (conn != null) conn.close(); 
		
	} catch (Exception e) { 
		logger.error("inc.db.executeQuery:"+sql+" : "+e.toString());
	    throw e;   
	}
	logger.debug("executeQuery*******************************\n"+sql);
	//logger.debug(rtn.toJSONString());
	return rtn;
} 

private JSONArray executeQuery(Connection conn, String sql) throws Exception {  
	Statement stmt = null;
	ResultSet rs = null;
	int i = 0;
	int j = 0; 
	JSONArray rtn = new JSONArray();
		
	try {
		stmt = conn.createStatement(); 
		//logger.error("inc.db.sql: "+sql); 
		rs = stmt.executeQuery(sql); 
		while(rs.next()) {  
			ResultSetMetaData rsmd = rs.getMetaData();
			int colcnt = rsmd.getColumnCount();
			//logger.error("colcnt: "+colcnt);
			JSONObject cols = new JSONObject();
			for (i = 0; i < colcnt; i++) { 
				//System.out.print("colnm("+(i+1)+")="+rsmd.getColumnName(i+1));
				cols.put( rsmd.getColumnName(i+1).toLowerCase(), nvl(rs.getString(i+1),"") ); //.replaceAll("´", "'")
			}  
			rtn.add(cols);
		}
		if (rs   != null) rs.close(); 
		if (stmt != null) stmt.close(); 
		
	} catch (Exception e) { 
		logger.error("inc.db.executeQuery:"+sql+" : "+e.toString());
	    throw e;   
	}
	logger.debug("executeQuery*******************************\n"+sql);
	//logger.debug(rtn.toJSONString());
	return rtn;
} 

private JSONArray executeQueryWithColOrder(String sql) throws Exception {  
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	int i = 0;
	int j = 0; 
	JSONArray rtn = new JSONArray();
		
	try {
		//Class.forName("oracle.jdbc.driver.OracleDriver"); 
		//conn = DriverManager.getConnection(db,usr,pwd);
		Context ctx = new InitialContext();
		Context envCtx = (Context)ctx.lookup("java:/comp/env");
		DataSource ds = (DataSource)envCtx.lookup(ctxLookup);
		conn = ds.getConnection();
		
		stmt = conn.createStatement(); 
		//logger.error("inc.db.sql: "+sql); 
		rs = stmt.executeQuery(sql);
		while(rs.next()) { 
			ResultSetMetaData rsmd = rs.getMetaData();
			int colcnt = rsmd.getColumnCount();
			//logger.error("colcnt: "+colcnt);
			LinkedHashMap<String,String> cols = new LinkedHashMap<String,String>();  
			for (i = 0; i < colcnt; i++) { 
				cols.put(rsmd.getColumnName(i+1).toLowerCase(), nvl(rs.getString(i+1),"") ); //.replaceAll("´", "'")
			}  
			rtn.add(cols);
		}
		if (rs   != null) rs.close(); 
		if (stmt != null) stmt.close(); 
		if (conn != null) conn.close(); 
		
	} catch (Exception e) { 
		logger.error("inc.db.executeQuery:"+sql+" : "+e.toString());
	    throw e;   
	}
	return rtn;
} 

private JSONArray executeQueryWithColOrder(Connection conn, String sql) throws Exception {  
	Statement stmt = null;
	ResultSet rs = null;
	int i = 0;
	int j = 0; 
	JSONArray rtn = new JSONArray();
		
	try {
		stmt = conn.createStatement(); 
		rs = stmt.executeQuery(sql);
		while(rs.next()) { 
			ResultSetMetaData rsmd = rs.getMetaData();
			int colcnt = rsmd.getColumnCount();
			LinkedHashMap<String,String> cols = new LinkedHashMap<String,String>();  
			for (i = 0; i < colcnt; i++) { 
				cols.put(rsmd.getColumnName(i+1).toLowerCase(), nvl(rs.getString(i+1),"") ); //.replaceAll("´", "'")
			}  
			rtn.add(cols);
		}
		if (rs   != null) rs.close(); 
		if (stmt != null) stmt.close(); 
		
	} catch (Exception e) { 
		logger.error("inc.db.executeQuery:"+sql+" : "+e.toString());
	    throw e;   
	}
	return rtn;
} 

private String executeUpdate(String sql) throws Exception {  
	Connection conn = null;
	Statement stmt = null;
	int rs; 
	String rtn = "OK";
	try {
		if(sql.toUpperCase().indexOf("BEGIN") >= 0 || sql.toUpperCase().indexOf("DECLARE") >= 0) {
			JSONObject result = new JSONObject();
			result = execute(sql);
			return (String)result.get("rst");
		}
		//Class.forName("oracle.jdbc.driver.OracleDriver"); 
		//conn = DriverManager.getConnection(db,usr,pwd);
		Context ctx = new InitialContext();
		Context envCtx = (Context)ctx.lookup("java:/comp/env");
		DataSource ds = (DataSource)envCtx.lookup(ctxLookup);
		conn = ds.getConnection();
		
		stmt = conn.createStatement(); 
		//logger.error("inc.db.sql: "+sql); 
		rs = stmt.executeUpdate(sql); 
		if (stmt != null) stmt.close(); 
		if (conn != null) conn.close(); 
		//logger.error("inc.db.executeUpdate:"+sql+" : "+rs+":success!");
	} catch (java.sql.SQLException oe) {
		logger.error("inc.db.executeUpdate:"+sql+":"+oe.getErrorCode()+" "+oe.getMessage());
		return oe.getMessage();
	} catch (Exception e) { 
		logger.error("inc.db.executeUpdate:"+sql+":"+e.toString());
	    throw e;   
	}
	return rtn;
}  

private JSONObject execute(String sql) throws Exception {  
	Connection conn = null;
	CallableStatement stmt = null;
	int rs;
	JSONObject result = new JSONObject();
	String rst = "OK";
	String rtn = "OK";
	try {

		int count = 0;

	    for(int i=0; i < sql.length(); i++)
	    {    if(sql.charAt(i) == '?')
	            count++;
	    }

	    if(count > 0) sql = sql.replace("?"," ");
	
		//Class.forName("oracle.jdbc.driver.OracleDriver"); 
		//conn = DriverManager.getConnection(db,usr,pwd);
		Context ctx = new InitialContext();
		Context envCtx = (Context)ctx.lookup("java:/comp/env");
		DataSource ds = (DataSource)envCtx.lookup(ctxLookup);
		conn = ds.getConnection();
		
		//sql = " declare " +  
		//      "    p_id varchar2(20); " +
		//"    l_rc sys_refcursor;" + 커서를 돌릴경우의 예제이다.		
		//      " begin select 'a' into p_id from dual; " +
		//"    open l_rc for " +
		//"    ? := l_rc;" +      
		//      "    ? := SQLCODE || ':' || SQLERRM;    " +
		//      " end;";
		
		String qry = "DECLARE " +
		             "lv_rst varchar2(3000) := 'OK'; " +
			         "lv_rtn varchar2(3000) := 'OK'; " +
		             "BEGIN " +
		             "    BEGIN " +
			                  sql +
			         "    EXCEPTION WHEN OTHERS THEN " +
                     "        lv_rst := SQLCODE; " +
			         "        lv_rtn := SQLERRM; " +
			         "    END; " +
                     " ? := lv_rst; " +  
                     " ? := lv_rtn; " +  
                     "END;";
		stmt = conn.prepareCall(qry);
		stmt.registerOutParameter(1, Types.VARCHAR);
		stmt.registerOutParameter(2, Types.VARCHAR);
		//cs.registerOutParameter(3, OracleTypes.CURSOR);
		stmt.execute();
		//ResultSet cursorResultSet = (ResultSet) cs.getObject(3);
        //while (cursorResultSet.next ())
        //{
        //    System.out.println (cursorResultSet.getInt(1) + " " + cursorResultSet.getString(2));
        //} 
        rst = stmt.getString(1);
        rtn = stmt.getString(2);
		if (stmt != null) stmt.close(); 
		if (conn != null) conn.close(); 
		
	} catch (java.sql.SQLException oe) {
		logger.error("inc.db.executeUpdate:"+sql+":"+oe.getErrorCode()+" "+oe.getMessage());
		//return oe.getMessage();
		rst = oe.getErrorCode()+"";
		rtn = sql+"\n\n\n"+oe.getMessage();
	} catch (Exception e) { 
		logger.error("inc.db.executeUpdate:"+sql+":"+e.toString());
	    //throw e;   
		rst = "-9999";
		rtn = sql+"\n\n\n"+e.toString();
	}
	result.put("rst",rst);
	result.put("msg",rtn);
	return result;
}  

private JSONArray executeQueryClob(String sql, String clobCol) throws Exception {  
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	int i = 0;
	int j = 0; 
	JSONArray rtn = new JSONArray();
		
	try {
		//Class.forName("oracle.jdbc.driver.OracleDriver"); 
		//conn = DriverManager.getConnection(db,usr,pwd);
		Context ctx = new InitialContext();
		Context envCtx = (Context)ctx.lookup("java:/comp/env");
		DataSource ds = (DataSource)envCtx.lookup(ctxLookup);
		conn = ds.getConnection();
		
		stmt = conn.createStatement();  
		rs = stmt.executeQuery(sql);
		while(rs.next()) {  
			ResultSetMetaData rsmd = rs.getMetaData();
			int colcnt = rsmd.getColumnCount(); 
			JSONObject cols = new JSONObject();
			for (i = 0; i < colcnt; i++) {  
				if(rsmd.getColumnName(i+1).toLowerCase().equals(clobCol)) {
					
					StringBuffer strOut = new StringBuffer();
					Reader input = rs.getCharacterStream(clobCol);
					if(input != null) {
				        char[] buffer = new char[1024]; 
				      	int byteRead = 0; 
				        while((byteRead=input.read(buffer,0,1024))!=-1){ 
				        	strOut.append(buffer,0,byteRead); 
				        } 
				        //logger.error(clobCol+"-clob:"+strOut.toString() );
						/*
						String aux;	
						try {
							BufferedReader br = new BufferedReader(rs.getClob(clobCol).getCharacterStream());
						    while ((aux=br.readLine())!=null) {
						    	strOut.append(aux);
								strOut.append(System.getProperty("line.separator"));
						    }
						} catch (Exception e) {
							System.out.println(e.toString()); //e.printStackTrace();
						}
						*/
				        cols.put(rsmd.getColumnName(i+1).toLowerCase(), strOut.toString()); //.replaceAll("´", "'")
					} else {
						cols.put(rsmd.getColumnName(i+1).toLowerCase(), "");
					}
				} else {
					cols.put(rsmd.getColumnName(i+1).toLowerCase(), nvl(rs.getString(i+1),"")); //.replaceAll("´", "'")
				}
			}  
			rtn.add(cols);  
		}
		if (rs   != null) rs.close(); 
		if (stmt != null) stmt.close(); 
		if (conn != null) conn.close(); 
		
	} catch (Exception e) { 
		logger.error("inc.db.executeQueryClob:"+sql+" : "+e.toString());
	    throw e;   
	}
	return rtn;
} 

private JSONArray executeQueryClob(Connection conn, String sql, String clobCol) throws Exception {  
	Statement stmt = null;
	ResultSet rs = null;
	int i = 0;
	int j = 0; 
	JSONArray rtn = new JSONArray();
		
	try {
		stmt = conn.createStatement();  
		rs = stmt.executeQuery(sql);
		while(rs.next()) {  
			ResultSetMetaData rsmd = rs.getMetaData();
			int colcnt = rsmd.getColumnCount(); 
			JSONObject cols = new JSONObject();
			for (i = 0; i < colcnt; i++) {  
				if(rsmd.getColumnName(i+1).toLowerCase().equals(clobCol)) {
					
					StringBuffer strOut = new StringBuffer();
					Reader input = rs.getCharacterStream(clobCol);
					if(input != null) {
				        char[] buffer = new char[1024]; 
				      	int byteRead = 0; 
				        while((byteRead=input.read(buffer,0,1024))!=-1){ 
				        	strOut.append(buffer,0,byteRead); 
				        } 
				        cols.put(rsmd.getColumnName(i+1).toLowerCase(), strOut.toString()); //.replaceAll("´", "'")
					} else {
						cols.put(rsmd.getColumnName(i+1).toLowerCase(), "");
					}
				} else {
					cols.put(rsmd.getColumnName(i+1).toLowerCase(), nvl(rs.getString(i+1),"")); //.replaceAll("´", "'")
				}
			}  
			rtn.add(cols);  
		}
		if (rs   != null) rs.close(); 
		if (stmt != null) stmt.close(); 
		
	} catch (Exception e) { 
		logger.error("inc.db.executeQueryClob:"+sql+" : "+e.toString());
	    throw e;   
	}
	return rtn;
}  

private JSONArray executeQueryBlob(Connection conn, String sql, String blobCol) throws Exception {  
	Statement stmt = null;
	ResultSet rs = null;
	int i = 0;
	int j = 0; 
	JSONArray rtn = new JSONArray();
		
	try {
		stmt = conn.createStatement();  
		rs = stmt.executeQuery(sql);
		while(rs.next()) {  
			ResultSetMetaData rsmd = rs.getMetaData();
			int colcnt = rsmd.getColumnCount(); 
			JSONObject cols = new JSONObject();
			for (i = 0; i < colcnt; i++) {  
				if(rsmd.getColumnName(i+1).toLowerCase().equals(blobCol)) {
					
					Reader input = rs.getCharacterStream(blobCol);
					
					if(input != null) {
						byte[] bytes = org.apache.commons.io.IOUtils.toByteArray( rs.getBlob(blobCol).getBinaryStream() );
						
						String b64 = javax.xml.bind.DatatypeConverter.printBase64Binary( bytes );
						
						//System.out.println( b64 );
						cols.put(rsmd.getColumnName(i+1).toLowerCase(), b64); 
					} else {
						cols.put(rsmd.getColumnName(i+1).toLowerCase(), "");
					}
					
				} else {
					cols.put(rsmd.getColumnName(i+1).toLowerCase(), nvl(rs.getString(i+1),"")); //.replaceAll("´", "'")
				}
			}  
			rtn.add(cols);  
		}
		if (rs   != null) rs.close(); 
		if (stmt != null) stmt.close(); 
		
	} catch (Exception e) { 
		logger.error("inc.db.executeQueryBlob:"+sql+" : "+e.toString());
	    throw e;   
	}
	return rtn;
} 

private String executeUpdateClob(Connection conn, String Tbl, String clobCol, String clobData, String where) throws Exception {  
	Statement stmt = null;
	int irs;
	ResultSet rs = null;
	String rtn = "OK";
	String sql = "";
	try {   
		stmt = conn.createStatement();  
		sql = "UPDATE "+Tbl+" SET "+clobCol+"=EMPTY_CLOB() "+where;
		

		logger.error("update :" + sql);
		
		irs = stmt.executeUpdate(sql);  
		
		logger.error(irs + ":" + sql);
		
		sql = "SELECT "+clobCol+" FROM "+Tbl+" "+where;   
	    stmt = conn.createStatement(); 
	    rs = stmt.executeQuery(sql);
	    
	    logger.error(rs + ":" + sql);
		
	    if(rs.next()) {
	    	CLOB clob = null;
	   		Writer writer = null;
	    	Reader src = null;
	    	char[] buffer = null;
	    	int read = 0;  
	        //clob = ((OracleResultSet)rs).getCLOB(1);  //ORACLE HACK
	        //clob = (CLOB)rs.getClob(1); 
	        clob = (CLOB)rs.getClob(1);  
	        writer = clob.getCharacterOutputStream();
            src = new CharArrayReader(clobData.toCharArray()); 
			buffer = new char[1024]; 
	        read = 0;
	        while ( (read = src.read(buffer,0,1024)) != -1) { 
	        	writer.write(buffer, 0, read); // write clob. 
	        }
	        src.close();         
	        writer.close();
	    } 
		
		if (stmt != null) stmt.close();  
	} catch (java.sql.SQLException oe) {
		logger.error("inc.db.executeUpdateClob2:SQLEX:"+":"+oe.getErrorCode()+" "+oe.getMessage());
		return oe.getMessage();
	} catch (Exception e) { 
		logger.error("inc.db.executeUpdateClob2:"+e.toString());
		return e.getMessage();   
	}
	return rtn;
} 

private String executeUpdateClob(String sql, String Tbl, String clobCol, String clobData, String where) throws Exception {  
	Connection conn = null;
	Statement stmt = null;
	int irs;
	ResultSet rs = null;
	String rtn = "OK";
	try { 
		//Class.forName("oracle.jdbc.driver.OracleDriver"); 
		//conn = DriverManager.getConnection(db,usr,pwd);
		Context ctx = new InitialContext();
		Context envCtx = (Context)ctx.lookup("java:/comp/env");
		DataSource ds = (DataSource)envCtx.lookup(ctxLookup);
		conn = ds.getConnection();
		
		stmt = conn.createStatement();
		irs = stmt.executeUpdate(sql); //Clob제외한 쿼리일단 수행
		//conn.commit();
	    conn.setAutoCommit(false);
	    
		sql = "UPDATE "+Tbl+" SET "+clobCol+"=EMPTY_CLOB() "+where;
		irs = stmt.executeUpdate(sql);  
		
		sql = "SELECT "+clobCol+" FROM "+Tbl+" "+where;   
	    stmt = conn.createStatement(); 
	    rs = stmt.executeQuery(sql);
	    if(rs.next()) {
	    	CLOB clob = null;
	   		Writer writer = null;
	    	Reader src = null;
	    	char[] buffer = null;
	    	int read = 0;  
	        //clob = ((OracleResultSet)rs).getCLOB(1);  //ORACLE HACK
	        //clob = (CLOB)rs.getClob(1); 
	        clob = (CLOB)rs.getClob(1);  
	        writer = clob.getCharacterOutputStream();
            src = new CharArrayReader(clobData.toCharArray()); 
			buffer = new char[1024]; 
	        read = 0;
	        while ( (read = src.read(buffer,0,1024)) != -1) { 
	        	writer.write(buffer, 0, read); // write clob. 
	        }
	        src.close();         
	        writer.close();
	    }
	    conn.commit();
	    conn.setAutoCommit(true); 
		
		if (stmt != null) stmt.close(); 
		if (conn != null) conn.close();  
	} catch (java.sql.SQLException oe) {
		logger.error("inc.db.executeUpdateClob:SQLEX:"+sql+":"+oe.getErrorCode()+" "+oe.getMessage());
		return oe.getMessage();
	} catch (Exception e) { 
		logger.error("inc.db.executeUpdateClob:"+sql+":"+e.toString());
	    throw e;   
	}
	return rtn;
} 


private ArrayList<LinkedHashMap<String,String>> executeQueryOLD(String sql) throws Exception {  
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	int i = 0;
	int j = 0; 
	ArrayList<LinkedHashMap<String,String>> al = new ArrayList<LinkedHashMap<String,String>>();
	//LinkedHashMap<String,String> hm = new LinkedHashMap<String,String>();

	try {
		//Class.forName("oracle.jdbc.driver.OracleDriver"); 
		//conn = DriverManager.getConnection(db,usr,pwd);
		Context ctx = new InitialContext();
		Context envCtx = (Context)ctx.lookup("java:/comp/env");
		DataSource ds = (DataSource)envCtx.lookup(ctxLookup);
		conn = ds.getConnection();
		
		stmt = conn.createStatement(); 
		//logger.error("inc.db.sql: "+sql); 
		rs = stmt.executeQuery(sql);
		while(rs.next()) { 
			ResultSetMetaData rsmd = rs.getMetaData();
			int colcnt = rsmd.getColumnCount();
			//logger.error("colcnt: "+colcnt);
			LinkedHashMap<String,String> hm = new LinkedHashMap<String,String>();
			for (i = 0; i < colcnt; i++) { 
				//logger.error("i="+i+": "+rsmd.getColumnName(i+1)+", "+nvl(rs.getString(i+1),""));
				hm.put(rsmd.getColumnName(i+1),nvl(rs.getString(i+1),"")); //.replaceAll("´", "'")
			}  
			al.add(hm);
		}  
		if (rs   != null) rs.close(); 
		if (stmt != null) stmt.close(); 
		if (conn != null) conn.close(); 
		
	} catch (Exception e) { 
		logger.error("inc.db.executeQuery:"+sql+" : "+e.toString());
	    throw e;   
	}
	return al;
}   
//** ACCESS Data Object *********************************************************************
public JSONObject getObject(String sData) throws Exception {  
	JSONObject oRtn = new JSONObject();
	JSONParser parser = new JSONParser();
	try {
		//String sAdjData = sData.replace("'","´").replace("\"","”"); 
		//oRtn = (JSONObject) parser.parse(sAdjData);
		if(!isNull(sData)) {
			oRtn = (JSONObject) parser.parse(sData);
		}
		return oRtn;
	} catch (Exception e) { 
		logger.error("inc.common.getObject:"+ e.toString());
	    throw e;   
	} 
}
public JSONArray getArray(String sData, String sArrId ) throws Exception {  
	JSONArray gridArr = new JSONArray();
	JSONParser parser = new JSONParser();
	try {
		//String sAdjData = sData.replace("'","´").replace("\"","”"); 
		//Object gridObj = parser.parse(sAdjData);
		Object gridObj = parser.parse(sData);
		String ClassName = gridObj.getClass().getName();
		//JSONArray 그 자체이면 sArrId에 관계없이 리턴해줌 
		if ("org.json.simple.JSONArray".equals(ClassName)) {
			gridArr = (JSONArray) gridObj;  
		//JSONArray를 담고있는 JSNOObject이면	
		} else if("org.json.simple.JSONObject".equals(ClassName)){
			gridArr = (JSONArray)((JSONObject)gridObj).get(sArrId);
		} 
		return gridArr;
	} catch (Exception e) { 
		logger.error("inc.common.getArray:"+ e.toString()+" : "+sData);
	    throw e;   
	} 
}
public JSONArray getArray(JSONObject gridObj, String sArrId ) throws Exception {  
	JSONArray gridArr = new JSONArray(); 
	try {
		gridArr = (JSONArray)gridObj.get(sArrId); 
		return gridArr;
	} catch (Exception e) { 
		logger.error("inc.common.getArray:"+ e.toString());
	    throw e;   
	} 
}
//getRow
public JSONObject getRow(JSONArray arr, int rownum) throws Exception {  
	try { 
		return (JSONObject)arr.get(rownum); 
	} catch (Exception e) { 
		logger.error("inc.common.getRow:"+arr.toString()+" : "+rownum);
	    throw e;   
	}  
}
public JSONObject getRow(JSONArray arr, String colid, String val) throws Exception {  
	try { 
		for(int i = 0; i < arr.size(); i++) {
			JSONObject row = getRow(arr,i);
			if(val.equals(getVal(row,colid))) {
				return row;
			}
		}
		return new JSONObject();
	} catch (Exception e) { 
		logger.error("inc.common.getRow:"+arr.toString()+" : "+colid+" : "+val);
	    throw e;   
	} 
}
//getCol
public String getCol(JSONObject obj, String colnm) throws Exception {  
	try {
		String rtn = "";
		if(obj.get(colnm)==null) rtn = ""; 
		else rtn = (String)(obj.get(colnm)+""); //.replace("'","´").replace("\"","”");
		if("null".equals(rtn)) rtn = "";
		//logger.error("debug-getCol:"+obj+":"+colnm+"->["+rtn+"]");
		return rtn;
	} catch (Exception e) { 
		logger.error("inc.common.getCol:"+obj.toString()+" : "+colnm);
	    throw e;   
	} 
} 
//getVal
public String getVal(JSONArray arr, int rownum, String colnm) throws Exception {  
	try { 
		String rtn = "";
		JSONObject row = getRow(arr, rownum);
		rtn = getCol(row,colnm);
		return rtn; 
	} catch (Exception e) { 
		logger.error("inc.common.getVal:"+arr.toString()+" : "+rownum);
	    throw e;   
	} 
} 
public String getVal(JSONObject obj, String datanm, String colnm) throws Exception {  
	try { 
		String rtn = "";
		JSONObject data = (JSONObject)obj.get(datanm);
		rtn = getCol(data,colnm);
		return rtn; 
	} catch (Exception e) { 
		logger.error("inc.common.getVal:"+obj.toString()+" : "+datanm);
	    throw e;   
	} 
}  
public String getVal(JSONObject obj, String arrnm, int rownum, String colnm) throws Exception {  
	try { 
		String rtn = "";
		JSONArray arr = (JSONArray)obj.get(arrnm);
		JSONObject row = getRow(arr, rownum);
		rtn = getCol(row,colnm);
		return rtn; 
	} catch (Exception e) { 
		logger.error("inc.common.getVal:"+arrnm+" : "+rownum);
	    throw e;   
	} 
} 
public String getVal(JSONObject obj, String key) throws Exception {  
	try { 
		return getCol(obj,key); 
	} catch (Exception e) { 
		logger.error("inc.common.getVal:"+obj+" : "+key);
	    throw e;   
	} 
} 

//getRowWithColOrder
public LinkedHashMap getRowWithColOrder(JSONArray arr, int rownum) throws Exception {  
	try { 
		return (LinkedHashMap)arr.get(rownum); 
	} catch (Exception e) { 
		logger.error("inc.common.getRowWithColOrder:"+arr.toString()+" : "+rownum);
	    throw e;   
	} 
} 


private String readJSONStringFromRequestBody(HttpServletRequest request){
    StringBuffer json = new StringBuffer();
    String line = null;
    try {
        BufferedReader reader = request.getReader();
        while((line = reader.readLine()) != null) {
            json.append(line);
        }
    }
    catch(Exception e) {
        System.out.println("Error reading JSON string: " + e.toString());
    }
    return json.toString();
} 
/*** DATA to HTML TABLE String : USAGE below
        String cols = "ds_season,ds_item_kind1,ds_item_kind2,ds_item_kind3,adj_amt_sc,right_amt";
	    String ths = "시즌,아이템,스타일,복종,조정액,조정후 가용예산";
	    String aligns = "center,center,center,center,right,right";
	    JSONArray data = getArray(INVAR,"data"); 
	    String html = makeHtmlTable(cols,ths,aligns,data); 
***/
public String makeHtmlTable(String cols, String ths, String aligns, JSONArray data) {
    String rtn = "<table class='APreport'>";
    
    String[] col = cols.split(",");
    String[] th  = ths.split(",");
    String[] align = aligns.split(",");
    
    rtn += "<thead><tr>";
    for(int i=0; i < th.length; i++) {
        rtn+="<th>"+th[i]+"</th>";
    }
    rtn += "</tr></thead>";
    rtn += "<tbody>";
    for(int j=0; j < data.size(); j++) {
        rtn += "<tr>"; 
        JSONObject row = (JSONObject) data.get(j); //getRow(data,j); 
        for(int i=0; i < col.length; i++) { 
            rtn += "<td style='text-align:" + align[i] + "'>" +  makeStyle(row.get(col[i]))   + "</td>"; //getVal(row, col[i])  row.get(col[i]) 
        } 
        rtn += "</tr>";
    }
    rtn += "</tbody>"; 
    rtn += "</table>";
    return rtn;
} 

public String makeStyle(Object v) {
	String rtn = ""; 

	if (v instanceof java.lang.String) {
		String r = "";
		try {
			r = (String)v;
			r = (String)v;
			Long l = Long.parseLong(r); 
			r = String.format("%,d",l);  
		} catch(Exception e) {
			try {
				Double d = Double.parseDouble(r); 
				r = String.format("%,.1f", d);	 
			} catch(Exception e2) {
				r = (String)v;
			}	
		}
		if("".equals(r)) rtn = (String)v;
		else rtn = r;
	} else if (v instanceof java.lang.Long || v instanceof java.lang.Integer) {
		rtn = String.format("%,",v); //NumberFormat.getInstance().format(v);          		
	} else if (v instanceof java.lang.Float || v instanceof java.lang.Double) {
		rtn = String.format("%,.1", v);          		
	} else {
		rtn = ""+v;
	}
	
	return rtn;
}

/*** common INFO ***/
public JSONObject selectComcd() {
	return selectComcd("all","%", "Y");
}
public JSONObject selectComcd(String grpcd) {
	return selectComcd(grpcd,"%","Y");
}
public JSONObject selectComcd(String grpcd, String term) {
	return selectComcd(grpcd,term,"Y");
}

public JSONObject selectComcd(String grpcd, String term, String opt) {
	return selectComcd(grpcd, term, opt, "");
}

public JSONObject selectComcd(String grpcd, String term, String opt, String addval) {
	Connection conn = null;
	JSONObject OUTVAR = new JSONObject(); 
	String rtnCode    = "OK";
	String rtnMsg     = "";
	String data = "";	
	String qryComcd = "";
	try {  
		conn = getConn("COMMON"); 
		
		//컬럼 cd, nm은 꼭 넣어줄 것
		if("pgmid".equals(grpcd)) {
			qryComcd = "SELECT A.pgmid CD, A.pgmnm NM, A.* FROM TPGM A WHERE 1=1 "; 
			if(!"%".equals(term)) {
				qryComcd += " AND (pgmid LIKE '"+term+"%' OR pgmnm LIKE '%"+term+"%')";
			}
			qryComcd += " AND STATCD ='"+opt+"'";
			qryComcd += " ORDER BY pgmnm";
		} else if("deptcd".equals(grpcd)) {
			qryComcd = "SELECT A.deptcd CD, A.deptnm NM, A.* FROM TDEPT A WHERE 1=1 "; 
			if(!"%".equals(term)) {
				qryComcd += " AND (DEPTCD LIKE '"+term+"%' OR DEPTNM LIKE '%"+term+"%')";
			}
			qryComcd += " AND ORGCD = NVL('"+addval+"',ORGCD) ";
			qryComcd += " AND STATCD ='"+opt+"' ";
			qryComcd += " ORDER BY ORGCD, DEPTCD";
		} else if("userid".equals(grpcd)) {
			qryComcd = "SELECT A.userid CD, A.usernm NM, A.orgcd, A.empno, A.deptcd, A.jobposcd, A.jobgradecd, email, telno, locdesc, rolecds FROM TUSER A WHERE 1=1 "; 
			if(!"%".equals(term)) {
				qryComcd += " AND (userid LIKE '"+term+"%' OR usernm LIKE '%"+term+"%')";
			}
			qryComcd += " AND STATCD ='"+opt+"' ";
			qryComcd += " ORDER BY userid";
		} else if("bpmcd".equals(grpcd)) {
			qryComcd = "SELECT cd, nm, val1, val2, val3 FROM TCODEBR WHERE GRPCD = 'BPM' AND BRCD = '00' WHERE 1=1 "; 
			if(!"%".equals(term)) {
				qryComcd += " AND (cd LIKE '"+term+"%' OR nm LIKE '%"+term+"%')";
			}
			qryComcd += " AND STATCD ='"+opt+"' ";
			qryComcd += " ORDER BY sortseq, cd";
		} else {
			qryComcd = "SELECT * FROM TCODE WHERE 1=1 ";
			if(!"all".equals(grpcd)) {
				qryComcd += " AND GRPCD = '"+grpcd+"'";   
			} 
			if(!"%".equals(term)) {
				qryComcd += " AND (CD LIKE '"+term+"%' OR NM LIKE '%"+term+"%')";
			}
			qryComcd += " AND STATCD ='"+opt+"'";
			qryComcd += " ORDER BY GRPCD, SORTSEQ, NM, CD";
		}    
		
		OUTVAR.put("comcd",selectSVC(conn, qryComcd)); 
	} catch (Exception e) {
		logger.error("common.selectComcd error occurred:"+e.toString()+":"+qryComcd);
		rtnCode    = "ERR";
		rtnMsg     = e.toString();
	} finally {
		closeConn(conn);
		OUTVAR.put("rtnCd",rtnCode);
		OUTVAR.put("rtnMsg",rtnMsg);
		//out.println(OUTVAR.toJSONString());
		//return data;
		return OUTVAR;
	}  		
}	

public JSONObject selectMenu(String userid) {
	Connection conn = null;
	JSONObject OUTVAR = new JSONObject(); 
	String rtnCode    = "OK";
	String rtnMsg     = "";
	String data = "";
	try {  
		conn = getConn("COMMON"); 	

	    String qry = ""; 
		qry += "SELECT C.*  \n";  
		qry += "     , (SELECT 'Y' FROM TUSERINFO X WHERE X.USERID = A.USERID AND X.INFOTYPE = 'FAVMENU' AND X.CD = C.PGMID) FAVYN \n";
		qry += "  FROM TUSER A \n"; 
		qry += "     , TPGM C \n"; 
		qry += " WHERE A.USERID = {userid} \n"; 
		qry += "   AND C.STATCD   = 'Y' \n";
		qry += "   AND C.PGMTYPE   = 'mdipage' \n";
		qry += "   AND (C.AUTHCD = 'ANY' OR A.ROLECDS LIKE '%ADM,%'  \n";
		qry += "    OR A.ROLECDS LIKE '%'||C.AUTHCD||',%') \n";
		qry += " ORDER BY C.menu1, C.SORTSEQ   \n"; 
		JSONObject INVAR = new JSONObject();
	    INVAR.put("userid",userid); 
	    qry = bindVAR(qry,INVAR); 
		logger.error(qry); 
        OUTVAR.put("menu",selectSVC(conn, qry)); 
	} catch (Exception e) {
		logger.error("frame.comcd error occurred:"+e.toString());
		rtnCode    = "ERR";
		rtnMsg     = e.toString();
	} finally {
		closeConn(conn);
		OUTVAR.put("rtnCd",rtnCode);
		OUTVAR.put("rtnMsg",rtnMsg);
		//out.println(OUTVAR.toJSONString());
		//return data; 
		return OUTVAR;
	}  	
}	

public String retrievePgmSpec(String pgmid) {
	JSONObject rtn = new JSONObject();
	JSONArray mRtn = new JSONArray(); 
	String qry = ""; 
	try {  
		qry += "SELECT * \n"; 
		qry += "  FROM TPGMSPEC A \n";
		qry += " WHERE A.PGMID = {pgmid} \n";
		qry += " ORDER BY INFOTYPE, GRIDID, SORTSEQ, COLID \n";  
		qry = qry.replace("{pgmid}","'"+pgmid+"'");
		setCtx("COMMON");
		//System.out.println(qry);		
		mRtn = executeQuery(qry);
		String infotype = "";
		JSONArray mInfo = new JSONArray();
		for(int i=0; i < mRtn.size(); i++) { //rtn안에 infotype별로 JSONArray를 쪼개서 넣어줌
			JSONObject row = getRow(mRtn,i);
            if(i==0) {
            	infotype = getCol(row,"infotype");
            	mInfo = new JSONArray();
            }
            if( !infotype.equals( getCol(row,"infotype") ) ) {
            	rtn.put(infotype,mInfo);
            	mInfo = new JSONArray();
            	infotype = getCol(row,"infotype");
            }
            mInfo.add(row); 
		}
		rtn.put(infotype,mInfo);
	} catch(Exception e) {  
		logger.error( "exception:"+e.toString()+":"+mRtn );
	} 
	return rtn.toJSONString();
}
 
/*** LOG ***/
int sessionCnt = 0;
public boolean aweCheck(HttpSession session) { //, HttpServletResponse response
	boolean rtn = false;
	try {
		/* 세션을 체크하여 Return */
		String USERID = (String)session.getAttribute("USERID"); 
		if(USERID==null || "".equals(USERID)) rtn=false; //response.sendRedirect("/index.jsp");
		rtn = true; 
	} catch (Exception e) {
		logger.error("지원하지 않는 잘못된 접근입니다.",e);
		rtn = false;
	}   
	return rtn;
}

//http req log를 리턴해줌
public String httpReqLog(HttpServletRequest req) {
	String rtn = ""; 
	Enumeration<String> params = req.getParameterNames(); 
	while(params.hasMoreElements()) {
		String paramName = (String)params.nextElement();
		rtn += paramName+":["+ req.getParameter(paramName)+"]\n";
	}
	return rtn;
} 
public String httpReqAttr(HttpServletRequest req) {
	String rtn = ""; 
	Enumeration<String> params = req.getAttributeNames(); 
	while(params.hasMoreElements()) {
		String paramName = (String)params.nextElement();
		rtn += paramName+":["+ req.getAttribute(paramName)+"]\n";
	}
	return rtn;
} 
public String httpReqHeader(HttpServletRequest req) {
	String rtn = ""; 
	Enumeration<String> params = req.getHeaderNames(); 
	while(params.hasMoreElements()) {
		String paramName = (String)params.nextElement();
		rtn += paramName+":["+ req.getHeader(paramName)+"]\n";
	}
	return rtn;
}  

public String insertMsg(String userid, String msgtype, String title, String memo, String pmsgno, String refkeyval, String rcvs) {
	String qry = "";
	String msgno = getUUID(20);  //여기서 UUID채번 
	JSONArray  mRtn  = new JSONArray();     
	String rst = "OK"; 
	try {  
		setCtx("COMMON");
    	qry  = "BEGIN	INSERT INTO TMSG	\n";
    	qry += "	      ( MSGNO	\n";
    	qry += "	      , MSGTYPE	\n";
    	qry += "	      , TITLE	\n"; 
    	qry += "	      , PMSGNO	\n"; 
    	qry += "	      , REFKEYVAL \n";
    	qry += "	      , STATCD	\n";
    	qry += "	      , REGUSERID	\n";
    	qry += "	      , REGDT     	\n";
    	qry += "	      , UPDUSERID  	\n";
    	qry += "	      , UPDDT  )	\n";
    	qry += "	VALUES (	\n";
    	qry += "	       {msgno}	\n";
    	qry += "	     , {msgtype}	\n";
    	qry += "	     , {title}	\n"; 
    	qry += "	     , {pmsgno}	\n"; 
    	qry += "	     , {refkeyval}	\n"; 
    	qry += "	     , 'Y'	\n";
    	qry += "	     , {userid}	\n";
    	qry += "	     , SYSDATE	\n";
    	qry += "	     , {userid}  	\n";
    	qry += "	     , SYSDATE	); \n";
		qry += " INSERT INTO TMSGCLOB (MSGNO) VALUES ({msgno}); "; //CLOB테이블에 PK만 우선 넣어줌
		if(rcvs!=null&& !"".equals(rcvs.trim())) {
			String[] arrRcvs = rcvs.split(",");
			for(int i=0; i < arrRcvs.length; i++) {
				String rcvuserid = arrRcvs[i];
				if(rcvuserid!=null&& !"".equals(rcvuserid.trim())) {
			    	qry += " INSERT INTO TMSGRCV	\n";
			    	qry += "	      ( MSGNO	\n";
			    	qry += "	      , RCVNO \n";
			    	qry += "	      , RCVUSERID \n"; 
			    	qry += "	      , RCVTYPE \n";  
			    	qry += "	      , SORTSEQ \n";
			    	qry += "	      , STATCD \n";
			    	qry += "	      , RCVSTATCD \n";
			    	qry += "	      , REGUSERID	\n";
			    	qry += "	      , REGDT     	\n";
			    	qry += "	      , UPDUSERID  	\n";
			    	qry += "	      , UPDDT  )	\n";
			    	qry += "	VALUES (	\n";
			    	qry += "	       {msgno}	\n";
			    	qry += "	     , "+(i+1)+"\n";
			    	qry += "	     , '"+rcvuserid+"' \n"; 
			    	qry += "	     , 'TO'	\n"; 
			    	qry += "	     , "+(i+1)+"	\n"; 
			    	qry += "	     , 'Y'	\n";
			    	qry += "	     , 'N'	\n";
			    	qry += "	     , {userid}	\n";
			    	qry += "	     , SYSDATE	\n";
			    	qry += "	     , {userid}  	\n";
			    	qry += "	     , SYSDATE	); \n";
				}
			}
		}
    	qry += " END; \n";
		qry = qry.replace("{msgno}","'"+msgno+"'"); 
		qry = qry.replace("{msgtype}","'"+msgtype+"'"); 
		qry = qry.replace("{title}","'"+title+"'");  
		qry = qry.replace("{pmsgno}","'"+pmsgno+"'");  
		qry = qry.replace("{refkeyval}","'"+refkeyval+"'"); 
		qry = qry.replace("{userid}","'"+userid+"'"); 
		rst = executeUpdate(qry);

	    if("OK".equals(rst)) { 
			//executeUpdateClob(String sql, String Tbl, String clobCol, String clobData, String where)
			String where = " WHERE msgno={msgno} ";
			where = where.replace("{msgno}","'"+msgno+"'"); 
		    qry  = "UPDATE TMSG SET upddt = SYSDATE "+where;  
			rst = executeUpdateClob(qry, "TMSGCLOB", "content", memo, where ); 
	    }
    } catch(Exception e) {  
		rst = "exception:"+e.toString();
	}    
	return msgno;  
} 

public String insertLog(String userid,String pgmid, String logtype, String keyval, String info) {
	String qry = "";
	String logno = getUUID(20);  //여기서 UUID채번  
	JSONObject INVAR = new JSONObject();
	INVAR.put("logno",logno);
	INVAR.put("userid",userid);
	INVAR.put("pgmid",pgmid);
	INVAR.put("logtype",logtype);
	INVAR.put("keyval",keyval);
	INVAR.put("info",info);
	
	String rst = "OK"; 
	try {  
		qry  = " INSERT INTO TLOG	\n";
    	qry += "	      ( LOGNO	\n";
    	qry += "	      , LOGTYPE	\n";
    	qry += "	      , PGMID 	\n"; 
    	qry += "	      , USERID	\n"; 
    	qry += "	      , KEYVAL  \n";
    	qry += "	      , INFO	\n";
    	qry += "	      , REGDT  )   	\n";
    	qry += "	VALUES (	\n";
    	qry += "	       {logno}	\n";
    	qry += "	     , {logtype}	\n";
    	qry += "	     , {pgmid}	\n"; 
    	qry += "	     , {userid}	\n"; 
    	qry += "	     , {keyval}	\n"; 
    	qry += "	     , {info} 	\n";
    	qry += "	     , SYSDATE )	\n"; 
		setCtx("COMMON");
		qry = bindVAR(qry,INVAR);
    	rst = executeUpdate(qry);
    } catch(Exception e) {  
		rst = "exception:"+e.toString();
	}    
	return logno;  
} 
	
public boolean isNull(Object val) {
	boolean rtn = false;
	if (val == null) rtn = true;
	else if (val instanceof java.lang.String && "".equals(val)) rtn = true;
	else if ("[]".equals(val.toString()) || "{}".equals(val.toString())) rtn = true; 
	return rtn;
}
public String nvl(String val, String rep) { //null일 경우 Replace값으로 치환
	String rtn = ""; 
	if (val == null) rtn = rep;
	else rtn = val;
	return rtn;
}
public String getDate() {
	String rtn = "2019-09-07";
	Calendar cal= Calendar.getInstance();
    int year = cal.get(Calendar.YEAR);
    int mon = cal.get(Calendar.MONTH) + 1;
    int day = cal.get(Calendar.DAY_OF_MONTH);

    rtn = year+"-";
    if(mon < 10) rtn += "0"+mon+"-";
    else rtn += mon+"-";
    
    if(day < 10) rtn += "0"+day;
    else rtn += day;
    
    return rtn; 		
}
public String getDateTime() {
	String rtn = "2019-09-07 16:42:21";
	Calendar cal= Calendar.getInstance();
    int year = cal.get(Calendar.YEAR);
    int mon = cal.get(Calendar.MONTH) + 1;
    int day = cal.get(Calendar.DAY_OF_MONTH);
    int hour = cal.get(Calendar.HOUR);
    int min = cal.get(Calendar.MINUTE);
    int sec = cal.get(Calendar.SECOND);

    rtn = year+"-";
    if(mon < 10) rtn += "0"+mon+"-";
    else rtn += mon+"-";
    
    if(day < 10) rtn += "0"+day;
    else rtn += day;
    
    rtn += " " + hour + ":" + min + ":" + sec;  
    
    return rtn; 		
}
public String getUUID(int len) {
	String rtn = "20190907164221dK2kdlkbi"; //시분초(14)+지정된자리수
	//UUID uuid = new UUID();
	String uid = (UUID.randomUUID()).toString();
	String ymd = "";
	String hms = "";
	Calendar cal= Calendar.getInstance();
    int year = cal.get(Calendar.YEAR);
    int mon = cal.get(Calendar.MONTH) + 1;
    int day = cal.get(Calendar.DAY_OF_MONTH);
    int hour = cal.get(Calendar.HOUR);
    int min = cal.get(Calendar.MINUTE);
    int sec = cal.get(Calendar.SECOND);
    ymd = ""+ year;
    ymd += fm(mon,"00");
    ymd += fm(day,"00");  
    hms = fm(hour,"00");  
    hms = fm(min,"00");  
    hms = fm(sec,"00");   
	
    if ( len < 8 ) rtn = uid.substring(0,len); 
    else if ( len < 14 ) rtn = ymd + (uid.substring(0,len-8));
    else rtn = ymd+hms+(uid.substring(0,len-14));
    return rtn; 		
}

public String fm(int val, String format) {
	if(format.equals("00")) {
		if(val < 10) return "0"+val;
		else return ""+val;
	}
	return "";
}

public String calgetWeekday(int day_of_week) {
	String m_week = "";
	if ( day_of_week == 1 ) m_week="일요일";
	else if ( day_of_week == 2 ) m_week="월요일";
	else if ( day_of_week == 3 ) m_week="화요일";
	else if ( day_of_week == 4 ) m_week="수요일";
	else if ( day_of_week == 5 ) m_week="목요일";
	else if ( day_of_week == 6 ) m_week="금요일";
	else if ( day_of_week == 7 ) m_week="토요일"; 
	else {
		Calendar cal= Calendar.getInstance();
		int day_of_week2 = cal.get ( Calendar.DAY_OF_WEEK );
		m_week = calgetWeekday(day_of_week2);
	}
return m_week; 
} 

//static Logger logger2 = new Logger(); //Logger.getLogger("common.jsp");//.getRootLogger(); //
public Logger logger = new Logger(); 
public class Logger {
	boolean chkval; 
	String Userid; 
	
	Logger() {	 
	}
	
	void setUp(String userid) {

		Userid = userid;
		
		if("192053".equals(userid) || "mnight80".equals(userid))
		{
			chkval = true;
		}
		else
		{
			chkval = false;
		}
		
	}
	
	void error(String msg, Exception e) { 
		if (chkval) error( msg + "-" + e.toString());
	}
	
	void error(String msg) {
		if (chkval) {
			String msg2 = "E - " + getDateTime() + " " + getCaller() + " " + Userid + " - " + msg;
			System.out.println(msg2);
		
			String dir = "D:\\ONLINEADMIN\\bin\\tomcat9_awe\\logs\\"; //C:\ONLINEADMIN\bin\tomcat9_awe\logs
			String dt = getDate();
			String fnm = "awelogger."+dt+".txt"; 
			String fullpath = dir + fnm;
			
			try {
				File newpath = new File(dir);
			    if (!newpath.exists()) {
			    	newpath.mkdirs();
			    }
			    File newfile = new File(fullpath);
			    if (!newfile.exists()) {
			    	newfile.createNewFile();
			    	Writer fw = null;
			    	fw = new OutputStreamWriter(new FileOutputStream(fullpath), StandardCharsets.UTF_8);
			    	fw.write( msg2 ); 
			    	fw.close();
			    } else {
					Files.write(Paths.get(fullpath), ("\n"+msg2).getBytes(), StandardOpenOption.APPEND);
			    }
			} catch( IOException e) {
				System.out.println("error in writing log file :"+ e);
			} 
		} 
	}
	
	void debug(String msg) {
		if (chkval) {
			String msg2 = "D - " + getDateTime() + " " + getCaller() + " " + Userid + " - " + msg;
			 
			if(getCaller().indexOf("msg_jsp") < 0  ) { // && getCaller().indexOf("index_jsp") < 0 
				System.out.println(msg2);
			
				String dir = "D:\\ONLINEADMIN\\bin\\tomcat9_awe\\logs\\"; //C:\ONLINEADMIN\bin\tomcat9_awe\logs
				String dt = getDate();
				String fnm = "awelogger."+dt+".txt"; 
				String fullpath = dir + fnm;
				
				try {
					File newpath = new File(dir);
				    if (!newpath.exists()) {
				    	newpath.mkdirs();
				    }
				    File newfile = new File(fullpath);
				    if (!newfile.exists()) {
				    	newfile.createNewFile();
				    	Writer fw = null;
				    	fw = new OutputStreamWriter(new FileOutputStream(fullpath), StandardCharsets.UTF_8);
				    	fw.write(msg2); 
				    	fw.close();
				    } else {
						Files.write(Paths.get(fullpath), ("\n"+msg2).getBytes(), StandardOpenOption.APPEND);
				    }
				} catch( IOException e) {
					System.out.println("error in writing log file :"+ e);
				}  
				
			} 
    	}
	}
	
	String getDate() {
		String rtn = "2019-09-07";
		Calendar cal= Calendar.getInstance();
	    int year = cal.get(Calendar.YEAR);
	    int mon = cal.get(Calendar.MONTH) + 1;
	    int day = cal.get(Calendar.DAY_OF_MONTH);
	    int hour = cal.get(Calendar.HOUR);  //log파일명에 시간추가

	    rtn = year+"-";
	    if(mon < 10) rtn += "0"+mon+"-";
	    else rtn += mon+"-";
	    
	    if(day < 10) rtn += "0"+day;
	    else rtn += day;
	    
	    return rtn+hour; 		//log파일명에 시간추가
	}
	
	String getDateTime() {
		String rtn = "";
		Calendar cal= Calendar.getInstance();
	    int year = cal.get(Calendar.YEAR);
	    int mon = cal.get(Calendar.MONTH) + 1;
	    int day = cal.get(Calendar.DAY_OF_MONTH);
	    int hour = cal.get(Calendar.HOUR);
	    int min = cal.get(Calendar.MINUTE);
	    int sec = cal.get(Calendar.SECOND);

	    rtn = year+"-";
	    if(mon < 10) rtn += "0"+mon+"-";
	    else rtn += mon+"-";
	    
	    if(day < 10) rtn += "0"+day;
	    else rtn += day;
	    
	    rtn += " " + hour + ":" + min + ":" + sec;  
	    
	    return rtn; 		
	}
	
	String getCaller() { 
		String rtn = "";
		StackTraceElement[] ste = new Throwable().getStackTrace(); 
		for(StackTraceElement element : ste) { 
			if("_jspService".equals(element.getMethodName())) {
				rtn = element.getClassName() + "(" + element.getLineNumber() + " of " + element.getFileName() + ")\n";
				break;
			}
		}
		return rtn; 
	}
} 

public final static class UUID implements java.io.Serializable, Comparable<UUID> { 
    private static final long serialVersionUID = -4856846361193249489L; 
    private final long mostSigBits; 
    private final long leastSigBits; 
    private static volatile SecureRandom numberGenerator = null; 
    private UUID(byte[] data) {
        long msb = 0;
        long lsb = 0;
        assert data.length == 16 : "data must be 16 bytes in length";
        for (int i=0; i<8; i++)
            msb = (msb << 8) | (data[i] & 0xff);
        for (int i=8; i<16; i++)
            lsb = (lsb << 8) | (data[i] & 0xff);
        this.mostSigBits = msb;
        this.leastSigBits = lsb;
    } 
    public UUID(long mostSigBits, long leastSigBits) {
        this.mostSigBits = mostSigBits;
        this.leastSigBits = leastSigBits;
    } 
    public static UUID randomUUID() {
        SecureRandom ng = numberGenerator;
        if (ng == null) {
            numberGenerator = ng = new SecureRandom();
        }

        byte[] randomBytes = new byte[16];
        ng.nextBytes(randomBytes);
        randomBytes[6]  &= 0x0f;  /* clear version        */
        randomBytes[6]  |= 0x40;  /* set to version 4     */
        randomBytes[8]  &= 0x3f;  /* clear variant        */
        randomBytes[8]  |= 0x80;  /* set to IETF variant  */
        return new UUID(randomBytes);
    } 
    public UUID nameUUIDFromBytes(byte[] name) {
        MessageDigest md;
        try {
            md = MessageDigest.getInstance("MD5");
        } catch (NoSuchAlgorithmException nsae) {
            throw new InternalError("MD5 not supported");
        }
        byte[] md5Bytes = md.digest(name);
        md5Bytes[6]  &= 0x0f;  /* clear version        */
        md5Bytes[6]  |= 0x30;  /* set to version 3     */
        md5Bytes[8]  &= 0x3f;  /* clear variant        */
        md5Bytes[8]  |= 0x80;  /* set to IETF variant  */
        return new UUID(md5Bytes);
    } 
    public UUID fromString(String name) {
        String[] components = name.split("-");
        if (components.length != 5)
            throw new IllegalArgumentException("Invalid UUID string: "+name);
        for (int i=0; i<5; i++)
            components[i] = "0x"+components[i];

        long mostSigBits = Long.decode(components[0]).longValue();
        mostSigBits <<= 16;
        mostSigBits |= Long.decode(components[1]).longValue();
        mostSigBits <<= 16;
        mostSigBits |= Long.decode(components[2]).longValue();

        long leastSigBits = Long.decode(components[3]).longValue();
        leastSigBits <<= 48;
        leastSigBits |= Long.decode(components[4]).longValue();

        return new UUID(mostSigBits, leastSigBits);
    } 
    public long getLeastSignificantBits() {
        return leastSigBits;
    } 
    public long getMostSignificantBits() {
        return mostSigBits;
    } 
    public int version() {
        // Version is bits masked by 0x000000000000F000 in MS long
        return (int)((mostSigBits >> 12) & 0x0f);
    } 
    public int variant() {
        // This field is composed of a varying number of bits.
        // 0    -    -    Reserved for NCS backward compatibility
        // 1    0    -    The Leach-Salz variant (used by this class)
        // 1    1    0    Reserved, Microsoft backward compatibility
        // 1    1    1    Reserved for future definition.
        return (int) ((leastSigBits >>> (64 - (leastSigBits >>> 62)))
                      & (leastSigBits >> 63));
    } 
    public long timestamp() {
        if (version() != 1) {
            throw new UnsupportedOperationException("Not a time-based UUID");
        }

        return (mostSigBits & 0x0FFFL) << 48
             | ((mostSigBits >> 16) & 0x0FFFFL) << 32
             | mostSigBits >>> 32;
    } 
    public int clockSequence() {
        if (version() != 1) {
            throw new UnsupportedOperationException("Not a time-based UUID");
        }

        return (int)((leastSigBits & 0x3FFF000000000000L) >>> 48);
    } 
    public long node() {
        if (version() != 1) {
            throw new UnsupportedOperationException("Not a time-based UUID");
        }

        return leastSigBits & 0x0000FFFFFFFFFFFFL;
    } 
    public String toString() {
        return (digits(mostSigBits >> 32, 8) + "-" +
                digits(mostSigBits >> 16, 4) + "-" +
                digits(mostSigBits, 4) + "-" +
                digits(leastSigBits >> 48, 4) + "-" +
                digits(leastSigBits, 12));
    } 
    private String digits(long val, int digits) {
        long hi = 1L << (digits * 4);
        return Long.toHexString(hi | (val & (hi - 1))).substring(1);
    } 
    public int hashCode() {
        long hilo = mostSigBits ^ leastSigBits;
        return ((int)(hilo >> 32)) ^ (int) hilo;
    } 
    public boolean equals(Object obj) {
        if ((null == obj) || (obj.getClass() != UUID.class))
            return false;
        UUID id = (UUID)obj;
        return (mostSigBits == id.mostSigBits &&
                leastSigBits == id.leastSigBits);
    } 
    public int compareTo(UUID val) {
        // The ordering is intentionally set up so that the UUIDs
        // can simply be numerically compared as two numbers
        return (this.mostSigBits < val.mostSigBits ? -1 :
                (this.mostSigBits > val.mostSigBits ? 1 :
                 (this.leastSigBits < val.leastSigBits ? -1 :
                  (this.leastSigBits > val.leastSigBits ? 1 :
                   0))));
    }
}

}
