/******************************************************************************************************************* 
* 전역변수
var rem     = 16;  //1rem이 몇 px인지 내부적으로 계산해 놓음

var gUserinfo;     //접속사용자정보 
var gds     = {};  //DATASET보관소 comcd, menu, ...
var gParam    ;    //페이지간, 페이지-팝업간 데이터통신 필요할때 사용
var gfn     = {};  //Context가 다른 window에서 원격호출이 필요한 경우 사용
var txcnt   = 0;   //txn 호출 Count

var gMDI    = {};  //포털 전체에서 사용되는 MDI Framework method호출용 
var gInterval ;    //사용자알리미 
var gDebug  = {};  //디버그용 DATASET보관소

* aweportal transaction ***************
gfnLoad(app,pgm,oContainer,callback,bSilence)
gfnJSON(mod,page,func,args,callback,bSilence)
_gfnAjax(mod,page,func,args,callback,ltxcnt,opt)
gfnAjax2(url,args,callback)                   : url직접호출
gfnDeploy(Obj,sArg)                           : Obj.html(sArg)실행하고 gfnResize()호출 
gfnCallback()                                 : callback이 지정되지 않았을때 콘솔에 결과찍어줌
gfnLog(pgm, data, key, func)		      : 로그 저장
gfnNotice(empList, app, msgKey, msg, register): socket.io 알림 저장 및 실시간 알림 전송

* aweportal messaging *********
gfnStatus(msg) : #frameStatus에 메시지표시
gfnAlert(title, content, afnCallback)         : alert창 표시
gfnPopup(title, content, aOpt, afnCallback)   : popup창 표시
gfnConfirm(title, content, afnCallback, oPos) : confirm창 표시

* aweportal common *************
gfnHome()   : pageHome만 표시, page#이 없을 경우 전체Reload함.
gfnLogout() : 로그아웃처리
gfnHelp(oPageInfo) : 도움말 팝업 호출
gfnSVC(oPageInfo)  : 서비스요청
gfnPersonalize(oPageInfo, pageid) : 개인화
 
* aweportal utilities ********
gfnGetUUID(digit)                                 : 문서번호등을 사용하기 위한 난수를 가져온다.
gfnGetImageUrl(logno)                             : TFILELOG 에서 이미지경로를 가져옴 
 
* window초기화
gButtonsetpanel 맨땅 찍을때 사라지게 하기
화면열릴때 스크롤 가장 위로 올려서 모바일 주소줄 사라지게 하기

 *******************************************************************************************************************/
/**** Global Variables *********************************************************************************************/
var gUserinfo = {};  //접속사용자정보 
var gds       = {};    //DATASET보관소
var gFrameset = {};  //frameset 
var gMDI      = {};  //MDI제어 = new gfnMDI();
var gfn       = {};  //framepageObject

var gParam  = {}  ;  //페이지간, 페이지-팝업간 데이터통신 필요할때 사용
var gParamFile = {};
var gPanelSeq = 0;   //팝업등으로 생성된 패널 일련번호(for unique ID)

var gObj      = {};  //전역오브젝트 
var gInterval ;      //사용자알리미 
var gDeferred = [];  //비동기Callback용 
var gDebug    = {};  //디버그용 DATASET보관소

var messages  = "";  //socket.io 서버 주소(frameSet에서 서버 주소 정의)

