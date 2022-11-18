<%@ include file="/WEB-INF/src/common.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
/*********************************************************************************************************************************/
//세션에 따른 onload 이벤트 처리 적용
try {  
	//pgm 파라미터로 서비스 호출 : 사용안함
	if(!isNull(request.getParameter("pgm"))) { 
		Boolean rtnStat    = true;
		int     rtnCd      = 0;
		String  rtnMsg     = "";
		JSONObject OUTVAR = new JSONObject();
		try {
			String[] pgm = (request.getParameter("pgm")).split("\\.");   
			String func = nvl(request.getParameter("func"),"init");
			if(pgm.length == 2 && !isNull(func)) {
				String app = pgm[0]; 	
				String pgmid = pgm[1]+".jsp"; 
				pageContext.forward("./WEB-INF/meet/"+app+"/"+pgmid+"?func="+func);  
			} else {
				rtnStat = false;
				rtnCd   = 400;
				rtnMsg  = "Bad Request : "+nvl(request.getParameter("pgm"),"null")+"."+nvl(request.getParameter("func"),"init");	
			}
		} catch(Exception e) {  
			rtnStat = false;
			rtnCd   = 503;
			rtnMsg  = "Cannot load your request : "+e.toString();
		} finally {
			OUTVAR.put("rtnStat", rtnStat );
			OUTVAR.put("rtnCd",   rtnCd   );
			OUTVAR.put("rtnMsg",  rtnMsg  );
			out.println(OUTVAR.toString());
		}
		return;
	//go 파라미터로 페이지 이동 : 사용안함	
	} else if(!isNull(request.getParameter("go"))) {  
		//load html & flush DOM with bindVAR replacing
		try {
			String[] pgm = (request.getParameter("go")).split("\\.");   
			String app = pgm[0]; 	
			String pgmid = pgm[1]+".html"; 
			pageContext.forward("/apps/"+app+"/"+pgmid); 
		} catch(Exception e) {
			log.error("meet.jsp - DOM load Exception(index):",e); 
		}  
		return; 
    //r 파라미터로 회의실별 현 예약정보 표시 및 입실/예약취소/퇴실처리
	} else if(!isNull(request.getParameter("r"))) {
		//********MRHome을 Load할때 r값을 던져주고, MRHome의 fnInitExtra에서 아래로직 구현*****************
		//세션없으면 -> 로그인요청 후 로그인되면 아래로 현재 회의정보 페이지로 이동  
		//세션있고 현재 회의가 있으면 회의정보페이지로 이동 - 버튼클릭시 사용자와 예약자가 같을 경우 즉시처리
		//                                                버튼클릭시 사용자와 예약자가 다르면 빠른 비번입력
		//        현재 회의 없으면 회의실정보페이지로 이동 - 미래이면 예약버튼 표시

	} 
 
} catch(Exception e) {  
	//LOG
	log.error("meet.jsp - Critical Exception(index):",e); 
}
/*********************************************************************************************************************************/
%> 	
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no">
<meta http-equiv="X-UA-Compatible" content="IE=edge"/>
<meta name="format-detection" content="telephone=no"/>  
<title>LFN& 회의실관리</title>
<link rel="shortcut icon" href="/images/meet_logo.png" type="image/x-icon" />
<link rel="stylesheet" href="/lib/jquery-ui/jquery-ui-1.12.1.min.css" /> 
<link rel="stylesheet" href="/lib/agGrid/ag-grid.css">
<link rel="stylesheet" href="/lib/agGrid/ag-theme-balham.css">
<link rel="stylesheet" href="/lib/jquery-ui/select2.min.css" /> 
<link rel="stylesheet" href="/src/meet.css?20220503">
<link rel="stylesheet" href="/src/awecomponent.css?20220503">
<script type="text/javascript" src="/lib/jquery/jquery-3.6.0.min.js"></script>
<script type="text/javascript" src="/lib/jquery-ui/jquery-ui-1.12.1.min.js"></script>
<script type="text/javascript" src="/lib/jquery-ui/select2.min.js"></script>
<script type="text/javascript" src="/lib/jquery.scrollTo-2.1.3/jquery.scrollTo.js"></script> 
<script src="/lib/agGrid/ag-grid-enterprise.min.noStyle.js"></script>
<script src="/lib/ace/src-min/ace.js"  type="text/javascript" charset="utf-8"></script>
<script src="/lib/ace/src/ext-themelist.js"  type="text/javascript" charset="utf-8"></script>
<script src="/lib/ace/src/ext-language_tools.js"  type="text/javascript" charset="utf-8"></script>
<script src="https://kit.fontawesome.com/b8597271c4.js" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.3.2/chart.min.js" crossorigin="anonymous"></script>
<script src='https://cdn.tiny.cloud/1/d150u0g21azfsd5gx41u1ix2gkle25siousm8a7g6ij1z2h0/tinymce/5/tinymce.min.js' referrerpolicy="origin"></script> 

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/fullcalendar@5.10.1/main.css">
<script src="https://cdn.jsdelivr.net/npm/fullcalendar@5.10.1/main.js"></script>

