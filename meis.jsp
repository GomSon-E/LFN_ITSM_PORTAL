<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %> 
<% 
    /* meis.jsp 는 모바일EIS로 다음의 기능을 수행한다 
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
%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0,minimum-scale=0.5,maximum-scale=3.0,user-scalable=yes">
<meta http-equiv="X-UA-Compatible" content="IE=edge"/>
<meta name="format-detection" content="telephone=no"/>  
<title>모바일EIS</title>
	<!-- Favicon -->
	<link rel="shortcut icon" href="/images/MEISicon.png" type="image/x-icon" />
    <link rel="icon" href="/images/MEISicon.png" type="image/x-icon">
	<!-- jQuery -->
	<link rel="stylesheet" href="/lib/jquery-ui/jquery-ui-1.12.1.min.css" /> 
    <link rel="stylesheet" href="/lib/jquery-ui/select2.min.css" />
    <link href="/lib/jampack/vendors/jquery-toast-plugin/dist/jquery.toast.min.css" rel="stylesheet" type="text/css" />
	<!-- Daterangepicker CSS -->
    <link href="/lib/jampack/vendors/daterangepicker/daterangepicker.css" rel="stylesheet" type="text/css" />
	<!-- Data Table CSS -->
    <link href="/lib/jampack/vendors/datatables.net-bs5/css/dataTables.bootstrap5.min.css" rel="stylesheet" type="text/css" />
    <link href="/lib/jampack/vendors/datatables.net-responsive-bs5/css/responsive.bootstrap5.min.css" rel="stylesheet" type="text/css" />
	<!-- agGrid CSS -->
	<link rel="stylesheet" href="/lib/agGrid/ag-grid.css">
	<link rel="stylesheet" href="/lib/agGrid/ag-theme-balham.css">
	<!-- CSS -->
    <link href="/lib/jampack/dist/css/style.css" rel="stylesheet" type="text/css"> 
	<link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Tangerine">        
	
	<!-- jQuery -->
    <script src="/lib/jampack/vendors/jquery/jquery.min.js"></script>
	<script type="text/javascript" src="/lib/jquery-ui/jquery-ui-1.12.1.min.js"></script>
    <script type="text/javascript" src="/lib/jampack/vendors/select2/dist/js/select2.full.min.js"></script> 
	<script type="text/javascript" src="/lib/jquery.scrollTo-2.1.3/jquery.scrollTo.js"></script>	
    <script type="text/javascript" src="/lib/jampack/vendors/jquery-toast-plugin/dist/jquery.toast.min.js"></script>	
    <!-- Bootstrap Core JS -->
   	<script src="/lib/jampack/vendors/bootstrap/dist/js/bootstrap.bundle.min.js"></script>
    <!-- FeatherIcons JS -->
    <script src="/lib/jampack/dist/js/feather.min.js"></script>
    <!-- Fancy Dropdown JS -->
    <script src="/lib/jampack/dist/js/dropdown-bootstrap-extended.js"></script>
	<!-- Simplebar JS -->
	<script src="/lib/jampack/vendors/simplebar/dist/simplebar.min.js"></script>
	<!-- Data Table JS -->
    <script src="/lib/jampack/vendors/datatables.net/js/jquery.dataTables.min.js"></script>
    <script src="/lib/jampack/vendors/datatables.net-bs5/js/dataTables.bootstrap5.min.js"></script>
	<script src="/lib/jampack/vendors/datatables.net-select/js/dataTables.select.min.js"></script>
	<!-- Daterangepicker JS -->
    <script src="/lib/jampack/vendors/moment/moment.min.js"></script>
	<script src="/lib/jampack/vendors/daterangepicker/daterangepicker.js"></script>
	<script src="/lib/jampack/vendors/daterangepicker/daterangepicker-data.js"></script> 
	<!-- Apex JS -->
	<script src="https://cdn.jsdelivr.net/npm/apexcharts"></script>
	<!-- script src="/lib/jampack/vendors/apexcharts/apexcharts.min.js"></script -->
	<!-- Chart.JS -->
	<SCRIPT src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.3.2/chart.min.js" crossorigin="anonymous"></script>
	<!-- agGrid JS -->
	<script src="/lib/agGrid/ag-grid-enterprise.min.noStyle.js"></script>	

	<!-- AWE Portal -->
	<link rel="stylesheet" href="/src/awecomponent.css?20221025">
	<script src="/src/awecommon.js?20221026"  type="text/javascript" charset="utf-8"></script>
	<script src="/src/awecomponent.js?20221025"  type="text/javascript" charset="utf-8"></script>

	<style>
	@import url(https://fonts.googleapis.com/earlyaccess/notosanskr.css);
	body {
		font-family: 'Noto Sans KR', var(--bs-body-font-family), sans-serif;
	}
	.navbar .navbar-brand {
		align-items: center;
	}
	.menu-group .dropdown-divider {
		margin-bottom: 1.5em;
	}
	.container-fluid .navbar-brand {
		margin-top: 0!important;
	} 
	.ui-state-error {
		color: red;
		background-color: lightpink;
	}
	.ui-state-highlight {
		color: darknavy;
		background-color: lightyellow;
	}
	textarea.prompt {
		width: calc(100% - 1em);
		padding: 0.5em;
		min-height: 8em;
		line-height: 1.25;
		border: 1px solid lightslategrey;
		background-color: beige;
	}
	.modal-content .componentBody .ag-root-wrapper-body {
		min-height: 15em;
	}
	.hk-pg-wrapper:has(.framepage) {
		display: flex;
		align-content: center;
		justify-content: center;
		align-items: center
	}
	.hk-wrapper .btnCond {
		padding: 0!important;
	}
    .hk-pg-wrapper .framepage.active {
		width: 100%;
		height: 100%;
	}

	.container-xxl .pageTop {
		margin: 0.25em 0 !important;
	}
	.container-xxl .pageTitle {
		margin-left: 0!important;
	}
	.container-xxl .pageFunc {
		margin-right: 0!important;
	}
	.container-xxl .pageCond {
		margin: 0!important;
	}
    .container-xxl .pageGuide {
		margin: 0.25em 0;
	}
    .btnClear { 
	    font-size: 0.2rem;
		padding:1px!important;
		line-height:1; 
	} 
    .container-xxl .pageContent {
		padding: unset!important;
		margin: unset!important;
	}
	.componentBody .ag-root-wrapper-body {
		min-height: 35em;
	}
	.hidden {
		display: none !important;
	}
	.card-header i.quickGuide, .componentFunc .quickGuide { 
		white-space: nowrap!important;
		text-align: right!important;
		font-size: 0.5em!important;
		font-style: italic!important;
		color: #6f6f6f!important;
	}
	.aweForm .select2-container {
		max-height: 27px; 
	}
	.aweForm .select2-selection {
		font-size: 12px!important;
		padding: 0.375em 1em;
		height: unset!important;
	}
	.aweForm .select2-selection__arrow {
		max-height: 2em;
	}
	.select2-search {
		font-size: 12px!important;
	}
	.select2-container:has(.select2-dropdown){
		font-size: 12px!important;
		width: unset!important;
	}
	.select2-results__option[aria-selected=true]:before {
		font-family: 'Font Awesome 5 Free';
		content: "\f00c";
		color: #fff;
		background-color: #f77750 !important;
		border: 0;
		display: inline-block;
		padding-left: 2px;
		font-size: 10px;
		font-weight: 600;
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

	.componentBody.aweSalesCalendar {
		overflow-x: auto;
	} 
	.aweCalendar .calendar, .aweSalesCalendar .calendar {
		caption-side: top;
	}
	.aweCalendar .calendar caption, .aweSalesCalendar .calendar caption {
		font-size: 1em;
		text-align: center;
	} 
	.aweSalesCalendar .calendar ul.cal {
		margin: 0.25em;
		padding:0.25em;
		text-align: right;
	}
	.aweSalesCalendar .calendar tr th, .aweSalesCalendar .calendar tr td {
		width: calc(100% / 8) !important;
		height: calc(100% / 6) !important; 
	}
	.aweSalesCalendar .calendar thead tr th {
		border-bottom: 2px solid #3a3a3a66;
	} 
	.aweSalesCalendar .calendar tr td:nth-child(7) {
		background-color: #eeeeffa0;
	}
	.aweSalesCalendar .calendar tbody tr th {
		background-color: #ffeeeea0;
	}
	.aweCalendar #top b {
		font-weight: 600!important;
	}
	.aweCalendar .cal .factor {
		color: #2e95b7;
	}
	</style>

<script comment="meis_portal.js" >
var gSYS = 'MEIS';
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
			if( oPage.find('.feather-icon').length > 0 ) feather.replace(); 
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

function gfnSendBotChat(ChannelId, msg, url, linkText, afnCallback) {
	var type = "link";  //or "text" // 텍스트 또는 링크
	if(isNull(url)) type="text"; 
	var args = {channelId:ChannelId, msg:msg, type:type, url:url, linkText:linkText};
	var invar = JSON.stringify(args);
	gfnTx("api.plas_naver_bot","sendBotChat",{INVAR:invar},function(OUTVAR){
		if(OUTVAR.rtnCd!="OK") console.log(OUTVAR);
		if(typeof(afnCallback)=='function') afnCallback(OUTVAR); 
	});	
}

function gfnSendMsg(toSys, useremail, msg, url, afnCallback, ref_info, pgmid) {
	if(toSys=="naverworks") {
		var userlist = ($.type(useremail)=='array')?useremail:[useremail]; //사용자ID
		var type = "link";  //or "text" // 텍스트 또는 링크
		var textMsg = msg; //메세지
		var link = nvl(url,"https://fo.lfnetworks.co.kr/meis.jsp"); //링크
		
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
		               connectInfo  : [ { title : "LFN 모바일EIS",
                                          imageUrl : nvl(url,"https://fo.lfnetworks.co.kr/meis.jsp") } ] 
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

var oAlert;
function gfnAlert(title,content=title) {
	if(isNull(oAlert)) { 
		var AlertPopLayer = document.createElement("div");
		AlertPopLayer.classList.add("modal");
		AlertPopLayer.classList.add("fade");
		AlertPopLayer.tabindex="-1";
		AlertPopLayer.role="dialog";
		AlertPopLayer.setAttribute("aria-labelledby","ModalLabel");
		AlertPopLayer.setAttribute("aria-hidden","true"); 

		var AlertPop = document.createElement("div");
		AlertPop.classList.add("modal-dialog");  
		AlertPop.classList.add("modal-lg");  
		AlertPop.classList.add("modal-dialog-centered");  
		AlertPop.classList.add("modal-dialog-scrollable");  
		 
		var AlertContent = document.createElement("div");
		AlertContent.classList.add("modal-content");
		
		var AlertHeader = document.createElement("div");
		AlertHeader.classList.add("modal-header");
		var AlertPopTitle = document.createElement("H5");
		AlertPopTitle.classList.add("modal-title");
		AlertPopTitle.id="ModalLabel";
		AlertPopTitle.innerHTML = title;
		var AlertPopCloseBtn = document.createElement("button");
		AlertPopCloseBtn.classList.add("btn-close");
		AlertPopCloseBtn.setAttribute("data-bs-dismiss","modal");
		AlertPopCloseBtn.setAttribute("aria-label","Close");
		var AlertPopCloseBtnIcon = document.createElement("span");
		AlertPopCloseBtnIcon.setAttribute("aria-hidden","true");
		AlertPopCloseBtnIcon.innerHTML = "&times;";

		var AlertBody = document.createElement("div");
		AlertBody.classList.add("modal-body");
		AlertBody.innerHTML = content;

		var AlertFooter = document.createElement("div");
		AlertFooter.classList.add("modal-footer");
		var AlertFooterCloseBtn = document.createElement("button");
		AlertFooterCloseBtn.classList.add("btn");
		AlertFooterCloseBtn.classList.add("btn-primary");
		AlertFooterCloseBtn.setAttribute("data-bs-dismiss","modal");
		AlertFooterCloseBtn.innerText = "Close"; 

		AlertHeader.append(AlertPopTitle);
		AlertPopCloseBtn.append(AlertPopCloseBtnIcon);
		AlertHeader.append(AlertPopCloseBtn);
		AlertFooter.append(AlertFooterCloseBtn);
		AlertContent.append(AlertHeader);
		AlertContent.append(AlertBody);
		AlertContent.append(AlertFooter);
		AlertPop.append(AlertContent);
		AlertPopLayer.append(AlertPop);
		document.body.append(AlertPopLayer); 
		oAlert = new bootstrap.Modal(AlertPopLayer);
		oAlert.show();
	} else {
		oAlert.hide();
		oAlert._element.querySelector(".modal-title").innerHTML = title;
		oAlert._element.querySelector(".modal-body").innerHTML = content;
		oAlert.show();
	}
}

function gfnStatus(title,content) { 
	$.toast({
		heading: title,
		text: content,
		position: 'bottom-center',
		loaderBg:'#00acf0',
		class: 'jq-toast-primary',
		hideAfter: 3500, 
		loader:false,
		stack: 6,
		showHideTransition: 'fade'
	});
}
 
function gfnPopup(title, content, aOpt, afnCallback) {
	var pageSeq = lpcnt++; 
	var popId = "popup"+pageSeq; 
	var PopLayer = document.createElement("div");
    PopLayer.id = popId;
	PopLayer.classList.add("modal");
	PopLayer.classList.add("fade");
	PopLayer.tabindex="-1";
	PopLayer.role="dialog";
	PopLayer.setAttribute("aria-labelledby","ModalLabel");
	PopLayer.setAttribute("aria-hidden","true"); 
	PopLayer.setAttribute("data-bs-backdrop","static");

	var Pop = document.createElement("div");
	Pop.classList.add("modal-dialog");  
	Pop.classList.add("modal-lg");  
	Pop.classList.add("modal-dialog-centered");  
	Pop.classList.add("modal-dialog-scrollable");  
	var Content = document.createElement("div");
	Content.classList.add("modal-content");
	
	var Header = document.createElement("div");
	Header.classList.add("modal-header");
	var PopTitle = document.createElement("H5");
	PopTitle.classList.add("modal-title");
	PopTitle.id="ModalLabel";
	PopTitle.innerHTML = title;
	var PopCloseBtn = document.createElement("button");
	PopCloseBtn.classList.add("btn-close");
	PopCloseBtn.setAttribute("data-bs-dismiss","modal");
	PopCloseBtn.setAttribute("aria-label","Close");
	var PopCloseBtnIcon = document.createElement("span");
	PopCloseBtnIcon.setAttribute("aria-hidden","true");
	PopCloseBtnIcon.innerHTML = "&times;";

	var Body = document.createElement("div");
	Body.classList.add("modal-body");
	$(Body).html(content); 

	Header.append(PopTitle);
	PopCloseBtn.append(PopCloseBtnIcon);
	Header.append(PopCloseBtn); 
	Content.append(Header);
	Content.append(Body); 
	Pop.append(Content);
	PopLayer.append(Pop);
	document.body.append(PopLayer); 
	gObj[popId] = new bootstrap.Modal(PopLayer, $.extend({},aOpt));
	if(typeof(afnCallback)=='function') {
		$("#"+popId)[0].addEventListener('hidden.bs.modal',function(e){
			afnCallback(e);
		});
	}
	gObj[popId].show();	
	return popId; 
}

function gfnConfirm(title, content, afnCallback, oPos) {
	if(isNull(afnCallback)) return false;
	var pageSeq = lpcnt++; 
	var confirmId = "confirmup"+pageSeq; 
	var confirmLayer = document.createElement("div");
    confirmLayer.id = confirmId;
	confirmLayer.classList.add("modal");
	confirmLayer.classList.add("fade");
	confirmLayer.tabindex="-1";
	confirmLayer.role="dialog";
	confirmLayer.setAttribute("aria-labelledby","ModalLabel");
	confirmLayer.setAttribute("aria-hidden","true"); 
	confirmLayer.setAttribute("data-bs-backdrop","static");

	var confirm = document.createElement("div");
	confirm.classList.add("modal-dialog"); 
	confirm.classList.add("modal-lg"); 
	confirm.classList.add("modal-dialog-centered");  
	confirm.classList.add("modal-dialog-scrollable");  
	var Content = document.createElement("div");
	Content.classList.add("modal-content");
	
	var Header = document.createElement("div");
	Header.classList.add("modal-header");
	var confirmTitle = document.createElement("H5");
	confirmTitle.classList.add("modal-title");
	confirmTitle.id="ModalLabel";
	confirmTitle.innerHTML = title;
	var confirmCloseBtn = document.createElement("button");
	confirmCloseBtn.classList.add("btn-close");
	confirmCloseBtn.setAttribute("data-bs-dismiss","modal");
	confirmCloseBtn.setAttribute("aria-label","Close");
	var confirmCloseBtnIcon = document.createElement("span");
	confirmCloseBtnIcon.setAttribute("aria-hidden","true");
	confirmCloseBtnIcon.innerHTML = "&times;";

	var Body = document.createElement("div");
	Body.classList.add("modal-body");
	$(Body).html(content);

	var Footer = document.createElement("div");
	Footer.classList.add("modal-footer");
	var FooterYesBtn = document.createElement("button");
	FooterYesBtn.classList.add("btn");
	FooterYesBtn.classList.add("btn-primary");
	FooterYesBtn.setAttribute("data-bs-dismiss","modal");
	FooterYesBtn.innerText = "예"; 
	var FooterCloseBtn = document.createElement("button");
	FooterCloseBtn.classList.add("btn");
	FooterCloseBtn.classList.add("btn-secondary");
	FooterCloseBtn.setAttribute("data-bs-dismiss","modal");
	FooterCloseBtn.innerText = "아니요"; 

	Header.append(confirmTitle);
	confirmCloseBtn.append(confirmCloseBtnIcon);
	Header.append(confirmCloseBtn);
	Footer.append(FooterYesBtn);
	Footer.append(FooterCloseBtn);
	Content.append(Header);
	Content.append(Body);
	Content.append(Footer);
	confirm.append(Content);
	confirmLayer.append(confirm);
	document.body.append(confirmLayer); 
	gObj[confirmId] = new bootstrap.Modal(confirmLayer, $.extend({},oPos));
	FooterYesBtn.addEventListener('click',function(){
		gObj[confirmId].returnValue = true;
	});
	if(typeof(afnCallback)=='function') {
		$("#"+confirmId)[0].addEventListener('hidden.bs.modal',function(e){
			afnCallback(gObj[confirmId].returnValue);
			gObj[confirmId].dispose();
			delete gObj[confirmId];
			$("#"+confirmId).remove();
		});
	}
	gObj[confirmId].show();	
	return confirmId; 
}  

function gfnPrompt(title, content, afnCallback, oPos, defval) {
	if(isNull(afnCallback)) return false;
	var pageSeq = lpcnt++; 
	var promptId = "promptup"+pageSeq; 
	var promptLayer = document.createElement("div");
    promptLayer.id = promptId;
	promptLayer.classList.add("modal");
	promptLayer.classList.add("fade");
	promptLayer.tabindex="-1";
	promptLayer.role="dialog";
	promptLayer.setAttribute("aria-labelledby","ModalLabel");
	promptLayer.setAttribute("aria-hidden","true"); 
	promptLayer.setAttribute("data-bs-backdrop","static");

	var prompt = document.createElement("div");
	prompt.classList.add("modal-dialog");  
	prompt.classList.add("modal-lg");  
	prompt.classList.add("modal-dialog-centered");  
	prompt.classList.add("modal-dialog-scrollable");  
	var Content = document.createElement("div");
	Content.classList.add("modal-content");
	
	var Header = document.createElement("div");
	Header.classList.add("modal-header");
	var promptTitle = document.createElement("H5");
	promptTitle.classList.add("modal-title");
	promptTitle.id="ModalLabel";
	promptTitle.innerHTML = title;
	var promptCloseBtn = document.createElement("button");
	promptCloseBtn.classList.add("btn-close");
	promptCloseBtn.setAttribute("data-bs-dismiss","modal");
	promptCloseBtn.setAttribute("aria-label","Close");
	var promptCloseBtnIcon = document.createElement("span");
	promptCloseBtnIcon.setAttribute("aria-hidden","true");
	promptCloseBtnIcon.innerHTML = "&times;";

	var Body = document.createElement("div");
	Body.classList.add("modal-body");
	$(Body).html( content+"<textarea class='prompt' placeholder='입력하세요...'>"+eval2(defval)+"</textarea>" );

	var Footer = document.createElement("div");
	Footer.classList.add("modal-footer");
	var FooterYesBtn = document.createElement("button");
	FooterYesBtn.classList.add("btn");
	FooterYesBtn.classList.add("btn-primary");
	FooterYesBtn.setAttribute("data-bs-dismiss","modal");
	FooterYesBtn.innerText = "확인"; 
	var FooterCloseBtn = document.createElement("button");
	FooterCloseBtn.classList.add("btn");
	FooterCloseBtn.classList.add("btn-secondary");
	FooterCloseBtn.setAttribute("data-bs-dismiss","modal");
	FooterCloseBtn.innerText = "취소"; 

	Header.append(promptTitle);
	promptCloseBtn.append(promptCloseBtnIcon);
	Header.append(promptCloseBtn);
	Footer.append(FooterYesBtn);
	Footer.append(FooterCloseBtn);
	Content.append(Header);
	Content.append(Body);
	Content.append(Footer);
	prompt.append(Content);
	promptLayer.append(prompt);
	document.body.append(promptLayer); 
	gObj[promptId] = new bootstrap.Modal(promptLayer, $.extend({},oPos));
	FooterYesBtn.addEventListener('click',function(){
		gObj[promptId].bReturn = true;
		gObj[promptId].returnValue = $("#"+promptId+" textarea.prompt").val();
	});
	if(typeof(afnCallback)=='function') {
		$("#"+promptId)[0].addEventListener('hidden.bs.modal',function(e){
			if(gObj[promptId].bReturn) afnCallback(gObj[promptId].returnValue);
			else afnCallback(null);
			gObj[promptId].dispose();
			delete gObj[promptId];
			$("#"+promptId).remove();
		});
	}
	gObj[promptId].show();	
	return promptId;  
}

function gfnToggleScreen(minmax) { 
	/*
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
	*/
	/* meis에서는 호출된 화면목록을 표시 -> 화면전환처리한다. */ 
	console.log("gfnToggleScreen");
	gfn.page1.fnScreen(); //$("#navbtnScreen").trigger("click");
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
function gfnMDI(frameset, mdiArea ) {
	var me = {};
	me.frameset      = $(frameset);
	me.pageContainer = $(mdiArea);
    me.tabContainer  = me.frameset.find("nav.pages");
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
		me.openPageOne("meisHome");
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
		appid = nvl(appid,"meis");
		//console.log(appid+"."+pgmid+" loading... on");
		//console.log(me.pageContainer);
		gfnLoad(appid,pgmid,me.pageContainer,OUTVAR=>{
		    //console.log(OUTVAR);	
			if(OUTVAR.rtnCd=="OK") { 
				me.hideAll();
				setTimeout(function(afnCallback){
					var oPage = OUTVAR.rtnMsg;
					if(oPage.attr("pgmid")!="meisHome") { 
						pagenm = nvl(pagenm,me.pageContainer.children(".framepage[id='"+oPage.attr("id")+"']").find(".pageTitle").text());
						console.log(me.pageContainer.children(".framepage[id='"+oPage.attr("id")+"']").find(".pageTitle").text());
						var tab = $("<a class='tab active' pageidx='"+ oPage.attr("id") +"'>"+pagenm+"<i class='fas fa-times-circle closetab'></i></a>");
						me.tabContainer.append(tab);
					}
					oPage.addClass("active").show();
					if(!isNull(afnCallback)) afnCallback(); 
					//dummy Element Remove
					$("body").children("div").each(function(idx,el){
						if(isNull(el.className) && isNull(el.innerText)) $(el).remove();
					}); 
					//menuHide
					if($(".hk-wrapper").attr("data-layout-style")=="collapsed") {
						$("#divMenu .navbar-toggle").trigger("click");
					}
					if($("#btnUser").siblings(".dropdown-menu").hasClass("show")) {
						$(".framepage.active").trigger("click");
					}
				},100,afnCallback); 
			} else {
				gfnStatus("오류","요청된 화면을 여는데 오류가 발생하였습니다 : ["+appid+"."+pgmid+"]"+nvl(pagenm,''));
				if(pgmid!="meisHome") me.go(0);
			}
		}); 
	} 
	//특정 framepage로 이동 
	me.go = function(to) { 		
		if($("body").outerWidth() < 480) $("body").addClass("mobile");
        else $("body").removeClass("mobile");

		if(to=="home" || to==0 || isNull(to)) { 
			if(me.pageContainer.children(".framepage[pgmid='meisHome']").length > 0) {
				me.hideAll();
				me.pageContainer.children(".framepage[pgmid='meisHome']").show();
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
			//menuHide
			if($(".hk-wrapper").attr("data-layout-style")=="collapsed") {
				$("#divMenu .navbar-toggle").trigger("click");
			}
			if($("#btnUser").siblings(".dropdown-menu").hasClass("show")) {
				$(".framepage.active").trigger("click");
			}
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

function gfnNumToStr(am,roundDigit=0) {
	var amv = toNum(am,roundDigit);
	var rtn = "";
	if(amv < 0) {
		rtn += "-";
		amv = Math.abs(amv);
	}
	if(amv>=1000000000000) {
		rtn += Math.trunc(amv/1000000000000)+"조"; 
		amv = amv - (Math.trunc(amv/1000000000000)*1000000000000);
	}
	if(amv>=100000000) {
		rtn += Math.trunc(amv/100000000)+"억"; 
		amv = amv - (Math.trunc(amv/100000000)*100000000);
	}
	if(amv>=1000000) {
		rtn += Math.trunc(amv/1000000)+"백만"; 
		amv = amv - (Math.trunc(amv/1000000)*1000000);
	}	
	if(amv>=1000) {
		rtn += Math.trunc(amv/1000)+"천"; 
		amv = amv - (Math.trunc(amv/1000)*1000);
	}	
	if(amv>=100) {
		rtn += Math.trunc(amv/100)+"백"; 
		amv = amv - (Math.trunc(amv/100)*100);
	}	
	if(amv>=10) {
		rtn += Math.trunc(amv/10)+"십"; 
		amv = amv - (Math.trunc(amv/10)*10);
	}
	if(amv==9) rtn += "구"; 
    if(amv==8) rtn += "팔"; 
    if(amv==7) rtn += "칠"; 
    if(amv==6) rtn += "육"; 
    if(amv==5) rtn += "오"; 
    if(amv==4) rtn += "사"; 
    if(amv==3) rtn += "삼"; 
    if(amv==2) rtn += "이"; 
    if(amv==1) rtn += "일"; 
	return rtn
}


</script>
<script id="initOnce">
/************************* 포털 INITIALIZE ***********************************/
var agent = navigator.userAgent.toLowerCase();
if ( (navigator.appName == 'Netscape' && agent.indexOf('trident') != -1) || (agent.indexOf("msie") != -1)) {
	alert("MS 인터넷익스플로러(IE)은 기술적으로 보안적으로 지원하지 않습니다.\n크롬이나 엣지 등 최신브라우저에서 접속해주세요!");
} 

function gfnInit(afnCallback) {  
    //MDI ( Frameset wrapper, Page Container ) : page와 Frameset간 Interaction...
	gMDI = new gfnMDI(".hk-wrapper",".hk-pg-wrapper"); 

<% if(!bSession || isNull(USERID) || "anonymous".equals(USERID)) { %> 
    gMDI.openPageOne("meisLogin");

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
	gMDI.openPageOne("meisHome");

<% } %>
	$("#initOnce").remove();
}  
/************************* 포털 INITIALIZE ***********************************/
</script>
</head> 
<body onload="gfnInit()">
   	<!-- Wrapper -->
	<div class="hk-wrapper" data-layout="navbar" data-layout-style="default" data-menu="light" data-footer="simple">
		<!-- Top Navbar -->
		<nav class="hk-navbar navbar navbar-expand-xl navbar-light fixed-top"  style="background-color:#efefef; padding-top:0">
			<div id="divNav" class="container-fluid">
				<!-- Start Nav -->
				<div class="nav-start-wrap flex-fill">
					<!-- Brand -->
					<a class="navbar-brand d-xl-flex flex-shrink-0 --d-none" href="meis.jsp">
						<img src="/images/MEISicon.png" alt="LF네트웍스 Mobile EIS" style="max-width:64px;max-height:48px" />
						<H2 class="display-5"><strong>모바일EIS</strong></H2>
					</a>
					<!-- /Brand --> 
				</div>
				<!-- /Start Nav -->

				<!-- Navbar Nav --><!-- /NavBar Nav -->
				
				<!-- End Nav --><!-- /End Nav -->
			</div>									
		</nav>
		<!-- /Top Navbar --> 

		<!-- Main Content -->
		<div class="hk-pg-wrapper"> 
			<!-- Page Footer -->
			<div class="hk-footer">
				<footer class="container-xxl footer">
					<p class="footer-text">
						<span class="copy-text">LF Networks © 2022 All rights reserved.</span> 
					</p> 
				</footer>
            </div>
            <!-- / Page Footer --> 
		</div>
		<!-- /Main Content -->
	</div> 
	<div class="loadTx">
		<div class="pop">
			<img src="/images/loader.gif">
			<div>
				서비스처리중입니다... 
				<span></span>
			</div>
		</div>
	</div>	
	<!-- Init JS -->
	<script src="/lib/jampack/dist/js/init.js"></script>
	<script src="/lib/jampack/dist/js/chips-init.js"></script>
	<!-- script src="/lib/jampack/dist/js/dashboard-data.js"></script -->
</body>
</html>