var encdeckey = "";	 //메세지 암호화, 복호화 키
/*** aweportal html laoderajax ************************************************************/
function gfnLoad(app,pgm,dom,callback,bSilence) {
	if(callback==undefined) {
		callback=gfnCallback;
		bSilence = true;
	}
	if(!bSilence) gfnAlert(1, "page loading : " + app + "." + pgm );
	$.ajax({
		url: "/apps/"+app+"/"+pgm+".html?"+date("today","yyyymmddhh24miss"),
		type: 'GET', /* static content는 POST가 아니라 GET으로 호출 */
		dataType: "html",   
		success: function(rtn) { // 위의 요청의 답으로 응답받은 데이터
			dom.attr("appid",app);
			dom.attr("pgmid",pgm);
			var oPage = $(rtn);

			progressUnvisible(); // progress 창 사라지기

			dom.html(oPage); //여기서 DB에서 요청받은 dom 안의 내용을 채워줌 
			var OUTVAR = {rtnCd:"OK",appid:app,pgmid:pgm}; 
			if (typeof(callback) == "function") callback();

			var args = {pgmid:pgm}
			var invar = JSON.stringify(args);
			gfnTx("aweportal.frameset","checkGfnTx",{INVAR:invar},function(OUTVAR){
				console.log("pageLoaded:"+pgm);
				console.log("checkGfnTx:");
				console.log(OUTVAR);
			});
		},
		error: function(jqx, stat, err) {

			progressUnvisible(); // progress 창 사라지기

			gfnStatus(err);
			var OUTVAR = {rtnCd:"ERR",rtnMsg:"["+jqx.responseText+"]"};
			callback(OUTVAR); 
		}
	});      
}

/**** aweportal transaction *********************************************************************************************/
function gfnTx(pgm,func,args,callback,bSilence) {
	if(!bSilence) gfnAlert(1, "transaction processing : " + pgm + "." + func );
	try { 
		var url = "awegtx.jsp?pgm="+pgm+"&func="+func;
		var async = true;
		if(args["async"]!=undefined) async = args["async"]; 
		var dataType = 'json';
		if(func=="init") dataType = 'html';
		if(args["datatype"]!=undefined) dataType = args["datatype"];  
			$.ajax({
				url: url,
				type: 'POST',
				dataType: dataType, 
				async: async,
				data: args,
				success: function(OUTVAR) {
					progressUnvisible(); // progress 창 사라지기 

					callback(OUTVAR); 
				},
				error: function(jqx, stat, err) {
					progressUnvisible(); // progress 창 사라지기
					
					gfnStatus(err);
					var OUTVAR = {rtnCd:"ERR",rtnMsg:"["+jqx.responseText+"]"};
					callback(OUTVAR); 
				}
			}); 
	} catch(e) { 
		gfnAlert("심각한 오류","처리 중 예외가 발생하였습니다..."+e, 1);
		var OUTVAR = {rtnCd:"ERR",rtnMsg:e};
		callback(OUTVAR);  
	}  
}

function gfnCallback() {
	logger("callback",arguments);
}

