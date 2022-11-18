<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %> 
<% 
    /* retail_mst.jsp 는 포털jsp로 다음의 기능을 수행한다 
	  - 유효세션이 없는 경우 login을 로드함
	  - 유효세션이 있는 경우 home을 로드한다.
	  - SSO 바로열기인 경우(아직 미구현 5/12현재) 
	      유효세션이 없으면 ssoLogin을 통해 세션을 생성한 후 home로드 후 요청페이지를 호출한다. 
		  유효세션이 있으면 home로드 후 요청페이지를 호출한다.
	*/
	boolean bSession = false;
	ORGCD  = null;
	ORGNM  = null;
	DEPTCD = null;
	DEPTNM = null;
	USERID      = null;
	USERNM      = null;
	USERNICKNM  = null;
	MULTIORGYN = null;
	USERAUTH    = null;
	USERSESSION = null;

	if(!isNull(session.getAttribute("USERSESSION"))) {
		ORGCD      =    (String)session.getAttribute("ORGCD" );
		ORGNM      =    (String)session.getAttribute("ORGNM"  );
		DEPTCD     =    (String)session.getAttribute("DEPTCD" );
		DEPTNM     =    (String)session.getAttribute("DEPTNM" );
		USERID     =    (String)session.getAttribute("USERID" );
		USERNM     =    (String)session.getAttribute("USERNM" );
		USERNICKNM =    (String)session.getAttribute("USERNICKNM" );
		USERAUTH   =    (String)session.getAttribute("USERAUTH" );
		MULTIORGYN =    (String)session.getAttribute("MULTIORGYN"  );  
		USERSESSION =   (String)session.getAttribute("USERSESSION"  );   
		bSession = true;
	}  

	String DOCID = nvl(request.getParameter("d"), (String)session.getAttribute("DOCID"));
	session.setAttribute("DOCID", DOCID);
%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0,minimum-scale=0.5,maximum-scale=2.0,user-scalable=yes">
<meta http-equiv="X-UA-Compatible" content="IE=edge"/>
<meta name="format-detection" content="telephone=no"/>  
<title>유통MD정보관리시스템</title>
<link rel="shortcut icon" href="/images/RetailIcon.png" type="image/x-icon" />
<link rel="stylesheet" href="/lib/jquery-ui/jquery-ui-1.12.1.min.css" /> 
<link rel="stylesheet" href="/lib/agGrid/ag-grid.css">
<link rel="stylesheet" href="/lib/agGrid/ag-theme-balham.css">
<link rel="stylesheet" href="/lib/jquery-ui/select2.min.css" />
<script>
var agent = navigator.userAgent.toLowerCase();
if ( (navigator.appName == 'Netscape' && agent.indexOf('trident') != -1) || (agent.indexOf("msie") != -1)) {
	alert("MS 인터넷익스플로러(IE)은 기술적으로 보안적으로 지원하지 않습니다.\n크롬이나 엣지 등 최신브라우저에서 접속해주세요!");
}
</script>
<script type="text/javascript" src="/lib/jquery/jquery-3.6.0.min.js"></script>
<script type="text/javascript" src="/lib/jquery-ui/jquery-ui-1.12.1.min.js"></script>
<script type="text/javascript" src="/lib/jquery-ui/select2.min.js"></script>
<script type="text/javascript" src="/lib/jquery.scrollTo-2.1.3/jquery.scrollTo.js"></script> 
<script src="/lib/agGrid/ag-grid-enterprise.min.noStyle.js"></script>
<script src="https://kit.fontawesome.com/b8597271c4.js" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.3.2/chart.min.js" crossorigin="anonymous"></script>
<script src='https://cdn.tiny.cloud/1/d150u0g21azfsd5gx41u1ix2gkle25siousm8a7g6ij1z2h0/tinymce/5/tinymce.min.js' referrerpolicy="origin"></script>   
<script src="https://unpkg.com/typeit@8.3.3/dist/index.umd.js"></script>     
<!-- aceEditor-->
<script src="/lib/ace/src-min/ace.js"  type="text/javascript" charset="utf-8"></script>
<script src="/lib/ace/src/ext-themelist.js"  type="text/javascript" charset="utf-8"></script>
<script src="/lib/ace/src/ext-language_tools.js"  type="text/javascript" charset="utf-8"></script>
<!-- html2canvas, jspdf  cdn-->
<script type = "text/javascript" src = "https://cdnjs.cloudflare.com/ajax/libs/jspdf/1.5.3/jspdf.min.js"></script>
<script type = "text/javascript" src = "https://html2canvas.hertzen.com/dist/html2canvas.min.js"></script>
<script type="text/javascript" src="lib/jquery-ui/viewer.min.js"></script>
<link rel="stylesheet" href="/src/awecomponent.css?20220906">
<script src="/src/awecommon.js?20220906"  type="text/javascript" charset="utf-8"></script>
<script src="/src/awecomponent.js?20220906"  type="text/javascript" charset="utf-8"></script>

<script comment="retail_mstportal.js로 분리" >
var gSYS = 'RETAIL';
var gfn = {};
var gObj = {};
var gParam = {};
var gds = {comcd:[]};
var gUserinfo = {userid:"anonymous"};
var gParamFile = {};
var lpcnt = 0; 
var SYS_URL = "";

