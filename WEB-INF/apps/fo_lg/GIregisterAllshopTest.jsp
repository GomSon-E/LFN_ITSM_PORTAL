<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_lg";
String pgmid   = "GIregisterAllshopTest"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/// *********************************************************************************************/

if("saveTest".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        String qryMst = getQuery(pgmid, "querysaveMst");
        String qryDet = getQuery(pgmid, "qrysaveDet");
        
        JSONArray shop2 = getArray(INVAR,"shop2");
        //JSONArray shoplist = getArray(INVAR,"shoplist");
        
        //매장LOOP
        for(int j = 0; j < shop2.size(); j++) {
        
            String qryRun = "";
            INVAR.put("comcd",ORGCD);
            INVAR.put("usid",USERID);
            JSONObject roww = getRow(shop2, j);
            INVAR.put("ord_content_shop",getVal(roww,"ord_content_shop"));
            INVAR.put("shopcd", getVal(roww,"shopcd"));
            INVAR.put("lg_ord_no","TBD"); //매장별 출고전표를 새로 채번시킨다. 
            
            String qryMstRun = bindVAR(qryMst,INVAR);
            OUTVAR.put("qryMstRun#"+j,qryMstRun);    
            qryRun += qryMstRun + "\n"; 
	        JSONObject rst = executeSVC(conn, qryRun); 
	  
	        if(!"OK".equals(getVal(rst,"rtnCd"))) {
	            conn.rollback();
	            rtnCode = getVal(rst,"rtnCd"); 
	            rtnMsg  = getVal(rst,"rtnMsg"); 
	        } else {  
	            String lg_ord_no = getVal(rst,"rtnMsg"); 
	            JSONArray arrList = getArray(INVAR,"arr");
	            int seq = 0;
	            String qryRunn = "";
	            
	            //상품LOOP
	            for(int i = 0; i < arrList.size(); i++) { 
	                JSONObject row = getRow(arrList,i);  
					if(getVal(row, "shopcd").equals(getVal(roww,"shopcd")) && !"".equals(getVal(row, "qty")) && !"0".equals(getVal(row, "qty")) ){ // && getVal(row, "qty") != null 
					    ///////////////////////////
						row.put("comcd",ORGCD); 
		                row.put("usid",USERID);
		                row.put("lg_ord_no",lg_ord_no);
		                row.put("lg_ord_seq",(++seq));
		                row.put("crud",getVal(INVAR,"crud"));
		                row.put("from_whcd", getVal(INVAR,"from_whcd"));
		                row.put("lg_tp", getVal(INVAR,"lg_tp"));
		                row.put("pack_tp",getVal(INVAR,"pack_tp"));
		                row.put("box_keycd",getVal(INVAR,"box_keycd"));
		                String qryDetRun = bindVAR(qryDet,row);
		                OUTVAR.put("qryDetRun#"+i,qryDetRun);    
		                qryRunn += qryDetRun + "\n"; 
					} //if 
				} // end of for 상품LOOP
				
				if(!"".equals(qryRunn)) {
    	            rst = executeSVC(conn, qryRunn);  
    	            if(!"OK".equals(getVal(rst,"rtnCd"))) {
    	                conn.rollback();
    	                rtnCode = getVal(rst,"rtnCd"); 
    	                rtnMsg  = getVal(rst,"rtnMsg"); 
    	            } else { 
    	                OUTVAR.put("lg_ord_no",lg_ord_no);
    	                conn.commit();
    	            } 
	            } 
	        } 
        } //end of for 매장Loop
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}

/*
//save:대상확정 이벤트처리(DB_Write)
if("save".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        String qryMst = getQuery(pgmid, "querysaveMst");
        String qryDet = getQuery(pgmid, "qrysaveDet");
        
        JSONArray shoplist = getArray(INVAR,"shoplist");
        
        //매장LOOP
        for(int j = 0; j < shoplist.size(); j++) {
        
            String qryRun = "";
            INVAR.put("comcd",ORGCD);
            INVAR.put("usid",USERID);
            JSONObject roww = getRow(shoplist, j);
            INVAR.put("ord_content_shop",getVal(roww,"ord_content_shop"));
            INVAR.put("shopcd", getVal(roww,"shopcd"));
            INVAR.put("lg_ord_no","TBD"); //매장별 출고전표를 새로 채번시킨다. 
            
            String qryMstRun = bindVAR(qryMst,INVAR);
            OUTVAR.put("qryMstRun#"+j,qryMstRun);    
            qryRun += qryMstRun + "\n"; 
	        JSONObject rst = executeSVC(conn, qryRun); 
	  
	        if(!"OK".equals(getVal(rst,"rtnCd"))) {
	            conn.rollback();
	            rtnCode = getVal(rst,"rtnCd"); 
	            rtnMsg  = getVal(rst,"rtnMsg"); 
	        } else {  
	            String lg_ord_no = getVal(rst,"rtnMsg"); 
	            JSONArray arrList = getArray(INVAR,"arr");
	            int seq = 0;
	            String qryRunn = "";
	            
	            //상품LOOP
	            for(int i = 0; i < arrList.size(); i++) { 
	                JSONObject row = getRow(arrList,i);  
					if(getVal(row, "shopcd").equals(getVal(roww,"shopcd")) && !"".equals(getVal(row, "qty")) && !"0".equals(getVal(row, "qty")) ){ // && getVal(row, "qty") != null 
					    ///////////////////////////
						row.put("comcd",ORGCD); 
		                row.put("usid",USERID);
		                row.put("lg_ord_no",lg_ord_no);
		                row.put("lg_ord_seq",(++seq));
		                row.put("crud",getVal(INVAR,"crud"));
		                row.put("from_whcd", getVal(INVAR,"from_whcd"));
		                row.put("lg_tp", getVal(INVAR,"lg_tp"));
		                row.put("pack_tp",getVal(INVAR,"pack_tp"));
		                row.put("box_keycd",getVal(INVAR,"box_keycd"));
		                String qryDetRun = bindVAR(qryDet,row);
		                OUTVAR.put("qryDetRun#"+i,qryDetRun);    
		                qryRunn += qryDetRun + "\n"; 
					} //if 
				} // end of for 상품LOOP
				
				if(!"".equals(qryRunn)) {
    	            rst = executeSVC(conn, qryRunn);  
    	            if(!"OK".equals(getVal(rst,"rtnCd"))) {
    	                conn.rollback();
    	                rtnCode = getVal(rst,"rtnCd"); 
    	                rtnMsg  = getVal(rst,"rtnMsg"); 
    	            } else { 
    	                OUTVAR.put("lg_ord_no",lg_ord_no);
    	                conn.commit();
    	            } 
	            } 
	        } 
        } //end of for 매장Loop
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}
*/

//searchGoods
if("searchGoods".equals(func)) {
    Connection conn = null; 
    try {  
        INVAR.put("comcd",ORGCD);
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "searchGoods"); 
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