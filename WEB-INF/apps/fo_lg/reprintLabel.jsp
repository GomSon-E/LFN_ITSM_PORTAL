<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_lg";
String pgmid   = "reprintLabel"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/// *********************************************************************************************/

if("searchBoxGoods".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "qryprintGoods"); 
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


//print: 선택된 출고전표의 패킹라벨 발행
if("print".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        
        String qryDet = getQuery(pgmid, "qryprintGoods"); 
        
        JSONArray boxlist = getArray(INVAR,"list");
        JSONObject arlist = new JSONObject();
        for(int i = 0; i<boxlist.size(); i++){
        
            JSONObject row = getRow(boxlist,i);
            
            row.put("comcd",ORGCD); 
            //row.put("dist_no", getVal(INVAR,"dist_no"));
		    //row.put("lg_ord_no", getVal(INVAR, "lg_ord_no"));
		          
            String qryDetRun = bindVAR(qryDet,row);
            //OUTVAR.put("qryDetRun#"+i,qryDetRun); 
            JSONArray goodslist = selectSVC(conn, qryDetRun);
             
            arlist.put("goodslist"+i,goodslist);
            OUTVAR.put("arlist",arlist);
        }
        
    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}
    
    
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