function gfnLoad(app,pgm,oDOM,afnCallback,domChildClear) {
	lpcnt++;
	$.ajax({
		url: "/apps/"+app+"/"+pgm+".html?"+(date("today","yyyymmddhh24miss")+""+lpcnt),
		type: 'GET', /* static content는 POST가 아니라 GET으로 호출 */
		dataType: "html",   
		success: function(rtn, stat) {
			var page = document.createElement("div"); 
			page.classList.add('framepage');
			page.setAttribute("pgmid",pgm); 
			page.setAttribute("id","page"+lpcnt); 
			var oPage = $(page); 
			oPage.html(rtn); 
			if(domChildClear) $(oDOM).children("*").remove();
			$(oDOM).append(oPage); 
			var OUTVAR = {rtnCd:"OK",rtnMsg:oPage}; 
			if(typeof(afnCallback)=='function') afnCallback(OUTVAR);
			var args = {pgmid:pgm}
			var invar = JSON.stringify(args);
			gfnTx("aweportal.frameset","updatePgmExecCnt",{INVAR:invar},OUTVAR=>{console.log(pgm+" loaded...")});
		},
		error: function(jqx, stat, err) {
			var OUTVAR = {rtnCd:"ERR",rtnMsg:"["+jqx.responseText+"]"};
			afnCallback(OUTVAR); 
		}
	});      
}

function gfnTx(pgm,func,data,afnCallback,bSilence) {
	try {  
		if(bSilence) $(".loadTx").hide();
		else {
			$(".loadTx span").text(pgm + " . " + func);
			$(".loadTx").show();
		}
		$.ajax({
			url: "/awegtx.jsp?pgm="+pgm+"&func="+func,
			type: 'POST',
			dataType: 'json', 
			async: true,
			data: data,
			success: function(OUTVAR, stat) { 
				$(".loadTx").hide();
				afnCallback(OUTVAR); 
				if(OUTVAR.rtnSubCd=="SESSION") {
					if(OUTVAR.rtnCd=="ERR" && OUTVAR.rtnMsg=="사용자세션이 종료되었습니다. 브라우저의 새탭을 띄워 다시 접속한 후 작업을 계속하세요!") gfnLogout();
					else gfnHome();
				}
			},
			error: function(jqx, stat, err) {
				$(".loadTx").hide();
				var OUTVAR = {rtnCd:"ERR",rtnMsg:"["+jqx.responseText+"]"};
				afnCallback(OUTVAR);  
			}
		});  
	} catch {
		gfnLogout();
	}
} 

function gfnSendMsg(toSys, useremail, msg, url, afnCallback, ref_info, pgmid) {
	if(toSys=="naverworks") {
		var userlist = ($.type(useremail)=='array')?useremail:[useremail]; //사용자ID
		var type = "link";  //or "text" // 텍스트 또는 링크
		var textMsg = msg; //메세지
		var link = nvl(url,"https://fo.lfnetworks.co.kr/retail.jsp"); //링크
		
		var usid = [];
		for(var i = 0; i<userlist.length; i++){
			usid.push({'usid':userlist[i], 'msg':textMsg, 'type':type, 'link':link});
		}
		var args = {};
		args.usidlist = usid;
		var invar = JSON.stringify(args);
		gfnTx("api.plas_naver_bot","sendMsg2",{INVAR:invar},function(OUTVAR){
			console.log(OUTVAR);
			if(OUTVAR.rtnCd=="OK") {
				var args2 = {};
				args2.list = [];
				userlist.forEach(el=>{
					var row = {usid:el.split("@")[0]}; 
					row.comments = textMsg+" "+nvl(url,"");
				    row.ref_info = nvl(ref_info,"");
				    row.pgmid    = nvl(pgmid,"registerAlert"); 
					args2.list.push( row ); 
				});
				var invar2 = JSON.stringify(args2);
				gfnTx("aweportal.registerAlert","saveLog2",{INVAR:invar2},function(OUTVAR2){
					if(OUTVAR2.rtnCd=="OK") {
						afnCallback(OUTVAR);
					} else {
						console.log(OUTVAR2);
					}
				});
			} else {
				gfnAlert("메세지 발송(네이버웍스 bot 전송) 오류",OUTVAR.rtnMsg);
			}
		});	
	} else if(toSys=="jandi") {
		var args = {};
		args.msgs = [{ email: useremail, body: msg,
		               connectInfo  : [ { title : "LFN 유통MD정보시스템",
                                          imageUrl : nvl(url,"https://fo.lfnetworks.co.kr/retail.jsp") } ] 
					 }];
		var invar = JSON.stringify(args);		
		gfnTx("api.mr_jandi_bot","sendMsg",{INVAR:invar},function(OUTVAR){
			if(OUTVAR.rtnCd=="OK") {
				var args2 = {};
				args2.usid = useremail;
				args2.comments = textMsg+" "+nvl(url,"");
				args2.ref_info = nvl(ref_info,"");
				args2.pgmid    = nvl(pgmid,"registerAlert");
		        var invar2 = JSON.stringify(args2);
				gfnTx("aweportal.registerAlert","saveLog",{INVAR:invar2},function(OUTVAR2){
					if(OUTVAR2.rtnCd=="OK") {
						afnCallback(OUTVAR);
					} else {
						console.log(OUTVAR2);
					}
				});
				afnCallback(OUTVAR);
			} else {
				gfnAlert("메세지 발송(잔디 bot 전송) 오류",OUTVAR.rtnMsg);
			}
		}); 
	}
}

function gfnAlert(title,content=title) {
	var AlertPopLayer = document.createElement("div");
	AlertPopLayer.classList.add("awePopLayer"); 
	var AlertPop = document.createElement("div");
	AlertPop.classList.add("awePop");
	var AlertPopTitle = document.createElement("H2");
	AlertPopTitle.innerHTML = title;
	AlertPop.append(AlertPopTitle);
	var AlertPopBody = document.createElement("DIV");
	AlertPopBody.innerHTML = content; 
    AlertPop.append(AlertPopBody); 
	AlertPop.addEventListener('click',e=>{
		AlertPopLayer.remove();
	})
	AlertPopLayer.append(AlertPop)
	document.body.append(AlertPopLayer); 
}

