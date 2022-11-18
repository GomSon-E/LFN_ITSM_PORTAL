<%@ include file="../common/service.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>  
<%
//전역상수
String path = "./"; 
String root = "./WEB-INF/src";         
String FILESL = "\\";

//전역변수 
String ORGCD = (String)session.getAttribute("ORGCD");
String ORGNM = (String)session.getAttribute("ORGNM");
String DEPTCD = (String)session.getAttribute("DEPTCD");
String DEPTNM = (String)session.getAttribute("DEPTNM");
String USERID = (String)session.getAttribute("USERID");
String USERNM = (String)session.getAttribute("USERNM");
String USERAUTH = (String)session.getAttribute("USERAUTH");  
String MULTIORGYN = (String)session.getAttribute("MULTIORGYN");

/* 메쏘드 리스트 ********************************************************************* 
* logger.error(str)
* logger.debug(str)
* aweCheck(HttpSession session)
* insertMsg (String userid, String msgtype, String title, String memo, String pmsgno, String refkeyval, String rcvs);
* insertLog(String userid,String pgmid, String logtype, String keyval, String info)

* boolean isNull(Object val)
* String nvl(String val, String rep)
* String fm(int val, String format)    
* String getDate()
* String getDateTime()
* calgetWeekday(int day_of_week)
* String getUUID(int len)

* setCtx(String userOrgCd )
* Connection getConn()
* String getQuery(conn, String pgmID, contentname)
* String bindVAR(String qry,JSONObject VAR)
* JSONArray selectSVC(conn, qry)
* JSONArray selectSVC(conn, pgmid, qryid, INVAR)
* JSONObject excuteSVC(conn, qry)
* closeConn(conn)

* JSONObject getObject(String sData)
* JSONArray getArray(String sData, String sArrId )
* JSONArray getArray(JSONObject gridObj, String sArrId )
* JSONObject getRow(JSONArray arr, int rownum)
* String getCol(JSONObject obj, String colnm)
* String getVal(JSONObject obj, String datanm, String colnm)
* String getVal(JSONArray arr, int rownum, String colnm)
* String getVal(JSONObject obj, String arrnm, int rownum, String colnm)
* LinkedHashMap getRowWithColOrder(JSONArray arr, int rownum)

** Deprecated ********************************************************************
* String httpReqLog(HttpServletRequest req)
* String httpReqAttr(HttpServletRequest req)
* String httpReqHeader(HttpServletRequest req)
* String readJSONStringFromRequestBody(HttpServletRequest request)

* JSONArray executeQuery(String sql)
* JSONArray executeQueryWithColOrder(String sql)
* JSONArray executeQueryWithColOrder(Connection conn, String sql)
* String executeUpdate(String sql)
* JSONObject execute(String sql)
* JSONArray executeQueryClob(String sql, String clobCol)
* JSONArray executeQueryClob(Connection conn, String sql, String clobCol) 
* String executeUpdateClob(String sql, String Tbl, String clobCol, String clobData, String where)
* ArrayList<LinkedHashMap<String,String>> executeQueryOLD(String sql) 
**********************************************************************************/

//DB 기본 컨텍스트 EIS.IT_ADMIN 으로 잡아줌 
setCtx( "COMMON" );
logger.setUp(USERID);
%>
<%!  
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
	} finally {
		closeConn(conn);
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
	Connection cconn = null; 
	try {
		cconn = getConn("common"); 
		String qry = getQuery(cconn, pgmid, qryid); //1)쿼리를 가져와서
        closeConn(cconn);
	    qry = bindVAR(qry,INVAR);                      //2)변수바이딩하고
        //결과조회
	    return executeQuery(conn,qry); 
	} catch (Exception e) {
		throw e; 
	} finally {
		closeConn(cconn);
	}
}

