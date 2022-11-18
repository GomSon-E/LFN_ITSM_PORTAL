<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" 
    import="java.net.*" %> 
<%  
//if (!aweCheck(session)) return;   

JSONObject OUTVAR = new JSONObject(); 
String appid   = "api";
String pgmid   = "order_accept"; 
String func  = request.getParameter("func"); 
String rtnCode    = "OK";
String rtnMsg     = "";
Boolean success = true;
int     code    = 200;
String  message  = "";
try { 
String invar = request.getParameter("INVAR");
JSONObject INVAR  = getObject(invar); 

/***************************************************************************************************/
/* 발송대상건을 조회하여 접수여부를 회신하고 상태를 업데이트 함 */
/***************************************************************************************************/
if("send".equals(func)) {
    Connection conn = null; 
    JSONObject body          = new JSONObject();
    JSONObject userinfo      = new JSONObject(); 
    
    String sUrl = request.getParameter("url");
	String enc = request.getParameter("enc"); 
	InputStreamReader isr = null;
	BufferedReader bin = null;
	
    try {  
        INVAR.put("comcd","LFN");
        conn = getConn("LFN");  
        conn.setAutoCommit(false);
        
        String qry     = getQuery(pgmid,"qryselect");
        String qryRun = "";
        String itemlist = "";
        JSONArray arrItemlist = getArray(INVAR,"list"); 
        for(int k=0;k<arrItemlist.size();k++){
            JSONObject row = getRow(arrItemlist,k);
            String market_idx = getVal(arrItemlist,k,"market_idx");
            String basket_idx = getVal(arrItemlist,k,"basket_idx");
            OUTVAR.put("market_idx",market_idx);
            OUTVAR.put("basket_idx",basket_idx);
            itemlist += "('" + market_idx + "'" + ","+ "'" + basket_idx + "')" + ",";
            /* MOV_YN이 O(고객직송) 이면 매장명 INVAR에 전송
            if('O'.equals(getVal(arrItemlist,k,"mov_yn"))){
                INVAR.put("rt_shop",getVal(arrItemlist,k,"rt_shop"));
            }
            */
        };
        itemlist = itemlist.replaceFirst(".$","");
        OUTVAR.put("itemlist",itemlist);
        INVAR.put("itemlist",itemlist);
        qryRun = bindVAR(qry,INVAR);
        JSONArray arrList = selectSVC(conn, qryRun);
        OUTVAR.put("qryRun",qryRun);
        OUTVAR.put("arrList",arrList);
        //if(arrList.size() > 0) {
            //전송한 후 
            if(isNull(sUrl)) sUrl = "https://square.bizhost.kr/bizhost_api/v1/lf_factory.php?apicode=order_accept";
		    if(isNull(enc)) enc = "UTF-8"; 
            URL url = new URL(sUrl);
		    HttpURLConnection huc = (HttpURLConnection)url.openConnection();
		    huc.setRequestMethod("POST");  
            huc.setRequestProperty("Accept", "application/vnd.tosslab.jandi-v2+json");
            huc.setRequestProperty("Content-Type", "application/json");  
            huc.setRequestProperty("Cache-Control","no-cache");  // 컨트롤 캐쉬 설정 
            huc.setRequestProperty("Content-Length", "length");  // 타입길이 설정(Request Body 전달시 Data Type의 길이를 정함.) 
            huc.setRequestProperty("User-Agent", "LFN_EP");        // User-Agent 값 설정 
            huc.setDoOutput(true); // OutputStream으로 POST 데이터를 넘겨주겠다는 옵션. 
            huc.setDoInput(true); // InputStream으로 서버로 부터 응답을 받겠다는 옵션. 
            OutputStream os = huc.getOutputStream(); // Request Body에 Data를 담기위해 OutputStream 객체를 생성.    
            
            userinfo.put("key","JIGHe-V6De0-VsHYn-a6xd6-BzDe4");
            body.put("userinfo",userinfo);
            body.put("ar_order_info",arrList);
            os.write(body.toString().getBytes("UTF-8")); //body.getBytes("UTF-8")  
            os.flush(); // Request Body에 Data 입력. 
            os.close(); // OutputStream 종료.     
        
            int responseCode = huc.getResponseCode();  //실제 서버로 Request 요청 하는 부분. (응답 코드를 받는다. 200 성공, 나머지 에러) 
            bin = new BufferedReader(new InputStreamReader(huc.getInputStream(), "UTF-8")); 
            StringBuffer sb = new StringBuffer(); 
            String temp = "";
            while ((temp = bin.readLine()) != null) {
                sb.append(temp);
            }
            
		    //isr = new InputStreamReader( huc.getInputStream(), enc ); 
		    //bin = new BufferedReader(isr);
		    //StringBuffer sb = new StringBuffer();
		    //int i;
		    //while((i=isr.read())!=-1){ 
			    //sb.append((char)i);  
		    //} 
		    //OUTVAR.put( rtn, sb ); 
            
        
        
        
        
        
        
        
        String sOUTVAR = sb.toString();
        OUTVAR.put("REQUSETVAL", body);
        OUTVAR.put("RESPONSECODE",responseCode);
        OUTVAR.put("RETURNVAL",sOUTVAR);
        OUTVAR.put("os",os);
        //JSONParser parser = new JSONParser();
        //OUTVAR = (JsonArray) parser.parse(sOUTVAR);  
        //OUTVAR.put("rtnCd", responseCode); 
        //OUTVAR.put("INVAR", INVAR);
            
        //결과 업데이트  
        String qry2 = getQuery(pgmid, "qryupdate");
        String qryRun2 = ""; 
        int txCnt = 0;  
        int oneTx = 50;
        JSONObject rst = new JSONObject();
        rst.put("rtnCd","OK");
        for(int j = 0; j < arrList.size(); j++) {
            JSONObject row = getRow(arrList,j); 
            row.put("comcd","LFN");
            row.put("usid","order_accept"); 
            qryRun2 += bindVAR(qry2,row) + "\n";
            if(txCnt > oneTx) { 
                rst = executeSVC(conn, qryRun2);  
                qryRun2="";
                if(!"OK".equals(getVal(rst,"rtnCd"))) break;
                txCnt = 0;
            } else {
                txCnt++;
            }
        } 
            if(!"".equals(qryRun2)) rst = executeSVC(conn, qryRun2);      
            OUTVAR.put("qryRun2",qryRun2); 
        
        /******************************************/
        if(!"OK".equals(getVal(rst,"rtnCd"))) {
            conn.rollback();
            success = false;
            code    = 207;
            message = getVal(rst,"rtnMsg");
        } else {  
            message = arrList.size()+" record(s) received successfully";
            conn.commit();
        }  
        //}

    } catch (Exception e) { 
        success = false;
        code    = 208;
        message = e.toString();
			
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