function gfnStatus(title,content) {
	var StatusPop = document.createElement("div"); 
	StatusPop.innerHTML = "<h5>"+title+"</h5>"+content; 
    $(".aweStatus").append(StatusPop);
	setTimeout(function(){ 
		StatusPop.remove();
	},5000); 
}
 
function gfnPopup(title, content, aOpt, afnCallback) {
	var pageSeq = lpcnt++;
	var opt = {  
			resizable: false, 
			modal: true, 
			minWidth: 400, 
			minHeight: 500, 
			beforeClose: function( event, ui ) {
				if(!isNull(afnCallback)) afnCallback( event, ui ); 
			},
			close:  function( event, ui ) {
				$(this).remove(); 
			} 
	}; 
	$.extend(true, opt, aOpt); 
	if(isNull(afnCallback)) afnCallback = function(){ console.log(arguments) }; 
	$("<div id='popup"+pageSeq+"' title='"+title+"'></div>").append(content).dialog(opt);  
	return $("#popup"+pageSeq); 
}

function gfnConfirm(title, content, afnCallback, oPos) {
	if(isNull(afnCallback)) return false;
	var pos = {my:"center", at:"center", of: window};
	if(oPos!=undefined) pos = oPos; 
	var popupConfirm = $("<div id='onloading"+title+"' title='"+title+"'><div style='margin-left:1em'>"+content+"</div></div>");
	popupConfirm.dialog({
		position: pos,
		resizable: false,
		modal: true, 
		buttons: [
			{   text:"확인",
				icon:"ui-icon-check",
				click:function() {
					afnCallback(true);
					$(this).dialog("close");
				}
			},
			{   text:"취소",
				icon:"ui-icon-cancel",
				click:function() {
					afnCallback(false);
					$(this).dialog("close");
				}
			} 			
		],
		close:  function( event, ui ) { 
			$(this).remove(); 
		}
	}); 
	return popupConfirm;
}  

function gfnPrompt(title, content, afnCallback, oPos, defval) {
	if(isNull(afnCallback)) return false;
	var pos = {my:"center", at:"center", of: window};
	if(oPos!=undefined) pos = oPos; 
	var popupPrompt = $("<div id='onloading"+title+"' title='"+title+"'><div style='margin-left:1em'>"+content+"<textarea class='prompt' placeholder='입력하세요...'>"+eval2(defval)+"</textarea></div></div>");
	popupPrompt.dialog({
		position: pos,
		resizable: false,
		modal: true, 
		buttons: [
			{   text:"확인",
				icon:"ui-icon-check",
				click:function() {
					var msg = $(this).find(".prompt").val();
					afnCallback({rtnCd:true,rtnMsg:msg});
					$(this).dialog("close");
				}
			},
			{   text:"취소",
				icon:"ui-icon-cancel",
				click:function() {
					var msg = $(this).find(".prompt").val();
					afnCallback({rtnCd:false,rtnMsg:msg});
					$(this).dialog("close");
				}
			} 			
		],
		close:  function( event, ui ) { 
			$(this).remove(); 
		}
	}); 
	return popupPrompt;
}

function gfnToggleScreen(minmax) {
	if(minmax==undefined) {
		$("nav.topbar").toggleClass("hide",20); 
		$("footer").toggleClass("hidden",20);
	} else if (minmax=="normal") {
		$("nav.topbar").removeClass("hide",20); 
        $("footer").removeClass("hidden",20);      
	} else if (minmax=="max") {
		$("nav.topbar").addClass("hide",20); 
        $("footer").addClass("hidden",20);      
	} else if (minmax=="min") {
		gfnToggleScreen("normal",20,gfnHome); 
	}
}

function gfnGetUUID(digit, afnCallback)  {
	var uuid = "";
	if(!isNum(digit)||isNull(digit)) digit = 20;
	gfnTx("aweportal.frameset","getUUID",{INVAR:{digit:digit}},function(OUTVAR){
		if(OUTVAR.rtnCd == "OK") uuid = OUTVAR.uuid;
		afnCallback( uuid );
	},true);
}

