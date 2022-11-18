<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "fo_lg";
String pgmid   = "popupMakePack"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/
//search: 상품목록조회
if("search".equals(func)) {
    Connection conn = null; 
    try {  
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        INVAR.put("comcd",ORGCD);
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


//selectBoxSeq: 순번(채번)
if("selectBoxSeq".equals(func)) {
    Connection conn = null; 
    try {  
        OUTVAR.put("INVAR",INVAR); //for debug
        conn = getConn("LFN");  
        INVAR.put("comcd",ORGCD);
        String qry = getQuery(pgmid, "selectBoxSeq"); 
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray boxseq = selectSVC(conn, qryRun);
        OUTVAR.put("boxseq",boxseq);         

    } catch (Exception e) { 
        rtnCode = "ERR";
        rtnMsg = e.toString();				
    } finally {
        closeConn(conn);
    }  
}



//save: 패킹정보 저장
if("save".equals(func)) {
    Connection conn = null; 
    try {  
        conn = getConn("LFN");
        conn.setAutoCommit(false);
        INVAR.put("comcd",ORGCD);
        
        String qryClear = getQuery(pgmid, "clearOrdGoods"); // insert를 위한 delete(clearOrdGoods)
        qryClear = bindVAR(qryClear,INVAR);
        JSONObject rst = executeSVC(conn, qryClear);  
        
        String qry = getQuery(pgmid, "selectBoxSeq");  
        String qryRun = bindVAR(qry,INVAR);
        OUTVAR.put("qryRun",qryRun); //for debug
        JSONArray arrBox = selectSVC(conn, qryRun);
        String box_seq = getVal(arrBox,0,"box_seq");  //채번한 순번
        INVAR.put("box_seq",box_seq);
        
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else { 
        
            String qryS = getQuery(pgmid, "savePack");
            String qryRunS = "";
            JSONArray arrList = getArray(INVAR,"list");
            String boxseq = getVal(arrList, 0, "boxseq"); //맨 처음 박스순번 1
            
            for(int i = 0; i < arrList.size(); i++) {
                JSONObject row = getRow(arrList,i); 
                
                row.put("comcd",ORGCD);
                row.put("usid",USERID);
                row.put("whcd",getVal(INVAR,"whcd"));
                row.put("to_whcd",getVal(INVAR,"to_whcd"));
                row.put("keyin",getVal(INVAR,"keyin"));
                row.put("lg_ord_no",getVal(INVAR,"lg_ord_no"));
                
                if(getVal(row, "boxseq").equals(boxseq)){
                    row.put("box_seq",box_seq); //채번한 순번을 넣어준다
                    
                }else{ //박스순번이 바뀔때 순번(채번)을 하나씩 증가 
                
                    boxseq = getVal(arrList,i,"boxseq"); //처음과 구분되는 다음 박스순번 2
                    box_seq = Integer.toString(Integer.parseInt(box_seq)+1); //(채번한 순번+1)
                    row.put("box_seq",box_seq);
                }
                
                qryRunS += bindVAR(qryS,row) + "\n";
                OUTVAR.put("qryRunS",qryRunS);
               
            } 
            rst = executeSVC(conn, qryRunS);  
            
            if(!"OK".equals(getVal(rst,"rtnCd"))) {
                conn.rollback();
                rtnCode = getVal(rst,"rtnCd"); 
                rtnMsg  = getVal(rst,"rtnMsg"); 
            } else { 
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
