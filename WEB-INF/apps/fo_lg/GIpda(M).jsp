<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_lg";
String pgmid   = "GIpda(M)"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/

//상품스캔
if("goodsSearch".equals(func)) {
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
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd");
            rtnMsg = getVal(rst,"rtnMsg");
        } else { 
            conn.commit();
            String goods_cd = getVal(rst,"rtnMsg");  //barcd에 대한 godos_cd가 있으므로 상품정보를 조회하여 Return한다.
            logger.info(goods_cd);
            qry = getQuery(pgmid,"goodsSearch"); 
            INVAR.put("goods_cd",goods_cd);
            qryRun = bindVAR(qry,INVAR); 
            JSONArray list = selectSVC(conn,qryRun);
            OUTVAR.put("list",list); 
        }   
    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}


//searchDet : 박스내 상품조회
if("searchPack".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID); 
    
        conn = getConn("LFN"); 
        
        String qry = getQuery(pgmid, "searchDet");
        String qryRun = bindVAR(qry,INVAR); 
        OUTVAR.put("qryRun",qryRun);
        JSONArray list = selectSVC(conn, qryRun);
        OUTVAR.put("list",list); 
        
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}

//boxOrd:대상확정 이벤트처리(DB_Write)
if("boxOrd".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        
        String qryMst = getQuery(pgmid, "qryBoxMst");
        String qryDet = getQuery(pgmid, "qryBoxDet");
        String qryRun = "";
        
        qryRun = bindVAR(qryMst,INVAR);  
        OUTVAR.put("qryMst",qryRun);
        JSONObject rst = executeSVC(conn, qryRun);  
        
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else {  
            String cur_lg_ord_no = getVal(rst,"rtnMsg");   
            
            qryRun = "";
            JSONArray arrList = getArray(INVAR,"det");
            for(int i = 0; i < arrList.size(); i++) {
            
                JSONObject row = getRow(arrList,i); 
                row.put("comcd",ORGCD); 
                row.put("usid",USERID);
                row.put("cur_lg_ord_no",cur_lg_ord_no); 
                row.put("box_no",getVal(row,"box_no"));
                row.put("lg_ord_no",getVal(row,"lg_ord_no"));
                String qryDetRun = bindVAR(qryDet,row);
                qryRun += qryDetRun + "\n"; 
            }          
            rst = executeSVC(conn, qryRun);  
            if(!"OK".equals(getVal(rst,"rtnCd"))) {
                conn.rollback();
                rtnCode = getVal(rst,"rtnCd"); 
                rtnMsg  = getVal(rst,"rtnMsg"); 
            } else { 
                OUTVAR.put("cur_lg_ord_no",cur_lg_ord_no); 
                conn.commit();
            } 
        }

    } catch (Exception e) {
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