var gDebug = {};
function gfnMDI() { 
	var me = {};
	me.tabContainer = $("nav.pages");
	me.pageContainer = $(".mainContent");
	me.idx = 0;  
	//page# 채번
	me.getNext = function() { 
		me.idx++;
		return me.idx;
	} 
	//page# 지난 번호
	me.getPrev = function() {
		me.idx--;
		return me.idx;
	}
	//page# 현재 페이지 번호
	me.getNum = function() {
		return me.idx;
	}
	//frameHome만 남기고 다 숨겨줌
	me.hideAll = function() { 
		me.tabContainer.children("a.tab").removeClass("active");
		me.pageContainer.children(".framepage").removeClass("active");
		me.pageContainer.children(".framepage").hide(); 
	} 
	//frameHome 로드 
	me.loadHome = function() {
		me.openPageOne("retailHome");
	};
	//프레임페이지를 중복 없이 한 개만 열기
	me.openPageOne = function(pgmid, pagenm, grpid, grpnm, afnCallback, appid) { 
		var chk = me.pageContainer.children(".framepage[pgmid='"+pgmid+"']");
		if(chk.length > 0) me.go($(chk[0]));
		else me.openPage(pgmid,pagenm, afnCallback, appid);
	}
	//framepage 열기(추가)
	me.openPage = function(pgmid, pagenm, afnCallback, appid) { 
		if($("body").outerWidth() < 480) $("body").addClass("mobile");
        else $("body").removeClass("mobile"); 
		appid = nvl(appid,"retail");
		//console.log(appid+"."+pgmid+" loading... on");
		//console.log(me.pageContainer);
		gfnLoad(appid,pgmid,me.pageContainer,OUTVAR=>{
		    //console.log(OUTVAR);	
			if(OUTVAR.rtnCd=="OK") { 
				me.hideAll();
				setTimeout(function(afnCallback){
					var oPage = OUTVAR.rtnMsg;
					if(oPage.attr("pgmid")!="retailHome") { 
						pagenm = nvl(pagenm,me.pageContainer.children(".framepage[id='"+oPage.attr("id")+"']").find(".pageTitle").text());
						console.log(me.pageContainer.children(".framepage[id='"+oPage.attr("id")+"']").find(".pageTitle").text());
						var tab = $("<a class='tab active' pageidx='"+ oPage.attr("id") +"'>"+pagenm+"<i class='fas fa-times-circle closetab'></i></a>");
						me.tabContainer.append(tab);
					}
					oPage.addClass("active").show();
					if(!isNull(afnCallback)) afnCallback();
					$("body").scrollTo(0);
					//background-image
					var gridCnt = oPage.find(".pageContent .agGrid .ag-center-cols-viewport").length;
					for(var i=0; i < 1+(gridCnt%3); i++) {
						var gridForBG = rnd(gridCnt,1);
						$(oPage.find(".pageContent .agGrid .ag-center-cols-viewport")[gridForBG-1]).addClass("gridBG").addClass("gridBG"+rnd(26,1)); 
					}
					//dummy Element Remove
					$("body").children("div").each(function(idx,el){
						if(isNull(el.className) && isNull(el.innerText)) $(el).remove();
					}); 
				},100,afnCallback); 
			} else {
				gfnStatus("오류","요청된 화면을 여는데 오류가 발생하였습니다 : ["+appid+"."+pgmid+"]"+nvl(pagenm,''));
				me.go(0);
			}
		}); 
	} 
	//특정 framepage로 이동 
	me.go = function(to) { 		
		if($("body").outerWidth() < 480) $("body").addClass("mobile");
        else $("body").removeClass("mobile");

		if(to=="home" || to==0 || isNull(to)) { 
			if(me.pageContainer.children(".framepage[pgmid='retailHome']").length > 0) {
				me.hideAll();
				me.pageContainer.children(".framepage[pgmid='retailHome']").show();
			} else {
				location.reload();
			}  
		} else if (to=="prev"||to=="next") {
            //prev/next는 tab기준으로 한다
			var cur = me.tabContainer.children("a.active"); 
			if(cur.length==0) me.go("home");
			var targetTab;
			if(to=="prev") targetTab = cur.prev(); 
			else if(to=="next") targetTab = cur.next();
			if(targetTab.length==0 || isNull(targetTab.attr("pageidx"))) me.go("home");
			me.go( targetTab.attr("pageidx") );
		} else {
			var toPage; 
			if(to instanceof jQuery) {
				toPage = to; 
			} else { 
				toPage = $(to);
				if(toPage.length==0) toPage=$("#"+to);
			}
			if(toPage.length == 0) {
				gfnStatus("오류","요청된 페이지가 존재하지 않습니다.:"+to); 
				console.log(to);
				return;
			}
			me.hideAll();
			toPage.addClass("active");
			toPage.show();
			me.tabContainer.children("a[pageidx='"+ toPage.attr("id") +"']").addClass("active");		
			me.syncGNB();  
		}  
	}  
	//특정 framepage로 이동 
	me.focusPage = function(pageidx) {  
		me.go(pageidx);  
	}
	//탭과 페이지 닫기
	me.closeTab = function(pageidx) {
		if(pageidx=="page1") {
			gfnStatus("홈화면은 닫을 수 없습니다.");
			return; 
		}
		//일단 닫으려는 탭으로 이동 후
		me.go(pageidx);
		//Next로 Focus하고 나서
		me.go("prev");
		//remove page
		me.pageContainer.children(".framepage[id='"+pageidx+"']").remove();
 		me.tabContainer.children("a.tab[pageidx='"+pageidx+"']").remove();
		delete gfn[pageidx];

		//남은 것이 없으면 Home으로
		if(me.tabContainer.children("a.tab").length==0) me.go("prev");  
	}
	 
    //탭클릭 이벤트 핸들러 
	$(me.tabContainer).on("click",function(e){
		var oE = $(e.target);
		if(oE.isON("[pageidx]")) {
			var pageidx = oE.attr("pageidx")||oE.parents("[pageidx]").attr("pageidx"); 
			//console.log(e);
			if(oE.hasClass("closetab")) {
				me.closeTab(pageidx); 
			} else {
				me.focusPage(pageidx);
			}
		}  
	});  

    //화면 최대화 토클
	me.screen = function(bMax) {   
		if(bMax) gfnToggleScreen("max")
		else gfnToggleScreen(); 
	}

    //현재 active화면 닫기
	me.close = function() {
		var curPage = me.pageContainer.children(".framepage.active");
		if(curPage.length == 0) return;
		me.closeTab( curPage.attr("id") );
	}

	//[Deprecated]채널 생성(중복 x)
	me.openChat = function(pgmid, grpid) {}
	//[Deprecated]한페이지 생성된 탭닫기
	me.closeTabOne = function(grpid) {}
	//[Deprecated]채널 닫기
	me.closeChat = function(grpid) {}
	//[Deprecated]frameBottom 의 좌우버튼 색표시
	me.syncGNB = function() {}
	//[Deprecated]frameLeft 메세지 채널 초기화
	me.portletChat = function() {} 
	me.portletAlert = function() {} 
	//[Deprecated]한 개의 특정 페이지로 이동
	me.goOne = function(grpid) {} 	

	return me;
}
var gMDI; //new gfnMDI();
//alias of gMDI.openPage
function gfnLoadPage(pgmid,afnCallback,pagenm,appid) { 
	gMDI.openPage(pgmid,pagenm,afnCallback,appid);
}
//alias of gMDI.go(0)
function gfnHome() { 
	gMDI.go(0);
} 

