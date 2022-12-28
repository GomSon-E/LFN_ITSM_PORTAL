<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid = "workbench";
String pgmid   = "workbench"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";

try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 
/***************************************************************************************************/
if("retrieveSpec".equals(func)) { 
	Connection conn = null; 
	try {  
		OUTVAR.put("INVAR",INVAR); //for debug

		conn = getConn("LFN");  
		// 가장 최신 버전 불러오기

        String qry_pgm = "SELECT * FROM HIS_PGM WHERE pgmid = {pgmid} AND ver = (SELECT MAX(VER) FROM HIS_PGM WHERE pgmid = {pgmid})"; 
        qry_pgm = bindVAR(qry_pgm,INVAR);
        JSONArray pgm = selectSVC(conn, qry_pgm);
        OUTVAR.put("pgm",pgm);

        String qry_pgm_func = "SELECT * FROM HIS_PGM_FUNC WHERE pgmid={pgmid} AND ver = (SELECT MAX(VER) FROM HIS_PGM WHERE pgmid = {pgmid}) ORDER BY SORT_SEQ"; 
        qry_pgm_func = bindVAR(qry_pgm_func,INVAR);
        JSONArray pgm_func = selectSVC(conn, qry_pgm_func);
        OUTVAR.put("pgm_func",pgm_func);

        String qry_pgm_data = "SELECT * FROM HIS_PGM_DATA WHERE pgmid={pgmid} AND ver = (SELECT MAX(VER) FROM HIS_PGM WHERE pgmid = {pgmid}) ORDER BY SORT_SEQ"; 
        qry_pgm_data = bindVAR(qry_pgm_data,INVAR);
        JSONArray pgm_data = selectSVC(conn, qry_pgm_data);
        OUTVAR.put("pgm_data",pgm_data);

        String qry_pgm_src = "SELECT * FROM HIS_PGM_SRC WHERE pgmid={pgmid} AND ver = (SELECT MAX(VER) FROM HIS_PGM WHERE pgmid = {pgmid}) ORDER BY SORT_SEQ"; 
        qry_pgm_src = bindVAR(qry_pgm_src,INVAR);
        JSONArray pgm_src = selectSVC(conn, qry_pgm_src);
        OUTVAR.put("pgm_src",pgm_src); 

	} catch (Exception e) {
		logger.error("workbench.retriveSpec:"+rtnCode,e);
		rtnCode = "ERR";
		rtnMsg = e.toString();			
	} finally {
		closeConn(conn);
	}  
} 
// *************************************************************************************************
else if("saveSpec".equals(func)) {
	Connection conn = null; 
	try {  
		conn = getConn("LFN");
		conn.setAutoCommit(false); 
		//INVAR = {pgm, pgm_func, pgm_data, pgm_src }
		String qry = " DECLARE lv_pgmid VARCHAR2(50) := {pgmid};";
               qry += "   lv_ver NUMBER(6,4) := 0.02; ";
               qry += "   lv_usid VARCHAR2(50) := 'admin'; ";
               qry += "   lv_dt   DATE := sysdate; ";
               qry += " BEGIN ";

		// 저장시 HIS TABLE에만 저장된다 (버전이 0.01씩 올라감)
		String qryHISPGM = "BEGIN	SELECT MAX(ver)	INTO lv_ver	FROM HIS_PGM 	WHERE pgmid = lv_pgmid;	EXCEPTION WHEN OTHERS THEN	lv_ver := 0.00;  SELECT  reg_usid, reg_dt	INTO lv_usid, lv_dt FROM HIS_PGM 	WHERE pgmid = lv_pgmid; END;";
			qryHISPGM += "INSERT INTO HIS_PGM ( pgmid, ver, app_pgmid, pgm_grp_nm, pgm_nm, pgm_tp, proc_mst_id, pgm_stat, remark, shortcut, sort_seq, reg_dt, reg_usid, upd_dt, upd_usid ) VALUES (  {pgmid}, lv_ver+0.01, {app_pgmid}, {pgm_grp_nm}, {pgm_nm}, {pgm_tp}, {proc_mst_id}, {pgm_stat}, {remark}, {shortcut}, {sort_seq}, TO_DATE({reg_dt},'yyyy-MM-dd HH24:mi:ss'), {reg_usid}, sysdate, {usid} );";
		String qryHISPGMFUNC = "INSERT into HIS_PGM_FUNC (  pgmid, funcid, content, func_icon, func_nm, func_tp, remark, sort_seq, ver ) VALUES (  lv_pgmid, {funcid}, {content}, {func_icon}, {func_nm}, {func_tp}, {remark}, {sort_seq}, lv_ver+0.01 );";
		String qryHISPGMDATA = "INSERT into HIS_PGM_DATA (  pgmid, data_id, component_option, component_pgmid, data_icon, data_nm, inout_tp, sort_seq, ver ) VALUES (  lv_pgmid, {data_id}, {component_option}, {component_pgmid}, {data_icon}, {data_nm}, {inout_tp}, {sort_seq}, lv_ver+0.01 );";
		String qryHISPGMSRC = "INSERT into HIS_PGM_SRC (  pgmid, srcid, src_tp, src_nm, sort_seq, t_id, func_tp, ver ) VALUES (  lv_pgmid, {srcid}, {src_tp}, {src_nm}, {sort_seq}, {t_id}, {func_tp}, lv_ver+0.01 );"; 
		String qryTPGM = "UPDATE T_PGM SET ver = lv_ver+0.01 , upd_dt = sysdate, upd_usid = {usid} WHERE pgmid = lv_pgmid;";


		JSONObject mHISPGM = getRow(getArray(INVAR,"pgm"),0);
    	mHISPGM.put("usid",USERID);
        qry = bindVAR(qry,mHISPGM) + "\n\n";    
		qry += bindVAR(qryHISPGM, mHISPGM) + "\n\n";
		qry += bindVAR(qryTPGM, mHISPGM) + "\n\n";    

        JSONArray pgm_func = getArray(INVAR,"pgm_func");
		for(int i = 0; i < pgm_func.size(); i++) {
			JSONObject mHISPGMFUNC = getRow(pgm_func,i); 
			qry += bindVAR(qryHISPGMFUNC,mHISPGMFUNC) + "\n";
		}
		qry += "\n\n";

        JSONArray pgm_data = getArray(INVAR,"pgm_data");
		for(int i = 0; i < pgm_data.size(); i++) {
			JSONObject mHISPGMDATA = getRow(pgm_data,i); 
			qry += bindVAR(qryHISPGMDATA,mHISPGMDATA) + "\n";
		}
		qry += "\n\n";

        JSONArray pgm_src = getArray(INVAR,"pgm_src");
		for(int i = 0; i < pgm_src.size(); i++) {
			JSONObject mHISPGMSRC = getRow(pgm_src,i); 
			qry += bindVAR(qryHISPGMSRC,mHISPGMSRC) + "\n";
		} 
        qry += "END;";      
		OUTVAR.put("qry",qry);

		JSONObject rst = executeSVC(conn, qry); 
		//System.out.println("97: executeSVC(conn, qry) ");
		 
		if(!"OK".equals(getVal(rst,"rtnCd"))) {
			conn.rollback();
			rtnCode = getVal(rst,"rtnCd"); 
			rtnMsg  = getVal(rst,"rtnMsg");
			//System.out.println("rollback finished");
		} else { 
			System.out.println("105: updateClob");
			boolean bRst = true;
			for(int i = 0; i < pgm_data.size(); i++) {
				//executeUpldateClob(conn,String tbl,String clobCol, String clobData, String where) 
				JSONObject row = getRow(pgm_data,i);
				rtnMsg = executeUpdateClob(conn, 
						                     "HIS_PGM_DATA",
						                     "content",
						                     getVal(row,"content"),
						                     "WHERE pgmid='"+getVal(mHISPGM,"pgmid")+"' AND data_id='"+getVal(row,"data_id")+"' AND ver=(SELECT MAX(VER) FROM HIS_PGM WHERE pgmid = '"+getVal(mHISPGM,"pgmid")+"')");

				if(!"OK".equals(rtnMsg)) {
					rtnCode = "-8888";
					bRst = false;
					break;
				} 
				//System.out.println("data_content row #"+i+" clob updated! :"+getVal(row,"data_id")+":"+getVal(row,"content"));
			}
			if(bRst) {
				for(int i = 0; i < pgm_src.size(); i++) {
					//executeUpldateClob(conn,String tbl,String clobCol, String clobData, String where) 
					JSONObject row = getRow(pgm_src,i);
					rtnMsg = executeUpdateClob(conn, 
												"HIS_PGM_SRC",
												"content",
												getVal(row,"content"),
												"WHERE pgmid='"+getVal(mHISPGM,"pgmid")+"' AND srcid='"+getVal(row,"srcid")+"' AND ver=(SELECT MAX(VER) FROM HIS_PGM WHERE pgmid = '"+getVal(mHISPGM,"pgmid")+"')");
					if(!"OK".equals(rtnMsg)) {
						rtnCode = "-8888";
						bRst = false;
						break;
					} 
					//System.out.println("src_content row #"+i+" clob updated! :"+getVal(row,"srcid")+":"+getVal(row,"content"));
				}
			}

			if (bRst) {
				conn.commit();
			} else { 
				conn.rollback();
			}  
			System.out.println("clob works finished");
		} 
	} catch (Exception e) {
		logger.error("workbench.saveSpec:"+rtnCode,e);
		rtnCode = "ERR";
		rtnMsg = e.toString();				
	} finally {
		closeConn(conn);
	} 
}