//알림 DB 저장 및 socket.io 실시간 알림 전송(수신자 배열, 앱, 메세지 키, 메세지 내용, 발신자 ID)
function gfnNotice(empList, app, msgKey, msg, register) {
	//3. DB 저장
	function empSend(data) {
		var args = {};
		args["listAlert"] = data;
		var invar = JSON.stringify(args);
		gfnTx("aweportal.frameset", "alertIU", { INVAR : invar }, function(OUTVAR) {
			if(OUTVAR.rtnCd == "OK") {
				//socket.io 알림 전송(DB 저장 데이터셋 전송);
				messages.emit("alert", data);
			}
		});
	}

	//2. 저장 데이터 가공
	function empData(data) {
		let temp = [];

		//유저가 여려명일 때,
		if(Object.keys(data).length > 1) {
			data.forEach((row) => {
				let listAlert = {};
				listAlert = {
					grpid       : row.usid,	//Receive USER ID
					ref_id      : app,		//APP ID
					ref_info_tp : msgKey,	//APP ID Specific Key
					comments    : msg,		//Message
					reg_usid    : register,	//Sent USER ID
					reg_dt      : null		//SYSDATE
				}
				temp.push(listAlert);
			})

		//유저가 한명일 때,
		} else if(Object.keys(data).length == 1) {
			let listAlert = {};
			listAlert = {
				grpid       : data.usid,	//Receive USER ID
				ref_id      : app,			//APP ID
				ref_info_tp : msgKey,		//APP ID Specific Key
				comments    : msg,			//Message
				reg_usid    : register,		//Sent USER ID
				reg_dt      : null			//SYSDATE
			}
			temp.push(listAlert);
		}
		empSend(temp);
	}

	//1. empList 변수 배열 체크(변수)
	if(!Array.isArray(empList)) {
		//배열이 아닌 경우, empList 값이 DEPT GRPID 인지, USER ID 인지 확인
		let args = { grpid : empList };
		let invar = JSON.stringify(args);
		gfnTx("aweportal.frameset", "alertCheckId", { INVAR : invar }, function(OUTVAR) {
			if(OUTVAR.rtnCd == "OK") {
				//empList GRPID 인 경우,
				if(OUTVAR.list.length > 0) {
					empData(OUTVAR.list);
				//empList USER ID인 경우,
				} else {
					empData( { usid : args.grpid });
				}
			}
		});
	//배열인 경우, 배열 가공
	} else {
		empData(empList);
	}
}
//로그 저장
function gfnLog(pgm, data, key, func, sub) {
	var args = {
		ref_id     : pgm
	  , comment_tp : func
      , comments   : null
	  , val_1      : key
	  , val_2	   : sub
	  //, val_3      : null
	  //, val_4      : null
	  //, val_5      : null
	}

	if(func == "save" || func == "confirm" || func == "reject" || func == "denied" || func == "deniedR" || func == "print") {
		var lg_tp      = data.lg_tp;
		var lg_tp_nm   = subset(subset(gds.comcd, "grpcd", "LG_TP"), "cd", lg_tp)[0].nm;
	
		var to_whcd    = data.to_whcd;

		var to_whcd_nm = null;

		if(to_whcd) {
			to_whcd_nm = subset(subset(gds.comcd, "comcd", "LFN"), "cd", to_whcd)[0].nm;
		} else {
			to_whcd_nm = data.to_wh_nm;
		}
		var lg_dt      = data.lg_dt;

		args.comments  = lg_tp_nm + " " + lg_dt + " " + lg_tp + " " + to_whcd_nm + " (" + sub + " 건)";

	} else if(func =="read") {
		if(sub) {
			args.comments = sub;
		}
	}
	var invar = JSON.stringify(args);
	gfnTx("aweportal.systemLog", "insertUserDocLog", { INVAR : invar }, function(OUTVAR) {
		if(OUTVAR.rtnCd == "OK") {
			//console.log(OUTVAR);
		};
	})
}

function gfnStatus(msg, state) {	
	//status layer 띄우기
	$("#status>ul").append('<li class="alert alert-dismissible alert-primary" style="top: ' + (40 * $("#status>ul").children().length + 90) + 'px;">' + msg + '<span>' + date("today","yyyy-mm-dd hh24:mi:ss") + '</span></li>');

	//status layer 사라지기
	setTimeout(function(){
		$("#status>ul>li").first().remove();
	}, 3000); 
}
 
function gfnAlert(title, content, afnCallback) {
	if(isNull(afnCallback)) afnCallback = gfnCallback; 

	if (!isNum(title)) {
		$("#alert .modal-content").draggable({handle: '.modal-header'});
		$("#alert h5").html(title);
		$("#alert p").html(content);

		// alert layer 띄우기
		$("#alert").css("z-index", 20);
		$("#alert").css("background-color", "rgba(0, 0, 0, 0.5)")
	}
	else {
		$("#progress h5").html("Progress");
		$("#progress p").html(content);

		// progress layer 띄우기
		$("#progress").css("z-index", 20);
		$("#progress").css("background-color", "rgba(0, 0, 0, 0.5)")
	}	
} 

function gfnCloseLayer (p) {
	if (p == "confirm") {
		$("#"+p).remove()
	}
	else {
		$("#"+p).css("z-index", -1);
		$("#"+p).css("background-color", "transparent") 
	}
}

function progressUnvisible() {
	// progress 창 사라지기
	$("#progress").css("z-index", -1);
	$("#progress").css("background-color", "transparent")
}