<script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.18.1/moment.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/fullcalendar@5.10.1/locales-all.js"></script>
<script src="https://unpkg.com/typeit@8.3.3/dist/index.umd.js"></script> 
<script src="https://unpkg.com/scroll-out/dist/scroll-out.min.js"></script>
<script src="/lib/anime/anime.min.js"></script>

<script src="/src/awecommon.js?20220504"  type="text/javascript" charset="utf-8"></script>
<script src="/src/awecomponent.js?20220510"  type="text/javascript" charset="utf-8"></script>
<script>
var gfn = {};
var gObj = {};
var gParam = {};
var gds = {comcd:[]};
var gUserinfo = {userid:"anonymous"};

var lpcnt = 0;
function gfnLoad(pgm,oDOM,afnCallback,domChildClear) {
	lpcnt++;
	$.ajax({
		url: "/apps/m/"+pgm+".html?"+(date("today","yyyymmddhh24miss")+""+lpcnt),
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
			afnCallback(OUTVAR);
		},
		error: function(jqx, stat, err) {
			var OUTVAR = {rtnCd:"ERR",rtnMsg:"["+jqx.responseText+"]"};
			afnCallback(OUTVAR); 
		}
	});      
}
function gfnTx(pgm,func,data,afnCallback) {  
	$.ajax({
		url: "/awegtx.jsp?pgm="+pgm+"&func="+func,
		type: 'POST',
		dataType: 'json', 
		async: true,
		data: data,
		success: function(OUTVAR, stat) { 
			afnCallback(OUTVAR); 
			if(OUTVAR.rtnSubCd=="SESSION") gfnHome();
		},
		error: function(jqx, stat, err) {
			var OUTVAR = {rtnCd:"ERR",rtnMsg:"["+jqx.responseText+"]"};
			afnCallback(OUTVAR);  
		}
	});  
} 

function gfnSendMsg(toSys, useremail, msg, url, afnCallback) {
	if(toSys=="naverworks") {
		var userlist = [useremail]; //사용자ID
		var type = "link";  //or "text" // 텍스트 또는 링크
		var textMsg = msg; //메세지
		var link = nvl(url,"https://fo.lfnetworks.co.kr/meet.jsp"); //링크
		
		var usid = [];
		for(var i = 0; i<userlist.length; i++){
			usid.push({'usid':userlist[i], 'msg':textMsg, 'type':type, 'link':link});
		}
		var args = {};
		args.usidlist = usid;
		var invar = JSON.stringify(args);
		gfnTx("api.mr_naver_bot","sendMsg",{INVAR:invar},function(OUTVAR){
			//console.log(OUTVAR);
			if(OUTVAR.rtnCd=="OK") {
				afnCallback(OUTVAR);
			} else {
				gfnAlert("메세지 발송(네이버웍스 bot 전송) 오류",OUTVAR.rtnMsg);
			}
		});	
	} else if(toSys=="jandi") {
		var args = {};
		args.msgs = [{ email: useremail, body: msg,
		               connectInfo  : [ { title : "회의실 예약시스템",
                                          imageUrl : nvl(url,"https://fo.lfnetworks.co.kr/meet.jsp") } ] 
					 }];
		var invar = JSON.stringify(args);		
		gfnTx("api.mr_jandi_bot","sendMsg",{INVAR:invar},function(OUTVAR){
			if(OUTVAR.rtnCd=="OK") {
				afnCallback(OUTVAR);
			} else {
				gfnAlert("메세지 발송(잔디 bot 전송) 오류",OUTVAR.rtnMsg);
			}
		}); 
	}
}

