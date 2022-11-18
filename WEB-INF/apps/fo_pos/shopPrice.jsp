<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_pos";
String pgmid   = "shopPrice"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/**********************************************************/
if("search".equals(func)) {
    Connection conn = null; 
    try {
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        //INVAR barcd, shopcd
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        String qry = getQuery(pgmid, "checkBarcd"); 
        String qryRun = bindVAR(qry,INVAR);
        JSONObject rst = executeSVC(conn, qryRun);
        OUTVAR.put("qryRun2",qryRun);
        OUTVAR.put("rst",rst);
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd");
            rtnMsg = getVal(rst,"rtnMsg");
        } else { 
            conn.commit();
            String goods_cd = getVal(rst,"rtnMsg");  //barcd에 대한 godos_cd가 있으므로 상품정보를 조회하여 Return한다.
            OUTVAR.put("goods_cd",goods_cd);
            logger.info(goods_cd);
            INVAR.put("goods_cd",goods_cd);
            OUTVAR.put("INVAR",INVAR);
            qry = getQuery(pgmid,"goodsSearch"); 
            qryRun = bindVAR(qry,INVAR); 
            JSONArray list = selectSVC(conn,qryRun);
            OUTVAR.put("qryRun",qryRun);
            OUTVAR.put("list",list); 
            
            /*
            String promogoods_cd = goods_cd.substring(0,9);
            INVAR.put("promogoods_cd",promogoods_cd);
            String qry2 = getQuery(pgmid,"promogoodsSearch"); 
            String qryRun2 = bindVAR(qry2,INVAR); 
            JSONArray list2 = selectSVC(conn,qryRun2);
            OUTVAR.put("list2",list2);
            OUTVAR.put("qryRun2",qryRun2);
            */
            
        }   
        
    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();	
    } finally {
        closeConn(conn);
    }  
}
/***************************************************************************************************/// *********************************************************************************************/
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