function gfnClosePop() { 
	$(".awePopLayer").remove();
}

function gfnLogout() { 
	gfnTx("aweportal.login","logout",{},function(OUTVAR){ 
		if(OUTVAR.rtnCd=="OK") {
			gUserinfo.email=null;
			gUserinfo.jobgradenm=null;
			gUserinfo.jobrolenm=null;
			gUserinfo.tel_no=null;
			gfnAlert("로그아웃 성공","로그아웃 되었습니다.");
			location.reload();
		}		
	}); 
}
 
function gfnCdNm(grpcd,cd,type) {
	var rtn;
	try { 
		if(type==undefined) type = "nm";
		rtn = subset(subset(gds["comcd"],"grpcd",grpcd),"cd",cd)[0][type];
	} catch(e) {
		rtn = "";
	}
	return rtn;
}

function gfnDataUrl(img) {
   // Create canvas
   const canvas = document.createElement('canvas');
   const ctx = canvas.getContext('2d');
   // Set width and height
   canvas.width = img.width;
   canvas.height = img.height;
   // Draw the image
   ctx.drawImage(img, 0, 0);
   return canvas.toDataURL('image/png');
}

function gfnShowPlasDoc(docid, mode="preview") {
	if(mode=="framepage") {
		$.extend(true,gParam||{},{INVAR:{docid:docid}}); //gParam.INVAR.docid
		//me.openPage(pgmid,pagenm, afnCallback, appid);
		gMDI.openPage("plasDocUpd","문서보기",function(OUTVAR){},"plas");
	} else if(mode=="popup"){
		$.extend(true,gParam||{},{INVAR:{docid:docid}}); //gParam.INVAR.docid
		gfnLoad("plas","plasDocUpd",$("body"),function(OUTVAR){
			//gfnPopup(title, content, aOpt, afnCallback)
			gfnPopup("문서보기", OUTVAR.rtnMsg, {width:800,height:600}, function(){});     
		}); 
	} else if(mode=="preview"){ 
		$.extend(true,gParam||{},{INVAR:{docid:docid, mode:"preview"}}); //gParam.INVAR.docid
		gMDI.openPage("plasDocUpd","문서보기",function(OUTVAR){},"plas");
	}
} 