else if("removeSrc".equals(func)) {
	Connection conn = null; 
	try {  
		conn = getConn("LFN");
		conn.setAutoCommit(false); 
		String qry = " DELETE FROM T_PGM_SRC WHERE pgmid={pgmid} AND srcid={srcid};";   
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
		logger.error("workbench.removeSrc:"+rtnCode,e);
		rtnCode = "ERR";
		rtnMsg = e.toString();				
	} finally {
		closeConn(conn);
	} 
}

//***********************************************************************************************/
else if("saveFile".equals(func)){
	try {  	
		String rootDir = application.getRealPath("/");
		// System.out.println(rootDir);  //C:\LFN\workspace\lfn_ep\
		String app_pgmid = getVal(INVAR,"appid");
		String _pgmid = getVal(INVAR,"pgmid");
		String ver = getVal(INVAR,"ver");
		
		String sPathHTML = rootDir+"qas"+FILESL+app_pgmid+FILESL;   // FILESL = "\\"
		// System.out.println(sPathHTML);
		File pathHTML = new File(sPathHTML);
		if (!pathHTML.exists()) {
			pathHTML.mkdirs();
			pathHTML.setReadable(true,false);
			pathHTML.setExecutable(true);
		}
		File fileHTML = new File(sPathHTML+_pgmid+".html");
		if (fileHTML.exists()) fileHTML.delete();
		if (!fileHTML.exists()) {
			fileHTML.createNewFile();
			Writer fw = null;
			fw = new OutputStreamWriter(new FileOutputStream(sPathHTML+_pgmid+".html"), StandardCharsets.UTF_8);
			fw.write( getVal(INVAR,"html") ); 
			fw.close(); 
			fileHTML.setReadable(true,false);
		}  

		String sPathJSP = rootDir+"WEB-INF"+FILESL+"qas"+FILESL+app_pgmid+FILESL;   // FILESL = "\\"
		//System.out.println(sPathJSP);
		File pathJSP = new File(sPathJSP);
		if (!pathJSP.exists()) {
			pathJSP.mkdirs();
			pathJSP.setReadable(true,false);
			pathJSP.setExecutable(true);
		}
		File fileJSP = new File(sPathJSP+_pgmid+".jsp");
		if (fileJSP.exists()) fileJSP.delete();
		if (!fileJSP.exists()) {
			fileJSP.createNewFile();
			Writer fw = null;
			fw = new OutputStreamWriter(new FileOutputStream(sPathJSP+_pgmid+".jsp"), StandardCharsets.UTF_8);
			fw.write( getVal(INVAR,"jsp") ); 
			fw.close(); 
			fileJSP.setReadable(true,false); 
		}   
	} catch (Exception e) { 
		rtnCode = "ERR";
		rtnMsg = e.toString();				
	} 
}
else if("deploySpec".equals(func)) {
	Connection conn = null; 
	try {  
		conn = getConn("LFN");
		conn.setAutoCommit(false);

		String qry = " DECLARE lv_pgmid VARCHAR2(50) := {pgmid};";
               qry += "   lv_ver NUMBER(6,4) := 0.00; ";
               qry += " BEGIN ";
			   qry += "DELETE FROM T_PGM_FUNC WHERE pgmid = lv_pgmid;	DELETE FROM T_PGM_DATA WHERE pgmid = lv_pgmid;	DELETE FROM T_PGM_SRC  WHERE pgmid = lv_pgmid;";

		qry += "INSERT INTO T_PGM_FUNC (  pgmid, funcid, content, func_icon, func_nm, func_tp, remark, sort_seq ) SELECT pgmid, funcid, content, func_icon, func_nm, func_tp, remark, sort_seq FROM HIS_PGM_FUNC WHERE pgmid=lv_pgmid AND ver = (SELECT MAX(VER) FROM HIS_PGM WHERE pgmid = lv_pgmid);";
		qry += "INSERT INTO T_PGM_DATA (  pgmid, data_id, component_option, component_pgmid, data_icon, data_nm, inout_tp, sort_seq, content ) SELECT pgmid, data_id, component_option, component_pgmid, data_icon, data_nm, inout_tp, sort_seq, content FROM HIS_PGM_DATA WHERE pgmid=lv_pgmid AND ver = (SELECT MAX(VER) FROM HIS_PGM WHERE pgmid=lv_pgmid);";
		qry += "INSERT INTO T_PGM_SRC (  pgmid, srcid, src_tp, src_nm, content, sort_seq, t_id, func_tp ) SELECT pgmid, srcid, src_tp, src_nm, content, sort_seq, t_id, func_tp FROM HIS_PGM_SRC WHERE pgmid=lv_pgmid AND ver = (SELECT MAX(VER) FROM HIS_PGM WHERE pgmid=lv_pgmid);"; 

		qry = bindVAR(qry, INVAR);
        qry += " END;";      
		OUTVAR.put("qry",qry);
		JSONObject rst = executeSVC(conn, qry);
		if(!"OK".equals(getVal(rst,"rtnCd"))) {
			conn.rollback();
			rtnCode = getVal(rst,"rtnCd"); 
			rtnMsg  = getVal(rst,"rtnMsg");
		}else {
			conn.commit();
		}
	} catch (Exception e) {
		logger.error("workbench.deploySpec:"+rtnCode,e);
		rtnCode = "ERR";
		rtnMsg = e.toString();			
	} finally {
		closeConn(conn);
	} 
}
else if("deployFile".equals(func)) { 
	
	try {  		
		String rootDir = application.getRealPath("/");
		// System.out.println(rootDir);  //C:\LFN\workspace\lfn_ep\
		String app_pgmid = getVal(INVAR,"appid");
		String _pgmid = getVal(INVAR,"pgmid");
		String ver = getVal(INVAR,"ver");

		String sPathHTML = rootDir+"apps"+FILESL+app_pgmid+FILESL;   // FILESL = "\\"
		// System.out.println(sPathHTML);
		File pathHTML = new File(sPathHTML);
		if (!pathHTML.exists()) {
			pathHTML.mkdirs();
			pathHTML.setReadable(true,false);
			pathHTML.setExecutable(true);
		}
		File fileHTML = new File(sPathHTML+_pgmid+".html");
		if (fileHTML.exists()) fileHTML.delete();
		if (!fileHTML.exists()) {
			fileHTML.createNewFile();
			Writer fw = null;
			fw = new OutputStreamWriter(new FileOutputStream(sPathHTML+_pgmid+".html"), StandardCharsets.UTF_8);
			fw.write( getVal(INVAR,"html") ); 
			fw.close(); 
			fileHTML.setReadable(true,false);
		}  

		String sPathJSP = rootDir+"WEB-INF"+FILESL+"apps"+FILESL+app_pgmid+FILESL;   // FILESL = "\\"
		//System.out.println(sPathJSP);
		File pathJSP = new File(sPathJSP);
		if (!pathJSP.exists()) {
			pathJSP.mkdirs();
			pathJSP.setReadable(true,false);
			pathJSP.setExecutable(true);
		}
		File fileJSP = new File(sPathJSP+_pgmid+".jsp");
		if (fileJSP.exists()) fileJSP.delete();
		if (!fileJSP.exists()) {
			fileJSP.createNewFile();
			Writer fw = null;
			fw = new OutputStreamWriter(new FileOutputStream(sPathJSP+_pgmid+".jsp"), StandardCharsets.UTF_8);
			fw.write( getVal(INVAR,"jsp") ); 
			fw.close(); 
			fileJSP.setReadable(true,false); 
		}   
	} catch (Exception e) { 
		rtnCode = "ERR";
		rtnMsg = e.toString();				
	} 
} 
if("migrate".equals(func)) {
    Connection conn = null;
    Connection connProd = null; 
    try {  
        conn = getConn("LFN");
        connProd = getConn("LFFODB");
        conn.setAutoCommit(false); //DDL문 실행이라 자동커밋됨! 데이터 복사시 커밋처리용 
        connProd.setAutoCommit(false); //DDL문 실행이라 자동커밋됨! 데이터 복사시 커밋처리용 
        
        String _pgmid = getVal(INVAR,"pgmid"); 

        //운영에 기존테이블이 존재하지 않으면 오류 
        String qry1 = "DELETE FROM T_PGM WHERE pgmid='"+_pgmid+"'; \n";
        String qry2 = "DELETE FROM T_PGM_FUNC WHERE pgmid='"+_pgmid+"'; \n";
        String qry3 = "DELETE FROM T_PGM_DATA WHERE pgmid='"+_pgmid+"'; \n";
        String qry4 = "DELETE FROM T_PGM_SRC WHERE pgmid='"+_pgmid+"'; \n";
        String qry5 = "DELETE FROM T_PGM_AUTH WHERE pgmid='"+_pgmid+"'; \n";
        String qryDel = qry1 + qry2 + qry3 + qry4 + qry5; 
        JSONObject rst = executeSVC(connProd,qryDel); //connProd! 
        if(!"OK".equals(getVal(rst,"rtnCd"))) { 
            connProd.rollback();
            rtnCode = getVal(rst,"rtnCd"); 
            rtnMsg  = getVal(rst,"rtnMsg"); 
        } else {
            connProd.commit();
            //운영 백업테이블 생성
            String copy1 = "INSERT INTO T_PGM@LFFODB SELECT * FROM T_PGM WHERE pgmid='"+_pgmid+"'; ";
            String copy2 = "INSERT INTO T_PGM_FUNC@LFFODB SELECT * FROM T_PGM_FUNC WHERE pgmid='"+_pgmid+"'; ";
            String copy3 = "INSERT INTO T_PGM_DATA@LFFODB SELECT * FROM T_PGM_DATA WHERE pgmid='"+_pgmid+"'; ";
            String copy4 = "INSERT INTO T_PGM_SRC@LFFODB SELECT * FROM T_PGM_SRC WHERE pgmid='"+_pgmid+"'; ";
            String copy5 = "INSERT INTO T_PGM_AUTH@LFFODB SELECT * FROM T_PGM_AUTH WHERE pgmid='"+_pgmid+"'; ";
            String qryCopy = copy1 + copy2 + copy3 + copy4 + copy5;
            rst = executeSVC(conn, qryCopy);  //conn
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
        closeConn(connProd);
    }
}
if("revert".equals(func)) { 
	Connection conn = null; 
	try {  
		OUTVAR.put("INVAR",INVAR); //for debug

		conn = getConn("LFN");  
        String qry_pgm = "SELECT * FROM HIS_PGM WHERE pgmid={pgmid} and ver={ver}"; 
        qry_pgm = bindVAR(qry_pgm,INVAR);
        JSONArray pgm = selectSVC(conn, qry_pgm);
        OUTVAR.put("pgm",pgm);

        String qry_pgm_func = "SELECT * FROM HIS_PGM_FUNC WHERE pgmid={pgmid} and ver={ver} ORDER BY SORT_SEQ"; 
        qry_pgm_func = bindVAR(qry_pgm_func,INVAR);
        JSONArray pgm_func = selectSVC(conn, qry_pgm_func);
        OUTVAR.put("pgm_func",pgm_func);

        String qry_pgm_data = "SELECT * FROM HIS_PGM_DATA WHERE pgmid={pgmid} and ver={ver} ORDER BY SORT_SEQ"; 
        qry_pgm_data = bindVAR(qry_pgm_data,INVAR);
        JSONArray pgm_data = selectSVC(conn, qry_pgm_data);
        OUTVAR.put("pgm_data",pgm_data);

        String qry_pgm_src = "SELECT * FROM HIS_PGM_SRC WHERE pgmid={pgmid} and ver={ver} ORDER BY SORT_SEQ"; 
        qry_pgm_src = bindVAR(qry_pgm_src,INVAR);
        JSONArray pgm_src = selectSVC(conn, qry_pgm_src);
        OUTVAR.put("pgm_src",pgm_src); 

	} catch (Exception e) {
		logger.error("workbench.retriveSpec:"+rtnCode,e);
		rtnCode = "ERR";
		rtnMsg = e.toString();				
	} finally {
		closeConn(conn);
	}  
} 

/*
// *************************************************************************************************
else if("domLoader".equals(func)) {
	Connection conn = null; 
	try {   
		conn = getConn("COMMON");	
		INVAR.put("pgmid","workbench");	
		INVAR.put("contenttype","domLoader");
		String res = getVal(selectSVC(conn, "pgm", "retrieveTPGMCONTENT", INVAR),0,"content");
        res = res.replace("{pageid}", pageid);
		OUTVAR.put("res", res ); 
	} catch (Exception e) {
		logger.error("workbench.domLoader:"+rtnCode,e);
		rtnCode = "ERR";
		rtnMsg = e.toString();				
	} finally {
		closeConn(conn);
	} 
}

// *************************************************************************************************
else if("deployJSP".equals(func)) {
	Connection conn = null; 
	try {   
		conn = getConn("COMMON");	
		INVAR.put("pgmid","workbench");	
		INVAR.put("contenttype","deployJSP");
		String res = getVal(selectSVC(conn, "pgm", "retrieveTPGMCONTENT", INVAR),0,"content");
        res = res.replace("{pageid}", pageid);
        res = res.replace("{module}", getVal(INVAR,"module"));
        res = res.replace("{jspid}", getVal(INVAR,"jspid")); 
		OUTVAR.put("res", res ); 
	} catch (Exception e) {
		logger.error("workbench.domLoader:"+rtnCode,e);
		rtnCode = "ERR";
		rtnMsg = e.toString();				
	} finally {
		closeConn(conn);
	} 
}
// ******************************************************************************************************************
else if ("deployJSPFileSave".equals(func)) { //upload로 올라오면 처리해준 다음 화면을 초기화 한다.
	Writer fw = null;
    BufferedWriter fwo = null;
    String rtn = "OK";
	try {   
			String saveDir = "D:\\ONLINEADMIN\\www\\awe\\WEB-INF\\src"; //"C:\\awe\\workspace\\ep\\WebContent\\WEB-INF\\src";//application.getRealPath("WEB-INF/src"); //일단 src경로에 받는다.  
			//savDir
		    int maxSize = 1024*1024*100; //최대 100MB
			String encType = "utf-8";   
			MultipartRequest multi = new MultipartRequest(request, saveDir, maxSize, encType, new DefaultFileRenamePolicy());
			String module = nvl(multi.getParameter("module"),"trash");  
			String jspid  = nvl(multi.getParameter("jspid"),"trash");  
			String src  = nvl(multi.getParameter("src"),"-none-");  
			String filename = jspid+".jsp";  
			
			if (!"".equals(filename)) { 
				//저장경로 확인하여 생성
				String sNewpath = saveDir+FILESL+module+FILESL;  
				File newpath = new File(sNewpath);
			    if (!newpath.exists()) {
			    	newpath.mkdirs();
			    }
			    String fullpath = sNewpath + filename; 

				File newfile = new File(fullpath); 
			    newfile.createNewFile();
			    fw = new OutputStreamWriter(new FileOutputStream(fullpath), StandardCharsets.UTF_8);
			    fw.write(src); 
			    fw.close(); 
			}    
	} catch (Exception e) {
		logger.error("deployJSPFileSave",e);
		rtn = e.toString();
	} finally {
		if(fw != null) fw.close();
	}
%><script>alert("파일저장:<%= rtn %>");</script><%  	
}
// ******************************************************************************************************************
else if("EditQry".equals(func)) {
	Connection conn = null; 
	try {   
		conn = getConn("COMMON");	
		INVAR.put("pgmid","workbench");	
		INVAR.put("contenttype","EditQry");
		String res = getVal(selectSVC(conn, "pgm", "retrieveTPGMCONTENT", INVAR),0,"content");
        res = res.replace("{pageid}", pageid); 
		OUTVAR.put("res", res ); 
	} catch (Exception e) {
		logger.error("workbench.domLoader:"+rtnCode,e);
		rtnCode = "ERR";
		rtnMsg = e.toString();				
	} finally {
		closeConn(conn);
	} 
}
// ******************************************************************************************************************
else if ("EditQryRun".equals(func)) { //쿼리문을 받아서 결과를 리턴한다.
	Connection conn = null; 
	try {  
		//INVAR = {qryString, dbms, cols... } 
		conn = getConn(getVal(INVAR,"dbms")); 
		INVAR.put("userid",USERID);
		String qry = getVal(INVAR,"qryString");
		qry = bindVAR(qry,INVAR);  
		OUTVAR.put("rst",selectSVCWithColOrder(conn, qry));
		
	} catch (Exception e) {
		logger.error("workbench.EditQryRun:"+rtnCode,e);
		rtnCode = "ERR";
		rtnMsg = e.toString();				
	} finally {
		closeConn(conn);
	}  
}    
// ******************************************************************************************
else if ("RunExec".equals(func)) { //쿼리문을 받아서 결과를 리턴한다.
    Connection conn = null; 
	try {   
		conn = getConn("COMMON");	
		INVAR.put("pgmid","workbench");	
		INVAR.put("contenttype","RunExec");
		String res = getVal(selectSVC(conn, "pgm", "retrieveTPGMCONTENT", INVAR),0,"content");
        res = res.replace("{pageid}", pageid); 
		OUTVAR.put("res", res ); 
	} catch (Exception e) {
		logger.error("workbench.domLoader:"+rtnCode,e);
		rtnCode = "ERR";
		rtnMsg = e.toString();				
	} finally {
		closeConn(conn);
	} 
}    
// ***********************************************************************************************
else if ("RunExecRun".equals(func)) { //쿼리문을 받아서 결과를 리턴한다.
	Connection conn = null; 
	try {  
		//INVAR = {qryString, dbms, cols... } 
		conn = getConn(getVal(INVAR,"dbms")); 
		conn.setAutoCommit(false); 
		
		INVAR.put("userid",USERID);
		String qry = getVal(INVAR,"qryString"); 
		qry = bindVAR(qry,INVAR);  
		JSONObject rst = executeSVC(conn, qry);

		rtnCode = getVal(rst,"rtnCd"); 
		rtnMsg  = getVal(rst,"rtnMsg");
		 
		if(!"OK".equals(getVal(rst,"rtnCd"))) {
			conn.rollback();
		} else {
			conn.commit();
		}
		
	} catch (Exception e) {
		logger.error("workbench.EditQryRun:"+rtnCode,e);
		rtnCode = "ERR";
		rtnMsg = e.toString();				
	} finally {
		closeConn(conn);
	}  
}    
// *********************************************************************************************
else if("AddQuot".equals(func)) {
	Connection conn = null; 
	try {   
		conn = getConn("COMMON");	
		INVAR.put("pgmid","workbench");	
		INVAR.put("contenttype","AddQuot");
		String res = getVal(selectSVC(conn, "pgm", "retrieveTPGMCONTENT", INVAR),0,"content");
        res = res.replace("{pageid}", pageid); 
		OUTVAR.put("res", res ); 
	} catch (Exception e) {
		logger.error("workbench.domLoader:"+rtnCode,e);
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