function gfnAlert(title,content) {
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

function gfnLoadPage(pgm,afnCallback) {
	const mainContent = document.querySelector(".mainContent");
	gfnLoad(pgm,mainContent,OUTVAR=>{
		if(OUTVAR.rtnCd=="OK") {
			const panel = document.querySelector(".panel");
			panel.hidden = true; 
			mainContent.classList.remove("hidden");
			mainContent.hidden = false; 
			if(!isNull(afnCallback)) afnCallback();
		} else {
			gfnHome();
		}
	},true);
}

function gfnClosePop() { 
	$(".awePopLayer").remove();
}

function gfnHome() {
	const toggle = document.querySelector('.topbar .toggle');
	const navigation = document.querySelector('.navigation');
	const main = document.querySelector('.main');
	toggle.classList.remove('active'); 
	navigation.classList.remove('active');
	main.classList.remove('active');
	const panel = document.querySelector(".panel");
	panel.hidden = false; 
	const mainContent = document.querySelector(".mainContent");
	mainContent.hidden = true;
	const userarea = document.querySelector(".userarea");
	userarea.innerHTML = "";
	userarea.hidden = false;  
	ScrollOut({});
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

function gfnCheckQpass(gbn,userid) {
	if(gUserinfo.userid==userid) return true;
	else if(isNull(gUserinfo.userid)) {
		gfnAlert("세션체크",gbn+"처리를 위해서는 먼저 로그인 해야합니다.");
		return false;
	}
	else if(gUserinfo.userid=="BOT") {
		try { 
			var qpass  = prompt("빠른 "+gbn+"처리 - 예약자 전화번호 뒷 네자리를 입력:");
			var usinfo = subset(gds.users,"usid",userid)[0].tel_no;
			var pass   = usinfo.substr(usinfo.length-4, 4);
			var BOTinfo = subset(gds.users,"usid","BOT")[0].tel_no;
			var BOTpass = BOTinfo.substr(BOTinfo.length-4, 4);
			if(qpass==pass||qpass==BOTpass) return true;
			gfnAlert("비밀번호 틀림", "빠른 비밀번호가 틀렸습니다."); 
			return false;
		} catch {
			gfnAlert("비밀번호 체크오류", "빠른 비밀번호 점검 중 오류가 발생하였습니다. 다시 로그인 후 시도해주세요."); 
			return false;
		}
	} 
	else {
		gfnAlert("사용자 정보오류", gbn+"처리는 본인만 할 수 있습니다."); 
		return false;
	}
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

function gfnInit() {
	//Navigation toggle event handler
	const toggle = document.querySelector('.topbar .toggle');
	const toggle2 = document.querySelector('.navigation .toggle');
	const navigation = document.querySelector('.navigation');
	const main = document.querySelector('.main');
	const fnToggle=function() {
		toggle.classList.toggle('active');
		navigation.classList.toggle('active');
		main.classList.toggle('active');
	}
	toggle.addEventListener('click', fnToggle);
	toggle2.addEventListener('click', fnToggle); 
	
    //Navigation li a MenuClick event handler
    const menus = document.querySelectorAll('.navigation > ul  li > a');
	menus.forEach((el,idx)=>{
		el.addEventListener('click', function(e){
			if(!isNull(el.getAttribute("data-pgm"))) {
				const pgm = el.getAttribute("data-pgm");
				gfnLoadPage(pgm,function(){
					toggle.classList.remove('active'); 
					navigation.classList.remove('active');
					main.classList.remove('active'); 
				}) 
			} else {
				gfnHome();
			}
		});
	});
 
    //search click event bind
	const search = document.querySelector(".topbar .search");
	search.addEventListener('click', ()=>{
		gfnHome();
	});

    //user click event bind
	const user = document.querySelector(".topbar .user");
	user.addEventListener('click', ()=>{
		if(isNull(gUserinfo.userid) || gUserinfo.userid=="anonymous") {
			const pgm = "MRLogin";
			const panel = document.querySelector(".userarea");
			panel.innerHTML = "";
			gfnLoad(pgm,panel,OUTVAR=>{}); 
		} else {
			const pgm = "MRUser"; 
			const panel = document.querySelector(".userarea");
			panel.innerHTML = "";
			gfnLoad(pgm,panel,OUTVAR=>{}); 
		} 
	}); 

    //load MRHome to .panel, 사용자정보를 조회해온다.
	const pgm = "MRHome";
	const panel = document.querySelector(".panel");
    gParam.r = "<%= request.getParameter("r") %>"
	gfnLoad(pgm,panel,OUTVAR=>{
		//anime
		anime({
			targets: 'div.toggle',
			/*translateX: 250,*/
			delay: "1000ms",
			rotate: '1turn',
			/* backgroundColor: '#FFF', */
			duration: 800
		});
	},true);  
} 



</script>
</head>
<body onload="gfnInit()">
    <div class="container">
		<div class="navigation">
			<ul>
				<li class="LOGO">
					<a href="#" class="sys_logo">
						<img src="/images/meet_logo.png" class="CI">
						<img src="/images/meet_logo1.png"> 
						<div class="toggle"></div>
					</a>
				</li>
				<div id="member" class="hidden"> 
					<li>
						<a href="#" data-pgm="MRStatus">
							<span class="icon"><i class="fas fa-door-open"></i></span>
							<span class="title">회의실 현황</span>
						</a>
					</li>
					<li>
						<a href="#" data-pgm="MRReservation">
							<span class="icon"><i class="fas fa-calendar"></i></span>
							<span class="title">회의실 예약</span>
						</a>
					</li>
					<li>
						<a href="#" data-pgm="MRMyUsageHistory">
							<span class="icon"><i class="fas fa-list"></i></span>
							<span class="title">회의실 사용내역</span>
						</a>
					</li>
					<li>
						<a href="#" data-pgm="MRSearhEmp">
							<span class="icon"><i class="fas fa-search"></i></span>
							<span class="title">임직원 검색</span>
						</a>
					</li>
				</div> 
				<div id="admin" class="hidden"> 
					<H4>관리자 페이지</H4> 
					<li>
						<a href="#" data-pgm="MRAdmin">
							<span class="icon"><i class="fas fa-save"></i></span>
							<span class="title">회의실 정보</span>
						</a>
					</li>  
					<li>
						<a href="#" data-pgm="MRAdminUsers">
							<span class="icon"><i class="fas fa-save"></i></span>
							<span class="title">사용자 정보</span>
						</a>
					</li>  
					<li>
						<a href="#" data-pgm="MRAdminResvs">
							<span class="icon"><i class="fas fa-save"></i></span>
							<span class="title">예약정보관리</span>
						</a>
					</li>   
					<li>
						<a href="#" data-pgm="MRDouzoneTest">
							<span class="icon"><i class="fas fa-question"></i></span>
							<span class="title">더존 인사정보 조회</span>
						</a>
					</li>  
				</div>	 
			</ul>
		</div>
		<div class="main"> 
			<div class="topbar">
				<div class="toggle"></div>
				<div class="search">
					<label>
						<input type="text" list="searchList" placeholder="Search here...">
						<datalist id="searchList">
							<option value="hello">World</option> 
						</datalist>
						<i class="fa fa-search"></i>
					</label>
				</div>
				<div class="user">
					<img src="/images/noimg.png">
				</div>
			</div> 
			<div class="panel"> 
			</div> <!-- end of panel --> 
			<div class="mainContent hidden"></div>
			<footer>
				<p>Copyright © 2022 LF Networks co.,Ltd. All rights reserved.</p>
				<div class="notice">
					<h5>이메일주소 무단수집 거부</h5>
					<p>본 홈페이지에 게시된 이메일 주소가 전자우편 수집 프로그램이나 그 밖의 기술적 장치를 이용하여 무단으로 수집되는 것을 거부하며, 
					이를 위반 시 정보통신망법에 의해 형사 처벌됨을 유념하시기 바랍니다.</p>
					<span>게시일: 2022년 4월 24일</span>
				</div>
			</footer>
			<div class="userarea hidden"></div>
		</div> <!-- end of main -->
    </div> <!-- end of container -->
	<div class="aweStatus"></div>
</body>
</html>