/************************* 포털 INITIALIZE ***********************************/
var bgRotater;
var bgIdx;
function gfnInit(afnCallback) {  
    //MDI
	gMDI = new gfnMDI();
    //배경화면 Rotater
	if(isNull(bgRotater)) {
		var bgImgs = ["G1","G2","G3","G4","G5","G6","G7","I1","I2","I3","I4","Y1","Y2","Y3"];
		bgRotater = setInterval(function(){  
			var i = rnd(0,bgImgs.length-1);
			if(bgIdx!=i) {
				bgIdx = i; 
				$(".mainContent").css("background-image","url(/images/lfsquare"+bgImgs[i]+".jpg)");
			}
		},10000);
	} 
   
<% if(!bSession || isNull(USERID) || "anonymous".equals(USERID)) { %> 
    //load retailHome to .panel, 사용자정보를 조회해온다.
	const pgm = "retailLogin"; 
	//console.log(pgm);
	gfnLoadPage(pgm);  
<% } else { %>
	gUserinfo.deptcd     = "<%= DEPTCD %>";
	gUserinfo.deptnm     = "<%= DEPTNM %>";
	gUserinfo.orgcd      = "<%= ORGCD %>"; 
	gUserinfo.orgcnt     = "<%= MULTIORGYN %>";
	gUserinfo.orgnm      = "<%= ORGNM %>";  
	gUserinfo.userid     = "<%= USERID %>";
	gUserinfo.usernicknm = "<%= USERNICKNM %>";
	gUserinfo.usernm     = "<%= USERNM %>";
	gUserinfo.usersession = "<%= USERSESSION %>";

	$("body").on("dblclick",".mainContent > .framepage.active > .pageTop", function(e){
		//console.log(e.target);//	if($(window).scrollTop() >= 48) gfnToggleScreen("max"); 
		gfnToggleScreen();
	});

    <% if(!isNull(DOCID)) { %>
		//load retailHome to .panel, 사용자정보를 조회해온다.
		const pgm = "retailHome"; 
		gfnLoadPage(pgm,function(OUTVAR){  
			gfnShowPlasDoc("<%=DOCID%>", mode="preview");
			if(typeof(afnCallback)=='function') afnCallback(OUTVAR);
	    }); 


    <% } else { %>
		//load PlasHome to .panel, 사용자정보를 조회해온다.
		const pgm = "retailHome";
		gfnLoadPage(pgm,afnCallback); 
    <% } %>
<% } %>
}  
/************************* 포털 INITIALIZE ***********************************/
</script>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@100;300;400;500;700;900&display=swap" rel="stylesheet">
<style comment="retail.css로 분리">
/*@import url(//fonts.googleapis.com/earlyaccess/nanumgothic.css); */
*
{
	margin: 0;
	padding: 0;
	box-sizing: border-box;
    font-family: 'Noto Sans Korean', sans-serif; /* 'Nanum Gothic', sans-serif; */
} 
:root
{ 
	--marginBig:20px; /*9  20px*/ 
	--margin:10px; /*6  10px*/
	--marginSmall:5px; /*3  5px*/
	--boxShadow: 0px 0px 3px rgba(0,0,0,0.2); 

    --iconSize: 36px;
	--logoBG:#111010; 
	--logoHover: linear-gradient(133deg, #242121, #5c0808);
    --logoColor:#f1ecec;
	--pointColor:#a10303;

	--topBG:#f4f6fa;
	--topColor:#111;
	--topBorder:1px solid rgba(0,0,0,0.2);
	
	--mainBG:#f5f5f5;
	--mainColor:rgba(0,0,0,0.95);
	--mainBorder:1px solid rgba(0,0,0,0.2);
	--mainHover:#03a9f4; 
	--fontSmall:300 10px 'Nanum Gothic', sans-serif;
	--fontSize: 11px;
	--font:11px 'Nanum Gothic', sans-serif;
	--fontBold:400 1em 'Nanum Gothic', sans-serif;
	--fontBig:500 1.2em 'Nanum Gothic', sans-serif;
	--fontHuge:600 2.4em 'Nanum Gothic', sans-serif;
	--fontHover:#03a9f4; 
	--fontSubColor:#aaa;
	--colorGood: hsl(105,50%,50%,0.5) !important; 
	--colorWarn: hsl(0,90%,35%,0.5) !important; 
	--colorAlert: hsl(51,77%,48%,0.5) !important; 
} 
body
{
	position: relative;
	overflow-x: hidden;
	font: var(--font); 
}
body::-webkit-scrollbar-thumb {
    height: 18%;
    background-color: hsla(206 91% 42% / 0.9);
    border-radius: 10px;
}
body::-webkit-scrollbar {
    width: 6px;
}
.ad {
    width: 100%;
    min-height: var(--iconSize);
    padding: var(--margin); 
    font: var(--fontHuge);
    display: flex;
    flex-direction: column;
    flex-wrap: wrap;
    align-content: center;
    justify-content: flex-start;
    align-items: flex-start;
	z-index: 1000;
}
.main {
	height: 100vh;
	min-height: 100vh; 
    position: relative;
	display: flex;
    flex-direction: column;
    justify-content: space-between;
}
.main > * {
	flex: 0 0 auto;
}
.main > div.mainContent {
	flex: 1 1 100%;
}

nav.topbar {
	position: sticky;
	top: 0;
	width: 100%;
	background-color: white;
	box-shadow: 0 0 var(--marginSmall);
	z-index: 100;    
	border-bottom: 3px solid #ee3124;
}
	nav.topbar.login {
		border-bottom: 0;
	} 
	div.topbarMain { 
		width: 100%;
		height: calc(var(--iconSize) * 1.4);
		display: flex;
		flex-direction: row; 
		align-content: space-between;
		justify-content: space-between;
		align-items: center;
		padding: var(--margin);
		/*background-image: linear-gradient(90deg, #c900000d, #b9b9000d, #00b9b90d, #0000c90d, #b900b90d, #0000000d);
		background-position: center; */
	}

		nav.topbar .logo {
			height: 100%
		}
		nav.topbar .logo > img { 
			height: 34px 
			/* calc(100% + 2px); */
			/* background-color: white; */
		}  

		nav.topbar #toolbar {
			display: flex; 
			align-items: center;
		}		
    nav.topbar nav.pages {
		width: 100%;
		font-size: 10px;
		background-color: var(--mainBG);
		
	}
	nav.topbar.login nav.pages {
		display: none;
	}

	nav.pages a.tab.active {
		background-color: var(--mainHover);
		color: var(--logoBG);
		position:relative;
	}
	nav.pages a.tab {
		padding: 2px 4px;
		border-radius: 4px 4px 0 0;
		margin-right: 2px;
		background-color: var(--fontSubColor);
		color: white;
		border: var(--topBorder);
		user-select: none;
		cursor: pointer;
		white-space: nowrap;
		line-height: 2.3;
	}
	nav.pages a.tab i {
		display:none;
	}
	nav.pages a.tab.active i {
		position: absolute;
		display: inline-block;
		top: -4px;
		right: -7px; 
		text-align: center;
		color: black;  
		background-color: white;
		border-radius: 100%;
		font-size: 12px;
		cursor:pointer;
	}
	nav.pages a.tab.active i:hover {
		color: darkred; 
	}

.mainContent {
	position: relative;
	width: 100%;
	height: calc(100% - 3px);
	padding: var(--marginSmall);
	transition: background 1.5s ease;
	opacity: 1.0; 
	background-color: #efefef;
	background-image: url(/images/lfsquareY1.jpg);
	background-size: cover;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    align-items: stretch;
}
	.mainContent.login { 
		display: flex;
		align-content: center;
		justify-content: center;
		align-items: center;
	}
	.framepage {
		height: 100%;
		width: 100%;
		background-color: white;
		border-radius: var(--marginSmall);
		box-shadow: 1px 1px 2px #aeaeae; 
		padding: var(--margin); 
		padding-top: 5px;
		display: flex;
		flex-direction: column;
		flex-wrap: nowrap;
		align-content: center;
		justify-content: center;
		align-items: stretch;
	} 
	.framepage > div {
		flex: 0 0 auto; 
	}
	.framepage > div.pageContent {
		flex: 1 1 100% !important;
		height: 100%;
		display: flex;
		flex-direction: column;
		flex-wrap: nowrap;
		align-content: center;
		justify-content: center;
		align-items: stretch;
	} 
	.framepage[pgmid='retailLogin'] {
		max-width:750px;
		max-height:590px;
	}

footer {
    width: 100%;
	min-height: 50px;
	display: flex;
	align-content: center;
	justify-content: center;
	align-items: center;
}
footer.login { 
	position: fixed;
	left: 0;
	right: 0;
	bottom: 0;
	background-color: rgba(0,0,0,.3);
	color: #fff;
	z-index: 9;
}
footer.login > img {
	display: none;
}
    footer .notice {
		background-color: rgba(0,0,0,0.1);
		padding: 0.25em;
		margin: 0.25em 0;
		line-height: 1.25;
		font-size: smaller;
		display: flex;
		justify-content: space-between;
		column-gap: var(--margin);
	} 

