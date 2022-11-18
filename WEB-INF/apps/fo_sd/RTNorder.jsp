<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_sd";
String pgmid   = "RTNorder"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/

/* 상품검색 ***************************************************************************************/
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
        OUTVAR.put("checkBarcd",qryRun);
        JSONObject rst = executeSVC(conn, qryRun);  
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd");
            rtnMsg = getVal(rst,"rtnMsg");
        } else { 
            conn.commit();
            String goods_cd = getVal(rst,"rtnMsg");  //barcd에 대한 godos_cd가 있으므로 상품정보를 조회하여 Return한다.
            qry = getQuery(pgmid,"goodsSearch"); 
            INVAR.put("goods_cd",goods_cd);
            qryRun = bindVAR(qry,INVAR); 
            OUTVAR.put("goodsSearch",qryRun);
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

/* 상품검색2 ***************************************************************************************/
if("goodsSearch2".equals(func)) {
    Connection conn = null; 
    try {
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        //INVAR barcds, shopcd
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        
        JSONArray barcds = (JSONArray)INVAR.get("barcds");
        
        String qry = getQuery(pgmid, "checkBarcd"); 
        JSONArray goods_cds = new JSONArray();
        for(int i=0; i < barcds.size(); i++) {
            JSONObject row = new JSONObject();
            row.put("barcd", (String)barcds.get(i)); 
            INVAR.put("barcd", (String)barcds.get(i));
            String qryRun = bindVAR(qry,INVAR);
            JSONObject rst = executeSVC(conn, qryRun); 
            if(!"OK".equals(getVal(rst,"rtnCd"))) {
                conn.rollback();
                row.put("checkBarcd","ERR");             
                row.put("goods_cd",(String)barcds.get(i));               
                row.put("goods_nm",getVal(rst,"rtnMsg"));             
            } else { 
                conn.commit();
                row.put("checkBarcd","OK");             
                row.put("goods_cd",getVal(rst,"rtnMsg"));                
            }    
            goods_cds.add(row); //row = {barcd, goods_cd, goods_nm, checkBarcd}
        }
        JSONArray list = new JSONArray();
        qry = getQuery(pgmid,"goodsSearch");
        
        for(int j=0; j < goods_cds.size(); j++) {
            JSONObject row = getRow(goods_cds,j);
            if("OK".equals(getVal(row,"checkBarcd"))) {
                INVAR.put("goods_cd", getVal(row,"goods_cd")); //barcd에 대한 godos_cd가 있으므로 상품정보를 조회하여 Return한다. 
                String qryRun = bindVAR(qry,INVAR); 
                JSONArray list2 = selectSVC(conn,qryRun);
                if(list2.size() > 0) {
                    JSONObject rtn = getRow(list2,0); 
                    row.put("init_price",getVal(rtn,"init_price"));
                    row.put("sale_price",getVal(rtn,"sale_price"));
                    row.put("goods_nm",getVal(rtn,"goods_nm"));
                    row.put("goods_cd",getVal(rtn,"goods_cd"));
                } else if (list2.size() == 0) {
                    row.put("init_price",null);
                    row.put("sale_price",null);
                    row.put("goods_nm","상품정보 없음"); 
                }
            } else {
                row.put("init_price",null);
                row.put("sale_price",null); 
            }
            list.add(row); 
        }  
        //OUTVAR.put("barcds",barcds);
        //OUTVAR.put("goods_cds",goods_cds);
        OUTVAR.put("list",list);
        
    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
} 
 
//search:조회 이벤트처리(DB_Read)     
if("search".equals(func)) {
    Connection conn = null; 
    try {  
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "qrysearch"); 
        INVAR.put("comcd",ORGCD);
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


//searchOrd: 조회 이벤트처리(DB_Read)     
if("searchOrd".equals(func)) {
    Connection conn = null; 
    try {  
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        String qry = getQuery(pgmid, "qrysearchMst"); 
        INVAR.put("comcd",ORGCD);
        //INVAR.put("comcd","LFN"); //임의로 데이터 넣음 나중에 수정
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray mst = selectSVC(conn, qryRun);
        OUTVAR.put("mst",mst); 
        
        String qryD = getQuery(pgmid, "qrysearchDet"); 
        String qryRunD = bindVAR(qryD,INVAR);
        OUTVAR.put("qryRunD",qryRunD); //for debug
        JSONArray det = selectSVC(conn, qryRunD);
        OUTVAR.put("det",det);         

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}

//save:대상확정 이벤트처리(DB_Write)
if("save".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        
        INVAR.put("comcd",ORGCD);
        INVAR.put("usid",USERID);
        
        String qryMst = getQuery(pgmid, "qrysaveMst");
        String qryDet = getQuery(pgmid, "qrysaveDet");
        String qryRun = "";

        
        qryRun = bindVAR(qryMst,INVAR);  
        OUTVAR.put("qryMst",qryRun);
        JSONObject rst = executeSVC(conn, qryRun);  
        
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else {  
            String rtn_ord_no = getVal(rst,"rtnMsg"); 
            
            qryRun = "";
            JSONArray arrList = getArray(INVAR,"det");
            for(int i = 0; i < arrList.size(); i++) {
            
                JSONObject row = getRow(arrList,i); 
                row.put("comcd",ORGCD); 
                row.put("usid",USERID);
                row.put("rtn_ord_no",rtn_ord_no); 
                String qryDetRun = bindVAR(qryDet,row);
                qryRun += qryDetRun + "\n"; 
            }          
            rst = executeSVC(conn, qryRun);  
            if(!"OK".equals(getVal(rst,"rtnCd"))) {
                conn.rollback();
                rtnCode = getVal(rst,"rtnCd"); 
                rtnMsg  = getVal(rst,"rtnMsg"); 
            } else { 
                OUTVAR.put("rtn_ord_no",rtn_ord_no); 
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

//cfm:확정 이벤트처리(DB_Write)
if("cfm".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        INVAR.put("comcd",ORGCD);
        String qry = getQuery(pgmid, "qrycfm");
        qry = bindVAR(qry,INVAR);
        JSONObject rst = executeSVC(conn, qry);  
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else { 
            conn.commit();
        } 
    } catch (Exception e) {
        rtnCode = "ERR";
        rtnMsg = e.toString();
    } finally {
        closeConn(conn);
    }
}

//delete:확정 이벤트처리(DB_Write)
if("delete".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        INVAR.put("comcd",ORGCD);
        String qry = getQuery(pgmid, "qrydelete");
        qry = bindVAR(qry,INVAR);
        JSONObject rst = executeSVC(conn, qry);  
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else { 
            conn.commit();
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