public JSONArray selectSVC(Connection conn, String pgmid, String qryid, JSONObject INVAR, String Clobcol) throws Exception {
	Connection cconn = null;
	try {
		cconn = getConn("common"); 
		String qry = getQuery(cconn, pgmid, qryid); //1)쿼리를 가져와서
        closeConn(cconn);
	    qry = bindVAR(qry,INVAR);                      //2)변수바이딩하고
        //결과조회
	    return executeQueryClob(conn,qry,Clobcol); 
	} catch (Exception e) {
		throw e;
		
	} finally {
		closeConn(cconn);
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

public JSONObject execute(Connection conn, String sql) {
	JSONObject OUTVAR = new JSONObject();
	JSONObject VAR    = new JSONObject();
	String rtnCode = "OK";
	String rtnMsg = ""; 
	Statement stmt = null;
	boolean rs;  
	try {
		stmt = conn.createStatement();  
		rs = stmt.execute(sql);  
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
	} finally {
		closeConn(conn);
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
	} finally {
		closeConn(conn);
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
		/* begin이나 declare로 시작하면 execute호출하고 그렇지 않으면 쿼리문 커넥션 맺어서 실행 */
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
		if(rs < 0 ) rtn = rs+"";
		if (stmt != null) stmt.close(); 
		if (conn != null) conn.close(); 
		//logger.error("inc.db.executeUpdate:"+sql+" : "+rs+":success!");
	} catch (java.sql.SQLException oe) {
		logger.error("inc.db.executeUpdate:"+sql+":"+oe.getErrorCode()+" "+oe.getMessage());
		return oe.getMessage();
	} catch (Exception e) { 
		logger.error("inc.db.executeUpdate:"+sql+":"+e.toString());
	    throw e;   
	} finally {
		closeConn(conn);
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
	} finally {
		closeConn(conn);
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
	} finally {
		closeConn(conn);
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
						
						//String b64 = javax.xml.bind.DatatypeConverter.printBase64Binary( bytes );
						String b64 = org.apache.commons.codec.binary.Base64.encodeBase64String(bytes);
						
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
		
		irs = stmt.executeUpdate(sql);  
		
		sql = "SELECT "+clobCol+" FROM "+Tbl+" "+where;   
	    stmt = conn.createStatement(); 
	    rs = stmt.executeQuery(sql);
	    /*	    logger.error(rs + ":" + sql); */
		
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
	} finally {
		closeConn(conn);
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
	} finally {
		closeConn(conn);
	}
	return al;
}  
%>
<%! 
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
			JSONObject obj = (JSONObject)gridObj;
		    Object rtn = obj.get(sArrId);
		    String rtnClass = rtn.getClass().getName();
		    if("org.json.simple.JSONArray".equals(rtnClass)) {
		    	gridArr = (JSONArray)rtn;	
		    } else {
		    	gridArr = null;
		    } 
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
		JSONObject obj = (JSONObject)gridObj;
	    Object rtn = obj.get(sArrId);
	    String rtnClass = rtn.getClass().getName();
	    if("org.json.simple.JSONArray".equals(rtnClass)) {
	    	gridArr = (JSONArray)rtn;	
	    } else {
	    	gridArr = null;
	    } 
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
public JSONObject getObj(JSONObject obj, String key) throws Exception {  
	try { 
		return  (JSONObject)obj.get(key); 
	} catch (Exception e) { 
		logger.error("inc.common.getObj:"+obj+" : "+key);
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
%> 
<%! 
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
            rtn += "<td style='text-align:" + align[i] + "'>" + makeStyle(row.get(col[i])) + "</td>"; //g makeStyle(row.get(col[i]))  etVal(row, col[i])  row.get(col[i]) 
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
		if(isNull((String)v)) {
			rtn = ""; 
		} else {
			try {
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
		}
		if("".equals(r)) rtn = (String)v;
		else rtn = r;
	} else if (v instanceof java.lang.Long || v instanceof java.lang.Integer) {
		rtn = String.format("%,d",v); //NumberFormat.getInstance().format(v);          		
	} else if (v instanceof java.lang.Float || v instanceof java.lang.Double) {
		rtn = String.format("%,.1f", v);          		
	} else {
		rtn = ""+v;
	}
	
	return rtn;
}

public Double toNum(Object v) {
	Double d = 0.0d;
	try {
		if (v instanceof java.lang.Long || v instanceof java.lang.Integer || v instanceof java.lang.Float || v instanceof java.lang.Double) {
			d = (Double)v;
		} else {
			d = Double.parseDouble( (String)v );
		}
	} catch(Exception e) {
		logger.error("toNum",e);
	}
	return d;
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
		//OUTVAR.put("qry",qryComcd);
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
		qry += "   AND (C.AUTHCD = CASE WHEN A.DEPTCD='SCM' THEN '' ELSE 'ANY' END \n"; //SCM이 아니면 ANY권한가짐
		qry += "    OR A.ROLECDS LIKE '%ADM,%'  \n"; //ADM은 전체권한
		qry += "    OR A.ROLECDS = C.AUTHCD     \n"; //SCM이거나		 		
		qry += "    OR A.ROLECDS LIKE '%'||C.AUTHCD||',%') \n"; //그외 가진 권한
		qry += " ORDER BY C.menu1, C.SORTSEQ   \n"; 
		JSONObject INVAR = new JSONObject();
	    INVAR.put("userid",userid); 
	    qry = bindVAR(qry,INVAR); 
		OUTVAR.put("qryMenu",qry);
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

%>
<%! 
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
	Connection conn = null;
	String qry = "";
	String msgno = getUUID(20);  //여기서 UUID채번 
	JSONArray  mRtn  = new JSONArray();     
	String rst = "OK"; 
	JSONObject rtn = new JSONObject();
	try {  
		conn = getConn("COMMON");
	    conn.setAutoCommit(false);
		
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
		rtn = executeSVC(conn, qry);

	    if(!"OK".equals(getVal(rtn,"rtnCd"))) {
	    	conn.rollback();
	    	closeConn(conn);
	    } else {
			//executeUpdateClob(String sql, String Tbl, String clobCol, String clobData, String where)
			//변경 -> executeUpdateClob(Connection conn, "TMSG", "content", String clobData, String where) 
			String where = " WHERE msgno={msgno} ";
			where = where.replace("{msgno}","'"+msgno+"'"); 
		    //qry  = "UPDATE TMSG SET upddt = SYSDATE "+where;  
			rst = executeUpdateClob(conn, "TMSGCLOB", "content", memo, where ); 
			conn.commit();
			closeConn(conn);
	    }
    } catch(Exception e) {  
		rst = "exception:"+e.toString();
	} finally {
		closeConn(conn);
	}   
	return msgno;  
} 

public String insertLog(String userid,String pgmid, String logtype, String keyval, String info) {
	String qry = "";
	String logno = getUUID(20);  //여기서 UUID채번   
	
	/* log기록으로 인한 성능저하 방지 */
	if(!"retrieveWMS".equals(pgmid)) {
		return logno;
	} else { 
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
} 
%>
<%! 
/*** JANDI ***/
public JSONObject gfnJandiTeam(String Usernm, String toEmail, String title, String Msg) {
	JSONObject INVAR = new JSONObject();
	INVAR.put("url_webhook","");
	INVAR.put("email",toEmail);
	INVAR.put("body", "**"+title+"**("+Usernm+") "+Msg );
	INVAR.put("connectColor","");
	INVAR.put("connectInfo","");
	return gfnJandi(INVAR);
}

public String gfnGetMail(String brand, String Roles) throws Exception {
	String emails = "";
	Connection conn = null; 
	try {  
	    conn = getConn("COMMON"); 
        String qry = "SELECT LISTAGG(email,',') WITHIN GROUP(ORDER BY 1) emails FROM (SELECT DISTINCT B.email "+
	                 "  FROM TCODEBR A "+
        			 "     , TUSER B " +
        		     " WHERE A.GRPCD='ROLECD' " +
        		     "   AND A.BRCD ='"+brand+"' " +  
        		     "   AND A.KEYCOL IN ("+Roles+") " +
        		     "   AND B.USERID = A.CD " +
        		     "   AND B.STATCD = 'Y' )";  
        JSONArray arrList = selectSVC(conn,qry); 
        if(arrList.size()==1) {
        	JSONObject oMails = getRow(arrList,0);
        	emails = getVal(oMails,"emails");
        } 
    } catch(Exception e) {
    	throw e;
    } finally { 
    	closeConn(conn);
    } 
	return emails;
}

public JSONObject gfnJandi(JSONObject INVAR) {
	String enc = "UTF-8"; 
    
	InputStreamReader isr = null;
	BufferedReader bin = null;
	HttpURLConnection huc = null;
	
	BufferedReader br = null;
    StringBuffer sb = null;
    String sOUTVAR = ""; 
	JSONObject OUTVAR = new JSONObject();
    
	try {  
		String url_webhook = getVal(INVAR, "url_webhook"); // request.getParameter("url");
		String email = getVal(INVAR, "email"); 
		String body = getVal(INVAR, "body"); 
		String connectColor = getVal(INVAR, "connectColor"); 
		JSONArray connectInfo = getArray(INVAR, "connectInfo"); 
		
        /* 트라이본즈/파스텔웹훅: 0254859c476d6cd040d34ecbeacac8d6 */
        /* 이기현 테스트웹훅 토큰: b462b488aaa151032d1736df6eeb4c36 */
		if(isNull(url_webhook)) url_webhook = "https://wh.jandi.com/connect-api/webhook/20736797/0254859c476d6cd040d34ecbeacac8d6"; 
		if(isNull(connectColor)) connectColor = "#FAC11B"; 
		URL url = new URL(url_webhook); 
		huc = (HttpURLConnection) url.openConnection();
        huc.setRequestMethod("POST");  
        huc.setRequestProperty("Accept", "application/vnd.tosslab.jandi-v2+json");
        huc.setRequestProperty("Content-Type", "application/json");  
        huc.setRequestProperty("Cache-Control","no-cache");  // 컨트롤 캐쉬 설정 
        huc.setRequestProperty("Content-Length", "length");  // 타입길이 설정(Request Body 전달시 Data Type의 길이를 정함.) 
        huc.setRequestProperty("User-Agent", "tribonsEP");        // User-Agent 값 설정 
        huc.setDoOutput(true); // OutputStream으로 POST 데이터를 넘겨주겠다는 옵션. 
        huc.setDoInput(true); // InputStream으로 서버로 부터 응답을 받겠다는 옵션. 
        OutputStream os = huc.getOutputStream(); // Request Body에 Data를 담기위해 OutputStream 객체를 생성.
        JSONObject oBody = new JSONObject();     // Request Body에 Data 셋팅.
        oBody.put("body",body);
        if(!isNull(email)) oBody.put("email",email);
        oBody.put("connectColor", connectColor); 
        oBody.put("connectInfo",connectInfo); 
        os.write(oBody.toString().getBytes("UTF-8")); //body.getBytes("UTF-8")  
        os.flush(); // Request Body에 Data 입력. 
        os.close(); // OutputStream 종료. 
        
        int responseCode = huc.getResponseCode();  //실제 서버로 Request 요청 하는 부분. (응답 코드를 받는다. 200 성공, 나머지 에러)br = new BufferedReader(new InputStreamReader(huc.getInputStream(), "UTF-8")); 
        sb = new StringBuffer(); 
        String temp = "";
        while ((temp = br.readLine()) != null) {
            sb.append(temp);
        }
        sOUTVAR = sb.toString();
        JSONParser parser = new JSONParser();
        OUTVAR = (JSONObject) parser.parse(sOUTVAR);  
        OUTVAR.put("rtnCd", responseCode); 
        OUTVAR.put("INVAR", INVAR);
        OUTVAR.put("oBody", oBody);
		
	} catch (Exception e) {
		OUTVAR.put("rtnCd","ERR");
		OUTVAR.put("rtnMsg", e.toString()); 
	} finally {
		if(bin!=null) try{ bin.close(); } catch(Exception ex1){ System.out.println(ex1);};	
		if(isr!=null) try{ isr.close();	} catch(Exception ex2){ System.out.println(ex2);};
		if(huc!=null) huc.disconnect();	
	}
	
	return OUTVAR;
}
%>