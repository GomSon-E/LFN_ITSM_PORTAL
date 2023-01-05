<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "aweportal";
String pgmid   = "manageCode"; 
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
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  

        String qry = getQuery(pgmid,"retrieveGrpcd"); //T_PGM_SRC.content 
        String qryRun = bindVAR(qry,INVAR); //OUTVAR.put("qry",qry);
        JSONArray head = selectSVC(conn,qryRun);   
        OUTVAR.put("head",head); 

        String qry2 = getQuery(pgmid,"retrieveCd"); //T_PGM_SRC.content 
        qry2 = bindVAR(qry2,INVAR); //OUTVAR.put("qry",qry);
        JSONArray list = selectSVC(conn,qry2);   
        OUTVAR.put("list",list); 

    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
    } finally {
    	closeConn(conn); 
    }        
} 
else if("save".equals(func)) {
    Connection conn = null;  
    try {   
        conn = getConn("LFN");  // DB 커넥션 파라미터 세팅  
		conn.setAutoCommit(false); 
        boolean bError = false;
        
        //필요한 쿼리를 가져옴 
        String qryRun = "";
        String qryH = getQuery(pgmid,"mergeGrpcd"); //T_PGM_SRC.content 
        String qryD = getQuery(pgmid,"mergeCd"); //T_PGM_SRC.content 
        String qryDel = getQuery(pgmid,"deleteCd"); //T_PGM_SRC.content 

        //INVAR={grpcd:jsonobject, cd: jsonarray}
        JSONObject grpcd = getRow(getArray(INVAR,"grpcd"),0);
        grpcd.put("usid",USERID);
        qryRun = bindVAR(qryH,grpcd); 
        OUTVAR.put("qryRun",qryRun);
        JSONObject rst = executeSVC(conn, qryRun);
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            bError = true;
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg");
        }  
        
        if(bError==false) { 
            JSONArray cdlist = getArray(INVAR,"cd");
            int RunCnt = 0;
            qryRun = "";
            for(int i = 0; i < cdlist.size(); i++) {
                JSONObject cd = getRow(cdlist,i); 
                cd.put("grpcd", getVal(grpcd,"cd"));
                cd.put("usid",USERID);
                if("D".equals(getVal(cd,"crud"))) {
                    qryRun += bindVAR(qryDel,cd) + "\n";
                } else {
                    qryRun += bindVAR(qryD,cd) + "\n";
                }
                OUTVAR.put("RunCnt",i);
                RunCnt++;
                if(RunCnt == 10) {
                    rst = executeSVC(conn, qryRun);
                    RunCnt = 0;
                    qryRun = "";
                    if(!"OK".equals(getVal(rst,"rtnCd"))) {
                        bError = true; 
                        rtnCode = getVal(rst,"rtnCd"); 
                        rtnMsg  = getVal(rst,"rtnMsg");
                        break;
                    }  
                }
            }
            if(RunCnt > 0) {
                rst = executeSVC(conn, qryRun);
                if(!"OK".equals(getVal(rst,"rtnCd"))) {
                    bError = true; 
                    rtnCode = getVal(rst,"rtnCd"); 
                    rtnMsg  = getVal(rst,"rtnMsg");
                }  
            }
        } 
        if(bError) {
            conn.rollback();
        } else { 
            conn.commit();
        }  

    } catch(Exception e) {
    	rtnCode = "ERR";
    	rtnMsg  = e.toString();
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
