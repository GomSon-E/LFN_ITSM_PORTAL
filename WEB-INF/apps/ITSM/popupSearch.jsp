<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "ITSM";
String pgmid   = "popupSearch"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/
if("search".equals(func)) { 
	Connection conn = null; 

	try { 
	    //INVAR = {grpcd:refcd, disp:nvl(disp,"cdnm"), term:nvl(term,""), where:(optional)}
	    String refcd  = getVal(INVAR, "grpcd");
	    String disp   = getVal(INVAR, "disp");
	    String term   = getVal(INVAR, "term");
	    String where  = getVal(INVAR, "where");
	    if(isNull(where)) where = " 1 = 1 ";
	    INVAR.put("orgcd", ORGCD);  //로그인사용자의 ORGCD 회사코드 쿼리문에 적용
	    INVAR.put("usid",  USERID); //로그인사용자 USERID 쿼리문에 적용
        INVAR.put("where", where);
        
        conn = getConn("LFN");
        String qry = "";
        
        //grpcd가 존재하는지 조회하는 SELECT 수행
        qry = getQuery(pgmid, "GRPCD");
        String qryRun = bindVAR(qry, INVAR);
        JSONArray arr = selectSVC(conn, qryRun);
        
        //2. grpcd가 존재하지 않는 경우, grpcd를 "popupSearch"의 소스 코드에서 getQuery('pgmid', 'qryID')의 qryID를 사용해 쿼리 수행
        if(arr.size() == 0) {
            //System.out.println("popupSearch.search:"+refcd);
            qry = getQuery(pgmid, refcd); //팝업을 위한 참조코드를 추가하려는 경우 popupSearch에 해당 이름의 쿼리를 추가해줘야 함! 
            
        //1. 공통 코드 구분 쿼리 - grpcd가 T_CODE에 존재하는지 검색한 후 존재하는 경우, 공통 코드 구분 쿼리 사용    
        } else {
            qry  = "SELECT * FROM ( SELECT A.*, cd||' '||nm cdnm FROM T_CODE A WHERE grpcd={grpcd} AND cd_stat='Y' )";
            qry += " WHERE [disp] LIKE '%[term]%'"; 
            qry += "   AND [where] "; 
            qry += " ORDER BY grpcd, sort_seq, nm ";
        }
        
        qryRun = bindVAR(qry, INVAR);
        OUTVAR.put("searchQry",qryRun);
        //System.out.println("popupSearch.search - qryRun:"+qryRun);
        JSONArray list = selectSVC(conn, qryRun);
        OUTVAR.put("list", list);

	} catch (Exception e) { 
		rtnCode = "ERR";
		rtnMsg  = e.toString();	
		
	} finally {
		closeConn(conn);
	}  
}  
/***************************************************************************************************/
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
