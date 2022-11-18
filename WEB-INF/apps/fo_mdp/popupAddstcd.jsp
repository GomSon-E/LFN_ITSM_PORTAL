<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_mdp";
String pgmid   = "popupAddstcd"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/// *********************************************************************************************/

//searchStcd : 입력한 스타일/상품 코드에 해당하는 바코드/상품 목록 가져오기
if("searchStcd".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        JSONArray list = getArray(INVAR,"list");
        //LIKE 정규식표현 활용 - WHERE REGEXP_LIKE(goods_cd, '^A|^B')
        String stcds = "";
        for(int i=0; i < list.size(); i++) {
            stcds += "^"+getVal(list, i, "stcd")+"|";
        }
        stcds += "''"; 
        /*
        String stcds = "";
        for(int i=0; i < list.size(); i++) {
            stcds += "'"+getVal(list, i, "stcd")+"',";
        }
        stcds += "''";
        */
        INVAR.put("stcds",stcds);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "qrysearchStcdlist"); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray list2 = selectSVC(conn, qryRun);
        OUTVAR.put("list2",list2); 

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