function gfnPopup(title, content, aOpt, afnCallback) {
	var popupMain = $("#popup .modal-content")

	$("#popup").css("left", 0);
	$("#popup").css("top", 0);
	$("#popup").css("width", "100%")
	$("#popup").css("height", "100%")
	popupMain.css("left", 0);
	popupMain.css("top", 0);

	if(isNull(afnCallback)) afnCallback = gfnCallback; 

	var width = aOpt.width ? aOpt.width : 400 ;
	var height = aOpt.height ? aOpt.height : 500;
	popupMain.css("width", width)
	popupMain.css("height", height)
	popupMain.css("left", "calc(50% - " + width/2 + "px)");
	popupMain.css("top", "calc(50% - " + height/2 + "px)");
	popupMain.resizable({minWidth: 200, minHeight: 200});
	
	$("#popup .modal-body").css("overflow", "scroll");

	$("#popup h5").html(title);
	$("#popup p").html(content);

	// popup layer 띄우기	
	$("#popup").css("z-index", 20);

	if (aOpt.modal) {
		$("#popup").css("position", "inherit")
		popupMain.draggable({handle: '.modal-header'});
		popupMain.css("left", "calc(50% - " + width/2 + "px)");
		popupMain.css("top", "calc(50% - " + height/2 + "px)");
		$("#popup").css("background-color", "rgba(0, 0, 0, 0.5)")
	} else {
		$("#popup").draggable({handle: '.modal-header'});
		$("#popup").css("position", "absolute")
		$("#popup").css("left", "calc(50% - " + width/2 + "px)");
		$("#popup").css("top", "calc(50% - " + height/2 + "px)");
		$("#popup").css("width", width)
		$("#popup").css("height", height)
		$("#popup").css("background-color", "transparent")
	}
}

function gfnConfirm(title, content, afnCallback, oPos) {
	if(isNull(afnCallback)) afnCallback = gfnCallback; 

	$("body").append(' <div id="confirm" class="modal" style="background-color: rgba(0, 0, 0, 0.5); z-index: 20;">\
												<div class="modal-content">\
														<div class="modal-header">\
																<h5 class="modal-title">'+ title +'</h5>\
																<button class="layerBtn btn-close" data-bs-dismiss="modal" aria-label="Close"\
																		onclick="gfnCloseLayer("confirm")">\
																</button>\
														</div>\
														<div class="modal-body">\
																<p>'+content+'</p>\
														</div>\
														<div class="modal-footer">\
																<button class="layerBtn btn btn-primary yes">확인</button>\
																<button class="layerBtn btn btn-secondary no" data-bs-dismiss="modal" onclick="gfnCloseLayer("confirm")">취소</button>\
														</div>\
												</div>\
										</div>')

	$("#confirm .yes").click(function(){
		afnCallback(true); 
		gfnCloseLayer("confirm")
	})
} 

/**** aweportal portal Common *****************************************************************************/
function gfnHome() {
	if($("#frameTab a.tab").length > 0) {
		gMDI.hideAll();
	} else {
		location.href="/index.html?"+date("today","yyyymmddhh24miss"); //location.reload();
	}
}

function gfnShowUserPanel() { 
	/*gfnLogout();  
	*/
	// var userPanel = gfnPanel({width:"100%",height:"500px"},true);
	// gfnLoad("aweportal","userinfo",userPanel,function(OUTVAR){
	// 	var mW = 800;
	// 	var mH = 550;
		 
	// 	gfnPopup("사용자정보",userPanel,opts); 
	// });
	var userPanel = $("<ul></ul>");
	var menus = [
		{ id:"manageProfile", nm:"프로필관리"},
		{ id:"changePwd", nm:"비밀번호 변경" },
		{ id:"withdrawlUser", nm:"회원탈회" },
		{ id:"logout", nm:"로그아웃" },
	];
	for(var i=0; i<menus.length; i++) {
		var menu = menus[i];
		var menuli = $(`<li>${menu.nm}</li>`);
		menuli.on("click",function(e){
			var oE = $(e.target);
			
			// gfnAlert("메뉴가 눌렸음", oE.text());
			switch(oE.text()){
				case "프로필관리" :
          
					gMDI.openPage("manageProfile","프로필 관리",function(OUTVAR){ 
						//do nothing 
					},"aweportal");
					break;

				case "비밀번호 변경" :  
					$(function(stat) {
						var userProfile = $(`<div><ul id="list"></ul></div>`);
						var collist = ["nm","nick_nm","photo","email"];
						var oTbl = userProfile.find("#list");
						var oRow = $(`<li></li>`);
						stat = (stat==undefined)?"new":stat;
						for(var i=0; i<collist.length; i++) {
							var colid = collist[i]; 
							var oCol = $(`<input type="text" name="${colid}" value="" placeholer="${stat}">`);
							oCol.on("change",function(e){
								var el = $(e.target);
								var label = el.prev("label");
								label.text( label.text()+"*" );
							});
							oRow.append(oCol);
							oCol.before( $(`<label>${colid}</label>`) );                
						}
						
						oTbl.append(oRow); 
						userProfile.append(oTbl);
						var opts = { resizable: false, height: 700, minWidth: mW, minHeight: mH, modal:false };
						gfnPopup("비밀번호 변경", userProfile, opts);
						return oRow;
					});

					break;
				case "회원탈회" :
					gfnAlert("메뉴가 눌렸음",oE.text());
					break;
				case "로그아웃" :
					gfnLogout();
					break;
			}
		});
		userPanel.append(menuli);
		
	}
	var opts = { resizable: false, height: 550, minWidth: mW, minHeight: mH, modal:false };
	gfnPopup("사용자정보 관리", userPanel, opts)

}