.icons {
    width: 40px;
    height: 40px;
    /* margin: 0 4px; */
    background-image: url(/images/icons.png)!important;
    background-repeat: no-repeat;
    background-position: 0 0;
    background-size: 240px auto;
	cursor: pointer;
    display: flex;
    align-content: center;
    justify-content: center;
    align-items: center;
}
.icons:hover {
	transition: background-color 1s;
    background-position-y: -40px; 
    background-color: #585d72;
    opacity: 0.5;
    border-radius: 20px;
}
.icons:active {
    background-position-y: -80px; 
    background-color: #585d72;
    opacity: 0.2;
    border-radius: 20px;
} 
.icons.search {
    background-position-x: 0px;
}
.icons.plus {
    background-position-x: -40px;
}
.icons.open {
    background-position-x: -80px;
}
.icons.alarm {
    background-position-x: -120px;
}
.icons.notice {
    background-position-x: -160px;
}
.icons.menu {
    background-position-x: -200px;
}

.aweStatus { 
    position: fixed;
    top: 1em;
    right: 1em; 
    z-index: 100;
	flex-direction: column;
    flex-wrap: nowrap;
    row-gap: var(--marginSmall);
} 
    .aweStatus > div {
		background-color: #fff8ce;
		width: 200px;
		max-width: 80%; 
		border-radius: 1em;
		box-shadow: 0px 0px 5px #5a5a5a;
		font-size: 1em;
		z-index: 101;
		padding: 1em; 
	} 
.awePopLayer {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: rgba(0,0,0,0.2);
    z-index: 200;
    display: flex;
    justify-content: center;
    align-items: center;
    align-content: center;
}
	.awePop {
		background-color: white;
		min-width: 25%; 
		max-width: 80%;
		max-height: 80%;
		overflow-y: auto;
		box-shadow: 5px 5px 5px rgb(0 0 0 / 50%);
		border-radius: var(--margin); 
	}
	.awePop > H2 {
		font: var(--fontBig);
		white-space: nowrap;
		background-color: var(--navBG);
		color: var(--navColor);
		border-top-left-radius: var(--marginSmall);
		border-top-right-radius: var(--marginSmall);
		border-bottom: var(--marginSmall) solid var(--componentBG);
		padding: var(--margin);
		position: sticky;
		top:0;
	}
	.awePop > H2::after {
		content: "X";
		color: darkgoldenrod;
		position: absolute;
		right: var(--margin);
		cursor:pointer;
	}
	.awePop > div {
		padding: var(--margin);
		background-color: var(--colorAlert);
		border-bottom-left-radius: var(--marginSmall);
		border-bottom-right-radius: var(--marginSmall);
		min-height: calc(var(--iconSize) * 2);
	}
.btnClear { 
    font: var(--fontSmall);
}
.hidden {
	display: none !important;
} 
img.fadeout { 
	transition: all 2s;
	opacity: 0;
	filter: grayscale(0.1) blur(10px);
}
img.fadein {
	transition: all 2s;
	opacity: 1;
	filter: unset;
} 

/* frameset HACK */
.ui-dialog-content .framepage {
    padding: 0 !important;
    box-shadow: unset !important; 
}

.aweForm div[colgrp] {
	min-height: 2.25em;
}

.aweForm fieldset legend {
    color: steelblue;
}

/* calendar class */
.aweCalendar {
    background-color: #ffffffA0;
    flex-direction: column;
    flex-wrap: nowrap;
	min-height: 24em;
}

.aweCalendar .calendar {
    flex: 1 1 100%;
    text-align: center;
}

.aweCalendar .calendar thead {
    background-color: #ffffee;
}

.aweCalendar .calendar tbody {
    background-color: #ffffffa0;
    vertical-align: text-top;
    text-align: left;
}

.aweCalendar .calendar tr td {
    width: calc(100% / 7);
    height: calc(100% / 6);
}

.aweCalendar .calendar tr td:first-child {
    background-color: #ffeeeea0;
} 

.aweCalendar .calendar tr td:last-child {
    background-color: #eeeeffa0;
}

.aweCalendar .calendar #top {
    font:var(--fontSmall);
	color:var(--fontSubColor);
}
.aweCalendar .calendar #top b {
    font:var(--fontBig); 
	color:var(--logoBG);
	cursor:pointer;
}
.aweCalendar .calendar #top b:hover {
    color:var(--pointColor)
}

.aweCalendar .calendar .today {
    background-color: #fffcee !important;
}

.aweCalendar .calendar .prevMon {
    background-color: #3a3a3a2e !important;
}

.aweCalendar .calendar .nextMon {
    background-color: #3a3a3a2e !important;
}

.loadTx {
    position: absolute;
    top: 0;
    bottom: 0;
    left: 0;
    right: 0;
    background-color: #3a3a3a3a;
    z-index: 10000;
    display: flex;
    flex-direction: column;
    align-content: space-between;
    justify-content: space-between;
    align-items: stretch;
}
.loadTx .pop {
    margin: auto;
    background-color: white;
    padding: 1em;
    border-radius: 1em;
    box-shadow: 0.5em 0.5em 5px 5px #3a3a3a3a;
    display: flex;
    flex-direction: row;
    flex-wrap: nowrap;
    align-content: center;
    justify-content: center;
    align-items: center;
    column-gap: 1em;
}
.loadTx .pop > div {
    display: flex;
    flex-direction: column;
    flex-wrap: nowrap;
    align-content: space-between;
    justify-content: space-between;
    align-items: stretch;
}
.loadTx .pop > div span {
    background-color: lightgray;
    padding: 0.5em;
    border-radius: 0.5em;
    font: var(--fontSmall);
}