function gfnLogout( bChk ) { 
	if(bChk==undefined) {
		gfnConfirm("로그아웃","로그아웃 하시겠습니까?",function(resp) {
			gfnLogout(resp);
		}); 
	} else if(bChk==false) {
		return;
	} else {
		gfnTx("aweportal.login","logout",{},function(OUTVAR){
			if(OUTVAR.rtnCd=="OK") {  
				var data = { status : "logout",  grpid : "main", userid : gUserinfo.userid, usernm : gUserinfo.usernm };
				messages.emit("main", data);
			    location.reload();
			}
		}); 
	}
}

function gfnHelp(oPageInfo) { // 도움말 팝업 호출
	gfnAlert("Page Help","on construction :"+oPageInfo.pgmnm);
}

function gfnSVC(oPageInfo)  { // 서비스요청
	gfnAlert("Customer Service Request","on construction :"+oPageInfo.pgmnm);
} 

function gfnPersonalize(oPageInfo, pageid) { // 개인화
	gfnAlert("Personalize","on construction.:"+oPageInfo.pgmnm);
}

function gfnCalendar() {
	var opts = { 
		autoOpen: true,
		width:400,
		height:600 
	}
	var oPage = $("<div></div>");
		oPage.attr("id","calendar");
		oPage.addClass("framepage");
	gfnLoad("aweportal","calendar",oPage,function(){	
		gfnPopup("시간과 달력", oPage , opts);
	});
}

/*** 사용자기본값 가져오기 *************************************************************************************/
function gfnDefVal(grpcd) {
	if( isNull(subset( subset( gUserinfo.defval, "grpcd", grpcd ), "defyn", "Y")) == false
		&& subset( subset( gUserinfo.defval, "grpcd", grpcd ), "defyn", "Y")[0] != undefined
		&& subset( subset( gUserinfo.defval, "grpcd", grpcd ), "defyn", "Y")[0].cd != undefined ) { 
		return subset( subset( gUserinfo.defval, "grpcd", grpcd ), "defyn", "Y")[0].cd;
	} else return "";
} 
function gfnDefValObj(grpcd) {
	var defval = subset(subset(gUserinfo.defval,"grpcd",grpcd),"defyn","Y");
	if(defval != undefined && defval.length == 1) {
		return defval[0];
	} else {
		return {grpcd:grpcd, cd:"", nm:""}
	}
}

/*** 데이터 *************************************************************************************/
function gfnGetImageUrl(imgno, afnCallback) {
	var url = "./images/noimg.png";
	if(isNull(imgno)) {
		afnCallback( url );
		return;
	} else { 
		gfnTx("aweportal.frameset","retrieveImgUrl",{imgno:imgno},function(OUTVAR){
			if(OUTVAR.rtnCd == "OK") url = OUTVAR.url;
			afnCallback( url );
		},true);
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