.aweForm .select2-container {
	width: unset !important;
	min-width: 8em;
	flex: 1 1;
	max-height: 27px;
}

.ui-dialog .ui-dialog-content {
	padding: 0.75em 0 0.75em 0;
}

.popupSearch .pageContent {
	padding: 0 !important;
}

.popupSearch .componentBody.agGrid {
	display: flex;
    flex-direction: column;
    flex-wrap: nowrap;
    align-content: space-between;
    justify-content: space-between;
    align-items: stretch;
    height: 100% !important;
}

.popupSearch .ag-root-wrapper {
	flex: 1 1 100%;
}

.ag-header-group-cell-label {
	justify-content: center;
}

.tox button {
	font-size: 12px !important;
}
.tox-editor-header svg { 
    transform: scale(0.8);
}

.gridBG::before {
	content: " ";
	opacity: 0.75;
	position: absolute;
    right: 3px;
	bottom: 3px;
	width: 40%;
	height: 40%;
	background-size: contain !important;
}
.gridBG1::before { background:url(/images/illust1.png) no-repeat 99% 99%; }
.gridBG2::before { background:url(/images/illust2.png) no-repeat 99% 99%; }
.gridBG3::before { background:url(/images/illust3.png) no-repeat 99% 99%; }
.gridBG4::before { background:url(/images/illust4.png) no-repeat 99% 99%; }
.gridBG5::before { background:url(/images/illust5.png) no-repeat 99% 99%; }
.gridBG6::before { background:url(/images/illust6.png) no-repeat 99% 99%; }
.gridBG7::before { background:url(/images/illust7.png) no-repeat 99% 99%; }
.gridBG8::before { background:url(/images/illust8.png) no-repeat 99% 99%; }
.gridBG9::before { background:url(/images/illust9.png) no-repeat 99% 99%; }
.gridBG10::before { background:url(/images/illust10.png) no-repeat 99% 99%; }
.gridBG11::before { background:url(/images/illust11.png) no-repeat 99% 99%; }
.gridBG12::before { background:url(/images/illust12.png) no-repeat 99% 99%; }
.gridBG13::before { background:url(/images/illust13.png) no-repeat 99% 99%; }
.gridBG14::before { background:url(/images/illust14.png) no-repeat 99% 99%; }
.gridBG15::before { background:url(/images/illust15.png) no-repeat 99% 99%; }
.gridBG16::before { background:url(/images/illust16.png) no-repeat 99% 99%; }
.gridBG17::before { background:url(/images/illust17.png) no-repeat 99% 99%; }
.gridBG18::before { background:url(/images/illust18.png) no-repeat 99% 99%; }
.gridBG19::before { background:url(/images/illust19.png) no-repeat 99% 99%; }
.gridBG20::before { background:url(/images/illust20.png) no-repeat 99% 99%; }
.gridBG21::before { background:url(/images/illust21.png) no-repeat 99% 99%; }
.gridBG22::before { background:url(/images/illust22.png) no-repeat 99% 99%; }
.gridBG23::before { background:url(/images/illust23.png) no-repeat 99% 99%; }
.gridBG24::before { background:url(/images/illust24.png) no-repeat 99% 99%; }
.gridBG25::before { background:url(/images/illust25.png) no-repeat 99% 99%; }
.gridBG26::before { background:url(/images/illust26.png) no-repeat 99% 99%; }

/* 발행용 스타일Class */
#previewPanel table {
	border-collapse: collapse; 
}
#previewPanel .doc_body table th, #previewPanel .doc_body table td {
	padding: 0.5em;
	line-height: 1.4;
	width: auto;
} 
#previewPanel .doc_footer .doc_val {
	padding-top: 0.25em;
	padding-bottom: 0.25em; 
} 
#previewPanel .doc_footer .doc_val > * {
	padding: 0.25em 0.5em; 
}  

.flexRow2 {
    display:flex;
    flex-direction:row !important;
    height:100%;
    column-gap: 1em;
}
textarea.prompt {
    width: calc(100% - 1em);
    padding: 0.5em;
    min-height: 8em;
    line-height: 1.25;
    border: 1px solid lightslategrey;
    background-color: beige;
}

@media (max-width: 992px)
{  
} 
@media (max-width: 768px)
{  
}
@media (max-height: 480px)
{   
	.framepage.active > *.pageContent {
        overflow-y: auto;
    }
}
@media (max-width: 480px)
{  
	.mainContent {
		display: block;
		height: unset !important;
	}
    .framepage.active > *.pageContent {
        overflow-y: auto;
		justify-content: flex-start;
    }	 
	.mainContent .framepage .row {
		display: block !important; 
	}
	.aweForm div[colgrp] {
		justify-content: stretch; 
		align-items: stretch;
		width: 100% !important;
	} 
	.aweForm label {
		flex: 0 0 4em;
		min-width: 5em;
	} 
    .flexRow {
		flex-wrap: wrap;
	}
	.flexRow2 {
        display:block; 
    }  

} 
</style> 
</head>
<body onload="gfnInit()">  
	<div class="main"> 
		<nav class="topbar login"> 
			<div class="topbarMain">
				<div class="logo">
					<img src="/images/CI.jpg">
				</div>  
			</div>
			<nav class="pages"></nav> 
		</nav> 
		<div class="mainContent login"> 
		</div>
		<footer class="login">
			<img src="/images/CI.jpg" style="width:90px"><b>Copyright © 2022 LF Networks co.,Ltd. All rights reserved.</b> 
		</footer> 
	</div>
	<div class="aweStatus"></div> 
	<div class="loadTx">
		<div class="pop">
			<img src="/images/loader.gif">
			<div>
				서비스처리중입니다... 
				<span></span>
			</div>
		</div>
	</div>
</body>
</html>