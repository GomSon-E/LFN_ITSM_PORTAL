/* aweportal Components **************************************************************************************************************************************************
*portal컴포넌트****
gfnMDI(tabContainer, pageContainer)  : tab/pageContainer로 구성된 mdi세팅
gfnMenu(menuContainer, oMDI)         : .side의 메뉴바와 메뉴팝업

*page컴포넌트 & util******
gfnButtonSet(btnContainer, afnEH, btnOpt)  : 기능버튼셋 세팅
gfnSearch(grpcd, term, fnCallback, opt)    : 공통코드 구분에 해당하는 코드/명 검색팝업. opt: auto, multi             

*portal util****** 
gfnframePageInit(pageid)              : 페이지생성 후 공통초기화 
gfnResize()                           : window변경에 따른 .main영역 높이 잡아주기 
gfnSetGridHeight(mdiPageId, gridId, marginBottom) : mdipage내의 gridId의 높이 잡아주기 
gfnAutocompleteOpen(str, term)        : autocomplete 결과 검색어 Highlight주기
setOptions(arr,cdcolnm,nmcolnm,bAll,defVal,disp)       : arr에서 지정된 코드/명 컬럼으로 Option만들어주기
setCheckboxes(fieldsetID, arr, cdcolnm, nmcolnm)  : fieldsetID 하위에 다중체크박스 만들어주기 

*grid컴포넌트*******
gfnGuideText()                           : guideText 설정
gfnAgGridDisp(gridid, oData, opt )       : agGrid 컨포넌트
  gfnAnalyze(rawData, aDS) => colinfo     : 데이터셋 분석
  gfnAgGridColDef(colinfo) => colDefs     : agGrid용 컬럼정의 
  gfnAgGridCellEditor                     : agGrid 컬럼 입력컨트롤 정의   
  gfnAgGridCellRenderer                   : agGrid 컬럼 조회컨트롤 정의 
  gfnAgDetailCellRenderer                 : gObj.DetailRender.ID 사용하여 init, refresh
gfnGridTable(containerId,aDS, opt,aEH)   : GridTable 컨포넌트
aweFormUtil(sDiv, oOpt, afnEH)           : form 컨포넌트 
*************************************************************************************************************************************************************************/

function gfnMDI(pageContainer,tabContainer) {
	var me = this;
	me.tabContainer = tabContainer;
	me.pageContainer = pageContainer;
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
		me.idx;
		return me.idx;
	}
//frameBottom 의 좌우버튼 색표시
	me.syncGNB = function() { 
		var prev = me.tabContainer.children("a.active").prev().length;
		if(prev > 0) $("#frameBottom button.prev").removeClass("noMore");
		else $("#frameBottom button.prev").addClass("noMore");
		var next = me.tabContainer.children("a.active").next().length;
		if(next > 0) $("#frameBottom button.next").removeClass("noMore");
		else $("#frameBottom button.next").addClass("noMore"); 
	}
	//frameHome 로드 
	me.loadHome = function(afnCallback) { 
		var oPage = $("<div></div>");
		oPage.attr("id","frameHome");
		oPage.addClass("framepage");

	
		gfnLoad("aweportal","frameHome",oPage,function(OUTVAR){
			me.pageContainer.children("#frameHome").remove();
			me.pageContainer.append(oPage);
			me.go(0);
			me.syncGNB();
			me.tabContainer.sortable(); //jquery sortable적용  
			if(afnCallback==undefined) afnCallback=gfnCallback;
			afnCallback();
		});
	} 
	//frameLeft 메세지 채널 초기화
	me.portletChat = function() {
		$("#frameLeft .grpChat *").remove();
		var portletChat = $("#frameLeft .grpChat");
		gfnLoad("aweportal", "portletChat", portletChat, function(OUTVAR) {
		}, true);
	}

	me.portletAlert = function() {
		var portletAlert = $("#frameAlert");
		gfnLoad("aweportal", "portletAlert", portletAlert, function(OUTVAR) {
		}, true);
	}
	
	//한 개의 특정 페이지로 이동
	me.goOne = function(grpid) {
		//1. 이미 열려있는 채팅방 페이지로 (채팅방 이름과 id를 사용해서)이동하도록 구현
		var toPage;

		toPage = me.pageContainer.children(".framepage[grpid='"+grpid+"']");

		toPage.addClass("active");
		toPage.show();

		//2. 현재 활성화된 페이지의 active를 제거한 뒤, hide()처리
		me.pageContainer.children(".framepage").removeClass("active");
		me.pageContainer.children(".framepage").hide();

		//3. 전환될 페이지를 active 상태로 show()
		toPage.addClass("active");
		toPage.show();

		//4. 현재 페이지 탭의 active를 제거
		me.tabContainer.children("a.active").removeClass("active");

		//5. 이동한 페이지의 tab을 active
		me.tabContainer.children("a[pageidx='"+ toPage.attr("id") +"']").addClass("active");

		//6. frameBottom CSS 추가
		me.syncGNB();
	}

	//특정 framepage로 이동 
	me.go = function(to) { 
		var curPage = me.pageContainer.children(".framepage.active");
		if(curPage.length < 1) {
			curPage = me.pageContainer.children(".framepage").last();
			if(curPage.length == 0) {
				gfnAlert("오류","열려있는 페이지가 없습니다.");
				return;
			}
		} 
		else if (curPage.length > 1) curPage = curPage.last();

		var toPage;			
		if(to=="home" || to==0 ) { 
			toPage = $("#frameHome");
		} else if (to=="prev"||to=="next") {
            //prev/next는 tab기준으로 한다
			var toTab = me.tabContainer.children("a.active")[to]();
			if(toTab.length==0) {
				gfnStatus("이동할 수 있는 페이지의 끝입니다.");
				toTab = (to=="prev")?me.tabContainer.children("a").last():me.tabContainer.children("a").first(); //한바퀴 돌리고
			} 
			if(toTab.length==0) toPage = $("#frameHome"); //그래도 없으면 frameHome으로 
			else toPage = me.pageContainer.children(".framepage[id='"+ toTab.attr("pageidx") +"']");
		} else {
			if(to instanceof jQuery) {
				toPage = to; 
			} else { 
				toPage = $(to);
				if(toPage.length==0) toPage=$("#"+to);
			}
			if(toPage.length == 0) {
				gfnStatus("요청된 페이지가 존재하지 않습니다.");
				toPage = $("#frameHome");
			}
		} 
		me.pageContainer.children(".framepage").removeClass("active");
		me.pageContainer.children(".framepage").hide();
		toPage.addClass("active");
		toPage.show();
		me.tabContainer.children("a.active").removeClass("active");
		me.tabContainer.children("a[pageidx='"+ toPage.attr("id") +"']").addClass("active");		
		me.syncGNB();  
	}  
	//특정 framepage로 이동 
	me.focusPage = function(pageidx) {  
		me.go(pageidx);  
	}
	//frameHome만 남기고 다 숨겨줌
	me.hideAll = function() { 
		me.go(0);
	}

	//프레임페이지를 중복 없이 한 개만 열기
	me.openPageOne = function(pgmid, pagenm, grpid, grpnm) {
		//아래는 openPage와 코드가 같으며, page 넘버링 및 탭 추가, 화면 추가 전환 코드
		//if(afnCallback==undefined) afnCallback=gfnCallback;
		me.getNext();

		//페이지를 생성할 때, 버튼으로 건네받은 grpid를 프레임 요소로 삽입
		//같은 채팅방 호출 시, 열려있는 탭의 유무를 pgmnm으로 확인한 뒤, grpid로 해당 채팅방으로 보내주도록 구현
		var oPage = $('<div class="framepage" id="page'+me.idx+'" grpid='+grpid+'></div>');

		//grpnm이 있는 경우,
		if(grpnm != undefined) {
			oPage.attr("grpnm", grpnm);
		}

		gfnLoad("aweportal", pgmid, oPage, function(OUTVAR){
			var oTab = $('<a class="tab" pageidx="page'+me.idx+'" grpid="'+grpid+'"><div>'+pagenm+'</div><i class="fa fa-times closetab"></i></a>');
			oTab.bind('mouseenter', function(){ /* 폭이 좁아져서 ...이 되면 tooltip으로 화면명 표시 */
				var $this = $(this); 
				if(this.offsetWidth < this.scrollWidth && !$this.attr('title')){
					$this.attr('title', $this.text());
					$this.tooltip({
						content: $this.text()
					}); 
				}
			});
			
			//요청으로 생성되는 탭을 포함해서 카운트하도록 탭을 먼저 생성
			me.tabContainer.append(oTab);

			//현재 활성화된 탭과 페이지의 넘버는 탭의 개수와 무관하므로(중간 탭을 닫아 중간 번호가 삭제되었을 수 있다)
			//getNext로 생성된 페이지 넘버만큼 카운트하는 것이 탭의 개수를 구함
			var countTab = me.getNum();

			//중복 카운트
			var count = 0;

			//활성화와 관계없이 생성된 탭 크기만큼 반복
			for(var i = 0; i < countTab; i++) {
				//현존하는 모든 탭 중에서 grpid를 가진 탭들 중 요청받은 grpid가 있는 경우 카운트
				if(me.tabContainer.children("a.tab[pageidx=page"+(i+1)+"]").attr("grpid") == grpid) {
					count++;
				}
			}
			
			//1개 이상은 중복이므로,
			if(count > 1) {
				//추가한 탭을 제거한 뒤,
				me.tabContainer.children("a.tab").last().remove();
				
				//생성한 페이지번호를 감소
				me.getPrev();

				//grpid로 만들어진 페이지로 이동
				me.goOne(grpid);
				return;

			} else {
				//페이지를 append
				me.pageContainer.append(oPage);

				//focus
				me.go(oPage);
				//afnCallback("page"+me.idx);	
			}
		});
	}

	//framepage 열기(추가)
	me.openPage = function(pgmid, pagenm, afnCallback, appid) { 
		if(afnCallback==undefined) afnCallback=gfnCallback;
		//get pgm info 
		var pgm = subset(gds.menu,"pgmid",pgmid);
		if(pgm.length == 0) {
			//메뉴에 추가되지 않은 화면을 호출하려면 appid를 던져줘야 한다.
			if(appid==undefined) {
				gfnStatus("요청된 페이지가 존재하지 않습니다.");
			    afnCallback(false);
			    return;	
			}  
		} else {
			pgm = pgm[0];
			appid = pgm.app_pgmid; 
		}
		//loadPage
		me.getNext(); 		
		var oPage = $('<div class="framepage" id="page'+me.idx+'"></div>');
		gfnLoad(appid, pgmid, oPage, function(OUTVAR){
			//addTab
			var oTab = $('<a class="tab" pageidx="page'+me.idx+'"><div>'+pagenm+'</div><i class="fa fa-times closetab"></i></a>');
			oTab.bind('mouseenter', function(){ /* 폭이 좁아져서 ...이 되면 tooltip으로 화면명 표시 */
				var $this = $(this); 
				if(this.offsetWidth < this.scrollWidth && !$this.attr('title')){
					$this.attr('title', $this.text());
					$this.tooltip({
						content: $this.text()
					}); 
				}
			});
			me.tabContainer.append(oTab); 
			//addPage
			me.pageContainer.append(oPage);
			//focus
			me.go(oPage); 
			//flex 리사이즈 기능
			gfnPageLayoutResizable(oPage); 

			//callback
            if(typeof(afnCallback)=='function') afnCallback(OUTVAR);

			//Logging
			var invar = JSON.stringify({ pgmid : pgmid });
			gfnTx("aweportal.systemLog", "insertOpenPageLog", { INVAR : invar }, function(OUTVAR) {
				if(OUTVAR.rtnCd != "OK") console.log(OUTVAR); 
			});
		});
	}

	//채널 생성(중복 x)
	me.openChat = function(pgmid, grpid) {
		var count = 0;
		var container = $("<div id='" + grpid + "' class='frameChat focus'></div>");

		//페이지 카운트
		if(document.getElementById(grpid)) count++;

		//페이지가 존재하는 경우, 페이지 넘버를 이전으로 돌린 후, 리턴
		if(count > 0) return;
		
		//grpid 메세지 채널이 없는 경우, frameChat 메세지 채널을 삽입
		else {
			gfnLoad("aweportal", pgmid, container, function(OUTVAR) {
				$("#frameChat").append(container);
			}, true);
		}
	}

	//한페이지 생성된 탭닫기
	me.closeTabOne = function(grpid) {
		me.goOne(grpid);
		me.go("next");

		me.pageContainer.children(".framepage[grpid='"+grpid+"']").remove();
 		me.tabContainer.children("a.tab[grpid='"+grpid+"']").remove();

		if(me.tabContainer.children("a").length==0) {
			//if(!me.tabContainer.hasClass("hidden")) me.tabContainer.addClass("hidden");
			me.go(0);
		}
	}

	//탭과 페이지 닫기
	me.closeTab = function(pageidx) {
		if(pageidx=="frameHome") {
			gfnStatus("홈화면은 닫을 수 없습니다.");
			return; 
		}
		//일단 닫으려는 탭으로 이동 후
		me.go(pageidx);
		
		//max상태의 창이 닫히면 새로운 창은 stat max를 넣어줘야 함
		var pageStat = $(".framepage.active").attr("stat"); 

		//Next로 Focus하고 나서
		me.go("next");
		$(".framepage.active").attr("stat",pageStat);

		//remove page
		me.pageContainer.children(".framepage[id='"+pageidx+"']").remove();
 		me.tabContainer.children("a.tab[pageidx='"+pageidx+"']").remove();
		delete gfn[pageidx];

		//남은 것이 없으면 Home으로
		if(me.tabContainer.children("a").length==0) {
			//if(!me.tabContainer.hasClass("hidden")) me.tabContainer.addClass("hidden");
			$("#frameGNB").css("display","block");
			gFrameset.fnShowFrameLeftBar(true); 
			gFrameset.fnFramesetLayout(); 
			me.go(0); 
		}
	} 

	//채널 닫기
	me.closeChat = function(grpid) {
		$(".frameChat[id='" + grpid + "']").remove();
	}

	me.screen = function(bMax) {   
		var curPage = $("#frameMain .framepage.active");
		if(curPage.length == 0 || curPage.attr("id")=="frameHome") return;
		if(bMax==undefined) {
			bMax = (curPage.attr("stat")!="max");
		}
		if(bMax) { 
			gFrameset.fnShowFrameLeftBar(false);
			$("#frameGNB").css("display","none");
			$("#frameBottom nav .screen").addClass("max");
			gFrameset.fnFramesetLayout(); 
			curPage.attr("stat","max");
		} else {
			$("#frameGNB").css("display","block");
			$("#frameBottom nav .screen").removeClass("max");
			gFrameset.fnFramesetLayout();
			curPage.attr("stat","normal");
		} 
	}

	me.close = function() {
		var curPage = $("#frameMain .framepage.active");
		if(curPage.length == 0) return;
		me.closeTab( curPage.attr("id") );
	}

//******************** YONG START 210821 ********************
	$(me.tabContainer).on("click",function(e){
		var oE = $(e.target);
		if(oE.isON("[pageidx]")) {
			var pageidx = oE.attr("pageidx")||oE.parents("[pageidx]").attr("pageidx");
			
			//그룹 아이디 추가
			var grpid = oE.attr("grpid")||oE.parents("[grpid]").attr("grpid");
			if(isNull(pageidx)) {
				return;

			} else if(!isNull(grpid) && oE.hasClass("closetab")) {
				me.closeTabOne(grpid);

			} else if(oE.hasClass("closetab")) {
				me.closeTab(pageidx);

			} else {
				me.focusPage(pageidx);
			}
		} 
	}); 

	/* 현재시간 : frameset의 fnInit()에 있어야 하지만 소스엉킴 문제로 gfnMDI에서 구현 */ 
	if( $("#frameGNB .curtime").length > 0) $("#frameGNB .curtime").remove(); 
	var curtime = $("<div class='curtime'></div>"); 
	$("#frameGNB nav.frameBtnSet.A").append(curtime);
	function curtime_ticker() {
		$("#frameGNB .curtime").html( date("today","mm월dd일<br>(w요일)<br>hh24:mi:ss") );
	} 
	window.setInterval( curtime_ticker, 1000); 
	
	return me;
}

/** PageLayoutResizable */ 
function gfnPageLayoutResizable(oPage) {
	function fnFlexRowResizable(oPage) {
		//page내의 pageContent하위에 flexRow가 있으면 
		$(oPage).find(".flexRow").each(function(idx,el) { 
			if(!$(el).hasClass("pageContent") && $(el).parents(".pageContent").length==0) return;  
			$(el).addClass("Resizable");
		});
		$(oPage).on("click",function(e) { 
			if(!($(e.target).hasClass("flexRow")&&$(e.target).hasClass("Resizable"))) return;
			if($(e.target).hasClass("active")) return;
			var handler = $("<div class='flexRowHandler'></div>"); 
			oPage.css("position","relative");
			var leftPage = oPage.position().left;
			var ofsPage = oPage.offset().left;
			var flex = $(e.target);			
			var leftFlex = flex.position().left;
			var ofsFlex = flex.offset().left;
			var wFlex = flex.outerWidth();
			var topFlex = flex.position().top; 
			var hFlex = flex.outerHeight();
			var leftPos = 0;
			var adjX = e.offsetX + (ofsFlex - ofsPage);
			var evtIdx = -1;  
			var idxEnd = flex.children("*:visible").length-1; 
			//console.log(leftPage+" / "+ofsPage+" on "+ adjX +" -> "+leftFlex+" / "+ofsFlex+" : "+wFlex);
			flex.children("*:visible").each(function(idx,el){
				var elX = $(el).position().left;
				var ofX = $(el).offset().left;
				var elW = $(el).outerWidth();
				//console.log(idx+" : "+elX+" / "+ofX+" : "+elW);
				if(adjX < elX) {
					return false;
				} else if(elX+elW < adjX) {
					leftPos = elX+elW;
					evtIdx = idx; 
				}
			}); 
			if(evtIdx < 0) return false; //시작점 이벤트 무시
			if(evtIdx == idxEnd) return false; //끝점 이벤트 무시 
			handler.css({"top":(topFlex+6)+"px","left":(leftPos+1)+"px","height":(hFlex-12)+"px"}); //클릭된 위치에 핸들러표시
			oPage.append(handler);
			flex.addClass("active");
			handler.data("flex",flex); //리사이징을 위해 flexRow를 data로 보내준다. 
			handler.draggable({ 
				axis: "x", 
				containment: "parent", 
				stop: function(e,ui) {
					var flex = $(this).data("flex"); 
					var preX = 0; //요소별로 앞 요소의 좌표를 확인 
					var evtX = ui.originalPosition.left; //이벤트가 일어난 X
					var move = ui.position.left - ui.originalPosition.left; //조정된 폭
					var arrData = []; //변화전 폭정보를 일단 모은다. each에서 변화시키면 다음 줄이 flex확장되어 버림 
					var evtIdx = -1; //변화해야할 요소 순번
					flex.children("*:visible").each(function(idx,el){
						var elX = $(el).position().left;
						var elW = $(el).outerWidth();
						if( preX < elX && elX+elW < evtX ) { //변화해야할 요소 순번 찾아냄
							if(elW+move < 100) move = (-1*elW) +100; //변경크기의 최소값을 정해줌
							evtIdx = idx; 
						} else if (evtIdx!=-1 && idx==evtIdx+1) { //변화할 다음 요소의 너비보다 크게 키워지면 
							if(elW-move < 100) move = elW-100;
						}
						arrData.push(elW); 
						preX = elX+elW ;
					});
					if(evtIdx >= 0) {
						for(var i=0; i < arrData.length; i++) { 
							if(i==evtIdx) flex.children("*:eq("+i+")").css("flex","1 1 "+(arrData[i]+move-12)+"px");
							else if(i==evtIdx+1) flex.children("*:eq("+i+")").css("flex","1 1 "+(arrData[i]-move-12)+"px");
							else flex.children("*:eq("+i+")").css("flex","1 1 "+(arrData[i]-12)+"px");
						}
					} 
					flex.removeClass("active");
					this.remove();
				} 
			});  
		});  
	} 
	fnFlexRowResizable(oPage);

    /*

	//pageContent 내에 flexColumn 중 Grid가 있는 aweForm과 인접하지 않은 요소에 Resizable을 추가함 
	$(oPage).find(".pageContent.Column, .pageContent .flexColumn").each(function(idx,el) {

		$(el).addClass("Resizable");
	});
	//flexColumn 리사이즈 기능
	$(oPage).on("click",".pageContent .flexColumn",function(e) { 
		if($(e.target).hasClass("flexColumn") && !$(e.target).hasClass("componentContainer")) { 
			var handler = $("<div class='flexColumnHandler'></div>"); 
			oPage.append(handler);
			oPage.css("position","relative");
			var topPage = oPage.offset().top;	
			var topFlex = $(e.target).position().top;				
			var posFlex = $(e.target).position().left; 
			var wFlex = $(e.target).outerWidth(); 
			handler.css({"top":(topFlex+e.offsetY-6)+"px","left":(posFlex+6)+"px","width":(wFlex-12)+"px"}); //클릭된 위치에 핸들러표시
			handler.data("flex",$(e.target)); //리사이징을 위해 flex를 data로 보내준다.
			handler.draggable({ 
				axis: "y", 
				containment: "parent", 
				stop: function(e,ui) {
					var flex = $(this).data("flex");
					var hFlex = flex.outerHeight();
					var preY = 0; //요소별로 앞 요소의 좌표를 확인 
					var evtY = ui.originalPosition.top; //이벤트가 일어난 y
					var move = ui.position.top - ui.originalPosition.top; //조정된 폭
					var arrData = []; //변화전 폭정보를 일단 모은다. each에서 변화시키면 다음 줄이 flex확장되어 버림 
					var evtIdx = -1; //변화해야할 요소 순번
					console.log(evtY + ":" + move);
					flex.children("*").each(function(idx,el){
						var elY = $(el).position().top;
						var elH = $(el).outerHeight();
						if( preY <= elY && elY+elH <= evtY ) { //변화해야할 요소 순번 찾아냄
							if(elH+move < 48) move = (-1*elH)+48; //변경크기의 최소값을 정해줌
							evtIdx = idx; 
						} else if (evtIdx!=-1 && idx==evtIdx+1) { //변화할 다음 요소의 너비보다 크게 키워지면 
							if(elH-move < 48) move = elH-48;
						}
						arrData.push(elH); 
						preY = elY+elH;
					});
					console.log("adjusted :" + move);
					if(evtIdx >= 0) {
						for(var i=0; i < arrData.length; i++) { 
							if(i==evtIdx) {
								flex.children("*:eq("+i+")").css("flex","1 1 "+(arrData[i]+move-12)+"px")
							} else if(i==evtIdx+1) {
								flex.children("*:eq("+i+")").css("flex","1 1 "+(arrData[i]-move-12)+"px");
							} else {
								flex.children("*:eq("+i+")").css("flex","1 1 "+(arrData[i]-12)+"px");
							}
						}
						setTimeout( function() {
							flex.find(".componentBody").each(function(idx,el){
								$(el).attr("mission","done");
								$(el).css({"height":"calc(100% - 2em) !important"});
							});
						}, 1);
					} 
					this.remove();
				} 
			}); 
		}
	}); 
	*/
}

/** MDI TABS/PAGES, MENU SHOWS ***********************************************************************************************************************/
function gfnTab(containerid, tabsid, option) {
	//container안에 tabsid와 refid가 모두 있어야 한다. 
	var opt = { 
		"multi-active":"off",
		"toggle-switch":"off" 
	} 
	opt = $.extend(opt,option);
	//옆으로 늘어지도록 aweTab Class를 추가함
	$("#"+containerid+" #"+tabsid).addClass("aweTab");
	//각 탭은 refid를 가지고 있어야 하며, 제어를 위해 tab Class를 추가하고, 콘테이너ID를 추가해준다.
    $("#"+containerid+" #"+tabsid).children("[refid]").each(function(idx,tab){
    	$(tab).addClass("tab");
    	$(tab).attr("containerid",containerid);
    }) 
    //탭 클릭이벤트시 refid영역을 보이고, 숨긴다.
    $("#"+containerid+" #"+tabsid+" .tab").on("click",function(e){
		//탭제어
    	var me = $(this);
        me.toggleClass("active");
		if(opt["multi-active"]=="off") { //다중active허용하지 않으면 
			me.siblings(".active").removeClass("active"); //다른 active제거
		}
		if($("#"+containerid+" #"+tabsid+" .tab.active").length==0) { //반드시 하나는 active
			me.addClass("active");
		} 
		//탭상태에 따라 container안의 refid 표시
    	$("#"+containerid+" #"+tabsid+" .tab").each(function(idx,tab){
    		var tab = $(tab);
            if(tab.hasClass("active")) {
				$("#"+tab.attr("containerid")+" #"+tab.attr("refid")).show();
			}
            else {
				$("#"+tab.attr("containerid")+" #"+tab.attr("refid")).hide(); 
			}
    	});
    }); 
    //toggle-switch가 on이면 multi-active를 제어할 수 있는 버튼을 보여준다. 
    if(opt["toggle-switch"]=="on") {
		$("#"+containerid+" #"+tabsid).find("i.fas").remove(); //없애고 추가해준다. 
    	var btnToggle = $("<i class='fas fa-toggle-off' style='margin-left:auto'></i>");
        $("#"+containerid+" #"+tabsid).append(btnToggle);
        if(opt["multi-active"]=="on") btnToggle.addClass("fa-toggle-on");
        btnToggle.on("click",function(e){ 
        	$(this).toggleClass("fa-toggle-on"); 
        	if($(this).hasClass("fa-toggle-on")) {
				opt["multi-active"]="on";
			} else {
				opt["multi-active"]="off";
				$("#"+containerid+" #"+tabsid+" .tab.active:eq(0)").trigger("click");
			}
        }); 
    } 
    
    //첫번째 탭을 클릭해준다.
    $("#"+containerid+" #"+tabsid+" .tab:eq(0)").trigger("click");
}

/* framepage 화면의 이벤트 -  조회조건 숨김, Quick Guide, Screen화면최대/원복버튼, 탭, ComponentTitle접기/펴기 발생시 
   그리드를 화면 가장 끝에 맞춰지도록 확장/축소해줌 */
function gfnFramepageLayout() { 
	//화면에 노출되는 가장 마지막 그리드의 높이를 페이지 하단에 맞도록 조정해준다.
	//framepage.active 의 높이를 맞춰준다.
	var tgt = $("#frameset .framepage.active .pageContent .componentBody.agGrid:visible:last");
	if( tgt.parent(".componentContainer").next(".componentContainer:visible").length == 0 ) {
		if(!tgt.parent(".componentContainer").hasClass("flexColumn")) tgt.parent(".componentContainer").addClass("flexColumn");
	}  
	var activePageId = $("#frameset .framepage.active").attr("id");
	if(!isNull(gfn[activePageId]) && !isNull(gfn[activePageId].fnFramepageLayout)) gfn[activePageId].fnFramepageLayout();
}

/*
let stylesheet = new CSSStyleSheet();
//document.styleSheets[document.styleSheets.length] = stylesheet;
function gfnReplaceCss(rule) {
	stylesheet.replace(rule)
		.then(() => {   console.log(stylesheet.cssRules[0].cssText);
	})
	.catch(err => {
		console.error('Failed to replace styles:', err);
	});
}
*/




/** framepage 초기화 및 공통이벤트 적용 */
function gfnFramepage( page ) {
    var me = this;
    me.page = $("#"+page.pageid);
    me.init = function() {
        me.initPageNav();
		me.initPageTop(); 
		window.setTimeout( gfnFramepageLayout, 50); 
        return me;
    }

    me.initPageNav = function() {
        var pageNav = $(`#${page.pageid} > .pageNav`); 
        if(pageNav.length <= 0) return; 

        // 북마크기능 고쳐야함
		var userMenuInfo = subset(gds.menu,"pgmid",page.dataDef._pgm.pgmid)[0];
        var fav = "";
        if( userMenuInfo!=undefined && userMenuInfo.fav_yn =="Y" ) fav ="fav";

        pageNav.html(`<div class="navTree">
            <span colid="app_pgmid">${page.dataDef._pgm.app_pgm_nm}</span>&nbsp>&nbsp   
            <span colid="pgm_grp_nm">${page.dataDef._pgm.pgm_grp_nm}</span>&nbsp>&nbsp
            <span colid="pgm_nm">${page.dataDef._pgm.pgm_nm}</span> 
            </div>`);

        pageNav.append(`<div class="commonFunc">
            <button class="icon" id="bookmark"><i class="far fa-bookmark"></i></button>
            <button class="icon" id="help"><i class="fas fa-question"></i></button>
            <button class="icon" id="csr"><i class="fas fa-desktop"></i></button>
            <button class="icon" id="close"><i class="fas fa-times"></i></button>
            </div>`); 


        //pageNav : Event-Handling
        // 여기 고쳐야함 기능들 >>> 북마크/도움말/CSR/창닫기
        pageNav.off("click");
        pageNav.on("click", function(e) {
            var oE = $(e.target);
			// MDI framepage의 공통버튼 클릭시 이벤트 처리 
			var btnMe = oE.exactObj("button.icon");
			if(btnMe.attr("id") == "bookmark") {
				console.log('bookmark 기능');
			}
			else if(btnMe.attr("id") == "help") {
				console.log('help 기능');
				// var popid = "help" + gMDI.getNext(); // gMDI..가 뭐죠
				// var container = $("<div id='"+popid+"' class='framepage active'></div>");
				var container = $("<div id='popid' class='framepage active'></div>");
				me.page.append(container);
				gParam = $.extend(true, gParam, { appid:page.appid, pgmid:page.pgmid, dataDef:page.dataDef });
				gfnLoad("aweportal","manageHelp",container,function(){ 
					gfnPopup("프로그램 이용 가이드", container, {width: 1000, height:700});
				});
			}
			else if (btnMe.attr("id") == "csr") { 
				console.log('csr 기능');
			}
			else if (btnMe.attr("id") == "close") {
				console.log('close 기능');
				gMDI.close();
			}
        });
    }

    me.initPageTop = function() {
        //화면타이틀
        me.pageTop = $(`#${page.pageid} > .pageTop`);
        if(me.pageTop.length <= 0) return;  

        me.pageTitle = $(`<div class="pageTitle">${page.dataDef._pgm.pgm_nm}</div>`);
        var viewBtn = $(`<button class="icon moreBtn"><i class="fas fa-caret-down"></i></button>`);
        me.pageTitle.append(viewBtn);
		me.pageTop.append(me.pageTitle);
		
		me.pageTop.children("*").remove();
		me.pageTop.html(me.pageTitle); //pageTop초기화

		// console.log(`${page.dataDef._pgm.pgm_nm} 타이틀 추가함`);

        // pageCond 숨기는 기능
        viewBtn.on("click", function(e){
            if(viewBtn.hasClass("clicked")){
                viewBtn.removeClass("clicked");
                $(`#${page.pageid} >.pageCond`).css("display", "block");
            }else{
                viewBtn.addClass("clicked");
                $(`#${page.pageid} >.pageCond`).css("display", "none");
            }
        })

        //기능버튼
        me.pageFunc = $(`<div class="pageFunc"></div>`); 
        me.pageTop.append(me.pageFunc);
        page.pageObj["_pageFunc"]  = new gfnButtonSet( "#"+page.pageid+" > .pageTop > .pageFunc", page.dataDef["_pgm_func"], page.fnEH );

	}

    me.init();
}

function gfnComponent( pageId, containerId, componentDef, afnEH, page ) {
	var me = this; 
	me.componentId = containerId;
	me.containerId = "#"+pageId+" "+((containerId=="pageCond")?".":"#")+containerId;
	me.container = $(me.containerId);
	me.componentDef = $.extend({},componentDef);
	me.init = function() {
		me.container.addClass("componentContainer");
		if(containerId=="pageCond") me.initPageCond();
		else me.initComponentTitle();
		me.initComponentBody();
		return me;
	}
	me.initPageCond = function() {
		
	},
	me.initComponentTitle = function() {
		// console.log("initComponentTitle");

		me.container.children("*").remove(); //일단 지우고 시작
		me.container.html("");
		me.componentTop = $(`<div class="componentTop"></div>`);
		//ComponentTitle
		me.componentTitle = $(`<div class="componentTitle">${me.componentDef.data_nm}</div>`);
		// if(!isNull(me.componentDef.data_icon)) {
		// 	me.componentTitle.append(`<i class="${me.componentDef.data_icon}"></i>`);
		// } else {
		// 	me.componentTitle.append(`<i class="fas fa-square"></i>`);
		// }
		// if(!isNull(me.componentDef.data_nm)) me.componentTitle.append(`<span>${me.componentDef.data_nm}</span>`); 
		// me.componentTitle.on("click",function(e) { //클릭하면 func와 body를 보이거나 숨긴다. 
		// 	if( me.componentTitle.hasClass("closed")) {
		// 		me.componentTitle.removeClass("closed"); 
		// 		me.componentTop.children(".componentFunc").show();
		// 		me.container.children(".componentBody").show();
		// 		me.container.removeClass("contentClosed"); 
		// 	} else {
		// 		me.componentTitle.addClass("closed");
		// 		me.componentTop.children(".componentFunc").hide();
		// 		me.container.children(".componentBody").hide(); 
		// 		me.container.addClass("contentClosed"); 
		// 		/*me.container.css("flex","unset !important")
		// 		if(me.container.siblings(".componentContainer").find(".componentBody.agGrid").length > 0) {
		// 			me.container.siblings(".componentContainer").css("flex","1 1 auto"); 
		// 		} 
		// 		*/ 
		// 	}
		// });
		me.componentTop.append(me.componentTitle);
		
		//ComponentFunc  
		if(!isNull(me.componentDef.component_option)) { 
			me.componentTop.children(".componentFunc").remove();
			me.componentFunc = $(`<div class="componentFunc"></div>`);
			//component_option .remark, .content, .func
			if(!isNull(me.componentDef.component_option) && !isNull(me.componentDef.component_option.remark)) {
				me.componentFunc.append(`<h5 class="quickGuide">${componentDef.component_option.remark}</h5>`);
			}
			//[SEL:30줄씩][BTN:추가] 등을 구현할때 아래와 같이 사용한다.
			if(!isNull(me.componentDef.component_option) && !isNull(me.componentDef.component_option.content)) { 
				me._componentCond = {};
				for(var i=0; i < me.componentDef.component_option.content.length; i++) {
					var colinfo = me.componentDef.component_option.content[i]; 
					me._componentCond[colinfo.colid] = new gfnControl(colinfo,function(colid, evt, newval){
						//이벤트를 바인딩해준다. 
						afnEH(me, "componentCond", evt, colid, newval );
					});
					me.componentFunc.append( me._componentCond[colinfo.colid].dispObj );
				}
			} 			
			if(!isNull(me.componentDef.component_option) && !isNull(me.componentDef.component_option.func)) { 
				//기능버튼이 있으면 추가해주고
				me.componentFunc[me.componentDef.data_id] = new gfnButtonSet(me.componentFunc, me.componentDef.component_option.func, function(btnSet, evt, funcid, func) { 
					//이벤트를 바인딩해준다. 이때 이벤트유형은 componentFunc이다.
					afnEH(me, "componentFunc", funcid, func);
				}); 
			} 
			else {
				me._componentFunc = new gfnButtonSet(me.componentFunc); 
			}
			me.componentTop.append(me.componentFunc);
		}

		me.container.append(me.componentTop);
		// if(me.componentDef.data_id == "pgm_data_content"){
		// 	$(`#${me.componentDef.data_id} > #${containerId}`).append(me.componentTop);
		// } else {
		// 	$(`#${me.componentDef.data_id}`).append(me.componentTop);
		// }
	} 
	me.initComponentBody = function() {
		me.componentBody = $(`<div class="componentBody"></div>`); 
		me.componentBody.addClass(me.componentDef.component_pgmid);
		me.component_option = me.componentDef.component_option;
		//컴포넌트Body그리드 높이지정: 미지정시 컨텐츠에 맞게 늘어남 
		// if(!isNull(me.component_option)) {
		// 	// if(!isNull(me.component_option.height)) me.componentBody.css("height",me.component_option.height );
		// 	if(!isNull(me.component_option.width)) me.componentBody.css("width",me.component_option.width );
		// 	if(!isNull(me.component_option.class)) me.componentBody.addClass( me.component_option.class );
		// }    
        //aweForm의 Body
		if( me.componentDef.component_pgmid =="aweForm" ) {  
			me.colinfo = me.componentDef.content;
			me.col = {}; //aweForm은 me.col[colid] 로 해당 컬럼에 접근할 수 있다. 
			me.data = {}; //정의되지 않은 컬럼의 값도 get/set하고 import/export할 수 있다.
			//컬럼별로 section > colgrp : label > .aweCol 로 배치해줌  
			var container = me.componentBody;
			var grpcontainer = me.componentBody;
			var curSection = "_init";
			var curColgrp = "_init";
			for(var i =0; i < me.colinfo.length; i++) {
				var colinfo = me.colinfo[i];
				//section이 없거나 바뀌었으면...
				if(isNull(nvl(colinfo.section,""))) container = me.componentBody;
				else if (colinfo.section!=curSection) {
                    curSection = colinfo.section;
					container = $(`<fieldset section="${curSection}" style="flex-basis: ${colinfo.w}%"></fieldset>`).appendTo(me.componentBody);
					var sLegend = $(`<legend></legend>`);
					if(!isNull(colinfo.section_icon)) sLegend.append(`<i class="${colinfo.section_icon}"></i>`);
					sLegend.append( " "+curSection );
					container.append( sLegend );
				} 
				//colgrp이 바뀌었으면...라벨을 달아줘야함
				if(isNull(nvl(colinfo.colgrp,""))) {
					grpcontainer = $(`<div colgrp="${colinfo.colnm}"></div>`).appendTo(container);
					grpcontainer.append(`<label>${colinfo.colnm}</label>`);
				} else if (colinfo.colgrp!=curColgrp) {
                    curColgrp = colinfo.colgrp;
					grpcontainer = $(`<div colgrp="${curColgrp}"></div>`).appendTo(container);
					grpcontainer.append(`<label>${curColgrp}</label>`);
				} 
                grpcontainer.addClass(colinfo.attr);
				/*************************************************************************/
				/* 컬럼: 컨트롤&eventHandler Callback *************************************/
				/*************************************************************************/
				me.col[colinfo.colid] = new gfnControl(colinfo,function(colid, evt, newval){ 
					if(evt=="change" && newval != me.data[colid]) {
						me.setStat(true);
					}
					//이벤트를 바인딩해준다. 
					afnEH(me, evt, 0, colid, newval );
				},me); //,me : 컴포넌트 자신도 던져줘서 이벤트시 컬럼상호작용시 참조토록 함
				grpcontainer.append( me.col[colinfo.colid].dispObj ); //컬럼추가
				
				/* 컬럼의 폭을 지정해줌 (w) */
				grpcontainer.css("flex-basis", `${nvl(colinfo.w, 100)}%`)

                /* 컬럼Group의 바깥크기를 지정해 줌 */
				var colgrpWidth = 0;
				if( grpcontainer.children("label").length > 0) colgrpWidth = 5;
				if( grpcontainer.children(".aweCol, .aweColWrap").length > 0) {
					grpcontainer.children(".aweCol, .aweColWrap").each(function(idx,el){
						colgrpWidth += toNum($(el).attr("w")); 
					})
				}
				// if( colgrpWidth > 0) grpcontainer.css("width",colgrpWidth+"em");

			}
			// form상태 : "" -> "C" 초기화 상태에서 값이 변경되면 C가 되고
			//          : ""-> "R" -> "U" Import되었다가 값이 변경되면 U가 됨
			me.stat = "";
			me.setStat = function(bChange) {
				if(bChange==true) {
					if(me.stat=="") me.stat="C";
					else if(me.stat=="R") me.stat="U";
				} else {
					if(me.stat=="C") me.stat="";
					else if(me.stat=="U") me.stat="R";
				}
				for(var colid in me.col) {
					if( inStr(me.col[colid].attr,"pk") >= 0 ) {
						if( me.stat=="R"||me.stat=="U") me.col[colid].setDisable(true);
						else me.col[colid].setDisable(false);
					}
				}
			}
			//setVal
			me.setVal = function(colid,val) {
				if(me.col[colid] == undefined) {
					me.data[colid] = val; 
				} else {
					me.col[colid].setVal(val); //setVal과정에서 정제될 수 있으므로
					me.data[colid] = me.getVal(colid); //data는 정제된 값을 적재함.
				}  
			}			
			//getVal 
			me.getVal = function(colid) {
				if(me.col[colid] == undefined) return me.data[colid];
				else return me.col[colid].getVal();
			} 
			//cval 
			me.cval = function(colid, val) {
				if(val==undefined) me.getVal(colid);
				else me.setVal(colid, val);
			}
			//dispVal : dtype에 의해 표시된 값을 그대로 가져옴 
			me.dispVal = function(colid) {
				if(me.col[colid] == undefined) return me.data[colid];
				else return me.col[colid].dispVal();
			}
			//form에 데이터표시 : 정의하지 않은 컬럼은 데이터를 저장하지 않는다. 
			me.importFormData = function(rowdata, stat) {
				try {
					if($.type(rowdata)!='array') rowdata = $.makeArray(rowdata);
					for(var colid in rowdata[0]) { //첫번째 데이터만 사용 
						me.setVal(colid, rowdata[0][colid]);
					}
					me.stat = nvl(stat,"R");
					me.setStat(false);
					return true;
				} catch {
					return false;
				}
			}
			//form에서 데이터추출 : 정의하지 않은 컬럼은 데이터를 리턴하지 않는다. 
			me.exportFormData = function() {
				var rtnData = [];
				var row = {};
				for(var i=0; i < me.colinfo.length; i++) {
					var colinfo = me.colinfo[i]; 
					row[colinfo.colid] = me.getVal(colinfo.colid); 
				} 
				row.crud = me.stat;
				rtnData.push(row);
				return rtnData;
			}
			//form에 데이터표시 : 정의하지 않은 컬럼은 데이터저장 
			me.importData = function(rowdata, stat) {
				try {
					delete me.data; me.data=[];  
					if($.type(rowdata)!='array') rowdata = $.makeArray(rowdata);
					rowdata = rowdata[0]; //배열로 만든후 첫번쨰 Row만 Import함 
                    var cols = extract(me.colinfo,"colid");
				    var colDefVals = extract(me.colinfo,["colid","defval"]); 
				    var curcols = Object.keys(nvl(rowdata,{})); 
					curcols.forEach((colid)=>{ //신규데이터에 있는 컬럽값은 row에 넣어주고 
						me.setVal(colid,rowdata[colid]); 
					});
					cols.forEach((colid)=>{ //컬럼정의에 있으나 신규데이터에 없는 컬럼은 기본값 넣어줌 
						if(curcols.length == 0 || inStr(curcols,colid) < 0) {
							me.setVal(colid, eval2(subset(colDefVals,"colid",colid)[0].defval)); 
						}
					});  
					me.stat = nvl(stat,"R");
					me.setStat(false);
					return true;
				} catch {
					return false;
				}
			}
			me.exportData = function() { 
				var rtndata =  {};
				var cols = extract(me.colinfo,"colid");  
				rtndata = $.extend({},me.data);
				cols.forEach((colid)=>{ //컬럼정의에 있는 컬럼값은 최종값 넣어줌  
					rtndata[colid] = me.getVal(colid); 
				});  
				rtndata.crud = me.stat;
				return [rtndata];
			} 
			//resetForm
			me.reset = me.initComponentBody;
			//focus
			me.focus = function(colid) {
				if(!isNull(me.col)&&!isNull(me.col[colid])&&!isNull(me.col[colid].obj)&&!me.col[colid].obj.is(":focus")) me.col[colid].focus();
			}
			//보이기 숨기기
			me.setDisp = function(colid, bShow) { 
			    if(!isNull(me.col[colid])) {
					me.col[colid].setHidden(!bShow);
					var colgrp = me.col[colid].obj.exactObj("[colgrp]");
					if(bShow) { 
						colgrp.show(); colgrp.removeClass("hidden");
					} else {
						if(colgrp.find(".aweCol").map((idx,el)=>$(el).css("display")).get().every(el=>el=='none')) colgrp.hide(); 
					}
					var section = colgrp.exactObj("[section]");
					if(bShow) {
						section.show(); section.removeClass("hidden");
					} else {
						if(section.children("[colgrp]").map((idx,el)=>$(el).css("display")).get().every(el=>el=='none')) section.hide();
					}
				}
			}			
			//validation 
			me.chkValid = function(bWarn) {
				if(bWarn==undefined) bWarn = true;
				for(var i=0; i < me.colinfo.length; i++) {
					var colinfo = me.colinfo[i]; 
					if(me.col[colinfo.colid] == undefined) continue;
					var chk = me.col[colinfo.colid].chkValid(bWarn); //validation Error인 경우 메시지
					if(chk != true) {
						me.col[colinfo.colid].focus();     //컬럼에 포커스만 주고 
						return false; 
					}
				}
				return true;
			} 
			//auto complete, popup, select, radio의 선택가능 옵션을 변경함 
			me.refreshOptions = function(colid, arr) {
				//arr에는 grpcd, 데이터배열, function이 들어올 수 있다.
				if(me.col[colid] != undefined) me.col[colid].refreshOptions(arr);
			} 

		} else if( me.componentDef.component_pgmid =="agGrid" ) {
			me.colinfo = me.componentDef.content;
			me.component_option = me.componentDef.component_option;
			//붙여넣기 강제실행 컬럼
			if(!isNull(me.component_option) && inStr(me.component_option.gridOpt,"bForcePaste")>=0) me.bForcePaste = true; 
			//컴포넌트Body그리드 높이지정: 미지정시 기본값 적용 
			var gridHeight = "calc(100% - 2em)"; //그리드 높이지정
			if(!isNull(me.component_option)&&!isNull(me.component_option.height)) {
				me.componentBody.css("height",me.component_option.height);
			} else {
				//me.componentBody.css("height",gridHeight); 
				//me.componentBody.css("min-height","10em");
				me.componentBody.addClass("gridHeight");
			}
			//me.componentDef.component_option.rowSelection 오류 방어코드
			me.rowSelection = null;
			if(!isNull(me.component_option)&&!isNull(me.component_option.rowSelection)) {
				me.rowSelection = me.component_option.rowSelection;
			}
			me.filter=function(node) {
				if(node.data) {
					if(node.data.hide=="Y") return false; 
				}
				return true;
			}
			me.componentBody.addClass("ag-theme-balham");
            me.gridOptions = {
				/*************************************************************************/
                /* define grid columns & event Handler ***********************************/
				/*************************************************************************/
                columnDefs: gfnAgGridColumnDef(
					me,
					me.colinfo, 
					function(nodeid, colid, evt, newval) {
						if(evt=="change" && me.gridOptions.api.getRowNode(nodeid)!=undefined) {
							me.setCRUD(nodeid,"U");
						}
						afnEH(me, evt, nodeid, colid, newval);
					}
				), 
				/* editType: 'fullRow',*/
                // default ColDef, gets applied to every column
                defaultColDef: {  
					/*suppressSizeToFit: true,*/
                    resizable: true, 
                    sortable:true,
					filter:true,
                    /*floatingFilter: true,*/
                    cellStyle: function(param) {
                        return gfnAgGridCellStyle(me.colinfo, param);
                    }, 
					suppressKeyboardEvent: function(params) { 
						if(isNull(params.event.target)) return false; //타겟element가 없을때 그리드 기본 이벤트처리
						if(isNull(params.event.key)) return false; //키보드값 없을때 그리드 기본 이벤트처리
						if(isNull(params.event.type) || params.event.type!="keydown") return false; //키보드값 없을때 그리드 기본 이벤트처리
						if(!isNum(params.node.rowIndex)) return false; //이벤트가 일어난 row가 없을때 그리드 기본 이벤트처리
						if(isNull(params.column.colId)) return false; //이벤트가 일어난 column이 없을때 그리드 기본 이벤트처리 
						var keyCode   = params.event.key;
						var rowToMove = params.node.rowIndex;
						var colId     = params.column.colId;
						if(keyCode=="Home"||keyCode=="End") return false; //Home,End키값 그리드 기본 이벤트처리
						//console.log(keyCode+" on"+colId+" / editing:"+params.editing); //LOGGING....
						if(isNull(params.colDef)||isNull(params.colDef.cellRendererParams)) return false;
						var colinfo = params.colDef.cellRendererParams.colinfo; 
						if(isNull(colinfo)) return false; //해당cell의 colinfo가 없으면 그리드기본 이벤트처리
						//INPUT Edit Mode일때 키보드 위 아래로 줄이동
						if(colinfo.etype=="txt"||colinfo.etype=="pwd") {
							if(!params.editing) {
								//console.log("not editing"); 
								return false; //편집모드가 아닐때는 그리드 기본 이벤트처리
							}
							if( keyCode=="ArrowDown"||keyCode=="ArrowUp") { //autocomplete아니면서 위 아래키 일때 커서이동
								//autocomplete아니면서 위 아래키 일때 커서이동안함
								if(inStr(colinfo.attr,"auto") >= 0) return true; 
								//위아래 이동 가능하면 이동
								if(keyCode=="ArrowDown") rowToMove++;
								else rowToMove--;  
								if(rowToMove >= 0 && rowToMove < me.countRow()) {	
									me.forceFocus(rowToMove,colinfo.colid,true);
									return true;
								} else {
									//그렇지 않으면 그리드 기본 이벤트처리 
									return false;
								}
							} else if (keyCode=="Enter" || keyCode=="Esc") {
								//autocomplete이고 Enter키 일때 포커스를 주려 하였으나.
								//Editing상태일떄는 아예 이벤트가 오지 않음
								if(inStr(colinfo.attr,"auto") >= 0) {
									me.forceFocus(rowToMove,colinfo.colid,false); 
								}
							}
							return false;
						} 
						if(colinfo.etype=="cbx") { 
							if(keyCode==" " && params.event.type=="keypress") {
								var nodeId = me.getNodeId(rowToMove);
								//console.log("["+nodeId+":"+me.getVal(nodeId,colinfo.colid)+"]");
								if(me.getVal(nodeId,colinfo.colid)=="Y") me.setVal(nodeId,colinfo.colid,"N");
								else me.setVal(nodeId,colinfo.colid,"Y"); 
							}
						} 
						if(colinfo.etype=="sel") { //SELECT일때 
							if(params.editing) {
								//console.log(keyCode); //editing상태에는 focus가 들어오지 않음
								if( keyCode == "Enter") return false;
							}
							/*{
								if ( keyCode=="ArrowDown"||keyCode=="ArrowUp") { //편집모드에서 옵션이 닫혀있는 상태일때만 이벤트가 발생함: 화살표키 작동중지처리
									if(keyCode=="ArrowDown") rowToMove++;
									else rowToMove--;   
									if(rowToMove >= 0 && rowToMove < me.countRow()) {	
										me.forceFocus(rowToMove,colinfo.colid,false); 
									}
									return false;
								} else if( keyCode == "Enter") {
									return true;
								} 
							} 
							*/ 
						} 					  
						//TEXTAREA에서 들어가는 Enter에서 값 사라짐
						if(colinfo.etype=="tarea") { 
							try {
								if(params.editing) {  
									if( keyCode == "Enter") { //편집모드일때 엔터키는 무시 -> ESC사용
										return true; //그리드 기본 이벤트처리 제한  	
									} else {
										return false;
									} 
								} else { //!params.editing
									if( keyCode == "Enter") { 
										setTimeout(function(){
											me.forceFocus(rowToMove,colinfo.colid,true); 	
										},1); 
										return true;
									}
								} 
							} catch {
								me.forceFocus(rowToMove,colinfo.colid,true); 
								return true;
							}
						}
					},
					/* flex:1, master-detail */
                },
				/* skipHeaderOnAutoSize:true, */
				/* rowHeight: 24, */
				getRowHeight: function(params) { 
					/*  console.log("*** RowHeight ***");  */
				    if(!isNull(params) && !isNull(params.node) && !isNull(params.node.detail)) {
						return nvl(toNum(me.gridOptions.detailRowHeight), 40);
					} else if(!isNull(params) && !isNull(params.data) && !isNull(params.data.rowheight) ) {
						return toNum(params.data.rowheight);
					} else {
						return 24;
					}
				}, 
				getRowClass : function(params) {
					//console.log("*** RowStyle ***");
					//console.dir(params);
					if(params.data!=undefined && params.data.crud=="D") {
						return 'aweRow-deleted';
					} else if(params.data!=undefined && params.data.hide=="Y") {
						return 'aweRow-hide';
					} if(params.data!=undefined && !isNull(params.data.subsumrow)) {
						return 'aweRow '+params.data.subsumrow;
					} else if(params.data!=undefined && !isNull(params.data.rowbg)) {
						return 'aweRow '+params.data.rowbg;
					} else {
						return 'aweRow';
					}
				},
				isExternalFilterPresent: function(){ return typeof(me.filter)=='function'},
  				doesExternalFilterPass: me.filter,
				rowSelection: nvl(me.rowSelection,'multiple'),
				/* rowDeselection: true,*/
				singleClickEdit: true, 
				enableRangeSelection: true, 
				/* stopEditingWhenCellsLoseFocus: true, */
				/* suppressRowTransform: true, */
				animateRows: true,
				multiSortKey: 'ctrl',
				statusBar: {
					statusPanels: [
						{
							statusPanel: 'agAggregationComponent',
							align: 'left',
						}
					]
				},
				/* sideBar: 'columns', */
				onCellFocused:function(e){ 
					if(isNull(e.column)) return false; 
					else if(e.column.userProvidedColDef!=undefined && me.cellFocusedHack==(e.rowIndex+","+e.column.userProvidedColDef.field)) return false;
					else me.cellFocusedHack = e.rowIndex+","+((!isNull(e.column.userProvidedColDef))?e.column.userProvidedColDef.field:null); 
					var node = me.grid.gridOptions.api.getDisplayedRowAtIndex(e.rowIndex);
					if(isNull(node) || isNull(node.id)) return false;
					me.onFocus(node.id, (e.column.userProvidedColDef!=undefined)?e.column.userProvidedColDef.field:"", e);
				},
				/*
				onCellValueChanged: function(params) { 
					var node = me.grid.gridOptions.api.getDisplayedRowAtIndex(params.rowIndex);
					if(node.data.crud != "C" && node.data.crud != "D") node.data.crud = "U"; 
					if(me.bEvent) {
						//console.log("grid change");
						afnEH(me, "change", node.id, params.column.colId, params.value);
					}
				},		
				*/ 		
				onCellDoubleClicked: function(params) { 
					var node = me.grid.gridOptions.api.getDisplayedRowAtIndex(params.rowIndex);
					if(me.bEvent) {
						//console.log("grid dblclick");
						afnEH(me, "dblclick", node.id, params.column.colId, params.value);
					}
				}, 
				onCellKeyDown: function(e) {
					//한칸만 선택했을때 row Object Data가 복사되는 것을 방지함.
					if( (e.event.key == 'c' || e.event.key == 'C')&&e.event.ctrlKey == true ) {
						var cells = me.grid.gridOptions.api.getCellRanges(); //getRangeSelections();
						if(cells.length == 1 && cells[0].columns.length==1) {
							var cell = cells[0];
							if(cell.startRow == cell.endRow ) {
								me.grid.gridOptions.api.copySelectedRangeToClipboard();
								e.event.preventDefault();	
								e.event.stopPropagation();
								e.event.stopImmediatePropagation();
								return false; 
							} 
						}
					} else if (e.event.keyCode == 13) { 
						var node = me.grid.gridOptions.api.getDisplayedRowAtIndex(e.rowIndex);
						afnEH(me, "enter", node.id, e.column.colId, e.value);  
					}
				}, 
				onFirstDataRendered: function(params){
					me.focusRow(0);
				}, 
				onPasteStart: function(params) { 
					me.grid.gridOptions.api.stopEditing(false); 
					if(me.bForcePaste) { //수정불가컬럼도 붙여넣기 하고 싶을때 이 옵션을 사용한다. 
						me._colDefsbackup = [];
						me.grid.gridOptions.columnDefs.forEach((el,idx)=>{me._colDefsbackup[idx]=(el.editable||false); el.editable=true;});
						me.grid.gridOptions.api.setColumnDefs(me.grid.gridOptions.columnDefs);
						//console.log("update colDef before Starting")
					}
					me.bPasting = true;
				}, 	
				onCellValueChanged: function(params) { 
					if(me.bPasting && !isNull(params.colDef) && !isNull(params.colDef.field) && !isNull(params.node) && !isNull(params.node.id)) { 
						var colinfo = subset(me.colinfo,"colid",params.colDef.field)[0];
						if(!isNull(colinfo)) {
							//console.log( params.node.id +","+ params.colDef.field +" - "+ colinfo.etype +":"+ params.newValue + " / "+params.newValue );
							if(colinfo.dtype=="num") {
								//params.value = toNum(params.newValue); 
								//params.data[params.colDef.field] = toNum(params.newValue); 
								//if(isNull(params.value)) {
								//	console.log(params);
								//}
								//console.log( params.node.id +","+ params.colDef.field +":"+ toNum(params.newValue) + " / "+params.newValue );
								if(me.bEvent==true) {
									me.setVal( params.node.id, params.colDef.field, toNum(params.newValue) );
								}
							} 
							/* raw컬럼에서는 paste시 onCellValueChanged 이벤트가 발생하지 않음..
							else if(colinfo.etype=="raw") {
								if(me.bEvent==true) {
									me.setVal( params.node.id, params.colDef.field, params.newValue );
								}
							} */
						} 
						if(params.oldValue != params.newValue) {
							me.setCRUD(params.node.id,"U"); 
						}
					}
				}, 
				onPasteEnd: function(params) {
					me.bPasting = false; 
					//if(me.bForcePaste) { //수정불가컬럼도 붙여넣기 하고 싶을때 이 옵션을 사용한다. 
						//me.grid.gridOptions.columnDefs.forEach((el,idx)=>{el.editable=me._colDefsbackup[idx];});
						//me.grid.gridOptions.api.setColumnDefs(me.grid.gridOptions.columnDefs);
						//console.log("update colDef after Ending")
					//} 
					afnEH(me, "paste", params );
				},
				/*
				onFilterChanged: function() {
					if(me.grid.gridOptions.api.getPinnedTopRowCount() > 0) {
						me.total("top");
					} else if(me.grid.gridOptions.api.getPinnedBottomRowCount() > 0) {
						me.total("bottom");
					}
				},
				*/
				processDataFromClipboard: function(params) {
					//console.log(params); 
					for (var i = 0; i < params.data.length; i++) {
						for (var j = 0; j < params.data[i].length; j++) {
							params.data[i][j] = trim(params.data[i][j]); 
						}
					}
					return params.data; 
				},			
				rowData: [],
				components:{ 
					agGridCellRender: gfnAgGridCellRender,
					agGridCellEdit: gfnAgGridCellEdit,
					agDetailCellRender: gfnAgDetailCellRenderer
				},
				/* master-detail */ 
				masterDetail: true, 
				detailRowAutoHeight: true,
				detailCellRenderer: 'agDetailCellRender',  
				detailCellRendererParams: { 
					pgmid: me.container.parents(".framepage").attr("pgmid"),
					componentId: me.componentId
				}
			};
			//excel 숫자를 copy/paste할때 뒤에 껴들어간 공백을 제거해야함 
			//https://www.ag-grid.com/javascript-data-grid/clipboard/#clipboard-events
			me.bPasting = false;

			if(!isNull(me.componentDef)&&!isNull(me.componentDef.component_option)&&!isNull(me.componentDef.component_option.gridOptions)) { 
                //줄 수에 따라서 화면이 늘어나는 domLayout 일단 사용중지  
				//delete me.componentDef.component_option.gridOptions.domLayout;
				me.gridOptions = $.extend(true, me.gridOptions, me.componentDef.component_option.gridOptions);
			}
			if($("body").hasClass("mobile")) {
				me.gridOptions.suppressMovableColumns = true;
			}
			
			var gridDiv = me.componentBody[0];
            me.grid = new agGrid.Grid(gridDiv, me.gridOptions); 
			//이벤트 허용여부 설정(일괄 값 설정시)
			me.bEvent = true;
			me.setEvent = function(bEvent) {
				if(bEvent) window.setTimeout(function(){ me.bEvent = true;},10);
				else me.bEvent = bEvent;
			}
			/* agGrid HACK*/
			me.cellFocusedHack = null; 
			me.onFocus = function(arrNodeIds,colid,e) { 
				if(me.bEvent) afnEH(me, "focus", arrNodeIds, colid, e);
			}
			//NodeId는 유니크한 rowId이고, rowIndex는 표시된 숫자임
			me.getNodeId = function(rowIndex) {
				var node = me.grid.gridOptions.api.getDisplayedRowAtIndex(rowIndex);
				if(isNull(node)) return -1;
				return node.id;
			} 
			me.getRowIndex = function(nodeId) {
				var node = me.grid.gridOptions.api.getRowNode(nodeId);
				if(isNull(node)) return -1;
				return node.rowIndex;
			}
			//전체 데이터 건수 / CRUD상태의 데이터건수
			me.countRow = function( sCRUD ) {
				var rtn = 0;
				if(sCRUD==undefined) {
					rtn = me.grid.gridOptions.api.getModel().getRowCount(); 
				} else { 
					me.grid.gridOptions.api.forEachNode(function(node,idx) {
						var crud = nvl(node.data.crud,"R");
						if(inStr(sCRUD,crud)>=0) rtn++;
					});
				}
				return rtn;
			}					
			//선택된 NodeId가져오기
			me.selectedRow = function() {
				var selectedRows = me.selectedRows(); 
				if(selectedRows.length==0) return -1;
				else return selectedRows[0];
			} 
			me.selectedRows = function() { 
				var rtn = [];
				me.grid.gridOptions.api.forEachNode(function(node,idx) {
					if(node.isSelected()) rtn.push(node.id);
				});
				return rtn;
			}
			//Row 선택하기/취소하기 
			me.selectRow  = function(nodeId,bSel) {
				me.selectRows([nodeId],bSel);
			} 
			me.selectRows = function(arrNodeIds, bSel) {
				if(bSel==undefined) bSel = true;
				me.grid.gridOptions.api.forEachNode(function(node) {
					if (arrNodeIds==undefined) {
						node.setSelected(bSel);
					} else { 
						if (inStr(arrNodeIds,node.id) >= 0) { 
							node.setSelected(bSel);
						} 
					}
				}); 
				if(bSel!=true) me.grid.gridOptions.api.clearRangeSelection();	
				/*			
				if(me.bResetHeight==false) {
					bResetHeight=true;
					setTimeout(function(){
						me.grid.gridOptions.api.resetRowHeights();
						bResetHeight = false; 
					},100);
				}
				*/
			} 
			me.rangeOn = function(rowIndex,colid) {
				me.grid.gridOptions.api.addCellRange(
					{	
						rowStartIndex:rowIndex,
						rowEndIndex:rowIndex,
						columnStart:colid,
						columnEnd:colid
					}
				);
			}
			me.forceFocus = function(rowIndex, colid, bEditing) {
				if(typeof(rowIndex)=="string") rowIndex = me.getRowIndex(rowIndex);
				var orgRow = me.selectedRows(); 
				//window.setTimeout(function(){
				me.grid.gridOptions.api.stopEditing(false); 
				me.selectRows(orgRow,false); 
				me.selectRow(me.getNodeId(rowIndex),true); 		
				var col = me.grid.gridOptions.columnApi.getColumn(colid);
				//console.log("focused");							
				me.grid.gridOptions.api.setFocusedCell(me.getNodeId(rowIndex),col);
				//console.log("rangeOn");
				me.rangeOn(rowIndex,colid);	
				//console.log("startEdit");
				if(bEditing) me.grid.gridOptions.api.startEditingCell({rowIndex:rowIndex,colKey:colid});
				//},1);			
			}
			//포커스주기/포커스된 NodeId가져오기
			me.focusRow = function(rowIndex) { 
				if(nzl(rowIndex,-1) < 0) return;
				me.grid.gridOptions.api.ensureIndexVisible(rowIndex);
		        var firstCol = me.grid.gridOptions.columnApi.getAllDisplayedColumns()[0];
				me.grid.gridOptions.api.ensureColumnVisible(firstCol);
				me.rangeOn(rowIndex,firstCol.colId);
			    me.grid.gridOptions.api.setFocusedCell(rowIndex, firstCol); 
			}
			me.focusedRow = function() {
				var NodeId = -1;
				var focusedCell = me.grid.gridOptions.api.getFocusedCell();
				if(focusedCell!=null) NodeId = focusedCell.rowIndex; //= me.getNodeId( focusedCell.rowIndex  );
				return NodeId;
			}
			//컬럼-값을 포함한 Node찾기
			me.findRow = function(colid,val) {
				var NodeId = -1; 
				me.grid.gridOptions.api.forEachNode(function(node) {
					if(node.data[colid]==val) NodeId = node.id;
				});
				return NodeId;
			} 
			//자동폭맞춤
			me.sizeColumnsToFit=function() {
				if(!isNull(me.container.parents(".framepage")) && me.container.parents(".framepage").css("display") != 'none') { 
					me.grid.gridOptions.api.sizeColumnsToFit();
				}
			}
			//내용에 맞춰 폭맞춤
			me.autoSizeAllColumns=function(bHeaderSkip) {
				if(!isNull(me.container.parents(".framepage")) && me.container.parents(".framepage").css("display") != 'none') { 
					me.grid.gridOptions.columnApi.autoSizeAllColumns(bHeaderSkip);
				}
			}
			//줄추가 
			me.addRow = function(row, NodeId) { //선택안하면 맨뒤, 선택하면 그 줄 위에 삽입 -> 처음으로 추가된 줄 Selected 
				if(row==undefined) { //값 없이 넘어오면 기본값으로 채워줌
					row = {} ;
					$.map(me.colinfo,function(el,idx) { if(el.colid) row[el.colid]=eval2(el.defval); }); 
				}
				if(!$.isArray(row)) row = [row];    //배열로 만들어 줌  
				for(var i = 0 ; i < row.length; i++) { //row crud flag세팅
					row[i].crud = 'C';  
				} 
				//추가하는 위치: 맨 위 또는 선택된 줄의 다음에 append
				if( NodeId==undefined ) {
					var focusedCell = me.grid.gridOptions.api.getFocusedCell();
					if(focusedCell==null) NodeId = -1;
					else NodeId = me.getNodeId( focusedCell.rowIndex );
				}
				var rowIndex = me.countRow(); //선택된 줄이 없으면 가장 끝에 넣어줌
				if( NodeId == -1) rowIndex = -1; //맨위에 줄추가 하려면 NodeId = -1
				else if( NodeId >= 0 ) rowIndex = toNum(me.getRowIndex(NodeId))+1;  
				if( rowIndex == -1 ) rowIndex = 0;
				me.grid.gridOptions.api.applyTransaction({add: row, addIndex: rowIndex});
				var node = me.grid.gridOptions.api.getDisplayedRowAtIndex( rowIndex );
				if(node != undefined ) { 
					me.selectRow( node.id, true ); //추가된 Row의 첫번째를 선택
					return node.id; //추가된 줄의 nodeId를 돌려줌!
				} else {
					return -1;
				}
			}
			//줄삭제 
			me.delRow = function(arrNodeIds, bForce) { //선택된 줄 또는 지정된 줄을 삭제하고 -> 그 다음 rowIndex에 Selected 
				if(arrNodeIds!=undefined) {    //삭제대상Row가 지정되었으면 
					me.selectRows(undefined,false); //일단 모두 unselect한후에 
					me.selectRows(arrNodeIds);         //선택된 Row를 선택해 줌
				}  	//삭제대상Row가 지정되지 않았으면 현재 선택된 Row로 삭제 진행함. 
				arrNodeIds = me.selectedRows();            //선택된 Row값을 가져와서 
				if(!$.isArray(arrNodeIds)) arrNodeIds = [arrNodeIds];    //배열로 만들어 줌  
				if(arrNodeIds.length == 0) {
					gfnAlert("작업 확인", "줄삭제 할 수 있는 정보가 없습니다.");
					return false;
				}
				var bNoti = false;
				for(var i=0; i < arrNodeIds.length; i++) {
					var row = me.grid.gridOptions.api.getRowNode(arrNodeIds[i]);
					if(row.data.crud=="C"||bForce==true) { //신규Row, 무조건일 경우 즉시 삭제한다. 
						me.grid.gridOptions.api.applyTransaction({remove:[row.data]});
					} else { 
						row.data.crud = "D";
						me.grid.gridOptions.api.applyTransaction({update:[row.data]});
						if(bNoti==false) {
						    gfnAlert("삭제확인","줄삭제 된 건들은 [저장]하여야 반영됩니다.");
							bNoti = true;
						}
					}
				}
				me.redraw();
			} 
			me.setCRUD = function(nodeid,crudFlag) {
				if(isNull(me.gridOptions.api.getRowNode(nodeid))) return;
				if(crudFlag==undefined) return;
				var crud = nvl(me.gridOptions.api.getRowNode(nodeid).data.crud,"");
				if(crudFlag=="U") { 
					if(crud=="") crud="C";
					else if(crud=="R") crud="U"; 
				} else {
					crud=crudFlag;
				}
				me.gridOptions.api.getRowNode(nodeid).data.crud = crud;
			}
			//Row단위로 Get/Set
			me.getRowData = function(nodeid) {
				return me.grid.gridOptions.api.getRowNode(nodeid).data;
			} 
			me.setRowData = function(nodeid, data) {
				var rowNode = me.grid.gridOptions.api.getRowNode(nodeid);
				rowNode.setData(data);
			}				
			//컬럼제어 
			me.cId = function(colid) {  //colinfo배열에서 colid이 존재하는 컬럼 인덱스번호 (=cellIdx. 주의! dataTable에서는 cId = cellidx-1)
				for(var cid = 0; cid < me.colinfo.length; cid++) {
					if(me.colinfo[cid].colid == colid) return cid;
				}
				return -1;
			}  
			me.setVal = function(nodeId, colid, val) { 
				if(!isNull(me.grid.gridOptions.api.getRowNode(nodeId))) {
					if(!isNull(colid) && subset(me.colinfo,"colid",colid).length > 0) {
						me.grid.gridOptions.api.getRowNode(nodeId).setDataValue(colid,val);
					}
				}
			} 
			//컬럼DEF 포인터찾기
			me.getColDef=function(colid) {
				me.colDefs = me.gridOptions.columnDefs;
				var pt = me.colDefs.find(el=>el.field==colid); //찾아보고
				if(isNull(pt)) {                                    //없으면
					me.colDefs.forEach(lv0=>{  //건건이
						if(!isNull(pt)) return false;
						//console.log("lv0");console.log(lv0);
						if(isNull(lv0.children)) return false;    
						lv0.children.forEach(lv1=>{              //아래로LOOP
							if(!isNull(pt)) return false;
							//console.log("lv1");console.log(lv1);
							if(lv1.field==colid) {          //찾아보고
								pt = lv1;
								//console.log("found lv1");console.log(pt); 
								return false;
							} 
							if(isNull(lv1.children)) return false;
							lv1.children.forEach(lv2=>{        // 아래로Loop
								if(!isNull(pt)) return false;
								//console.log("lv2");console.log(lv2);
								if(lv2.field==colid) {   //찾아보고
									pt = lv2;
									//console.log("found lv2");console.log(pt); 
									return false;
								} 
								if(isNull(lv2.children)) return false;
								lv2.children.forEach(lv3=>{       //아래로Loop
									if(!isNull(pt)) return false;
									//console.log("lv3");console.log(lv3);
									if(lv3.field==colid) {   //찾아본다.
										pt = lv3;
										//console.log("found lv3");console.log(pt); 
										return false;
									}
								}); //end of lv3
							}); //end of lv2
						});  //end of lv1
					});  //end of lv0
				}
				return pt;
			}
			//보이기 숨기기
			me.setDisp = function(colid, bShow, bStopRefresh=false) { 
				var pt = me.getColDef(colid);
				if(isNull(pt)) return;
				pt.hide = !bShow;
				if(pt.hide==false) { 
					var colinfo = pt.cellRendererParams.colinfo;
					pt.cellRendererParams.colinfo.attr = colinfo.attr.replace("hidden","");
					//etype in (txt, pwd, cbx, sel, tarea) and attr not in ('readonly','disabled') => editable처리  
					if(inStr("txt, pwd, cbx, sel, tarea",colinfo.etype)>=0 && inStr("readonly, disabled",colinfo.etyp)<0) {
						pt.cellEditorParams.colinfo.attr = pt.cellRendererParams.colinfo.attr;
						pt.cellEditor = 'agGridCellEdit'; 
					} 
				} 
				//if(!isNull(me.col[colid])) me.col[colid].setHidden(!bShow); 
				if(!bStopRefresh) me.gridOptions.api.setColumnDefs(me.colDefs);
			}		
			//다시그리기
			me.refresh = function() {
				return me.gridOptions.api.redrawRows();
			} 
			//값 가져오기 	
			me.getVal = function(nodeId, colid) { 
				return (me.grid.gridOptions.api.getRowNode(nodeId)!=undefined)?me.grid.gridOptions.api.getRowNode(nodeId).data[colid]:null;
			}
			me.cval = function(nodeId, colid, val) { 
				if(val==undefined) return me.getVal(nodeId, colid);
				else me.setVal(nodeId, colid, val); 
			}	
			//위/아래 합계값 get/set
			me.cvaltop = function(rownum, colid, val) {
				if(val==undefined) {  //get
					return me.grid.gridOptions.api.getPinnedTopRow(rownum).data[colid]; 
				} else {  //set
					me.grid.gridOptions.api.getPinnedTopRow(rownum).data[colid] = val;
				}
			}	
			me.cvalbottom = function(rownum, colid, val) {
				if(val==undefined) {  //get
					return me.grid.gridOptions.api.getPinnedBottomRow(rownum).data[colid]; 
				} else {  //set
					me.grid.gridOptions.api.getPinnedBottomRow(rownum).data[colid] = val;
				}
			}
			//grid에 데이터가져오기 
			me.bResetHeight = false;
			me.importData = function(rowdata,crudFlag) { 
				if(isNull(rowdata)) {
					me.grid.gridOptions.api.setRowData([]); 
					return;
				}
				me.bEvent = false;
				//crudFlag세팅
				for(var i=0; i < rowdata.length; i++) {
					if(rowdata[i].crud==undefined) rowdata[i].crud=nvl(crudFlag,"R");
				}
				me.grid.gridOptions.api.setRowData(rowdata);  
				me.bEvent = true;
				/*조회 후 폭 넓이 조정해주기 : autoSizeColumns, sizeColumnsToFit 모두 원하는대로 사이징 되지 않음. 컬럼정의에서 사이즈 필수 입력할 것.
				setTimeout(function(){
					// Grid자체가 Hidden인 경우 소용이 없음 
					// 컬럼내용에 맞춰 폭 조정 (Hidden상태인 경우 20px로 컬럼폭이 축소됨) 
					if (me.componentBody.parents("[style*='display: none;']").length == 0) {
						var allColumnIds = [];
						me.gridOptions.columnApi.getAllColumns().forEach(function (column) {
							if(column.colId!="rn"&&column.colId!="chk") allColumnIds.push(column.colId);
						});
						me.gridOptions.columnApi.autoSizeColumns(allColumnIds,true);
					}
					me.gridOptions.api.sizeColumnsToFit(); //그리드폭에 맞춰 전체 컬럼크기 조정 
				},10); 
				*/  
				/*
				if(me.bResetHeight==false) {
					bResetHeight=true;
					setTimeout(function(){
						me.grid.gridOptions.api.resetRowHeights();
						bResetHeight = false; 
					},330);
				}
				*/
			} 
			me.exportData = function(sCRUD) {
				me.grid.gridOptions.api.stopEditing(false);
				var rtn = [];
				if(sCRUD==undefined) sCRUD = "CRUD";
				if(sCRUD=="selected") {
					me.grid.gridOptions.api.forEachNode(function(row,idx)  {
						if(row.isSelected()) {
							for(var i=0; i < me.colinfo.length; i++) {
								row.data[me.colinfo[i].colid] = nvl(row.data[me.colinfo[i].colid],null);
							}
							row.data.id = row.id;
							rtn.push(row.data);
						}
					});
				} else {
					me.grid.gridOptions.api.forEachNode(function(row,idx) {
						var crud = nvl(row.data.crud,"R");
						if(inStr(sCRUD,crud)>=0) {
							for(var i=0; i < me.colinfo.length; i++) {
								row.data[me.colinfo[i].colid] = nvl(row.data[me.colinfo[i].colid],null);
							}
							row.data.id = row.id;
							rtn.push(row.data);
						}
					});
				} 
				return rtn;
			} 
			me.exportFilteredData = function() {
				me.grid.gridOptions.api.stopEditing(false);
				var rtn = [];
				me.grid.gridOptions.api.forEachNodeAfterFilterAndSort(function(row,idx) {
					for(var i=0; i < me.colinfo.length; i++) {
						row.data[me.colinfo[i].colid] = nvl(row.data[me.colinfo[i].colid],null);
					}
					row.data.id = row.id;
					rtn.push(row.data);
				});
				return rtn;
			}
			me.exportXls = function( title, isSelected ) {
				isSelected = nvl(isSelected,false);
				var params = {
					onlySelected: isSelected,  
					fileName : title + "_" + new Date().format("yymmddhh24miss"),
					sheetName: "DATA" 
				};
				me.grid.gridOptions.excelStyles = [
					{
						id: 'dateFormat',
						dataType: 'dateTime',
						numberFormat: {
							format: 'YYYY-MM-DD;@'
						}
					},
					{
						id: 'textFormat',
						dataType: 'string'
					}
				];
				me.grid.gridOptions.api.exportDataAsExcel(params);
			}
			//Validation
			me.chkValid = function(bWarn) {  
				if(bWarn==undefined) bWarn = true;
				var rtn = true;
				me.grid.gridOptions.api.forEachNode(function(row,idx)  {
					if(rtn==true && row.data.crud != "D") {
						for(var ci=0; ci < me.colinfo.length; ci++) {
							var coli = me.colinfo[ci];
							var val = me.getVal( row.id, coli.colid);
							if(gfnChkValid(coli, val, bWarn, (row.id) )==false) {
								me.focusRow(row.rowIndex);
								rtn = false; 
								return false;
							}
						} 
					}
				});
				return rtn;
			}
			//합계 구하기
			me.total = function( sPos ) {
				var data = me.exportData("CRU");
				var rowTotal = {};
				//var data2 = me.exportFilteredData();
				//var rowTotal2 = {};
				//var data3 = me.exportData("selected");
				//var rowTotal3 = {};				
				for( var i=0; i < me.colinfo.length; i++ ) {
					var col = me.colinfo[i];
					if(col.dtype == "num") {
						rowTotal[ col.colid ] = 0;
						//rowTotal2[ col.colid ] = 0;
						//rowTotal3[ col.colid ] = 0;
						for(var j =0 ; j < data.length; j++) {
							if(!isNull(data[j]) && !isNull(data[j].subsumrow)) continue;
							var row = data[j];
							rowTotal[ col.colid ] += toNum(row[ col.colid ]);
						} 
						/*
						for(var j =0 ; j < data2.length; j++) {
							if(!isNull(data2[j]) && !isNull(data2[j].subsumrow)) continue;
							var row = data2[j];
							rowTotal2[ col.colid ] += toNum(row[ col.colid ]);
						}
						for(var k =0 ; k < data3.length; k++) {
							if(!isNull(data3[k]) && !isNull(data3[k].subsumrow)) continue;
							var row = data3[k];
							rowTotal3[ col.colid ] += toNum(row[ col.colid ]);
						} 
						*/
					}
					if(!isNull(col.totFormula)) { 
						//console.log(col.colid+" : "+arrFormula(data, col.totFormula)+" ("+col.totFormula+")");
						rowTotal[ col.colid ] = arrFormula(data, col.totFormula);
						//rowTotal2[ col.colid ] = arrFormula(data2, col.totFormula);
						//rowTotal3[ col.colid ] = arrFormula(data3, col.totFormula);						
					} 
				}  
				rowTotal["rn"] = data.length+"건";	
				//rowTotal2["rn"] = data2.length+"건";	
				//rowTotal3["rn"] = data3.length+"건";					

				var rowTotals = [];
				rowTotals.push(rowTotal);
				//if(JSON.stringify(rowTotal) != JSON.stringify(rowTotal2) && data2.length > 0) rowTotals.push(rowTotal2);
				//if(JSON.stringify(rowTotal) != JSON.stringify(rowTotal3) && data3.length > 0) rowTotals.push(rowTotal3);
				if(sPos=="top") {
					//console.log(rowTotals);
					me.grid.gridOptions.api.setPinnedTopRowData(rowTotals);
				} else {
                    me.grid.gridOptions.api.setPinnedBottomRowData(rowTotals);
				} 
			}			
			//다시그리기, 초기화 
			me.redraw = function(arrNodeIds) {
				if(arrNodeIds==undefined) {
					arrNodeIds = [];
					me.grid.gridOptions.api.forEachNode(function(node,idx) {
						arrNodeIds.push(node.id);
					});
				}
				me.grid.gridOptions.api.refreshCells({rowNodes: arrNodeIds,force:true}); //redrawRows 
			} 			
			me.reset = me.initComponentBody;
		} else if( me.componentDef.component_pgmid =="aweCardView" ) {
			//resetForm
			me.reset = me.initComponentBody;			
			//componentBody = rows > row > [ section > colgrp > ] col   
			// dataset component  
			/**************************************************************************
			  rows에 data를 byRef로 참조하여 연동되게 하려는 시도는
			                        data삭제시 rows의 요소에는 반영되지 않으므로 실패임.
			  따라서, data에는 unique id를 지정하고, dom에는 data-rownum을 추가해줘서 
			    상호참조가 가능하도록 하는 것이 타당하다. 
			**************************************************************************/  			
			me.data = []; //정의되지 않은 컬럼의 값도 get/set하고 import/export할 수 있다. 
			me.colinfo = me.componentDef.content;  //컬럼정의정보[]	
			me.setter = function(colid,val) {      //컬럼 값세팅시 dtype,etype,attr에 따라 값정제
				var colinf = subset(me.colinfo,"colid",colid);
				if(isNull(colinf) || colinf.length==0) return val;
				colinf = colinf[0]; 
				if(colinf.dtype=="num") {
					if(inStr(colinf.attr,"dec1")>=0) return format(toNum(val),1);
					else if(inStr(colinf.attr,"dec2")>=0) return format(toNum(val),2);
					else if(inStr(colinf.attr,"dec3")>=0) return format(toNum(val),3);
					else if(inStr(colinf.attr,"dec4")>=0) return format(toNum(val),4);
					else return format(toNum(val));
				}
				else if (colinf.dtype=="ymd") {
					val=""+val;
					if(trim(val).length==8) return date(val,"yyyymmdd"); 
					else if(trim(val).length==4) return date((date("today").substr(0,4)+""+val),"yyyymmdd"); 
					else return date(val);
				}
				else if (colinf.dtype=="text") {
					if($.type(val)=="string") {
						if(inStr(colinf.attr, "upper")>=0) val = upper(val);
						else if(inStr(colinf.attr, "lower")>=0) val = lower(val);
						else if(inStr(colinf.attr,"biz_no")>=0) val = biz_no(val); 
						else if(inStr(colinf.attr,"ccard")>=0) val = ccard(val); 
						else if(inStr(colinf.attr,"nm")>=0) val = (val||"").split(":")[1];
					}
					return val;
				} else if (colinf.etype=="cbx") {
					if(val==true||val=="on"||val=="Y") return "Y";
					else return "N";
				}
				return val;
			}
			me.getRowData = function(rownum) {  //row를 byRef로 가져옴. 없으면 undefined리턴 
				return me.data.find(el=>el["rownum"]==rownum);
			} 
			me.setRowData = function(rownum, rowdata, stat, bRefresh=true) {  //row에 데이터를 넣어줌 
				var row = me.getRowData(rownum);
				if(row==undefined) return false; //setData할 row가 없으면 실패
				var cols = extract(me.colinfo,"colid");
				var colDefVals = extract(me.colinfo,["colid","defval"]); 
				var curcols = Object.keys(nvl(rowdata,{})); 
				curcols.forEach((colid)=>{ //신규데이터에 있는 컬럽값은 row에 넣어주고 
					if(inStr(cols,colid)>=0) row[colid]=me.setter(colid,rowdata[colid]);
					else row[colid]=me.setter(colid,rowdata[colid]); 
				});
				cols.forEach((colid)=>{ //컬럼정의에 있으나 신규데이터에 없는 컬럼은 기본값 넣어줌 
					if(curcols.length == 0 || inStr(curcols,colid) < 0) row[colid]=me.setter(colid,eval2(subset(colDefVals,"colid",colid)[0].defval)); 
				});  
				row.crud = stat; 
				if(bRefresh) me.refreshRow(rownum); /**** call RefreshRow 해당Row만 *****/
			}	 
			me.getVal = function(rownum,colid) {  
				var row = me.getRowData(rownum);
				if(row==undefined) return null;
				return row[colid];
			} 			
			me.setVal = function(rownum, colid, val, bRefresh=true) {
				var row = me.getRowData(rownum); //byRef
				if(row==undefined) return false; //setValue할 row가 없으면 중단
				var oldval = me.getVal(rownum,colid);
				if(oldval != me.setter(colid,val)) me.setStat(rownum,true);
				row[colid] = me.setter(colid,val);  
				if(bRefresh) me.refreshCol(rownum,colid); /**** call RefreshCol *****/
			}  
			me.cval = function(rownum, colid, val) {
				if(val==undefined) me.getVal(rownum, colid);
				else me.setVal(rownum, colid, val);
			}	
			me.setStat = function(rownum,bChange) {
				var row = me.getRowData(rownum);
				if(row==undefined) return false; 
				if(bChange==true) {
					if(row.crud=="") row.crud="C";
					else if(row.crud=="R") row.crud="U";
				} else {
					if(row.crud=="C") row.crud="";
					else if(row.crud=="U") row.crud="R";
				}
				me.refreshRow(rownum);  /**** call RefreshRow 해당Row만 *****/
			}
			me.newRownum = 0; 
			me.addRow = function(rowdata, rowpos, stat = "C", bRefresh=true) {
				//data[idx]는 의미없음!!!
				var rownum = (me.newRownum++);
				if(isNull(rowpos) || rowpos=="last") { //끝에 append
					rowpos = me.data.length; //append
					me.data.push({rownum:rownum});
				} else if(rowpos < 0 || rowpos=="1st") { //맨앞에 insert
					rowpos = 0;
					me.data.splice(0, 0, {rownum:rownum});
				} else if(rowpos < me.data.length) { //중간에 insert
					me.data.splice(rowpos,0,{rownum:rownum});
				}    
				me.setRowData(rownum, rowdata, stat, bRefresh); 
				return rownum;
			} 
			me.delRow = function(rownum, bIgnore = false, bRefresh=true) {
				var row = me.getRowData(rownum);
				if(row==undefined) return false; //지울Row가 없으면 실패 
				var rowIdx = me.data.indexOf(row);
				if(isNull(row.crud)||row.crud=="C"||bIgnore==true) {
					me.data.splice(rowIdx, 1); 
				} else {
					row.crud="D"; 
				}
				if(bRefresh) me.refreshRow(rownum); /**** call RefreshRow 해당Row만 *****/
			}			
			me.importData = function(rowdata, stat="R") {
				try {
					delete me.data; me.data=[];  
					me.newRownum = 0;
					if($.type(rowdata)!='array') rowdata = $.makeArray(rowdata);
					rowdata.forEach((newrow)=> { 
						me.addRow(newrow,"last",stat,false);
					}); 
					me.refreshRow();  /**** call RefreshRow 마지막에 한번 *****/
					return true;
				} catch {
					return false;
				}
			}
			me.exportData = function(sCRUD,rowClass) { 
				var rtnData = [];
				me.data.forEach(function(row) {
					if(isNull(sCRUD) || inStr(sCRUD,row.crud)>=0) {
						if(isNull(rowClass)) {
							rtnData.push(row); 	
						} else {
							var rownum = row.rownum;
							var rowObj = me.getRowObj(rownum);
							if(!isNull(rowObj) && rowObj.hasClass(rowClass)) {
								rtnData.push(row);
							}
						}
					}  
				});
				return rtnData;
			} 
			me.getRowObj = function(rownum) {
				return me.componentBody.find(`.aweRow[rownum='${rownum}']`); 
			}
			me.refreshRow = function(rownum) {
				if(rownum!=0 && isNull(rownum)) {  //전체Refresh
					me.componentBody.find("*").remove();
					for(var i=0; i < me.data.length; i++) {
						me.refreshRow( me.data[i].rownum );
					} 
				} else {
					var row    = me.getRowData(rownum); 
					var rowIdx = me.data.indexOf(row);
					var rowObj = me.getRowObj(rownum); 
					//row가 없는데 rowObj가 있으면 삭제
					//row가 있는데 rowObj가 없으면 신규추가
					//row가 있고 rowObj도 있으면 업데이트
					if(isNull(row) && rowObj.length >=1) { 
						rowObj.remove(); 
					} else {
						if(!isNull(row) && rowObj.length==0) { //draw NewRow : 현재 표시대상일떄만 추가필요.
							rowObj = $("<div class='aweRow' rownum='"+rownum+"'></div>");
							me.componentBody.append(rowObj); 
						}
						me.renderRow(rowObj,row,rowIdx);
					} 					
				}
			}  
			me.renderRow=function(rowObj,rowData,rowIdx) { 
				//컬럼별로 section > colgrp : label > .aweCol 로 배치해줌  
				var container = rowObj;
				var grpcontainer = rowObj;
				var curSection = "_init";
				var curColgrp = "_init";
				var col={}; 
				for(var i =0; i < me.colinfo.length; i++) {
					var colinfo = me.colinfo[i];
					//section이 없거나 바뀌었으면...
					if(isNull(nvl(colinfo.section,""))) container = rowObj;
					else if (colinfo.section!=curSection) {
						curSection = colinfo.section;
						container = $(`<section section="${curSection}"></section>`).appendTo(rowObj); 
					} 
					//colgrp이 바뀌었으면... 
					if(isNull(nvl(colinfo.colgrp,""))) grpcontainer = container; 
					else if (colinfo.colgrp!=curColgrp) {
						curColgrp = colinfo.colgrp;
						grpcontainer = $(`<ul colgrp="${curColgrp}"></ul>`).appendTo(container); 
					} 
					//grpcontainer.addClass(colinfo.attr); 
					col[colinfo.colid] = new gfnControl(colinfo,function(colid, evt, newval){ 
						var rownum = rowObj.attr("rownum");
						if(evt=="change" && me.setter(colinfo.colid,newval) != me.getVal(rownum,colinfo.colid)) {
							me.setStat(rownum,true);
						}
						//이벤트를 바인딩해준다. 
						afnEH(me, evt, rownum, colid, newval );
					},me); //,me : 컴포넌트 자신도 던져줘서 이벤트시 컬럼상호작용시 참조토록 함
					col[colinfo.colid].setVal(rowData[colinfo.colid]);
					if(isNull(rowObj.data("col")) || isNull(rowObj.data("col")[colinfo.colid])) {
						grpcontainer.append( col[colinfo.colid].dispObj ); //컬럼추가
					}
				}
				rowObj.data("col",col); //upsert
			}

			me.refreshCol = function(rownum, colid) { 
				/*
				var rowObj = me.getRowObj(rownum);
				for(var colid in me.rows[rownum].col) {
					if( inStr(me.rows[rownum].col[colid].attr,"pk") >= 0 ) {
						if( me.data[rownum].crud=="R"||me.data[rownum].crud=="U") me.rows[rownum].col[colid].setDisable(true);
						else me.rows[rownum].col[colid].setDisable(false);
					}
				}
                */ 
			}
			me.col = {}; //aweForm은 me.col[colid] 로 해당 컬럼에 접근할 수 있다. 
			//dispVal : dtype에 의해 표시된 값을 그대로 가져옴 
			me.dispVal = function(colid) {
				if(me.col[colid] == undefined) return me.data[colid];
				else return me.col[colid].dispVal();
			} 
			//validation 
			me.chkValid = function(bWarn) {
				if(bWarn==undefined) bWarn = true;
				for(var i=0; i < me.colinfo.length; i++) {
					var colinfo = me.colinfo[i]; 
					if(me.col[colinfo.colid] == undefined) continue;
					var chk = me.col[colinfo.colid].chkValid(bWarn); //validation Error인 경우 메시지
					if(chk != true) {
						me.col[colinfo.colid].focus();     //컬럼에 포커스만 주고 
						return false; 
					}
				}
				return true;
			}  
		} else if( me.componentDef.component_pgmid =="aweImgViewer" ) {

		} else if( me.componentDef.component_pgmid =="aweCalendar" ) {  
			//pageId, containerId, componentDef, afnEH, page
			/*
			me.componentId = containerId;
			me.containerId = "#"+pageId+" "+((containerId=="pageCond")?".":"#")+containerId;
			me.container = $(me.containerId); 
			me.componentDef = $.extend({},componentDef);
			me.componentBody = $(`<div class="componentBody"></div>`);  
		    me.component_option = me.componentDef.component_option;
			me.colinfo = me.componentDef.content;
	        */ 
			me.calendarTemplate = `<table class='calendar'>
				<caption></caption>
				<thead>
					<tr>
						<th>일</th><th>월</th><th>화</th><th>수</th><th>목</th><th>금</th><th>토</th>
					</tr>
				</thead>
				<tbody>						
				</tbody>
			</table>`;

			me.initCalendar = function(calOption=me.component_option, afnCallback) {
				if(typeof(calOption)=='string' && isYmd(calOption)) {
					calOption = {start_dt:calOption}
				}
				me.calOption  = $.extend(true,{},calOption); // {caltype:, fnTemplate, start_dt, week_cnt}
				me.caltype    = nvl(me.calOption.caltype,"COMMON");
				me.fnTemplate = nvl(eval2(me.calOption.fnTemplate),function(row={}){return nvl(row.remark,"")});
				me.start_dt   = nvl(me.calOption.start_dt,date("1st","yyyymmdd"));
				if(!isYmd(me.start_dt)) me.start_dt = date("1st","yyyymmdd");
				me.week_cnt   = nvl(me.calOption.week_cnt,5); 
				var args = {start_dt:me.start_dt,caltype:me.caltype,week_cnt:me.week_cnt}
				var invar = JSON.stringify(args);
				gfnTx("aweportal.manageCal","initCalendar",{INVAR:invar},function(OUTVAR){
					if(OUTVAR.rtnCd=="OK") {
						me.calendar = $(me.calendarTemplate);
						me.calendar.find("caption").append("<H2>"+date(me.start_dt,"yyyymmdd","'yy.mm월")+"</H2>"); 
						OUTVAR.list.forEach((row,idx)=>{
							if(idx%7==0) me.calendar.find("tbody").append("<tr></tr>");
							var td = $(`<td id='${row.ymd}'><div id='top'><b>${row.ymd.substr(6,2)}</b>${nvl(row.remark,"")}</div></td>`);
							td.find("div#top").data("data",row);
							if(me.start_dt.substr(0,6) > row.ymd.substr(0,6)) td.addClass("prevMon");
							else if(me.start_dt.substr(0,6) < row.ymd.substr(0,6)) td.addClass("nextMon"); 
							else if(row.ymd == date("today","yyyymmdd")) td.addClass("today");
							me.calendar.find("tbody tr").last().append(td);
						});
						me.componentBody.children("*").remove();
						me.componentBody.append(me.calendar); 
						me.calendar.on("click","td",function(e){
							var eTd = $(e.target).exactObj("td");
							afnEH(me,"click",eTd.attr("id"),eTd.find("#top").data("data"),eTd.find("#cont").data("data"));
						});
						if(typeof(afnCallback)=='function') afnCallback(OUTVAR,me); 
					} else {
						gfnAlert("Error","calendar initializing Error...:"+OUTVAR.rtnMsg);
						if(typeof(afnCallback)=='function') afnCallback(OUTVAR); 
					}
				});
			} 
			me.setVal = function(ymd,rowData) {  
				if(typeof(ymd)=='string' && isYmd(ymd)) {
					var td = me.calendar.find('td#'+ymd);
					if(td.length > 0) { 
						td.find("#cont").remove();
						var content = $(`<div id='cont'>${nvl(me.fnTemplate(rowData),"")}</div>`); 
						content.data("data",rowData); 
						td.append(content);
					}
				} else if(typeof(ymd)=='object') {
					if(typeof(ymd.ymd)=='string' && isYmd(ymd.ymd)) {
						me.setVal(ymd.ymd, ymd);
					}
				} else {
					console.log(arguments)
				}
			}
            me.getVal = function(ymd) {
				var content = me.calendar.find('td#'+ymd+" > #cont");
				if(td.length > 0) return content.data("data");
				else return {};
			}
			me.importData=function(rowData) { 
				rowData.forEach(row=>{
					if(isYmd(row.ymd)) {
						me.setVal(row)
					} 
				});
			}
			me.exportData=function() { 
				return me.calendar.find("tbody td #cont").each(function(idx,el) {
					if(!isNull($(el).data("data"))) {
						return $(el).data("data");
					}  
				}).get();
			} 
		    if(isNull(me.caltype)) me.initCalendar(); //initCalendar call  

		} else if( me.componentDef.component_pgmid =="aweSalesCalendar" ) {  
			//주 + 월~일
			me.calendarTemplate = `<table class='calendar'>
				<caption></caption>
				<thead>
					<tr>
						<th>주</th><th>월</th><th>화</th><th>수</th><th>목</th><th>금</th><th>토</th><th>일</th>
					</tr>
				</thead>
				<tbody>						
				</tbody>
			</table>`;

			me.initCalendar = function(calOption=me.component_option, afnCallback) {
				if(typeof(calOption)=='string' && isYmd(calOption)) {
					calOption = {start_dt:calOption}
				}
				me.calOption  = $.extend(true,{},calOption); // {caltype:, fnTemplate, start_dt, week_cnt}
				me.caltype    = nvl(me.calOption.caltype,"COMMON");
				me.fnTemplate = nvl(eval2(me.calOption.fnTemplate),function(row={}){return nvl(row.remark,"")});
				me.start_dt   = nvl(me.calOption.start_dt,date("1st","yyyymmdd"));
				if(!isYmd(me.start_dt)) me.start_dt = date("1st","yyyymmdd");
				me.week_cnt   = nvl(me.calOption.week_cnt,5); 
				var args = {start_dt:me.start_dt,caltype:me.caltype,week_cnt:me.week_cnt}
				var invar = JSON.stringify(args);
				gfnTx("aweportal.manageCal","initSalesCalendar",{INVAR:invar},function(OUTVAR){
					if(OUTVAR.rtnCd=="OK") {
						me.calendar = $(me.calendarTemplate);
						me.calendar.find("caption").text( date(me.start_dt,"yyyymmdd","'yy.mm월") ); 
						var wCnt = 0;
						OUTVAR.list.forEach((row,idx)=>{
							if(idx%7==0) {
								me.calendar.find("tbody").append("<tr></tr>");
								wCnt++;
								var tw = $(`<th id='w${wCnt}'><div id='top'><b>w${row.yweek}</b></div></th>`);	
								me.calendar.find("tbody tr").last().append(tw);	
							}
							var td = $(`<td id='${row.ymd}'><div id='top'><b>${row.ymd.substr(6,2)}</b>${nvl(row.remark,"")}</div></td>`);
							td.find("div#top").data("data",row);
							if(me.start_dt.substr(0,6) > row.ymd.substr(0,6)) td.addClass("prevMon");
							else if(me.start_dt.substr(0,6) < row.ymd.substr(0,6)) td.addClass("nextMon"); 
							else if(row.ymd == date("today","yyyymmdd")) td.addClass("today");
							me.calendar.find("tbody tr").last().append(td);
						});
						me.componentBody.addClass("aweCalendar"); 
						me.componentBody.children("*").remove();
						me.componentBody.append(me.calendar); 
						me.calendar.on("click","td",function(e){
							var eTd = $(e.target).exactObj("td");
							afnEH(me,"click",eTd.attr("id"),eTd.find("#top").data("data"),eTd.find("#cont").data("data"));
						});
						if(typeof(afnCallback)=='function') afnCallback(OUTVAR,me); 
					} else {
						gfnAlert("Error","calendar initializing Error...:"+OUTVAR.rtnMsg);
						if(typeof(afnCallback)=='function') afnCallback(OUTVAR); 
					}
				});
			} 
			me.setVal = function(ymd,rowData) {  
				if(typeof(ymd)=='string' && isYmd(ymd)) {
					var td = me.calendar.find('td#'+ymd);
					if(td.length > 0) { 
						td.find("#cont").remove();
						var content = $(`<div id='cont'>${nvl(me.fnTemplate(rowData),"")}</div>`); 
						content.data("data",rowData); 
						td.append(content);
					}
				} else if(typeof(ymd)=='object') {
					if(typeof(ymd.ymd)=='string' && isYmd(ymd.ymd)) {
						me.setVal(ymd.ymd, ymd);
					}
				} else {
					console.log(arguments)
				}
			}
            me.getVal = function(ymd) {
				var content = me.calendar.find('td#'+ymd+" > #cont");
				if(content.length > 0) return content.data("data");
				else return {};
			} 
			me.setWVal = function(wCnt,rowData) {  
				if(typeof(wCnt)=='string') {
					var tw = me.calendar.find('th#w'+wCnt);
					if(tw.length > 0) { 
						tw.find("#cont").remove();
						var content = $(`<div id='cont'>${nvl(me.fnTemplate(rowData),"")}</div>`); 
						content.data("data",rowData); 
						tw.append(content);
					}
				} else if(typeof(wCnt)=='object') { 
					me.setWVal(wCnt.wCnt, wCnt); 
				} else {
					console.log(arguments)
				}
			}
            me.getWVal = function(wCnt) {
				var content = me.calendar.find('th#w'+wCnt+" > #cont");
				if(content.length > 0) return content.data("data");
				else return {};
			}			
			me.importData=function(rowData) { 
				rowData.forEach(row=>{
					if(isYmd(row.ymd)) {
						me.setVal(row)
					} 
				});
			}
			me.exportData=function() { 
				return me.calendar.find("tbody td #cont").each(function(idx,el) {
					if(!isNull($(el).data("data"))) {
						return $(el).data("data");
					}  
				}).get();
			} 
		    if(isNull(me.caltype)) me.initCalendar(); //initCalendar call  			
		} else if( me.componentDef.component_pgmid =="aweChart" ) {

		} else if( me.componentDef.component_pgmid =="aweList" ) {
			//resetForm
			me.reset = me.initComponentBody;			
			//componentBody = rows > row > [ section > colgrp > ] col   
			// dataset component  
			/**************************************************************************
			 rows에 data를 byRef로 참조하여 연동되게 하려는 시도는
									data삭제시 rows의 요소에는 반영되지 않으므로 실패임.
			따라서, data에는 unique id를 지정하고, dom에는 data-rownum을 추가해줘서 
				상호참조가 가능하도록 하는 것이 타당하다. 
			**************************************************************************/  			
			me.data = []; //정의되지 않은 컬럼의 값도 get/set하고 import/export할 수 있다. 
			me.colinfo = me.componentDef.content;  //컬럼정의정보[]	
			me.setter = function(colid,val) {      //컬럼 값세팅시 dtype,etype,attr에 따라 값정제
				var colinf = subset(me.colinfo,"colid",colid);
				if(isNull(colinf) || colinf.length==0) return val;
				colinf = colinf[0]; 
				if(colinf.dtype=="num") {
					if(inStr(colinf.attr,"dec1")>=0) return format(toNum(val),1);
					else if(inStr(colinf.attr,"dec2")>=0) return format(toNum(val),2);
					else if(inStr(colinf.attr,"dec3")>=0) return format(toNum(val),3);
					else if(inStr(colinf.attr,"dec4")>=0) return format(toNum(val),4);
					else return format(toNum(val));
				}
				else if (colinf.dtype=="ymd") {
					val=""+val;
					if(trim(val).length==8) return date(val,"yyyymmdd"); 
					else if(trim(val).length==4) return date((date("today").substr(0,4)+""+val),"yyyymmdd"); 
					else return date(val);
				}
				else if (colinf.dtype=="text") {
					if($.type(val)=="string") {
						if(inStr(colinf.attr, "upper")>=0) val = upper(val);
						else if(inStr(colinf.attr, "lower")>=0) val = lower(val);
						else if(inStr(colinf.attr,"biz_no")>=0) val = biz_no(val); 
						else if(inStr(colinf.attr,"ccard")>=0) val = ccard(val); 
						else if(inStr(colinf.attr,"nm")>=0) val = (val||"").split(":")[1];
					}
					return val;
				} else if (colinf.etype=="cbx") {
					if(val==true||val=="on"||val=="Y") return "Y";
					else return "N";
				}
				return val;
			}
			me.getRowData = function(rownum) {  //row를 byRef로 가져옴. 없으면 undefined리턴 
				return me.data.find(el=>el["rownum"]==rownum);
			} 
			me.setRowData = function(rownum, rowdata, stat, bRefresh=true) {  //row에 데이터를 넣어줌 
				var row = me.getRowData(rownum);
				if(row==undefined) return false; //setData할 row가 없으면 실패
				var cols = extract(me.colinfo,"colid");
				var colDefVals = extract(me.colinfo,["colid","defval"]); 
				var curcols = Object.keys(nvl(rowdata,{})); 
				curcols.forEach((colid)=>{ //신규데이터에 있는 컬럽값은 row에 넣어주고 
					if(inStr(cols,colid)>=0) row[colid]=me.setter(colid,rowdata[colid]);
					else row[colid]=me.setter(colid,rowdata[colid]); 
				});
				cols.forEach((colid)=>{ //컬럼정의에 있으나 신규데이터에 없는 컬럼은 기본값 넣어줌 
					if(curcols.length == 0 || inStr(curcols,colid) < 0) row[colid]=me.setter(colid,eval2(subset(colDefVals,"colid",colid)[0].defval)); 
				});  
				row.crud = stat; 
				if(bRefresh) me.refreshRow(rownum); /**** call RefreshRow 해당Row만 *****/
			}	 
			me.getVal = function(rownum,colid) {  
				var row = me.getRowData(rownum);
				if(row==undefined) return null;
				return row[colid];
			} 			
			me.setVal = function(rownum, colid, val, bRefresh=true) {
				var row = me.getRowData(rownum); //byRef
				if(row==undefined) return false; //setValue할 row가 없으면 중단
				var oldval = me.getVal(rownum,colid);
				if(oldval != me.setter(colid,val)) me.setStat(rownum,true);
				row[colid] = me.setter(colid,val);  
				if(bRefresh) me.refreshCol(rownum,colid); /**** call RefreshCol *****/
			}  
			me.cval = function(rownum, colid, val) {
				if(val==undefined) me.getVal(rownum, colid);
				else me.setVal(rownum, colid, val);
			}	
			me.setStat = function(rownum,bChange) {
				var row = me.getRowData(rownum);
				if(row==undefined) return false; 
				if(bChange==true) {
					if(row.crud=="") row.crud="C";
					else if(row.crud=="R") row.crud="U";
				} else {
					if(row.crud=="C") row.crud="";
					else if(row.crud=="U") row.crud="R";
				}
				me.refreshRow(rownum);  /**** call RefreshRow 해당Row만 *****/
			}
			me.newRownum = 0; 
			me.addRow = function(rowdata, rowpos, stat = "C", bRefresh=true) {
				//data[idx]는 의미없음!!!
				var rownum = (me.newRownum++);
				if(isNull(rowpos) || rowpos=="last") { //끝에 append
					rowpos = me.data.length; //append
					me.data.push({rownum:rownum});
				} else if(rowpos < 0 || rowpos=="1st") { //맨앞에 insert
					rowpos = 0;
					me.data.splice(0, 0, {rownum:rownum});
				} else if(rowpos < me.data.length) { //중간에 insert
					me.data.splice(rowpos,0,{rownum:rownum});
				}    
				me.setRowData(rownum, rowdata, stat, bRefresh); 
				return rownum;
			} 
			me.delRow = function(rownum, bIgnore = false, bRefresh=true) {
				var row = me.getRowData(rownum);
				if(row==undefined) return false; //지울Row가 없으면 실패 
				var rowIdx = me.data.indexOf(row);
				if(isNull(row.crud)||row.crud=="C"||bIgnore==true) {
					me.data.splice(rowIdx, 1); 
				} else {
					row.crud="D"; 
				}
				if(bRefresh) me.refreshRow(rownum); /**** call RefreshRow 해당Row만 *****/
			}			
			me.importData = function(rowdata, stat="R") {
				try {
					delete me.data; me.data=[];  
					me.newRownum = 0;
					if($.type(rowdata)!='array') rowdata = $.makeArray(rowdata);
					rowdata.forEach((newrow)=> { 
						me.addRow(newrow,"last",stat,false);
					}); 
					me.refreshRow();  /**** call RefreshRow 마지막에 한번 *****/
					return true;
				} catch {
					return false;
				}
			}
			me.exportData = function(sCRUD,rowClass) { 
				var rtnData = [];
				me.data.forEach(function(row) {
					if(isNull(sCRUD) || inStr(sCRUD,row.crud)>=0) {
						if(isNull(rowClass)) {
							rtnData.push(row); 	
						} else {
							var rownum = row.rownum;
							var rowObj = me.getRowObj(rownum);
							if(!isNull(rowObj) && rowObj.hasClass(rowClass)) {
								rtnData.push(row);
							}
						}
					}  
				});
				return rtnData;
			} 
			me.getRowObj = function(rownum) {
				return me.componentBody.find(`.aweRow[rownum='${rownum}']`); 
			}
			me.refreshRow = function(rownum) {
				if(rownum!=0 && isNull(rownum)) {  //전체Refresh
					me.componentBody.find("*").remove();
					for(var i=0; i < me.data.length; i++) {
						me.refreshRow( me.data[i].rownum );
					} 
				} else {
					var row    = me.getRowData(rownum); 
					var rowIdx = me.data.indexOf(row);
					var rowObj = me.getRowObj(rownum); 
					//row가 없는데 rowObj가 있으면 삭제
					//row가 있는데 rowObj가 없으면 신규추가
					//row가 있고 rowObj도 있으면 업데이트
					if(isNull(row) && rowObj.length >=1) { 
						rowObj.remove(); 
					} else {
						if(!isNull(row) && rowObj.length==0) { //draw NewRow : 현재 표시대상일떄만 추가필요.
							rowObj = $("<div class='aweRow' rownum='"+rownum+"'></div>");
							me.componentBody.append(rowObj); 
						}
						me.renderRow(rowObj,row,rowIdx);
					} 					
				}
			}  
			me.renderRow=function(rowObj,rowData,rowIdx) { 
				//컬럼별로 section > colgrp : label > .aweCol 로 배치해줌  
				var container = rowObj;
				var grpcontainer = rowObj;
				var curSection = "_init";
				var curColgrp = "_init";
				var col={}; 
				for(var i =0; i < me.colinfo.length; i++) {
					var colinfo = me.colinfo[i];
					//section이 없거나 바뀌었으면...
					if(isNull(nvl(colinfo.section,""))) container = rowObj;
					else if (colinfo.section!=curSection) {
						curSection = colinfo.section;
						container = $(`<section section="${curSection}"></section>`).appendTo(rowObj); 
					} 
					//colgrp이 바뀌었으면... 
					if(isNull(nvl(colinfo.colgrp,""))) grpcontainer = container; 
					else if (colinfo.colgrp!=curColgrp) {
						curColgrp = colinfo.colgrp;
						grpcontainer = $(`<ul colgrp="${curColgrp}"></ul>`).appendTo(container); 
					} 
					//grpcontainer.addClass(colinfo.attr); 
					col[colinfo.colid] = new gfnControl(colinfo,function(colid, evt, newval){ 
						var rownum = rowObj.attr("rownum");
						if(evt=="change" && me.setter(colinfo.colid,newval) != me.getVal(rownum,colinfo.colid)) {
							me.setStat(rownum,true);
						}
						//이벤트를 바인딩해준다. 
						afnEH(me, evt, rownum, colid, newval );
					},me); //,me : 컴포넌트 자신도 던져줘서 이벤트시 컬럼상호작용시 참조토록 함
					col[colinfo.colid].setVal(rowData[colinfo.colid]);
					if(isNull(rowObj.data("col")) || isNull(rowObj.data("col")[colinfo.colid])) {
						grpcontainer.append( col[colinfo.colid].dispObj ); //컬럼추가
					}
				}
				rowObj.data("col",col); //upsert
			}

			me.refreshCol = function(rownum, colid) { 
				/*
				var rowObj = me.getRowObj(rownum);
				for(var colid in me.rows[rownum].col) {
					if( inStr(me.rows[rownum].col[colid].attr,"pk") >= 0 ) {
						if( me.data[rownum].crud=="R"||me.data[rownum].crud=="U") me.rows[rownum].col[colid].setDisable(true);
						else me.rows[rownum].col[colid].setDisable(false);
					}
				}
				*/ 
			}
			me.col = {}; //aweForm은 me.col[colid] 로 해당 컬럼에 접근할 수 있다. 
			//dispVal : dtype에 의해 표시된 값을 그대로 가져옴 
			me.dispVal = function(colid) {
				if(me.col[colid] == undefined) return me.data[colid];
				else return me.col[colid].dispVal();
			} 
			//validation 
			me.chkValid = function(bWarn) {
				if(bWarn==undefined) bWarn = true;
				for(var i=0; i < me.colinfo.length; i++) {
					var colinfo = me.colinfo[i]; 
					if(me.col[colinfo.colid] == undefined) continue;
					var chk = me.col[colinfo.colid].chkValid(bWarn); //validation Error인 경우 메시지
					if(chk != true) {
						me.col[colinfo.colid].focus();     //컬럼에 포커스만 주고 
						return false; 
					}
				}
				return true;
			}  
		} else if( me.componentDef.component_pgmid =="aweComment" ) {
			//말풍선목록과 하단채팅창이 있는 채팅컨트롤임 - T_COMMNET테이블에 대응(T_CHAT아님!)
			//me.colinfo = me.componentDef.content; - 컬럼 사용안함
			me.component_option = me.componentDef.component_option||{};
			me.ref_info_tp = me.component_option.ref_info_tp||'T_USER';
			me.ref_id      = me.component_option.ref_id||gUserinfo.userid;			
			me.read_cnt    = me.component_option.read_cnt||100;    //한번에 읽어오는 건수*** 
			me.readmore_yn = me.component_option.readmore_yn||'Y'; //commentList 위아래에 더읽기 표시여부
			me.comment_yn  = me.component_option.comment_yn||'Y';  //하단 입력창 생성여부
			me.comment_tp  = me.component_option.comment_tp||"코멘트";
			me.syslog_class = me.component_option.syslog_class||"이력 AUTO_LOG"; //이 문구를 포함한 row는 .syslog가 추가되고 채팅창이 아니라 로그로 표시된다.
			me.del_yn      = me.component_option.del_yn||'N';      //선택된 메시지 삭제허용
			me.data        = me.component_option.data||[];         //처리중인 데이터:{rowid,comment_tp,comments,val_1,val_2,val_3,val_4,val_5,reg_usid,reg_dt}
			me.refresh     = 10000; //10초에 한번 
			me.autoForward = null;  //딱 한번만 refresh를 가동해준다. 
			me.noMoreBwd   = false; //스크롤Up하여 더이상 없으면 다시 조회하지 않음
			me.initComponent=function() { 
				me.componentBody.children("*").remove();
				me.noMoreBwd   = false; //스크롤Up하여 더이상 없으면 다시 조회하지 않음 초기화
				me.componentBody.off("click").off("keyup");
				if(!isNull(me.commentList)) me.commentList.off("scroll").off("click"); 

				//메인채팅창 = aweCommentList
				me.commentList = $("<ul class='aweCommentList'></ul>");
				me.commentList.on("scroll",function(e){
					if( $(e.target).scrollTop() == 0 ) me.readBackward();
				});
				me.commentList.on("click",".fa-trash",function(e){
					var rid = $(e.target).exactObj(".aweRow").attr("rid");
					if(isNull(rid)) return;
					gfnConfirm("삭제확인","코멘트를 삭제합니다.",function(rtn){
						if(rtn) {
							var args = {rid:rid}
							var invar = JSON.stringify(args);
							gfnTx("aweportal.myMemo","delete",{INVAR:invar},function(OUTVAR){
								if(OUTVAR.rtnCd=="OK") {
									me.reset();
									gfnStatus("삭제성공(코멘트가 삭제되었습니다!)","코멘트가 삭제되었습니다!");
								} else { 
									gfnAlert("삭제오류",OUTVAR.rtnMsg);
								}
							});
						}
					}); 
				}); 
				me.commentList.on("click",".aweRow",function(e){
					me.commentList.find(".focus").removeClass("focus");
					$(e.target).exactObj(".aweRow").addClass("focus");
				}); 

				//컴포넌트바디에 코멘트리스트넣어줌
				me.componentBody.append(me.commentList);
				if(me.readmore_yn=="Y") {
					me.btnReadBackward = $("<a href='#' class='btnReadBackward'>이전보기</a>");
					me.btnReadForward = $("<a href='#' class='btnReadForward'>더보기</a>");
					me.btnReadBackward.on("click",me.readBackward);
					me.btnReadForward.on("click",me.readForward);
					me.componentBody.prepend(me.btnReadBackward);
					me.componentBody.append(me.btnReadForward);
				} 

				//하단에 코멘트입력과 등록버튼 추가
				if(me.comment_yn=="Y") {
					me.componentBody.append("<div class='addComment'><textarea placeholder='코멘트를 입력하세요...(줄바꿈:Shift-Enter)'></textarea><button class='aweCol'>코멘트<br>등 록<br><i class='fas fa-pen'></i></div>");
					me.componentBody.on("click","button",function(e){
						me.saveComment(me.componentBody.find("textarea").val()); 
					});
					me.componentBody.on("keyup",".addComment textarea",function(e){
						if(e.key=="Enter" && e.shiftKey==false) { 
						 	me.saveComment(me.componentBody.find("textarea").val()); 
						}
					});
				}

				if(isNull(me.data)) {
					//console.log("init ReadForward");
					me.readForward(); //새로운건 읽기
				} else {
					//console.log("init ReadBackward");
					me.readBackward(); //과거건 더읽기
				} 
				/* 이름조회를 위해 전체사용자를 조회하지 않기로 함.
				if(gds.comcd.some(el=>el.grpcd=="USID")) {
					_initComponent();
					return;
				} else {
					gfnGetData("USID",function(){
						_initComponent();
					});
				} 
				*/	
			}
			me.readForward=function() {
				if(me.onLoad) return;
				if(!isNull(me.autoForward) && me.componentBody.exactObj(".framepage.active").length==0) return; //활성화된 페이지가 아니면 재조회 하지 않는다. 
				me.componentBody.find(".btnReadForward").text("더보기");
                var reg_dt="";
				var rid   =""; 
				if(me.data.length > 0) {
					reg_dt=me.data[0].reg_dt;
					rid=me.data[0].rid; 
				} 
				var args = {ref_info_tp:me.ref_info_tp, ref_id:me.ref_id, reg_dt:reg_dt, rid:rid, read_cnt:me.read_cnt}
				var invar = JSON.stringify(args);
				me.onLoad = true;
        		gfnTx("aweportal.myMemo","search",{INVAR:invar},function(OUTVAR){  
					me.onLoad = false;
					if(OUTVAR.rtnCd=="OK") {
						//console.log("comment forward:"+OUTVAR.list.length);
						OUTVAR.list.forEach(el=>{
							me.data.splice(0,0,el); //최신이 앞으로
                            me.addComment(el,"bottom"); //최신이 아래로          
						});
						//자동갱신해준다.
						if(isNull(me.autoForward) && !isNull(me.refresh) && me.refresh > 1000) {
							me.autoForward = me.refresh;
							me.componentBody.find(".btnReadForward").text("더보기(자동Refresh:"+toNum(me.refresh/1000,0)+"초");
							setTimeout(me.readForward, me.refresh); //if(isNull(me.autoForward)) me.autoForward = window.setInterval( me.readForward, me.refresh);  
						}
						//더 가져올 건이 있는데 스크롤이 안생겼으면 재조회 
						//if(isNull(reg_dt) && OUTVAR.list.length > 0 && OUTVAR.list[0].left_cnt > 0 && me.commentList[0].offsetHeight == me.commentList[0].scrollHeight) {
						//	setTimeout( me.readBackward, 10);
						//}
					} else { 
						gfnAlert("조회오류",OUTVAR.rtnMsg);
					}
				},true);
			} 
			me.readBackward=function() {
				if(!isNull(me.autoForward) && me.componentBody.exactObj(".framepage.active").length==0) {
					//console.log("Exit with "+ me.autoForward + " , " + me.componentBody.exactObj(".framepage.active").length );
					return; //활성화된 페이지가 아니면 재조회 하지 않는다. 
				}
				if(me.noMoreBwd) {
					//console.log("Exit with me.noMoreBwd "+ me.noMoreBwd );
					return;
				}
                var reg_dt="";
				var rid   =""; 
				if(me.data.length > 0) {
					reg_dt=me.data[me.data.length-1].reg_dt;
					rid=me.data[me.data.length-1].rid; 
				} 
				var args = {ref_info_tp:me.ref_info_tp, ref_id:me.ref_id, reg_dt:reg_dt, rid:rid, read_cnt:me.read_cnt}
				var invar = JSON.stringify(args);
				//console.log("Search with ...");
				//console.log(args);
        		gfnTx("aweportal.myMemo","searchBack",{INVAR:invar},function(OUTVAR){
					if(OUTVAR.rtnCd=="OK") {
						//console.log("comment backward:"+OUTVAR.list.length);
						if(OUTVAR.list.length==0) {
							me.noMoreBwd = true;
							me.componentBody.find(".btnReadBackward").remove();
							gfnStatus("코멘트 조회(더 가져올 내용이 없습니다.)","더 가져올 내용이 없습니다.");
						} else {
							OUTVAR.list.forEach(el=>{
								me.data.splice(me.data.length,0,el); //오래된 것이 뒤로 
								me.addComment(el,"top");  //오래된 것이 위로         
							}); 
							//더 가져올 건이 있는데 스크롤이 안생겼으면 재조회 
						    //if(OUTVAR.list[0].left_cnt > 0 && me.commentList[0].offsetHeight == me.commentList[0].scrollHeight) {
							//	setTimeout( me.readBackward, 10);
							//}
						} 
					} else { 
						gfnAlert("조회오류",OUTVAR.rtnMsg);
					}
				},true);
			}
			me.addComment=function(el,dir='bottom') {
				var li = $(`<li class='aweRow' rid='${el.rid}'></li>`);
				if(!isNull(el.comment_tp) && inStr(me.syslog_class,el.comment_tp)>=0) li.addClass("syslog");
				if(!isNull(el.reg_usid)) li.append(`<div class='aweCommentBy'>${el.reg_usnm}</div>`);
				li.append(`<div class='aweCommentMsg'>${el.comments}</div>`);  
				if(!isNull(el.reg_dt)) li.append(`<span class='aweCommentAt'>${el.reg_dt}</span>`); 
				if(!isNull(el.val_1)) li.find(".aweCommentMsg").append(`<span class='info val_1'>${el.val_1}</span>`);
				if(!isNull(el.val_2)) li.find(".aweCommentMsg").append(`<span class='info val_2'>${el.val_2}</span>`);
				if(!isNull(el.val_3)) li.find(".aweCommentMsg").append(`<span class='info val_3'>${el.val_3}</span>`);
				if(!isNull(el.val_4)) li.find(".aweCommentMsg").append(`<span class='info val_4'>${el.val_4}</span>`);
				if(!isNull(el.val_5)) li.find(".aweCommentMsg").append(`<span class='info val_4'>${el.val_5}</span>`);				
				if(gUserinfo.userid==el.reg_usid) {
					li.addClass("my");
					if(me.del_yn=='Y' &&!isNull(el.comments)) li.find(".aweCommentMsg").append(`<i class='fas fa-trash'></i>`);
				}

				if(dir=="bottom") {
					me.commentList.append(li);
					//me.scroll = 0;
					//me.commentList.find(".aweRow").map((idx,el)=>$(el).outerHeight()).get().forEach(el=>me.scroll+=toNum(el)); //높이를 더해서 스크롤 아래로 시켜줌
					me.commentList.scrollTop( me.commentList[0].scrollHeight ); 
					
				} else if(dir=="top") {
					me.commentList.prepend(li);
					//me.commentList.scrollTop( 1 ); //0으로 보내면 다시 조회하므로 
				}
			}
			me.saveComment=function(comments) {  
				if(isNull(comments)) {
					gfnStatus("코멘트 확인(입력된 내용이 없습니다.)","입력된 내용이 없습니다.");
					return;
				}    
				var args = {ref_info_tp:me.ref_info_tp, ref_id:me.ref_id, comment_tp:me.comment_tp, comments:comments}
				var invar = JSON.stringify(args);
				//console.log(args);
        		gfnTx("aweportal.myMemo","save",{INVAR:invar},function(OUTVAR){
					if(OUTVAR.rtnCd=="OK") {
						me.componentBody.find("textarea").val("");
						me.readForward();
					} else {
						//console.log(OUTVAR);
						gfnAlert("저장오류",OUTVAR.rtnMsg);
					}
				});
			}
			me.exportData=function() {
				return me.data;
			}
			me.focus=function(rowid){
				me.commentList.find(".aweRow.focus").removeClass("focus");
				var row = me.commentList.find("[rid='"+rowid+"']")
				var idx = row.index();
				row.addClass("focus");
				me.scroll = 0;
				me.commentList.find(".aweRow").map((i,el)=>{ if(i<idx) return $(el).outerHeight() }).get().forEach(el=>me.scroll+=toNum(el));
                me.commentList.scrollTop( me.scroll );
			}
			me.reset=function(){
				me.data=[];
				me.initComponent();
			}
			me.initComponent();
		}
		me.container.children(".componentBody").remove();
		me.container.append(me.componentBody);
	};  
	me.init(); 
} 

//colinfo와 val를 받아서 Validation을 수행함(:가장작은 단위) > gfnControl > gfnComponent
function gfnChkValid(colinfo,val,bWarn,rowid) { 
	var rtnMsg = "";
	if(colinfo==undefined) return false; //colinfo가 없으면 시작할 것도 없이 return
	var colid = nvl(colinfo.colid,"");
	var colnm = nvl(colinfo.colnm,"");
	var dtype = nvl(colinfo.dtype,"text");
	var etype = nvl(colinfo.etype,"txt");
	var attr  = nvl(colinfo.attr,"");
	var len   = nvl(colinfo.len,0); 
	var vali  = eval2(nvl(colinfo.valid,"")); //사용자 추가 Validation(함수 또는 String eval)

	function fnCallback(aRtnMsg) {
		if(bWarn==true) gfnAlert(colnm+"("+colid+")값 오류", (!isNull(rowid)?"[줄:"+rowid+"] ":"") + val + " : " + aRtnMsg);
 		return false;
	}

	if (inStr(dtype,"ymd")>=0) {
		if(!isNull(val) && !isYmd(val)) { 
			rtnMsg = "날짜 형식이어야 합니다."; 
			return fnCallback(rtnMsg); 
		}
	}  
	if (inStr(dtype,"num")>=0) {
		if(!isNull(val) && !isNum(val)) { 
			rtnMsg = "숫자 형식이어야 합니다."; 
			return fnCallback(rtnMsg);  
		}
	} 	
	if(inStr(attr,"pk")>=0 || inStr(attr,"keycol")>=0) { 
		if(isNull(val)) { 
			rtnMsg = "필수입력 값이 입력되지 않았습니다."; 
			return fnCallback(rtnMsg); 
		}
	} 	
	if(inStr(attr,"lower")>=0) { 
		var regExp = /[A-Z]/g;
		if( !isNull(val) && regExp.test(val) == true) { //대문자가 하나라도 있으면 
			rtnMsg = "소문자 이어야 합니다."; 
			return fnCallback(rtnMsg); 
		}
	} 
	if(inStr(attr,"upper")>=0) { 
		var regExp = /[a-z]/g;
		if( !isNull(val) && regExp.test(val) == true) { //소문자가 하나라도 있으면 
			rtnMsg = "대문자 이어야 합니다."; 
			return fnCallback(rtnMsg); 
		}
	}  
	if(len != "infinite" && len != 0 && !isNull(len)) {
		var llen = toNum(String(len).split(":")[0]);
		if(llen != null && llen >= 0) {  //점검기준이 음수일떄는 체크하지 않음. 0일때는 입력받으면 안되는 것을 의미함. 
			if(!isNull(val) && String(val).length > llen) {
				rtnMsg = llen + "자리보다 크게 입력되었습니다."; 
				return fnCallback(rtnMsg); 	
			}
		} 
	}  
	if($.type(vali) == "regexp") { 
		if( vali.test(val) != true ) { //ex. /[a-z]/g.test("ABC") => false
			rtnMsg = "형식에 맞지 않습니다.:"+vali; 
			return fnCallback(rtnMsg); 
		} 
	} else if($.type(vali) == "string") {  
		if( vali != "" && eval2(val+vali) != true ) {  //ex. eval2( 15 + " > 100" ) => false
			rtnMsg = "조건에 맞지 않습니다.:"+vali; 
			return fnCallback(rtnMsg); 
		}
	} else if($.type(vali,rowid) == "function") { 
		if( vali(val,rowid) != true ) {  //ex. me.fnVali = function(val,rowid) { return val>100?true:false }
			rtnMsg = "점검식에 맞지 않습니다."; 
			return fnCallback(rtnMsg); 
		} 
	} else if($.type(vali) == "object" || $.type(vali) == "array" ) {
		if( inStr(vali, val) < 0 ) {  //ex. inStr([10,20,30], 15) or inStr({a:1, b:2}, 2) or inStr({a:1, b:2}, {a:2})
			rtnMsg = "점검목록에 포함되지 않습니다."; 
			return fnCallback(rtnMsg); 
		}
	} 
	
	return true; 
}

/** colInfo를 받아서 html control을 return함  
dtype	etype		attr
======	==========	===============	
num		raw			pk		keycol
ymd		pre			center	hidden
text	txt			readonly	
		pwd		    disabled
		cbx			auto	
		sel			pop	
		tarea		ymd		upper
		img			dec1~4	lower
		link		num	
		btn		
		aceEditor	fixL
		awiViewer	fixR 
*/
function gfnControl(colinfo, afnEH, oComponent, rowid, val, rowPinned, agHack) {
	var me = this;
	me.oComponent = oComponent;
	me.colinfo = $.extend({},colinfo); //colinfo가 null일때 exception처리때문에 {}로 치환 
	me.afnEH = afnEH;
	me.obj = $("<span class='aweCol'></span>"); 
	me.agHack = agHack; 
	/* 합계에서는 etype:raw, attr:auto,ymd,pop을 제거한다.*/
	if(rowPinned==true) { 
		me.colinfo.etype = "raw";
		me.colinfo.defval = "";
		if(!isNull(me.colinfo.attr)) {
			me.colinfo.attr = me.colinfo.attr.replace("ymd","").replace("auto","").replace("pop","");
		}  
	} 	
	me.init = function() {
		
		me.colid = nvl(me.colinfo.colid,"");
		me.dtype = nvl(me.colinfo.dtype,"text");
		me.etype = nvl(me.colinfo.etype,"txt");
		me.attr  = nvl(me.colinfo.attr,"");

		/* len:w:h 로 관리하던 것을  -> len 과 w, h를 분리하기로 함 */
		me.len   = nvl(me.colinfo.len,0); 
		if(inStr(me.len,":")>=0) {
			me.w = trim(me.len.split(":")[0]);
			me.h = trim(me.len.split(":")[1]);
			me.len = me.len.split(":")[0];
		} else {
			me.w = me.len; 
			me.h = "";
		}
		me.w = nvl(nvl(me.colinfo.w, me.w),8); //길이 기본값은 8
		me.h = nvl(me.colinfo.h, me.h);

		/* 기본값: dv가 function이면 실행, dv가 String이면 그대로 사용 */
		var dv = eval2(nvl(me.colinfo.defval,null));
	    me.defval = $.type(dv)=='function'?dv():dv;  
		/* sel, auto, pop일때 사용하는 옵션 */
	    me.refcd = eval2(me.colinfo.refcd);  //참조공통코드 또는 참조데이터array/function 
		me.option = nvl(me.colinfo.option,"all:cd:nm:cdnm"); //참조옵션: gfnSetOpts참고할 것
		if(!isNull(me.option)) { 
			try {
				var opt = JSON.parse(me.option);
				if(typeof(opt)=="object") me.oOption = opt;
			} catch {
				//do_nothing
			}
		}
		me.setPairVal = function(colid, val) { 
			//console.log(arguments);
			//if(val==undefined) return console.log("val:"+val);
			if(colid==me.colid) return; // console.log("colid:"+colid);
			if(oComponent==undefined) return; // console.log("oComponent");
			if(oComponent.componentDef==undefined) { /* 직접추가한 컬럼일 경우 직접val세팅 */
				if( oComponent instanceof jQuery ) oComponent.val(val);
				else if (oComponent instanceof gfnControl ) oComponent.setVal(val);  
			} else if(oComponent.componentDef.component_pgmid=="aweForm") { /* aweForm일때 */
				oComponent.setVal(colid, val);  
			} else if(oComponent.componentDef.component_pgmid=="agGrid") { /* agGrid일때 */
				//console.log("agGrid");
				oComponent.setVal(rowid, colid, val);  	 
			} 
		}
		/* validation, 수식, 소계, 총계, 비고 */
	    me.valid  = eval2(me.colinfo.valid);  
	    me.valFormula = eval2(me.colinfo.valFormula);		
	    me.grpFormula = eval2(me.colinfo.grpFormula);  
	    me.totFormula = eval2(me.colinfo.totFormula);  
		me.remark = nvl(me.colinfo.remark,"");

		/* etype에 따른 컨트롤 오브젝트 생성 */
		var obj = $(`<span></span>`); 
		if( me.etype=="pre") {
			obj =  $(`<${me.etype}></${me.etype}>`); 
		} else if(me.etype=="txt") {
			obj =  $(`<input type="text" placeholder="${me.remark}"/>`); 
		} else if(me.etype=="pwd") {
			obj =  $(`<input type="password" placeholder="${me.remark}"/>`); 
		} else if(me.etype=="sel") {
			if(me.agHack=="selRenderer") {
				obj = $(`<span></span>`); 
			} else {
				obj =  $(`<select></select>`);
			} 
		} else if(me.etype=="cbx") {
			obj =  $(`<input type="checkbox"/>`);
		} else if(me.etype=="tarea") {
			obj =  $(`<textarea placeholder="${me.remark}"></textarea>`); 
		} else if(me.etype=="img") {
			// obj =  $(`<img></img>`); 
		} else if(me.etype=="link") {
			// obj =  $(`<a target="_blank"></a>`); 
		} else if(me.etype=="btn") { 
			obj =  $(`<button></button>`); 
			// obj.addClass("ui-button");
		} else if(me.etype=="none") {
			// obj.addClass("hidden");
		}
		if(!isNull(me.oOption)) {
			Object.keys(me.oOption).forEach(key=>{
				obj.attr(key,me.oOption[key]);
			})
		}
		obj.attr("colid",me.colid);
		obj.addClass("aweCol"); 
		/* etype, attr에 따른 기능Bind : sel pk disabled readonly hidden auto pop ymd dec1~4 upper lower*/
		obj.addClass(me.dtype); /* num ymd text */
		if(!isNull(me.attr)) obj.addClass(me.attr); /*pk, keycol, center, readonly, hidden */
		if(inStr(me.attr,"inputmodenone") >= 0) obj.attr("inputmode","none");
		if(inStr(me.attr,"disabled") >= 0) me.setDisable(true);
		if(oComponent!=undefined&&rowid!=undefined&&oComponent.getVal!=undefined) {
			setTimeout(function(){ 
				var crud = nvl(oComponent.getVal(rowid,"crud"),"C");
				if(crud != "C" && inStr(me.attr,"pk") >= 0) me.setDisable(true);
			}); 
		}
		if(inStr(me.attr,"readonly") >= 0) me.setReadonly(true);
		if(inStr(me.attr,"hidden") >= 0) me.setHidden(true);
		if(inStr(me.attr,"scan") >= 0) obj.attr("inputmode","none");
		/* me.obj에 할당 */
		me.obj = obj;
		me.dispObj = obj; 
		/* cbx는 span으로 싸준다. */
		if(me.etype=="cbx" && !isNull(me.attr)) {
			me.dispObj = $("<span></span>");
			me.dispObj.addClass("aweCol");
			me.dispObj.addClass(me.dtype);  
			me.dispObj.addClass(me.attr);
			me.dispObj.append(me.obj);
		}
		/* dblclick event 바인드 */ 
		if(me.rowid == undefined) { 
			me.obj.on("dblclick",function(e){
				afnEH(me.colid, "dblclick", me.getVal());  
			});
		}
		/* sel 옵션추가 */
		if(me.etype=="sel") {
			if(me.agHack!="selRenderer") {
				gfnSetOpts(obj, me.refcd, me.option, me.defval);
			}
		}
		/* btn 표시 */
		if (me.etype=="btn") {
			var btnText = nvl(me.colinfo.defval,me.colinfo.colnm);
			var btnIcon = nvl(me.colinfo.section_icon,"");
			if(!isNull(me.colinfo.option)) {
				btnText = me.colinfo.option.split(":")[0];
				btnIcon = me.colinfo.option.split(":")[1];
			}   
			if(!isNull(btnIcon)) me.obj.append(`<i class='${btnIcon}'></i> `);
			me.obj.append(btnText);
			me.obj.on("click",function(){ 
				afnEH(me.colid, "click");  
			});
		}
        /* ymd, auto, pop 은 버튼이 추가됨 */				
		if(inStr(me.attr,"ymd")>=0||inStr(me.attr,"pop")>=0) {			
			me.dispObj = gfnSetOpts(obj, me.refcd, me.option, me.defval);
		} else if(inStr(me.attr,"auto")>=0 && rowPinned == undefined) {
			me.dispObj = gfnSetOpts(obj, me.refcd, me.option, me.defval);
		} else { /* 엔터키 이벤트를 추가해 줌 */
			me.obj.on("keyup",function(e){
				if(e.keyCode==13) {
					afnEH($(e.target).attr("colid"), "enter", me.getVal()); 
				}
			});
		} 
		/* auto select 선택되면 처리 */ 	
		me.obj.on("autoselect",function(e, aParam){
			if(aParam==gParam) return;
			/* sel, auto, pop 은 값 변경이 일어났을때 코드/명과 같은 쌍 컬럼값을 변경해 준다. */
			var cdVal = (!isNull(aParam) && !isNull(aParam.item))?nvl(aParam.item.cd,null):null;
			var nmVal = (!isNull(aParam) && !isNull(aParam.item))?nvl(aParam.item.nm,null):null; 
			setTimeout(function() {
				me.setPairVal(me.option.split(":")[1], cdVal);
				me.setPairVal(me.option.split(":")[2], nmVal); 
				afnEH(me.colid, "change", me.getVal());  
			},1); 
		});	
		/* auto select 선택되면 처리 */ 	
		me.obj.on("autoselect2",function(e, aParam){
			/* sel, auto, pop 은 값 변경이 일어났을때 코드/명과 같은 쌍 컬럼값을 변경해 준다. */
			var cdVal = (!isNull(aParam) && !isNull(aParam.item))?nvl(aParam.item.cd,null):null;
			var nmVal = (!isNull(aParam) && !isNull(aParam.item))?nvl(aParam.item.nm,null):null; 
			setTimeout(function() {
				me.setPairVal(me.option.split(":")[1], cdVal);
				me.setPairVal(me.option.split(":")[2], nmVal);  
				afnEH(me.colid, "change", me.getVal());  
			},1); 
		});
		//popup
		me.obj.on("searchPop",function(e, aParam) { //사용자조작에 의해 바뀔때 Invoke된다. 
			//사용자정의 팝업을 사용하려는 경우 바로 리턴한다. 
			if( !isNull(arguments) && !isNull(arguments[1]) && arguments[1] =="mypop") {
				afnEH(me.colid, "mypop", arguments);  
				return;
			}
			var cdVal = null;
			var nmVal = null;  
			//aParam은 데이터만 조회할떄와 팝업이 뜰떄가 달라서 사용안함 대신 gParam사용 
			if(!isNull(gParam) && !isNull(gParam.rtnData)) {
				cdVal = nvl(gParam.rtnData[0]["cd"],null);
				nmVal = nvl(gParam.rtnData[0]["nm"],null);
			} 
			if(me.colid==gParam.colcd) me.setVal(cdVal);
			else if(me.colid==gParam.colnm) me.setVal(nmVal); 
			 //변경발생시 데이터정제 
			setTimeout(function() { 
				me.setPairVal(me.option.split(":")[1], cdVal);
				me.setPairVal(me.option.split(":")[2], nmVal); 
				afnEH(me.colid, "change", me.getVal());  
			},1);
		});
		me.obj.on("change",function(e, aParam){ //사용자조작에 의해 바뀔때 Invoke된다. 
			/* sel, auto, pop 은 값 변경이 일어났을때 코드/명과 같은 쌍 컬럼값을 변경해 준다. */
			if (me.etype=="sel") { 
				if(me.agHack!="selRenderer") { 
					setTimeout(function() {
						var cdVal = me.obj.find("option:selected").val(); 
						var nmVal = me.obj.find("option:selected").attr("pairVal"); 					
						me.setPairVal(me.option.split(":")[1], cdVal);
						me.setPairVal(me.option.split(":")[2], nmVal); 
					},1);
				} //selRenderer 모드일때는 change event가 발생할 수 없고, 처리하지도 않는다. 
			}  
			if (inStr(me.attr,"auto") < 0 && inStr(me.attr,"pop") < 0) { 
				var val = me.dispVal();
				me.setVal(val); //변경발생시 데이터정제  
				afnEH(me.colid, "change", me.getVal());  
			}
		}); 
		me.focusHack = false;
		me.obj.on("focus",function(e){
			if(!me.focusHack) {
				me.focusHack = true;
				me.obj.select(); 
			}
		}); 

		/* 기본값 설정 */
		if(val!=undefined) me.setVal(val,true); //값이 있으면 값이 우선
		else if(!isNull(me.defval)) me.setVal(me.defval); //없으면 기본값을 세팅

		/* 활성상태 */
		if(inStr(me.attr,"readonly")>=0) me.setReadonly(true);
		if(inStr(me.attr,"disabled")>=0) me.setDisable(true);
		
		/* 크기 표시 */
		// if(!isNull(me.w)) me.dispObj.attr("w",me.w); 
		// me.dispObj.css("flex", "1 1 "+me.w+"em"); 
		// if(!isNull(me.h)) me.dispObj.css("height",me.h+"em");   

		/* select2 적용  */
		if(me.etype=="sel") {
			
			if(me.agHack!="selRenderer") {
				if(!isNull(me.oComponent) && !isNull(me.oComponent.componentId) && me.oComponent.componentId=="pageCond") {
					if(!isNull(me.oComponent) && !isNull(me.oComponent.componentId) && me.oComponent.componentId=="pageCond") {
					if((inStr(me.option,"multi")>=0)) {
						setTimeout(function(control,bMulti){$(control).select2({
							multiple: true,
							closeOnSelect : false,
							dropdownAutoWidth : true 
						})},5,me.obj);
					} else {
						setTimeout(function(control,bMulti){$(control).select2({
							dropdownAutoWidth : true 
						})},5,me.obj);
					}
					} 
				}
			}
		}

		/* tooltip추가 */
		if(!isNull(me.remark)) me.obj.attr("title",me.remark); 

		return me;
	}  
	//값 변경시 데이터형식에 맞게 값 정제
	me.setter = function(val) {  
		// console.log("me.setter") ;
		if(me.dtype=="num") {
			if(inStr(me.attr,"dec1")>=0) return format(toNum(val),1);
			else if(inStr(me.attr,"dec2")>=0) return format(toNum(val),2);
			else if(inStr(me.attr,"dec3")>=0) return format(toNum(val),3);
			else if(inStr(me.attr,"dec4")>=0) return format(toNum(val),4);
			else return format(toNum(val));
		}
		else if (me.dtype=="ymd") {
			val=""+val;
			if(trim(val).length==8) return date(val,"yyyymmdd"); 
			else if(trim(val).length==4) return date((date("today").substr(0,4)+""+val),"yyyymmdd"); 
			else return date(val);
		}
		else if (me.dtype=="text") {
			if($.type(val)=="string") {
				if(inStr(me.attr, "upper")>=0) val = upper(val);
				else if(inStr(me.attr, "lower")>=0) val = lower(val);
				else if(inStr(me.attr,"biz_no")>=0) val = biz_no(val); 
				else if(inStr(me.attr,"ccard")>=0) val = ccard(val); 
				else if(inStr(me.attr,"nm")>=0) {
					me.cdnmVal = val;
					val = (val||"").split(":")[1];
				}
			}
			return val;
		} else if (me.etype=="cbx") {
			if(val==true||val=="on"||val=="Y") return "Y";
			else return "N";
		}
		return val;
	}
	//값 세팅
    me.setVal = function(val,bIinitialSkip) {
		// console.log("me.setVal") ;
		if( me.etype=="raw") {
			me.obj.includeObj(".aweCol").html(me.setter(val));
		} else if( me.etype=="pre") {
			me.obj.includeObj(".aweCol").html(me.setter(val));
		} else if(me.etype=="txt") {
			me.obj.includeObj(".aweCol").val(me.setter(val));
		} else if(me.etype=="pwd") {
			me.obj.includeObj(".aweCol").val(val);
		} else if(me.etype=="cbx") {  
			if(me.setter(val)=="Y") {
				me.obj.includeObj(".aweCol")[0].checked=true; 
				me.obj.includeObj(".aweCol").prop("checked",true);
			} else {
				me.obj.includeObj(".aweCol")[0].checked=false;  
				me.obj.includeObj(".aweCol").removeProp("checked");
			}
		} else if(me.etype=="sel") {
            if(me.agHack!="selRenderer") {
				me.obj.includeObj(".aweCol").val(val);
				setTimeout(function() {
					var cdVal = me.obj.find("option:selected").val(); 
					var nmVal = me.obj.find("option:selected").attr("pairVal"); 					
					me.setPairVal(me.option.split(":")[1], cdVal);
					me.setPairVal(me.option.split(":")[2], nmVal); 
				},1); 
			} else {  
				var pairVal = null;
				if(!isNull(me.colinfo)&&!isNull(me.refcd)&&!isNull(val)) {
					var disp = "cdnm"; 
					if(!isNull(me.colinfo)&&!isNull(me.option)&&!isNull(me.option.split(":")[3])) {
						disp = me.option.split(":")[3]; 
					}
					pairVal = gfnCdNm(me.refcd, val, "nm");
					if(disp=="cd") {
						me.obj.includeObj(".aweCol").html( me.setter( val ) );  
					} else if(disp=="nm") {
						me.obj.includeObj(".aweCol").html( pairVal );  
					} else {
						me.obj.includeObj(".aweCol").html( "["+me.setter( val )+"] " + pairVal );   
					} 
				} else {
					me.obj.includeObj(".aweCol").html( this.setter( val ) );  
				} 
				setTimeout(function() {
					me.setPairVal(me.option.split(":")[1], val);
					me.setPairVal(me.option.split(":")[2], pairVal); 
				},1); 
			} 
		} else if(me.etype=="tarea") {
			me.obj.includeObj(".aweCol").val(val);
		} else if(me.etype=="img") {
			me.obj.includeObj(".aweCol").attr("src",val);
		} else if(me.etype=="link") {
			me.obj.includeObj(".aweCol").attr("href",val);
		} else if(me.etype=="btn") {
			if(!isNull(val) && (isNull(me.colinfo) || isNull(me.colinfo.option))) { 
				var icon = nvl(me.obj.includeObj(".aweCol").children("i"),"");
				console.log(icon);
				me.obj.includeObj(".aweCol").html(val);
				if(!isNull(icon)) icon.prependTo(me.obj.includeObj(".aweCol"));
			}	
			me.obj.includeObj(".aweCol").data("val",val);
		} 
		if(rowid != undefined && !bIinitialSkip) { //agGrid일 경우 컨트롤이 변경된 경우 값을 agGrid쪽으로 값을 Sync해줘야함 
			if(oComponent.componentDef!=undefined && 
			   oComponent.componentDef.component_pgmid=="agGrid" &&
			   $.type(oComponent.setVal)=='function') {
				oComponent.setVal(rowid, me.colid, val);
			}
		}  
	}
	//표시값 가져오기 
	me.dispVal = function() {
		// console.log("me.disVal") ;
		var rtn = null;		
		if( me.etype=="raw") {
			rtn = me.obj.includeObj(".aweCol").html();
		} else if( me.etype=="pre") {
			rtn = me.obj.includeObj(".aweCol").html();
		} else if(me.etype=="txt") { 
			rtn = me.obj.includeObj(".aweCol").val();
			if(inStr(me.attr,"nm")>=0) rtn = me.cdnmVal; 
		} else if(me.etype=="pwd") {
			rtn = me.obj.includeObj(".aweCol").val();
		} else if(me.etype=="cbx") {
			if(me.obj.includeObj(".aweCol")[0].checked==true||me.obj.includeObj(".aweCol").prop("checked")==true) rtn = "Y";
			else rtn = "N";  
		} else if(me.etype=="sel") {
			rtn = me.obj.includeObj(".aweCol").val();
		} else if(me.etype=="tarea") {
			rtn = me.obj.includeObj(".aweCol").val();
		} else if(me.etype=="img") {
			rtn = me.obj.includeObj(".aweCol").attr("src");
		} else if(me.etype=="link") {
			rtn = me.obj.includeObj(".aweCol").attr("href");
		} else if(me.etype=="btn") {
			rtn = me.obj.includeObj(".aweCol").data("val"); 
		} 
		if($.type(rtn)=="string") {
			if(inStr(me.attr, "upper")>=0) rtn = upper(rtn);
			else if(inStr(me.attr, "lower")>=0) rtn = lower(rtn);
		}
		return rtn;
	}
	//데이터형식에 맞는 값 가져오기 
	me.getVal = function() {
		// console.log("me.getVal") ;
		var rtn = me.dispVal();
		if(me.dtype=="num") return toNum(rtn); 
		else if (me.dtype=="ymd") return date(rtn,"yyyy-mm-dd","yyyymmdd"); 
		return rtn;
	}  
	//ATTR에 따른 상태처리 
	me.setDisable = function(bLock) {
		// console.log("me.setDisable") ;
		if(bLock==true) {
			me.obj.includeObj(".aweCol").addClass("disabled");
			me.obj.includeObj(".aweCol").attr("disabled","disabled"); 
			me.obj.children(".aweColBtn").attr("disabled","disabled");
		} else {
			me.obj.includeObj(".aweCol").removeClass("disabled");
			me.obj.includeObj(".aweCol").removeAttr("disabled");
			me.obj.children(".aweColBtn").removeAttr("disabled");
		}
	} 
	me.setReadonly = function(bLock) {
		// console.log("me.setReadonly") ;
		if(bLock==true) {
			me.obj.includeObj(".aweCol").addClass("readonly");
			me.obj.includeObj(".aweCol").attr("readonly","readonly");
			me.obj.children(".aweColBtn").attr("disabled","disabled");
			if(me.etype == "sel") { me.obj.includeObj(".aweCol").attr("disabled","disabled"); }		
		
		} else {
			me.obj.includeObj(".aweCol").removeClass("readonly");
			me.obj.includeObj(".aweCol").removeAttr("readonly");
			me.obj.children(".aweColBtn").removeAttr("disabled");
			if(me.etype == "sel") { me.obj.includeObj(".aweCol").removeAttr("disabled"); }
		}
	}		
	me.setHidden = function(bHide) {
		// console.log("me.setHidden") ;
		if(bHide==true) {
			me.obj.hide();
			if(!isNull(me.dispObj)) me.dispObj.hide();
			me.obj.siblings(".select2").hide();
		} else {
			me.obj.show(); 
			if(!isNull(me.dispObj)) { me.dispObj.show(); me.dispObj.removeClass("hidden"); }
			me.obj.siblings(".select2").show().removeClass("hidden");
		}
	}	
	//컨트롤에 포커스 주기 
	me.focus = function() {
		// console.log("me.focus") ;
		if(!me.obj.includeObj(".aweCol").is(":focus")) { 
			setTimeout(function() {
				//console.log("focus on me.obj:"+me.colinfo.colid);
				me.obj.includeObj(".aweCol").focus();
				//console.log("control focused");
				//me.obj.includeObj(".aweCol").select();
			},1); 
		}
	}
	//option을 변경해 줌
	me.refreshOptions  = function(arr) {
		// console.log("me.refreshOption") ;
		var obj = me.obj.includeObj(".aweCol"); 
		gfnSetOpts(obj, arr, me.option, me.getVal() );
	}
	//값이 Valid한지 Return
	me.chkValid = function(bWarn) { 
		// console.log("me.chkValid") ;
		return gfnChkValid(me.colinfo, me.getVal(), bWarn);
	}

	me.init(); //초기화호출
}

//SELECT, AUTOCOMPLETE, POPUP을 위한 OBJECT설정
function gfnSetOpts(obj, refcd, option, val) {
	if(isNull(obj) || obj instanceof jQuery == false) return;
	/* 선택옵션:코드컬럼:명칭컬럼:표시형식:그룹컬럼 
		선택옵션- all(전체)/sel(선택)/multi(다중-pop에서만)/auto(1건 존재시 자동닫힘-pop에서만)
		검색코드컬럼:명칭컬럼: 검색Dataset에서 해당하는 컬럼ID
		표시형식: cd(코드만표시)/nm(명칭만표시)/cdnm(코드와 명칭표시), popup일 경우 검색어(=term,val)이 어떤 컬럼인지 특정
		그룹컬럼: 그룹핑하여 표시할 경우 그룹컬럼ID */	
	var options = option.split(":");
	var optSel = nvl(options[0],"sel");
	var colcd  = nvl(options[1],"cd");
	var colnm  = nvl(options[2],"nm");
	var disp   = nvl(options[3],"cdnm");
	var colgrp = nvl(options[4],""); 
	var val_1  = nvl(options[5],""); 
	var val_2  = nvl(options[6],""); 

	/* SELECT일 경우 옵션세팅 */ 
	var fnSetOpts = function(arr) { 
		obj.children("*").remove();
		if(optSel=="all") obj.append("<option value='' selected='selected'>-전체-</option>");
		if(optSel=="sel") obj.append("<option value='' selected='selected' disabled >-선택-</option>");
		if(optSel=="multi") {
			//obj.append("<option disabled selected='selected'>-선택-</option>");
			obj.prop("multiple","multiple");
		}
		var optgrp = obj; 
		if(arr==undefined) arr = [];
		for(var i=0; i < arr.length; i++) {
			if(!isNull(colgrp) && optgrp.attr("label")!=arr[i][colgrp]) { 
				optgrp = $(`<optgroup label="${arr[i][colgrp]}"></optgroup>`);
				obj.append(optgrp);
			}
			if(!isNull(val_1) && arr[i].val_1!=val_1) continue; 
			if(!isNull(val_2) && arr[i].val_2!=val_2) continue; 
			var opt = $(`<option value='${arr[i].cd}' pairVal='${arr[i].nm}' ${(val==arr[i].cd)?"selected":""} ${isNull(arr[i]["disabled"])?"":"disabled"}></option>`); 
			if(disp=="cd") opt.append(arr[i].cd);
			else if(disp=="nm") opt.append(arr[i].nm);
			else opt.append("["+arr[i].cd+"]"+arr[i].nm);
			optgrp.append(opt);
		}  
	}  
	/* obj유형에 맞게 초기화 *****************************************************/
	var fnInit = function() {
		//select
		if(obj.prop("tagName")=="SELECT") { 
			//gfnGetData(refcd, fnCallback, disp, term, bForceRefresh, where)  
			gfnGetData(refcd, fnSetOpts, "cdnm", ""); //옵션데이터를 가져와서 뿌려준다. 
		}
		//ymd
		else if(obj.hasClass("ymd")) {
			var wrap = $("<div class='aweColWrap'></div>");
			obj.datepicker({
				dateFormat:"yy-mm-dd",
				changeMonth: true,
				changeYear: true				
			});
			wrap.append(obj);
			var objId = obj.attr("id"); //datepicker를 지정하면 uuid가 세팅되므로 이를 사용한다.
			var btnYmd = $(`<button class='aweColBtn ui-icon ui-icon-calendar' refid='${objId}' tabIndex='-1'></button>`); 
			btnYmd.on("click",function(e){ 
				var refid = $(e.target).attr("refid");
				$("#"+refid).datepicker("show"); 
			});
			wrap.append(btnYmd);
			return wrap; //obj을 둘러싼 wrap을 돌려준다. 
		}
		//autocomplete
		else if(obj.hasClass("auto")) {
			var wrap = $("<div class='aweColWrap'></div>");
			var opt = {
					minLength: 0,
					source:function(req, res){
						gfnGetData(refcd, function(arr) {
							var rtn = $.map( arr, function(el,idx) {
								var r = $.extend(el,{value:el.cd,label:(el.cd+" "+el.nm),category:el[colgrp]});
								return r; 
							});
							res(rtn);
						}, "cdnm", req.term);
					},
					open: function() {
						gParam.item = undefined;
					},
					select:function(evt,ui) {
						gParam.item = undefined;
						gParam = $.extend(true, gParam, {rtnData:[gParam.item]}); 
						obj.trigger("autoselect",ui);  
					},
					autoFocus: true, 
					focus:function(evt,ui) {
						gParam = $.extend(true, gParam, ui);
					},
					close:function(evt,ui) {
						if(gParam.item!=undefined) { 
							obj.trigger("autoselect2",gParam); 
						} 
					}, 
				}
			if( optSel=="multi" ) {
				function split( val ) {
					return val.split( " " );
				}
				function extractLast( term ) {
					return split( term ).pop();
				}
				opt = {
					minLength:0,
					source:function(req, res){
						gfnGetData(refcd, function(arr) {
							var rtn = $.map( arr, function(el,idx) {
								var r = $.extend(el,{value:el.cd,label:(el.cd+" "+el.nm),category:el[colgrp]});
								return r; 
							});
							res(rtn);
						}, "cdnm", extractLast(req.term) );
					}, 
					select:function(evt,ui) {
						gParam.item = undefined;
						var terms = split( obj[0].value ); 
						terms.pop(); // remove the current input 
						terms.push( ui.item.value ); // add the selected item 
						terms.push( "" ); // add placeholder to get the comma-and-space at the end
						obj[0].value = terms.join( " " );
						return false;   
					}, 
					focus:function(evt,ui) {
						return false;
					},
					close:function(evt,ui) {
						//do nothing
					}, 
				}
			}
			if( !isNull(colgrp)) {
				obj.catcomplete(opt);
			} else { 
				obj.autocomplete(opt);
			}
			wrap.append(obj);
			/* autocomplete는 버튼 없앰
			var btnAuto = $("<button class='aweColBtn ui-icon ui-icon-comment'></button>"); 
			if( !isNull(colgrp)) {
				btnAuto.on("click",function(e){
					var refobj = $(e.target).siblings(".aweCol");
					refobj.catcomplete("search",refobj.val());
				});
			} else { 
				btnAuto.on("click",function(e){
					var refobj = $(e.target).siblings(".aweCol");
					refobj.autocomplete("search",refobj.val());
				});
			}
			wrap.append(btnAuto);  
			*/
			return wrap; //obj을 둘러싼 wrap을 돌려준다.  
		}				
		//popup
		else if(obj.hasClass("pop")) {  
			var wrap = $("<div class='aweColWrap'></div>");	
			wrap.append(obj);
			var btnPop = $(`<button class='aweColBtn' tabIndex='-1'><i class="fas fa-search"></i></button>`);
			wrap.append(btnPop); 
			/*
			obj.on("keyup change",function(e){
				if(e.keyCode==13) {   
					gfnSearch(refcd, function(rtn){
						obj.trigger("searchPop",rtn); 
					}, "auto:"+colcd+":"+colnm+":"+disp+":"+colgrp, obj.val() ); //1건 존재시 자동닫힘
				}
			});
			*/
			obj.on("change",function(e){  
				gfnSearch(refcd, function(rtn){
					obj.trigger("searchPop",rtn); 
				}, "auto:"+colcd+":"+colnm+":"+disp+":"+colgrp, obj.val() ); //1건 존재시 자동닫힘
			});	
			btnPop.on("click",function(e){ 
				gfnSearch(refcd, function(rtn){
					obj.trigger("searchPop",rtn); 
				}, option, obj.val() )
			});
			return wrap; //obj을 둘러싼 wrap을 돌려준다. 
		}  
		return obj;
	} 
    return fnInit(); //초기화 호출
}

/* 표준코드 검색창을 띄우고 fnCallback을 호출  *****************************************************/
function gfnSearch(refcd, fnCallback, option, term, bForcerefresh, where) {
	/*  refcd = 공통코드구분(grpcd값) 또는 popupSearch에 정의한 검색구분
	            또는 결과셋을 리턴하는 함수 또는 배열
				* gfnGetData 참조
	    option = "선택옵션:코드컬럼:명칭컬럼:표시형식:그룹컬럼" 
		  선택옵션- sel(선택)/multi(다중-pop에서만)/auto(1건 존재시 자동닫힘-pop에서만)
		  코드컬럼:명칭컬럼 = 값을 리턴받을 컬럼ID
		  검색컬럼: term이 어떤 컬럼인지 cd(코드)/nm(명칭)/cdnm(코드명칭무관)
		  그룹컬럼: 그룹핑하여 표시할 경우 그룹컬럼ID
		term = 검색어
		fnCallback = 검색어를 검색한 결과를 리턴받을 콜백함수 */

	/* 사용자정의 팝업을 사용하려는 경우 바로 리턴한다. */
	if(refcd=="mypop") {
		fnCallback(arguments); //will invoke gfnControl.searchPop  
		return;
	}	
		
	var options = option.split(":");
	var optSel = nvl(options[0],"sel");
	var colcd  = nvl(options[1],"cd");
	var colnm  = nvl(options[2],"nm");
	var disp   = nvl(options[3],"cdnm");
	var colgrp = nvl(options[4],""); 
	/* 팝업창을 띄운다. */ 
	var fnOpenPop = function(refcd, list, term, afnCallback, bForcerefresh, where) {
		if($(".framepage.popupSearch").length > 0) return;
		var popid =  "search"+gMDI.getNext();
		var container = $("<div id='"+popid+"' class='framepage popupSearch' style='display:flex;flex-direction:column;'></div>");
		$("#frameset").append(container);		
		//검색창을 불러들인 후 팝업창 호출 
		gParam["refcd"]  = refcd; //검색구분
		gParam["list"]  = list; //조회해놓은 데이터셋을 던진다. 
		gParam["optSel"] = optSel; 
		gParam["colcd"] = colcd;
		gParam["colnm"] = colnm;
		gParam["disp"] = disp;
		gParam["colgrp"] = colgrp; 
		gParam["term"] = term; //전달된 검색어를 던진다.
		gParam["bForcerefresh"] = bForcerefresh; //전달된 검색어를 던진다.
		gParam["where"] = where; //전달된 검색어를 던진다.
		gfnLoad("aweportal","popupSearch",container,function(){
			var title = "코드 검색";
	    	gfn["popupTemp"] = gfnPopup(title, container, {}, afnCallback);
		},true); 
	} 
	/* 데이터를 조회한 후 팝업을 띄운다. */
	gParam = {}; //검색전 gParam Clear...
	gfnGetData(refcd, function(list){
		if(optSel=="auto" && list.length==1) {
			var rtn = [];
			for(var i=0; i < list.length; i++) {
				var row = {};
				row[colcd] = list[i].cd;
				row[colnm] = list[i].nm;
				$.extend(true, row, list[i]);
				rtn.push(row);
			}
			gParam = $.extend(true, gParam, {rtnCd:"OK", rtnData:rtn, colcd:colcd, colnm:colnm});
			fnCallback(gParam);
		} else {
			fnOpenPop(refcd, list, nvl(term,""), fnCallback, bForcerefresh, where);
		}
	}, disp, nvl(term,""), bForcerefresh, where);
} 
/* refcd(grpcd)에 따라 데이터를 조회하고 fnCallback을 호출  ****************************************/	
function gfnGetData(refcd, fnCallback, disp, term, bForceRefresh, where) { 
	if($.type(eval2(refcd))=="string") {
		if(bForceRefresh) {
			for(var i=gds.comcd.length-1; i >= 0; i--) {
				if(gds.comcd[i].grpcd == refcd) gds.comcd.splice(i,1);
			} 
		}
		//refcd 가 공통코드에 있으면 gds.comcd 사용
		if(subset(gds.comcd,"grpcd",refcd).length > 0) { 
			var arrRtn = subset(gds.comcd,"grpcd",nvl(refcd,"GRPCD"));
			var arrDisp = ["cd","nm"];
			if(disp=="cd") arrDisp = "cd";
			else if(disp=="nm") arrDisp = "nm";
			arrRtn = subset(arrRtn,arrDisp,nvl(term,""),true); 
			fnCallback(arrRtn); 
		} else { //refcd 가 공통코드에 없는 스트링이면 조회하여 사용
			if(isNull(refcd)) return;
			var args = {grpcd:refcd, disp:nvl(disp,"cdnm"), term:nvl(term,"")}; 
			if(!isNull(where)) args.where = where; 
			var invar = JSON.stringify(args);
			gfnTx("aweportal.popupSearch","search",{INVAR:invar},function(OUTVAR){
				if(OUTVAR.rtnCd=="OK") {
					if(isNull(term)) { //검색어가 없이 조회되면 검색결과를 공통코드에 넣어준다.: 다음 호출부터는 공통코드에서 가져오도록 함.
						if(!isNull(OUTVAR.list) && OUTVAR.list.length < 1001) {
							for(var i=0; i < OUTVAR.list.length; i++) {
								var row = OUTVAR.list[i];
								row.grpcd = refcd;
								gds.comcd.push(row);
							} 
						}
					}
					fnCallback( OUTVAR.list );
				} else {
					gfnAlert("코드검색오류","코드 검색 중 오류가 발생하였습니다.");
					console.log(OUTVAR);
					console.log(args);
					fnCallback( [{}] );
				}
			});
		}
	} else if($.type(eval2(refcd))=="function") { //refcd 가 function이면 호출하여 사용
		fnCallback( eval2(refcd)(disp, nvl(term,"")) );           
	} else if($.type(eval2(refcd))=="array") {  //refcd 가 오브젝트 배열이면 그대로 사용 
		if($.type(eval2(refcd)[0])!="object") {   
			var list = [];
			for(var i=0; i < eval2(refcd).length; i++) {
				list.push({"cd":eval2(refcd)[i],"nm":eval2(refcd)[i]});
			}
			fnCallback( list ); 
		} else { 
			var arrDisp = ["cd","nm"];
			if(disp=="cd") arrDisp = "cd";
			else if(disp=="nm") arrDisp = "nm";
			var list = subset(eval2(refcd),arrDisp,nvl(term,""),true);  
			fnCallback( list );
		}
	}
}  

/* 메세지 채널을 생성하거나 생성된 채널의 정보를 관리 */
function gfnManageChat(grpid, userid) {

	//참고하는 gParam 데이터셋 초기화
	gParam["grpid"]		= [];
	gParam["userid"]	= [];

	//팝업 생성
	//grpid와 userid를 팝업 호출 시 전달받음
	gParam["grpid"]	 = grpid;
	gParam["userid"] = userid;

	if($.contains(document.body, document.getElementsByClassName("manageframeChat")[0])) $("#frameset .manageframeChat").remove();
	
	var container = $("<div class='manageframeChat'></div>");
	$("#frameset").append(container);
	
	gfnLoad("aweportal", "manageChat", container, function() {
	}, true);

	// //팝업 생성
	// var fnOpenPop = function(grpid, userid) {
	// 	var container = $("<div class='manageChat'></div>");

	// 	//grpid와 userid를 팝업 호출 시 전달받음
	// 	gParam["grpid"]	 = grpid;
	// 	gParam["userid"] = userid;

	// 	gfnLoad("aweportal", "manageChat", container, function() {
	// 		var title = "메세지 채널";
	// 		var opt = {
	// 			resizable: true,
	// 			modal : true,
	// 			draggable: true,
	// 			minWidth: 430,
	// 		}
	// 		gfnPopup(title, container, opt);
	// 	}, true);
	// }
	// fnOpenPop(grpid, userid);
}

/* popupUpload 파일 업로드 창 */
function gfnUpload(UUID, file_tp, ref_file_tp, afnCallback) {
	var UUID = UUID;
	var file_tp = file_tp;
	var ref_file_tp = ref_file_tp;

	/* 팝업창을 띄운다. */ 
	var fnOpenPop = function(UUID, file_tp, ref_file_tp) {
		var popid =  "upload"+gMDI.getNext();
		var container = 
		$("<div id='"+popid+"' class='framepage popupUpload' style='display:flex;flex-direction:column;'></div>");
		$("#frameset").append(container);
		// $('#frameset').css("pointer-events","none");
		// $('#frameGNB').css("pointer-events","none");

		/* 선언된 데이터를 업로드창으로 넘겨준다. */
		gParam["UUID"] = UUID;
		gParam["file_tp"] = file_tp;
		gParam["ref_file_tp"] = ref_file_tp; 
		 
		gfnLoad("aweportal", "popupUpload", container, function() { 
			var title = "파일 업로드";
			var opt = {
				resizable: true,
				modal : true,
				draggable : true,
				minWidth : 850
			} 
	    	gfn["popupTemp"] = gfnPopup(title, container,{width:896,height:530, modal:true}, function(){ 
				var filelist = [];
				if(gParam!=undefined && gParam.rtnCd =="OK" ) { 
					filelist = gParam.filelist;
				}
				if(afnCallback!=undefined) afnCallback(filelist);
				
			});
		}, true); 
	}
	fnOpenPop(UUID, file_tp, ref_file_tp);
}

function gfnDownloadDirect(url, filename) {
	if(isNull(url)||url.lastIndexOf("/")+1 == url.length) {
		gfnAlert("파일다운로드오류","파일정보를 가져오는데 오류가 발생하였습니다.<br> => 잘못된 파일경로 : " + url);
		return;
	}
    var file_nm = nvl(filename, url.substr(url.lastIndexOf("/")+1)); 
    var frm = $("<form class='fileDownloader' action='/awegtx.jsp?pgm=aweportal.fileDownloader' target='_blank' " +
                " method='POST' style='display:none'></form>");
    var args = {url:url, filename:file_nm};
    var sArgs = JSON.stringify(args);
    frm.append("<input type='text' name='INVAR' value='"+sArgs+"'>");
    frm.appendTo("body"); 
    frm.submit();
	$("body .fileDownloader").remove();
}

function gfnDownload(fileid, filename) {
	var invar = JSON.stringify({fileid:fileid});
	gfnTx("aweportal.popupUpload","searchFileid",{INVAR:invar},function(OUTVAR){
		//console.log(OUTVAR);
		if(OUTVAR.rtnCd=="OK" && OUTVAR.list.length==1) { 
			var fileInfo = OUTVAR.list[0];
			var frm = $("<form class='fileDownloader' action='/awegtx.jsp?pgm=aweportal.fileDownloader' target='_blank' " +
						" method='POST' style='display:none'></form>");
			var args = {url:fileInfo.file_url, filename:nvl(filename,fileInfo.file_nm)};
			var sArgs = JSON.stringify(args);
			frm.append("<input type='text' name='INVAR' value='"+sArgs+"'>");
			frm.appendTo("body"); 
			frm.submit();
			$("body .fileDownloader").remove();
		} else {
			gfnAlert("파일다운로드오류","파일정보를 가져오는데 오류가 발생하였습니다.<br> => 권한이 없거나 잘못된 파일ID : " + fileid);
		}
	})
}

/* 공지사항 및 배너 상세보기 화면 */
function gfnPopupDetailBBS(docid) {
	var docid = docid;
	/* 팝업창을 띄운다. */ 
	var fnOpenPop = function(docid) {
		var popid =  "detailBBS"+gMDI.getNext();
		var container = $("<div id='"+popid+"' class='framepage detailBBS' style='display:flex;flex-direction:column;'></div>");
		$("#frameset").append(container);

		/* 선언된 데이터를 업로드창으로 넘겨준다. */
		gParam["docid"] = docid;

		gfnLoad("aweportal", "detailBBS", container, function() { 
			var title = "공지사항";
			var opt = {
				resizable: true,
				modal : true,
				draggable : true,
				minWidth : 1000,
				height : 600
			} 
	    	gfn["popupTemp"] = gfnPopup(title, container, opt, function(){
			});
		}, true); 
	}
	fnOpenPop(docid);
}

//AgGrid처리를 위한 함수 및 클래스 Start****************************************************/
var RN_WIDTH = 40;
var CHK_WIDTH = 32;
function gfnAgGridColumnDef(oComponent, colinfos, afnEH) {
	var colDefs = []; 
	//맨 앞에 rownum을 넣어줌
	if(!isNull(oComponent.component_option) && inStr(oComponent.component_option.gridOpt,"rn")>=0) {
		/* RowIndex와 RowNode를 표시 */
		var RowNumbering = {  
			colId: "rn",
			field: "rn",
			width: 50,  
			headerName: "No", 
			resizable: false,
			suppressMenu: true, 
			pinned : "left", 
			cellClass: "text-center",
			valueGetter: function(params) { 
				//console.log(params);
				return {rowIndex:(params.node.rowIndex+1),nodeId:params.node.id}; 
			},
			cellRenderer: function(params) { 
				var bg = "rgba(210, 210, 210, 0.3)";
				if(params.data!=undefined&&params.data.crud=="D") bg = "rgba(10, 10, 10, 0.5)";
				else if(params.data!=undefined&&params.data.crud=="C") bg = "hsla(65 100% 90% / 0.5)";
				else if(params.data!=undefined&&params.data.crud=="U") bg = "hsla(95 100% 90% / 0.5)";
				//else if(params.node.isSelected()) bg = "rgba(0, 145, 234, 0.5)";
				params.eGridCell.style.backgroundColor=bg; 
				if(params.data!=undefined&&!isNull(params.data.rn)) return params.data.rn;
				return (params.value!=undefined)?params.value.rowIndex:null; //+"-"+params.value.nodeId;
			} 
		};
		colDefs.unshift(RowNumbering); 
	}
	//그 앞에 체크박스를 넣어줌
	if(!isNull(oComponent.component_option) && inStr(oComponent.component_option.gridOpt,"chk")>=0) {
		var cbx = { 
			colId: "chk",
			field: "chk",
			headerName: "",
			width: 30,
			resizable: false,
			headerCheckboxSelection: true, 
			editable: false,			
			cellClass: "text-center",
			checkboxSelection: true, 
			pinned: 'left', 
			suppressMenu: true
			/* suppressClickEdit: true */
		} 
		colDefs.unshift(cbx);
	}  
	var colgrp = {};
	var colgrpnm = "";
	var sectionNode = [];
	var parentNode = []; 
	for(var i=0; i < colinfos.length; i++) {  
		var colinfo = colinfos[i];
		var colDef = {};
		colDef.headerName = colinfo.colnm;
		colDef.field      = colinfo.colid;
		if(inStr("none raw div pre img button link",colinfo.etype) >= 0) { 
		    colDef.editable   = false; //컬럼속성에 따라 
		    /* if(inStr(colinfo.attr,"rowSpan") >= 0) { 
				대량데이터에서 AG-GRID가 정상적으로 작동하지 않음.
			    colDef.rowSpan = function(param) {
				    var rtn = 1;
				    if(!isNull(param.column) && !isNull(param.column.colId) &&
				       !isNull(param.node) && isNull(param.node.rowPinned)) {
				        var colId = param.column.colId;
					    var rowIdx = param.node.rowIndex;
						var val = param.data[colId];
						var node = undefined;
						var bStop = true; 
						if(!isNull(val)) { 
							node = param.api.getDisplayedRowAtIndex(rowIdx-1);
							if(!isNull(node)) {
								if(node.data[colId] == val) {
									return 1;
								}
							}
							do {
								node = param.api.getDisplayedRowAtIndex(rowIdx);
								if(!isNull(node)) {
									if(node.data[colId] == val) { 
										rtn++;
										rowIdx++;
										bStop = false; //next! 
									} else { 
										bStop = true;
									}
								} else { 
									bStop = true;
								} 	
							} while (!bStop);   
						}
				   }  
				   return rtn;
			    }
		    } */
		} else {
			if(inStr(colinfo.attr,"readonly")>=0 ||inStr(colinfo.attr,"disabled")>=0  ) {
				colDef.editable   = false; //컬럼속성에 따라  
			} else {
				colDef.editable   = true;
			} 
		}
		if("none"==colinfo.etype || inStr(colinfo.attr,"hidden") >= 0) {
			colDef.hide = true;
		}
		if(inStr(colinfo.attr,"wbhidden") >= 0) {
			colDef.hide = true;	// 워크벤치 agGird Column 숨김
		}

		me = {};
		/* len:w:h 로 관리하던 것을  -> len 과 w, h를 분리하기로 함 */
		me.len   = nvl(colinfo.len,0); 
		if(inStr(me.len,":")>=0) {
			me.w = trim(me.len.split(":")[0]);
			me.h = trim(me.len.split(":")[1]);
			me.len = me.len.split(":")[0];
		} else {
			me.w = me.len; 
			me.h = "";
		}
		if( colinfo.dtype == "num" ) {
			colDef.comparator = function(valueA, valueB, nodeA, nodeB, isInverted) {
				return toNum(valueA) - toNum(valueB);
			}
		}
		me.w = nvl(nvl(colinfo.w, me.w),8); //너비 기본값은 8
		me.h = nvl(colinfo.h, nvl(me.h,1));
		colDef.width = nzl(toNum(me.w)*10,32); //최소32
		
		if(inStr(colinfo.attr,"fixL") >= 0) colDef.pinned = 'left';
		else if(inStr(colinfo.attr,"fixR") >= 0) colDef.pinned = 'right';		

		/*none raw div pre 이면 renderer, editor지정하지 않음
		if(inStr("none raw div pre tarea",colinfo.etype) >= 0) { 
			colDef.wrapText = true;
			colDef.autoHeight = true;
		} 
		*/
		if(colinfo.etype=="cbx") {
			colDef.editable =  false;
			colDef.cellRenderer = 'agGridCellRender';
			colDef.cellRendererParams = { oComponent:oComponent, colinfo:colinfo, afnEH:afnEH };
		} else {
			if(inStr(colinfo.attr,"grp")>=0) {
				colDef.cellRenderer = 'agGroupCellRenderer';
			} else {
				colDef.cellRenderer = 'agGridCellRender';
			} 
			colDef.cellRendererParams = { oComponent:oComponent, colinfo:colinfo, afnEH:afnEH };
			if(colDef.editable == true) { //editable true일때만 에디터지정 
				colDef.cellEditor = 'agGridCellEdit'; //컬럼속성에 따라
				colDef.cellEditorParams = { oComponent:oComponent, colinfo:colinfo, afnEH:afnEH }; //컬럼속성에 따라  
			}
			if(inStr(colinfo.attr,"wrapText_autoHeight")>=0) {
				colDef.wrapText = true;
				colDef.autoHeight = true; 
			}  
		}

		//섹션이 없으면 만들어준다.(섹션은 발생즉시 넣어줌)
		if(!isNull(colinfo.section)&&colDefs.find(col=>col.section==colinfo.section)==undefined) {
			colDefs.push({headerName:colinfo.section, section:colinfo.section, children:[] }); 
		}  
		//그룹이 없으면 섹션.children 또는 ColDefs에 만들어준다.
		sectionNode = colDefs; 	
        if(!isNull(colinfo.section)&&sectionNode.find(col=>col.section==colinfo.section)!=undefined) {
			sectionNode = sectionNode.find(col=>col.section==colinfo.section).children; 
		}
		if(!isNull(colinfo.colgrp)&&sectionNode.find(col=>col.colgrp==colinfo.colgrp)==undefined) { 
			var colGrpDef = {headerName:colinfo.colgrp, colgrp:colinfo.colgrp, children:[] }; 
			if(!isNull(colinfo.section)) colGrpDef.section = colinfo.section;
			sectionNode.push(colGrpDef); 
		} 
		//ColDef을 넣어준다. 
		parentNode = colDefs; 
        if(!isNull(colinfo.section)&&colDefs.find(col=>col.section==colinfo.section)!=undefined) {
			parentNode = colDefs.find(col=>col.section==colinfo.section).children;
		}
		if(!isNull(colinfo.colgrp)&&parentNode.find(col=>col.colgrp==colinfo.colgrp)!=undefined) {
			parentNode = parentNode.find(col=>col.colgrp==colinfo.colgrp).children;
		}
        parentNode.push(colDef);
	} 
	//property삭제:section,colgrp
	function DeleteAttr(arr) {
		arr.forEach(col=>{
			delete col.colgrp;
			delete col.section;
			if(!isNull(col.children)) DeleteAttr(col.children);  
		});
	}
	DeleteAttr(colDefs); 
	return colDefs; 
}
function gfnAgGridCellStyle(colinfos, param) {
	if(!isNull(param.node) && !isNull(param.node.rowPinned)) return;
	if(isNull(colinfos)) return;
	if(subset(colinfos, "colid", param.colDef.field).length==0) return;
	var colinfo = subset(colinfos, "colid", param.colDef.field)[0];
	var cellStyle = {};	  
	if(inStr(colinfo.attr, "rowSpan") >= 0) {
		$.extend(cellStyle,{"border":"0"});
		//$.extend(cellStyle,{"background-color":"white"});
		if(!isNull(param.column) && !isNull(param.column.colId) &&
		   !isNull(param.node) && isNull(param.node.rowPinned)) {
			var colId = param.column.colId;
			var rowIdx = param.node.rowIndex;
			var val = param.data[colId];
			var node = undefined; 
			if(!isNull(val)) { 
			    node = param.api.getDisplayedRowAtIndex(rowIdx-1);
				if(!isNull(node)) {
					if(node.data[colId] == val) {
					    $.extend(cellStyle,{"color":"#dedede"});
					}
				}
			}
		}
	}  
	return cellStyle; 
}
class gfnAgGridCellRender { //조회컬럼은 span을 사용한다. 
	init(param) { 
		if(isNull(param.colinfo)||param.colinfo.colid=="rn"||param.colinfo.colid=="chk") {
			//this.eGui = $(`<span class="aweCol">${nvl(param.value,"")}</span>`)[0];
			return;
		}  
		//컬럼에서 Grid를 참조하기 위해 생성시 oComponent와 rowid를 넣어줌
		this.param = param;
		this.colinfo = param.colinfo;
		this.colObj = $("<span></span>");
		if( this.colinfo.etype=="pre") {
			this.colObj =  $(`<pre></pre>`); 
		} else if(this.colinfo.etype=="txt") {
			this.colObj =  $("<span></span>");
		} else if(this.colinfo.etype=="tarea") {
			this.colObj =  $(`<pre></pre>`); 
		} else if(this.colinfo.etype=="img") {
			this.colObj =  $(`<img></img>`); 
		}  
		this.colObj.addClass("aweCol");
		this.colObj.addClass(this.colinfo.dtype);
		this.colObj.addClass(this.colinfo.etype);
		this.colObj.addClass((this.colinfo.attr||"").replace("hidden",""));
 
		this.defval = eval2(this.colinfo.defval); 
        var rowPinned = undefined;
		if(param.node.rowPinned) rowPinned = true; //rowPinned이면 컨트롤을 표시하지 않도록 함 
		if(this.colinfo.etype =="img") {
			if(this.setter(nvl(param.value,this.defval)) == "" || this.setter(nvl(param.value,this.defval))=="/images/noimg.png") {
				this.colObj.addClass("noimg");    
			    this.colObj.attr("src","/images/noimg.png");
			} else {
				this.colObj.removeClass("noimg");   
			    this.colObj.attr("src", this.setter(nvl(param.value,this.defval)));  
			} 
		} else if(this.colinfo.etype =="link") { 
			this.col = new gfnControl(this.colinfo, function(colid, evt, newval) {
				param.afnEH(param.node.id, colid, evt, newval);
			}, param.oComponent, param.node.id, param.value, rowPinned); 
			this.colObj = this.col.obj;  
		} else if(this.colinfo.etype =="sel") { //sel일때 재설정 
			this.col = new gfnControl(this.colinfo, function(colid, evt, newval) {
				param.afnEH(param.node.id, colid, evt, newval);
			}, param.oComponent, param.node.id, param.value, rowPinned, "selRenderer");  
			this.colObj = this.col.obj;  
			/*
			if(!isNull(this.colinfo)&&!isNull(this.colinfo.refcd)&&!isNull(this.colinfo.refcd)) {
				var refcd = this.colinfo.refcd;
				var disp = "cdnm"; 
				if(!isNull(this.colinfo)&&!isNull(this.colinfo.option)&&!isNull(this.colinfo.option.split(":")[3])) {
					disp = this.colinfo.option.split(":")[3]; 
				}
				if(disp=="cd") {
					this.colObj.text( this.setter( nvl(param.value,"") ) );  
				} else if(disp=="nm") {
					this.colObj.text( gfnCdNm(refcd, param.value, "nm") );  
				} else {
					if(!isNull(param.value)) {
						this.colObj.text( "["+this.setter( nvl(param.value,"") )+"] "+gfnCdNm(refcd, param.value, "nm") );  
					}
				} 
			} else {
				this.colObj.text( this.setter( param.value ) );  
			}
			*/
		} else if (this.colinfo.etype =="cbx") { //cbx일때 재설정 
			this.col = new gfnControl(this.colinfo, function(colid, evt, newval) {
				param.afnEH(param.node.id, colid, evt, newval);
			}, param.oComponent, param.node.id, param.value, rowPinned); 
			this.colObj = this.col.dispObj; 
		} else if(this.colinfo.etype =="btn") {
			this.col = new gfnControl(this.colinfo, function(colid, evt, newval) {
				param.afnEH(param.node.id, colid, evt, newval);
			}, param.oComponent, param.node.id, param.value, rowPinned); 
			this.colObj = this.col.obj;  
		} else {
			if(isNum(param.value) && toNum(param.value) < 0) {
				this.colObj.addClass("minus");	
			} else {
				this.colObj.removeClass("minus");	
			}
			this.colObj.text( this.setter( param.value ) ); 
		}
		this.eGui = this.colObj[0]; 
	}  
	getGui() {
		return this.eGui;
	}
	/*
	destroy() {
        this.eGui.removeEventListener('click', this.checkedHandler);
	}
	*/
	setter(val) { 
		if(this.colinfo.dtype=="num") {
			if(inStr(this.colinfo.attr,"dec1")>=0) return format(toNum(val),1);
			else if(inStr(this.colinfo.attr,"dec2")>=0) return format(toNum(val),2);
			else if(inStr(this.colinfo.attr,"dec3")>=0) return format(toNum(val),3);
			else if(inStr(this.colinfo.attr,"dec4")>=0) return format(toNum(val),4);
			else return isNum(val)?format(toNum(val)):val;
		}
		else if (this.colinfo.dtype=="ymd") {
			val=""+val;
			if(trim(val).length==8) return date(val,"yyyymmdd"); 
			else return date(val);
		}
		else if (this.colinfo.dtype=="text") { 
			if(this.colinfo.colid=="goods_cd") {
				val = nvl(val,"").replaceAll(" ","");
				val = trim(val.substr(0,4)+" "+val.substr(4,5)+" "+val.substr(9,2)+" "+val.substr(11,3) + " "+val.substr(14));
				if(inStr(this.colinfo.attr,"nospacing") >= 0 ){
					val = val.replace(/ /g,"");
				}
			}
			if(inStr(this.colinfo.attr,"upper")>=0) return upper(val);
			else if(inStr(this.colinfo.attr,"lower")>=0) return lower(val);
			else if(inStr(this.colinfo.attr,"biz_no")>=0) return biz_no(val);
			else if(inStr(this.colinfo.attr,"ccard")>=0) return ccard(val);
			else if(inStr(this.colinfo.attr,"nm")>=0) return (val||"").split(":")[1];
		} else if (this.colinfo.etype=="cbx") {
			if(val==true||val=="on"||val=="Y") return "Y";
			else return "N";
		}
		return val;
	}
	refresh(params) {
		var obj = $(this.eGui);
		if(this.colinfo.etype =="img") {
			if(params.value == "" || params.value=="/images/noimg.png") {
				obj.addClass("noimg");    
			    obj.attr("src","/images/noimg.png");
			} else {
				obj.removeClass("noimg");   
			    obj.attr("src", params.value);  
			} 
		} else if(this.colinfo.etype =="link") {
			obj.attr("href", params.value);
		} else if(this.colinfo.etype =="cbx") {
			this.col.setVal(params.value); 
		} else if(this.colinfo.etype =="sel") {
			this.col.setVal(params.value); 
		} else if(this.colinfo.etype =="btn") {
			this.col.setVal(params.value); 
		} else { 
	    	obj.text( this.setter(params.value) );
        }
	    return true;
	}; 
}
class gfnAgGridCellEdit { //edit컬럼은 gfnControl을 사용한다.
	init(param) {   
		this.param = param;
		this.colinfo = param.colinfo;
		//컬럼에서 Grid를 참조하기 위해 생성시 oComponent와 rowid를 넣어줌 
		var rowPinned = undefined;
		if(param.node.rowPinned) rowPinned = true; 
		this.col = new gfnControl(param.colinfo, function(colid, evt, newval) {
			param.afnEH(param.node.id, colid, evt, newval);
		}, param.oComponent, param.node.id, param.value, rowPinned ); 
		this.param = param;
		this.val = param.value;
		this.eInput = this.col.dispObj[0];   
	}
	getGui() {
		return this.eInput;
	}
	getValue() {
		return this.col.getVal();
	}
	/*
	isCancelBeforeStart() {
		return false;
	}
	*/
	afterGuiAttached() {    
		if(!isNull(this.colinfo)&&!isNull(this.colinfo.etype)) {
			if(this.colinfo.etype=="sel") { 
				//this.col.obj.focus();
				if($.type(gParam)!="object") gParam={};
				gParam.selectEditor = this;
				var sel = $(gParam.selectEditor.eInput);
				var cell = sel.parents(".ag-cell");
				var opt_pos = {my:"left top",at:"left bottom"};
				if (cell.offset().top+300 > window.outerHeight) {
					//console.log(cell.offset().top);
					//console.log(window.outerHeight);
					opt_pos = {my:"left bottom",at:"left top"};
				}
				gParam.sel = $(gParam.selectEditor.eInput).selectmenu({
					width: null,
					position: opt_pos, 
					/* appendTo: this, */
					focus: function(){},
					close: function(){ 
						if(!isNull(gParam.selectEditor)&&!isNull(gParam.selectEditor.param)&&!isNull(gParam.selectEditor.param.stopEditing)) {
							gParam.selectEditor.param.stopEditing();
						}
					},
					open: function(){},
					select: function(){},
				}).selectmenu("open");  
				$(".ui-selectmenu-open > ul").focus();
				$(".ui-selectmenu-open > ul").on("keyup",function(e){
					if(!isNull(e.keyCode) && e.keyCode==27 && !isNull(gParam.sel)) gParam.sel.selectmenu("close");
				});
			} else if(this.colinfo.etype=="cbx") { 
				//do nothing
			} else {
				this.col.focus(); 				
			}
		} else {
			this.col.focus(); 
		}

		/*
		$(this.eInput).includeObj(".aweCol")[0].focus();
		if($.type($(this.eInput).includeObj(".aweCol")[0].select)=='function') {
			$(this.eInput).includeObj(".aweCol")[0].select(); 
		} 
		*/ 
	} 
	setValue(val) { 
		this.col.setVal(val);
		return true;
	} 
	/*
	focusIn(params) {
		console.log("focusIn");
		console.dir(params);
	} 
	focusOut(params) {
		console.log("focusOut");
		console.dir(params);
	} 
	*/
	destroy() { 
		if(inStr(this.param.colinfo.attr,"pop") >= 0) {
			setTimeout( function() { $(this.eInput).remove(); }, 0); 
		} else {
			if(this.val!=this.col.getVal()) {
				this.param.afnEH(this.param.node.id, this.param.colinfo.colid, "change", this.col.getVal()); 
			}
			$(this.eInput).remove(); 
		}
	}
}
class gfnAgDetailCellRenderer {
	init(params) {
		this.eGui = document.createElement('div');
		this.params = params; 
		if(!isNull(gObj[params.pgmid+"-"+params.componentId])) {
			this.eGui.innerHTML = gObj[params.pgmid+"-"+params.componentId](params);
		} else {
			this.eGui.innerHTML = '<h1 style="padding: 20px;">My Custom Detail</h1>';
		} 
	}
  
	getGui() {
	  return this.eGui;
	}
  
	refresh(params) {
	  return false;
	}
}
//AgGrid처리를 위한 함수 및 클래스 Start****************************************************/



/** Global Function에 버튼셋 초기화 **********************************************************************************************************************/
function gfnButtonSet(btnContainer, btnInfo, afnEH) {
    var me = this;
    me.container = $(btnContainer);
    me.opt = {
		btnExtras: [],
		containerClass: "gbuttonSet"
	};
    me.btns = {};
    me.extraPanel = {};

    // [{funcid, func_nm, func_icon, disp, remark},..] : 버튼정보
    me.btnInfoCovert = function(aBtnInfo) { 
        var FuncOPt = {};
        if(aBtnInfo != null && aBtnInfo != undefined) {
            var FuncOpt = {};
            var FuncBtnNames = [];
            var FuncExtra = [];   
            for(var i =0; i < aBtnInfo.length; i++ ) { //pageFunc정보를 gButtonset에 맞게 치환한다.
                var bInfo = aBtnInfo[i]; 
                var bName = (bInfo.funcid.charAt(0).toUpperCase()) + (bInfo.funcid.slice(1));
                var bFunc = "fn"+ bName;
                var bDisp  = bInfo.disp==undefined? true:bInfo.disp;
                if(isNull(bInfo.func_icon) || inStr(bInfo.func_icon,"extra") < 0) {  //icon에 extra가 없으면 기본버튼 
                    if(inStr(FuncBtnNames,bInfo.funcid) < 0) FuncBtnNames.push(bInfo.funcid);
                    FuncOpt["btn"+bInfo.funcid] = {
                        icon:bInfo.func_icon,
                        text:bInfo.func_nm,
                        funcid:bInfo.funcid,
                        func:bFunc,
                        disp:bDisp
                    }; 
                } else { //extra가 있으면 추가패널 
                    var btnEx = {
                        icon:bInfo.func_icon,
                        text:bInfo.func_nm,
                        funcid:bInfo.funcid,
                        func:bFunc,
                        disp:bDisp
                    };
                    FuncExtra.push(btnEx);
                } 	
            }
            FuncOpt.btnNames = FuncBtnNames;
            FuncOpt.btnExtras = FuncExtra; 
        }
        return FuncOpt;
    } 

    me.init = function() {
        // 버튼정보 변환 
        var btnOpt = me.btnInfoCovert(btnInfo); 
		$.extend(me.opt,btnOpt); 
		me.container.addClass(me.opt.containerClass); 
        //기본버튼(!=extra) 완전히 Clear하고 그려줌.
    	me.container.children(".gButton").remove();
		if(me.opt.btnNames != undefined){
			for(var i = 0; i < me.opt.btnNames.length; i++){
				me.btns[me.opt.btnNames[i]] = me.setButton(me.opt[`btn${me.opt.btnNames[i]}`]); // 버튼 초기화
				me.setDisp(me.opt.btnNames[i],me.opt["btn"+me.opt.btnNames[i]]["disp"]); 
			}
		}
        
        // Extra 추가 기능 버튼과 패널 (Functions▼)
        if(me.opt.btnExtras.length > 0) {
            me.btns["Extras"] = me.setButton({icon:"fas fa-bars",text:"",func:"fnExtra",funcid:"extra",disp:true});
            
            var oPanel = $("<ul></ul>");
    	    oPanel.addClass("gButtonPanel"); 

            for(var i = 0; i < me.opt.btnExtras.length; i++) {
                var extraBtnItem;
                extraBtnItem = $(`<li>${me.opt.btnExtras[i].text}</li>`);
                extraBtnItem.addClass("gButtonsetpanelBtn");
                extraBtnItem.attr("funcid",me.opt.btnExtras[i].funcid);
                extraBtnItem.attr("func",me.opt.btnExtras[i].func);

                // Extra 버튼 리스트 클릭이벤트
                extraBtnItem.on("click", function(e) {
                    var btnMe = $(this).exactObj("li.gButtonsetpanelBtn");
                    console.log(`Extra 버튼 클릭 이벤트 발생`);
                    me.fnEH(btnMe);
                    oPanel.hide();
                });
                oPanel.append(extraBtnItem);
            }
            // Functions▼ 버튼에 갖다붙이기
            me.container.append(oPanel);
            me.extraPanel = oPanel;
        } else {
			if(me.btns["extra"]) me.setDisp("Extra",false); 
		}

        // 다른 곳 클릭시 none, gButtonsetpanelBtn이 아니면 닫아.
        // $(document).click(function(e) {
        //     console.log($(e.target));
        //     // console.log($(e.target).parent().hasClass("gButtonsetpanel"));
        //     // console.log($(e.target).attr("func"));
        //     if(!$(e.target).parent().hasClass("gButtonsetpanel") && $(e.target).attr("func") != "fnExtra"){
        //         // oPanel.hide();
        //         console.log("사라져");
        //     }
        // });


		//자기 자신을 Return
    	return me;
    }

    // 버튼 그리기
    me.setButton = function(btnInfo) {
        var oBtn;
		var sBtn = btnInfo.text;
    	if(btnInfo.icon != undefined && btnInfo.icon != "") sBtn = "<i class='"+btnInfo.icon+"'></i> " + sBtn;
        oBtn = $(`<button>${sBtn}</button>`); 
		oBtn.addClass("gButton");
		oBtn.attr("funcid",btnInfo.funcid);      //ex) search
		oBtn.attr("func", btnInfo.func);      //ex) fnSearch  
        oBtn.click(function(e){
			var btnMe = $(this).exactObj("button.gButton");
			if (btnMe.attr("func") == "fnExtra") {
				me.showPanel();
			} else if (btnMe.attr("func") != undefined && btnMe.attr("func")!="") {  
                // 각 함수들 실행
				me.fnEH( btnMe );
			} 
		});
        me.container.append(oBtn);
		return oBtn;
    }

    // 클릭이벤트
    me.fnEH = function(jBtn) {
        afnEH(me, "click", jBtn.attr("funcid"), jBtn.attr("func"));
    }
    
    // 패널 dispaly 여부 (처음엔 none 클릭하면 나타나게, 다른 곳 클릭하면 none되게)
    me.showPanel = function() {
        if(me.extraPanel.css("display") == "none") {
            me.extraPanel.css("display", "block");
        } else {
            me.extraPanel.css("display", "none");
        }
    }

	me.setDisp = function(btnName,disp) {  //옵션값에 따른 버튼표시
    	//disp: true, false, disabled, seperator
		if(isNull(me.btns[btnName])) return;
    	me.opt["btn"+btnName]["disp"] = disp; //옵션값 변경 
    	if(disp==true) {
    		me.btns[btnName].css("display","inline-block");
    		me.btns[btnName].removeAttr("disabled");
    	} else if(disp==false||disp==undefined) {
    		me.btns[btnName].css("display","none"); 
    	} else if(disp=="disabled") {
    		me.btns[btnName].css("display","inline-block");
    		me.btns[btnName].attr("disabled","disabled");
    	} 
    }


	me.init();

    return me; //선언시 버튼셋 오브젝트 초기화 실행
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function gfnExcelDown(framepage, componentId, pgm_nm, condition, userinfo, headers, data){
	if(isNull(framepage) || isNull(componentId)) {
		gfnStatus("잘못된 엑셀 요청입니다.");
		return;
	}
    if(isNull(pgm_nm)) {
		pgm_nm = framepage.dataDef._pgm.pgm_nm;	
	}
	if(isNull(condition)) {
		condition = [];
	}
	var cond = framepage.pageObj["pageCond"];
	if(!isNull(cond)){
		var cond_content = cond.componentDef.content; //조회조건 contents
		var cnt=0;
		for(let i=0;i<cond_content.length;i++){
			condition.push({[cond_content[i].colnm] : cond.getVal(cond_content[i].colid)})
		}
	}
	if(isNull(userinfo)) {
        userinfo = gUserinfo.usernm;
	}
	if(isNull(headers)) {
		var content = framepage.pageObj[componentId].componentDef.content;
		headers = [];
		for(let i=0;i<content.length;i++){
            var head = ""+content[i].colnm;
			if(!isNull(head) && !isNull(content[i].colgrp)) {
				head = head.replace(trim(content[i].colgrp),"").replace("_","");
				head = content[i].colgrp + "_" + head;
			}
            headers.push({[content[i].colid] : head}); 
        }
	}
	if(isNull(data)) {
        data = framepage.pageObj[componentId].exportFilteredData(); 		
	}

	gfnGetData("supr",function(rtn){
		for(var i=0;i<data.length;i++){
			for(var j=0;j<rtn.length;j++){
				if(rtn[j].cd == data[i].suprcd){
					data[i].suprcd = rtn[j].cdnm;
				}
			}
		}
	}); 

	var content = framepage.pageObj[componentId].colinfo;
	for(let i=0;i<content.length;i++){
        if(content[i].dtype == "num"){
			var colid = content[i].colid;
			for(var j=0;j<data.length;j++){
				data[j][colid] = toNum(data[j][colid]);
			}
		}
    }
	var frm = $("<form action='https://fo.lfnetworks.co.kr/excel' target='_blank' "+" method='POST' style='display:none'></form>");
	var args = {pgm:pgm_nm, condition: condition, headerData:headers, listData:data, userinfo:userinfo};
	var sArgs = JSON.stringify(args);
	var oINVAR = $("<input type='text' name='INVAR'>");
	oINVAR.val(sArgs);
	frm.append(oINVAR);
	frm.appendTo(framepage.page);
	frm.submit();
}
function gfnPdf(framepage, divId) {
	var me = framepage;
	var file_nm = framepage.dataDef._pgm.pgm_nm;
	var usernm = gUserinfo.usernm;

	// 새로운 태그 생성, 화면에 맞는 고정된 이미지캔버스 크기 생성 위해
	var form = framepage.page.find("#"+divId);
	var pdf = $("<div id='pdf' style='width: 190mm'></div>");
	var pdf_header = $(`<div style='display: flex; justify-content:space-between'></div>`);
	pdf_header.append(`<p>${file_nm}</p>`);
	pdf_header.append(`<p>${date("today")}  /  ${usernm}</p>`);
	pdf.append(pdf_header);
	pdf.append(`<div style='border: 1px solid black; opacity:0.5; margin-bottom:50px'></div>`);
	var pdf_form = form.clone().appendTo(pdf);
	pdf_form.attr("id","pdf_form");
	pdf_form.width("190mm");
	form.append(pdf);
	$("#pdf_form .componentFunc").remove();

	html2canvas($('#pdf')[0]).then(function(canvas) {
		var imgData = canvas.toDataURL('image/png'); //canvas를 base64로 encode한 것.

		var pageWidth = 210; //가로길이 a4 기준
		var pageHeight = pageWidth * 1.414; //출력페이지 세로길이
		var imgWidth = pageWidth - 20; //190
		var imgHeight = canvas.height * imgWidth /canvas.width;
		let heightLeft = imgHeight //페이징 처리를 위해 남은 페이지 높이 세팅.
		var margin = 10;

		var doc = new jsPDF({
			'orientation': 'p',
			'unit': 'mm',
			'format': 'a4',//210 x 297
		});
		var position =0;
		//position = 90;

		doc.addImage(imgData, 'PNG', margin, margin, imgWidth, imgHeight);
		doc.line(margin,277,200,277); //line

		//Paging 처리(한페이지를 넘을때)
		heightLeft -= pageHeight
		while (heightLeft >= 20) {
			position = heightLeft - imgHeight
			doc.addPage();
			doc.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight);
			heightLeft -= pageHeight;
		}
		doc.save(`${file_nm}정보(${date("today")}).pdf`);
	},{
		scale: 2
	});

	//생성된 태그 제거
	$('#pdf').remove();
}


var grdHeight = 30;
var gFileDocNo = "common"; //CDN으로 fileupload하기 위해 사용하는 문서번호(스타일번호) 

/** gfnComcd : 검색을 빠르게 하기위해 공통코드를 Client로 내려줌 ************************************/ 
function gfnComcd() {
	gfnTx("aweportal.framset","retrieveComcd",{},function(OUTVAR){
		if(OUTVAR.rtnCd=="OK") {
			gds["comcd"] = OUTVAR.comcd;
		} else {
			gds["comcd"] = [];  
		} 
	}); 	
}

var gPanelseq = 0;
function gfnPanel(css,bNoClose) {
	var pageid = "panel"+ (gPanelseq++);
    var body = $("<div id='"+pageid+"' class='panel'></div>");
    if(css!=undefined) body.css(css);
    if(bNoClose!=true) {
        var cls = $("<i panelid='"+pageid+"' class='fa fa-times closetab'></i>");
        cls.on("click",function(e){
        	$("#"+$(e.target).attr("panelid")).remove();
        });
        body.append(cls);    	
    }
	return body;
} 

/** JQUERYUI EXTENTION */
$.widget( "custom.catcomplete", $.ui.autocomplete, {
	_create: function() {
	  this._super();
	  this.widget().menu( "option", "items", "> :not(.ui-autocomplete-category)" );
	},
	_renderMenu: function( ul, items ) {
	  var that = this,
		currentCategory = "";
	  $.each( items, function( index, item ) {
		var li;
		if ( item.category != currentCategory ) {
		  ul.append( "<li class='ui-autocomplete-category'>" + item.category + "</li>" );
		  currentCategory = item.category;
		}
		li = that._renderItemData( ul, item );
		if ( item.category ) {
		  li.attr( "aria-label", item.category + " : " + item.label );
		}
	  });
	}
});

/* gfnColDef : 데이터로 부터 컬럼정의 추출 */
function gfnColDef(rawData) {
	if (isNull(rawData)) return false; 
	//헤더분석   
	colinfo = [];
	if($.type(rawData)=="string") { //스트링인 경우 1Row값을 헤더로 인식
		var CR = "\n"; 
		var TAB = "\t";
		var rawRows = rawData.split(CR); 
		var rawRow  = rawRows[0];
		var cols = rawRow.split(TAB); 
		for(var i=0; i < cols.length; i++) { 
			var colid = cols[i].replace("[","").replace("]",""); 
			var colDef = gfnDict(colid);
			colinfo.push({ 
				sort_seq: (i+1),
				section: "",
				section_icon: "",
				colgrp: "",
				colid: colid,
				colnm: colDef.colnm,
				dtype: colDef.dtype,
				etype: colDef.etype,
				attr: colDef.attr,
				defval: "",
				w: 8,
				h: "",
				refcd: "",
				option: "",
				len: colDef.len,
				valid: "",
				colFormula: "",
				grpFormula: "",
				totFormula: "",
				remark: "" 
			}); 
		} 
	} else if($.type(rawData)=="array") { //rawData = array
		if ($.type(rawData[0])=="object") { //key:val로 헤더구성 
			var idx = 1; 
			$.each(rawData[0],function(key,val){  
				var colid = key.replace("[","").replace("]",""); 
				var colDef = gfnDict(colid);
				colinfo.push({
					sort_seq: idx,
					section: "",
					section_icon: "",
					colgrp: "",
					colid: colid,
					colnm: colDef.colnm,
					dtype: colDef.dtype,
					etype: colDef.etype,
					attr: colDef.attr,
					defval: "",
					w: 8,
					h: "",
					refcd: "",
					option: "",
					len: colDef.len,
					valid: "",
					colFormula: "",
					grpFormula: "",
					totFormula: "",
					remark: "" 
				}); 
				idx++;
			}); 
		}
	} 
	
	//데이터넣기
	if($.type(rawData)=="string") { 
		var CR = "\n"; 
		var TAB = "\t";
		var rawRows = rawData.split(CR);
		rawRows.pop(); //끝 공백열 하나는 날려줌 
		rows = [];
		for(var j=1; j < rawRows.length; j++) {
			var row  = {crud:""};
			var cols = rawRows[j].split(TAB);
			for(var i=0; i < colinfo.length; i++) {
				var colval;
				if( i >= cols.length ) colval = null;
				else colval = ((cols[i]=="NULL")?"":cols[i]);  
				row[ colinfo[i].colid ] = colval; 
			}
			rows.push(row); 
		}
	} else if($.type(rawData)=="array" && $.type(rawData[0])=="object") {
		var rows = []; 
		for(var j=0; j < rawData.length; j++) {
			var row  = {crud:""};
			var cols = rawData[j]; 
			for(var i=0; i < colinfo.length; i++) {
				var colval;
				if( cols[ colinfo[i].colid ] == undefined ) colval = null;
				else colval = ((cols[ colinfo[i].colid ]=="NULL")?"":cols[ colinfo[i].colid ]) ;
				row[ colinfo[i].colid ] = colval;  
			} 
			rows.push(row); 
		}
	}
	
    //실제 데이터를 사용하여 colinfo업데이트
	for(var i=0; i < colinfo.length; i++) { 
		for(var j=0; j < rows.length; j++) { 
			var colval = rows[j][ colinfo[i].colid ]; 
			var ilen = (colval+"").length;
			if(ilen > colinfo[i].len ) colinfo[i].len = ilen; 
		} 
	} 
	return {colinfo:colinfo, rows:rows}; 
}

/* 컬럼ID을 넣어서 컬럼명과 dtype찾기 */
function gfnDict(colid) {
	var rtn = {colnm: "", dtype: "", etype: "raw", attr: "", w: 8, refcd: "", option: "", len: "" };
	var dict = subset(gds.comcd,"grpcd","DICT");
	var bFind = false;
	if(subset(dict,"cd",colid).length == 1) {
		var data = subset(dict,"cd",colid)[0];
		rtn.colnm = nvl(data.nm,colid);
		if(data.val_1=="VARCHAR2 (8)") {
			rtn.dtype = "ymd";
			rtn.len = 8;
		} else if(inStr(data.val_1,"VARCHAR2") >= 0) {
			rtn.dtype = "text";
			rtn.len = (""+data.val_1).replace("VARCHAR2","").replace("(","").replace(")","").trim();
		} else if(inStr(data.val_1,"NUMBER") >= 0) {
			rtn.dtype = "num";
			if(inStr(data.val_1,",1)")>=0) rtn.attr = "dec1";
			else if(inStr(data.val_1,",2)")>=0) rtn.attr = "dec2";
			else if(inStr(data.val_1,",3)")>=0) rtn.attr = "dec3";
			else if(inStr(data.val_1,",4)")>=0) rtn.attr = "dec4"; 
		} 
		if(rtn.colnm=="") rtn.colnm = colid;
		if(rtn.dtype=="") rtn.dtype=="text";
	} else if(inStr(colid,"_")>=0) {
		var words = colid.split("_");
		for(var i=0; i < words.length; i++) {
			var el = gfnDict(words[i]);
			rtn.colnm += el.colnm; 
			if(!isNull(el.dtype) && el.dtype != rtn.dtype) rtn.dtype = el.dtype; 
			if(!isNull(el.len) && el.len != rtn.len) rtn.len = el.len;
		} 
	} else {
		rtn.colnm = colid;
		rtn.dtype = "text";
		rtn.len   = 10;
	}
	return rtn;
}

var termTemplate = "<span class='ui-autocomplete-term'>%s</span>"; 
function gfnAutocompleteOpen(str, term) {
	return str.replace( term, termTemplate.replace('%s', term) ); 		
} 

/* 어떤 클래스의 어떤 요소속성을 변경한다. */
function gfnChangeCss(theClass,element,value) { 
    var cssRules;

	for (var S = 0; S < document.styleSheets.length; S++){
 	    try{
			document.styleSheets[S].insertRule(theClass+' { '+element+': '+value+'; }',document.styleSheets[S][cssRules].length);
 	    } catch(err){
			try{
			    document.styleSheets[S].addRule(theClass,element+': '+value+';');
			}catch(err){
			 	try{
				    if (document.styleSheets[S]['rules']) {
					    cssRules = 'rules';
					} else if (document.styleSheets[S]['cssRules']) {
					    cssRules = 'cssRules';
					} else {
					    //no rules found... browser unknown
					}
 				    for (var R = 0; R < document.styleSheets[S][cssRules].length; R++) {
					    if (document.styleSheets[S][cssRules][R].selectorText == theClass) {
						    if(document.styleSheets[S][cssRules][R].style[element]){
							    document.styleSheets[S][cssRules][R].style[element] = value;
								break;
						    }
						}
					}
				} catch (err){}
			}
 	    }
    }
}

/* 데이터 형식에 표시값 치환 */
function gfnDispVal(val, colinfo) {  
	var me = colinfo||{}
	if(me.dtype=="num") {
		if(inStr(me.attr,"dec1")>=0) return format(toNum(val),1);
		else if(inStr(me.attr,"dec2")>=0) return format(toNum(val),2);
		else if(inStr(me.attr,"dec3")>=0) return format(toNum(val),3);
		else if(inStr(me.attr,"dec4")>=0) return format(toNum(val),4);
		else return format(toNum(val));
	}
	else if (me.dtype=="ymd") {
		val=""+val;
		if(trim(val).length==8) return date(val,"yyyymmdd"); 
		else if(trim(val).length==4) return date((date("today").substr(0,4)+""+val),"yyyymmdd"); 
		else return date(val);
	}
	else if (me.dtype=="text") {
		if($.type(val)=="string") {
			if(inStr(me.attr, "upper")>=0) val = upper(val);
			else if(inStr(me.attr, "lower")>=0) val = lower(val);
			else if(inStr(me.attr,"biz_no")>=0) val = biz_no(val); 
			else if(inStr(me.attr,"ccard")>=0) val = ccard(val); 
			else if(inStr(me.attr,"nm")>=0) {
				//me.cdnmVal = val;
				val = (val||"").split(":")[1];
			}
		}
		return val;
	} else if (me.etype=="cbx") {
		if(val==true||val=="on"||val=="Y") return "Y";
		else return "N";
	}
	return val;
}

/* 테이블 그리기 */
function gfnTable(framepage,gridId,arrDispCols,arrColHeader=[],arrColAttr=[],totalTopBottom){
	var meta = framepage.dataDef._pgm_data[gridId].content;
	var data = framepage.pageObj[gridId].exportData();
    if(isNull(arrDispCols)) { //출력대상컬럼 점검
		arrDispCols=[];
		meta.forEach(col=>{
			if(col.etype!="none"&&inStr((col.attr||""),"hidden")<0) arrDispCols.push(col.colid);
		});
	}
	arrDispCols.forEach((col,idx)=>{  //출력용헤더텍스트
		if(isNull(arrColHeader[idx])) {
			var m = meta.find(el=>el.colid==col)||{};
			arrColHeader[idx] = trim(nvl(m.section,'')+" "+nvl(m.colgrp,'')+" "+m.colnm);
		};
	}); 

	arrDispCols.forEach((col,idx)=>{  //출력용속성(Class)
		var m = meta.find(el=>el.colid==col)||{};
		arrColAttr[idx] =  trim( nvl(arrColAttr[idx],"") + " " + m.dtype+" "+m.attr );
	});

	//테이블Obj
    var div = $("<div></div>");	
	/* 발행용CSS는 무효처리되어 스타일을 직접 지정함
	var css = $(`<style>
		.aweTable {
			border-collapse: collapse; 
		}
		.aweTable th, .aweTable td {
			padding: 0.5em;
			line-height: 1.4;
			width: auto;
		} 
		.aweRow {
			min-height: 24px !important;
    		max-height: 24px !important;
		}
		.aweCol.center, .aweCol.ymd {
			text-align: center !important;
		}
		.aweCol.right, .aweCol.num {
			text-align: right !important;
		}
		.aweCol.left {
			text-align: left !important;
		}
	`);
	//tbl.append(css);
	*/
	var tbl = $("<table class='aweTable' style='width:100%'></table>");
	div.append(tbl);
	//헤더만들기
	var thead = $("<thead></thaed>");
	var tr = $("<tr class='aweRow' style='min-height: 24px;'></tr>");
	var css = function(td, attr) {
		if(inStr(attr,"center")>=0 || inStr(attr,"ymd")>=0) td.css("text-align","center");
		if(inStr(attr,"right")>=0 || inStr(attr,"num")>=0) td.css("text-align","right");
		if(inStr(attr,"left")>=0) td.css("text-align","left");
	}
    arrColHeader.forEach(col=>{
		tr.append("<th style='border-color:#aaa;border-width:1px;border-style:solid;background-color:#ecf0f1;text-align:center;font-weight:bold;padding:0.5em;line-height:1.4;width:auto'>"+col+"</th>");
	})
	thead.append(tr);
    //바디만들기
	var tbody = $("<tbody></tbody>");
	data.forEach(row=>{
		var tr = $("<tr class='aweRow' style='min-height: 24px;'></tr>");
		arrDispCols.forEach((col,idx)=>{
			var td = $("<td class='aweCol' style='border-color:#aaa;border-width:1px;border-style:solid;'></td>");
			td.addClass( trim(arrColAttr[idx].replace(/null/gi,'')) );
            css( td,trim(arrColAttr[idx].replace(/null/gi,'')) );
			var m = meta.find(el=>el.colid==col)||{};
			td.html( nvl(gfnDispVal(row[col],m),"&nbsp;") );
			tr.append(td); //rowspan따위 지금은 생략할꺼야!
		});
		tbody.append(tr);
	});
	//소계구하기
	tr = $("<tr class='aweSumRow' style='min-height: 24px;'></tr>"); 
	arrDispCols.forEach((col,idx)=>{
		var col = meta.find(el=>el.colid==col)||{};
		var colTotal;
		if(col.dtype == "num") {
			colTotal = 0;
			for(var j =0 ; j < data.length; j++) {
				if(!isNull(data[j]) && !isNull(data[j].subsumrow)) continue;
				var row = data[j];
				colTotal += toNum(row[ col.colid ]);
			} 
		}
		if(!isNull(col.totFormula)) { 
			colTotal = arrFormula(data, col.totFormula);
		}  
		var td = $("<td class='aweCol' style='border-color:#aaa;border-width:1px;border-style:solid;background-color:#fbeeb8;'>"+ nvl(gfnDispVal(colTotal,col),"&nbsp;") +"</td>");
		td.addClass( trim(arrColAttr[idx].replace(/null/gi,'').replace(/keycol/gi,'')) );
		css( td,trim(arrColAttr[idx].replace(/null/gi,'').replace(/keycol/gi,'')) );
		tr.append(td); 
	});
	if(totalTopBottom=="top") {
		tbl.append(thead).append(tr).append(tbody); 
	} else if(totalTopBottom=="bottom"){
		tbl.append(thead).append(tbody).append(tr); 
	} else {
		tbl.append(thead).append(tbody);
	}
	return div.html();
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
// 나상하 제작
function gfnAgGridColumnDef2(oComponent, colinfos, afnEH) {

	// console.log("gfnAgGridColumnDef2");
	// console.log(oComponent);
	// console.log(colinfos);
	// console.log(afnEH);

	var colDefs = []; 
	//맨 앞에 rownum을 넣어줌
	if(!isNull(oComponent.component_option) && inStr(oComponent.component_option.gridOpt,"rn")>=0) {
		/* RowIndex와 RowNode를 표시 */
		var RowNumbering = {  
			colId: "rn",
			field: "rn",
			width: 50,  
			resizable: false,
			headerName: "No", 
			suppressMenu: true, 
			pinned : "left", 
			cellClass: "text-center",
			valueGetter: function(params) { 
				//console.log(params);
				return {rowIndex:(params.node.rowIndex+1),nodeId:params.node.id}; 
			},
			cellRenderer: function(params) { 
				var bg = "rgba(210, 210, 210, 0.3)";
				if(params.data!=undefined&&params.data.crud=="D") bg = "rgba(10, 10, 10, 0.5)";
				else if(params.data!=undefined&&params.data.crud=="C") bg = "hsla(65 100% 90% / 0.5)";
				else if(params.data!=undefined&&params.data.crud=="U") bg = "hsla(95 100% 90% / 0.5)";
				//else if(params.node.isSelected()) bg = "rgba(0, 145, 234, 0.5)";
				params.eGridCell.style.backgroundColor=bg; 
				if(params.data!=undefined&&!isNull(params.data.rn)) return params.data.rn;
				return (params.value!=undefined)?params.value.rowIndex:null; //+"-"+params.value.nodeId;
			} 
		};
		colDefs.unshift(RowNumbering); 
	}
	//그 앞에 체크박스를 넣어줌
	if(!isNull(oComponent.component_option) && inStr(oComponent.component_option.gridOpt,"chk")>=0) {
		var cbx = { 
			colId: "chk",
			field: "chk",
			headerName: "",
			width: 30,
			resizable: false,
			headerCheckboxSelection: true, 
			editable: false,			
			cellClass: "text-center",
			checkboxSelection: true, 
			pinned: 'left', 
			lockPinned: true,
			suppressMenu: true
			/* suppressClickEdit: true */
		} 
		colDefs.unshift(cbx);
	}
	// 나머지 열 생성
	for(var i=0; i < colinfos.length; i++) {
		var colinfo = colinfos[i];
		var colDef = {};
		colDef.headerName = colinfo.colnm;
		colDef.field      = colinfo.colid;

		var data = { 
			colId: colinfo.colid,
			field: colinfo.colid,
			headerName: colinfo.colnm,
			// width: 100,
			aggFunc: null,
			editable: true,			
			cellClass: "text-center",
			// suppressSizeToFit: false
		} 
		colDefs.unshift(data);
	}   
	// console.log("열 정보");
	// console.log(colDefs);
	return colDefs; 
}
function gfnControl2(colinfo, afnEH, oComponent, rowid, val, rowPinned, agHack) {
	var me = this;
	me.oComponent = oComponent;
	me.colinfo = $.extend({},colinfo); //colinfo가 null일때 exception처리때문에 {}로 치환 
	me.afnEH = afnEH;
	me.obj = $("<span class='aweCol'></span>"); 
	me.agHack = agHack; 
	/* 합계에서는 etype:raw, attr:auto,ymd,pop을 제거한다.*/
	if(rowPinned==true) { 
		me.colinfo.etype = "raw";
		me.colinfo.defval = "";
		if(!isNull(me.colinfo.attr)) {
			me.colinfo.attr = me.colinfo.attr.replace("ymd","").replace("auto","").replace("pop","");
		}  
	} 	
	me.init = function() {
		
		me.colid = nvl(me.colinfo.colid,"");
		me.dtype = nvl(me.colinfo.dtype,"text");
		me.etype = nvl(me.colinfo.etype,"txt");
		me.attr  = nvl(me.colinfo.attr,"");

		/* len:w:h 로 관리하던 것을  -> len 과 w, h를 분리하기로 함 */
		me.len   = nvl(me.colinfo.len,0); 
		if(inStr(me.len,":")>=0) {
			me.w = trim(me.len.split(":")[0]);
			me.h = trim(me.len.split(":")[1]);
			me.len = me.len.split(":")[0];
		} else {
			me.w = me.len; 
			me.h = "";
		}
		me.w = nvl(nvl(me.colinfo.w, me.w),8); //길이 기본값은 8
		me.h = nvl(me.colinfo.h, me.h);

		/* 기본값: dv가 function이면 실행, dv가 String이면 그대로 사용 */
		var dv = eval2(nvl(me.colinfo.defval,null));
	    me.defval = $.type(dv)=='function'?dv():dv;  
		/* sel, auto, pop일때 사용하는 옵션 */
	    me.refcd = eval2(me.colinfo.refcd);  //참조공통코드 또는 참조데이터array/function 
		me.option = nvl(me.colinfo.option,"all:cd:nm:cdnm"); //참조옵션: gfnSetOpts참고할 것
		if(!isNull(me.option)) { 
			try {
				var opt = JSON.parse(me.option);
				if(typeof(opt)=="object") me.oOption = opt;
			} catch {
				//do_nothing
			}
		}
		me.setPairVal = function(colid, val) { 
			//console.log(arguments);
			//if(val==undefined) return console.log("val:"+val);
			if(colid==me.colid) return; // console.log("colid:"+colid);
			if(oComponent==undefined) return; // console.log("oComponent");
			if(oComponent.componentDef==undefined) { /* 직접추가한 컬럼일 경우 직접val세팅 */
				if( oComponent instanceof jQuery ) oComponent.val(val);
				else if (oComponent instanceof gfnControl ) oComponent.setVal(val);  
			} else if(oComponent.componentDef.component_pgmid=="aweForm") { /* aweForm일때 */
				oComponent.setVal(colid, val);  
			} else if(oComponent.componentDef.component_pgmid=="agGrid") { /* agGrid일때 */
				//console.log("agGrid");
				oComponent.setVal(rowid, colid, val);  	 
			} 
		}
		/* validation, 수식, 소계, 총계, 비고 */
	    me.valid  = eval2(me.colinfo.valid);  
	    me.valFormula = eval2(me.colinfo.valFormula);		
	    me.grpFormula = eval2(me.colinfo.grpFormula);  
	    me.totFormula = eval2(me.colinfo.totFormula);  
		me.remark = nvl(me.colinfo.remark,"");

		/* etype에 따른 컨트롤 오브젝트 생성 */
		var obj = $(`<span></span>`); 
		if( me.etype=="pre") {
			obj =  $(`<${me.etype}></${me.etype}>`); 
		} else if(me.etype=="txt") {
			obj =  $(`<input type="text" placeholder="${me.remark}"/>`); 
		} else if(me.etype=="pwd") {
			obj =  $(`<input type="password" placeholder="${me.remark}"/>`); 
		} else if(me.etype=="sel") {
			if(me.agHack=="selRenderer") {
				obj = $(`<span></span>`); 
			} else {
				obj =  $(`<select></select>`);
			} 
		} else if(me.etype=="cbx") {
			obj =  $(`<input type="checkbox"/>`);
		} else if(me.etype=="tarea") {
			obj =  $(`<textarea></textarea>`); 
		} else if(me.etype=="img") {
			obj =  $(`<img></img>`); 
		} else if(me.etype=="link") {
			obj =  $(`<a target="_blank"></a>`); 
		} else if(me.etype=="btn") { 
			obj =  $(`<button></button>`); 
			// obj.addClass("ui-button");
		} else if(me.etype=="none") {
			obj.addClass("hidden");
		}
		if(!isNull(me.oOption)) {
			Object.keys(me.oOption).forEach(key=>{
				obj.attr(key,me.oOption[key]);
			})
		}
		obj.attr("colid",me.colid);
		obj.addClass("aweCol"); 
		/* etype, attr에 따른 기능Bind : sel pk disabled readonly hidden auto pop ymd dec1~4 upper lower*/
		obj.addClass(me.dtype); /* num ymd text */
		if(!isNull(me.attr)) obj.addClass(me.attr); /*pk, keycol, center, readonly, hidden */
		if(inStr(me.attr,"inputmodenone") >= 0) obj.attr("inputmode","none");
		if(inStr(me.attr,"disabled") >= 0) me.setDisable(true);
		if(oComponent!=undefined&&rowid!=undefined&&oComponent.getVal!=undefined) {
			setTimeout(function(){ 
				var crud = nvl(oComponent.getVal(rowid,"crud"),"C");
				if(crud != "C" && inStr(me.attr,"pk") >= 0) me.setDisable(true);
			}); 
		}
		if(inStr(me.attr,"readonly") >= 0) me.setReadonly(true);
		if(inStr(me.attr,"hidden") >= 0) me.setHidden(true);
		if(inStr(me.attr,"scan") >= 0) obj.attr("inputmode","none");
		/* me.obj에 할당 */
		me.obj = obj;
		me.dispObj = obj; 
		/* cbx는 span으로 싸준다. */
		if(me.etype=="cbx" && !isNull(me.attr)) {
			me.dispObj = $("<span></span>");
			me.dispObj.addClass("aweCol");
			me.dispObj.addClass(me.dtype);  
			me.dispObj.addClass(me.attr);
			me.dispObj.append(me.obj);
		}
		/* dblclick event 바인드 */ 
		if(me.rowid == undefined) { 
			me.obj.on("dblclick",function(e){
				afnEH(me.colid, "dblclick", me.getVal());  
			});
		}
		/* sel 옵션추가 */
		if(me.etype=="sel") {
			if(me.agHack!="selRenderer") {
				gfnSetOpts(obj, me.refcd, me.option, me.defval);
			}
		}
		/* btn 표시 */
		if (me.etype=="btn") {
			var btnText = nvl(me.colinfo.defval,me.colinfo.colnm);
			var btnIcon = nvl(me.colinfo.section_icon,"");
			if(!isNull(me.colinfo.option)) {
				btnText = me.colinfo.option.split(":")[0];
				btnIcon = me.colinfo.option.split(":")[1];
			}   
			if(!isNull(btnIcon)) me.obj.append(`<i class='${btnIcon}'></i> `);
			me.obj.append(btnText);
			me.obj.on("click",function(){ 
				afnEH(me.colid, "click");  
			});
		}
        /* ymd, auto, pop 은 버튼이 추가됨 */				
		if(inStr(me.attr,"ymd")>=0||inStr(me.attr,"pop")>=0) {			
			me.dispObj = gfnSetOpts(obj, me.refcd, me.option, me.defval);
		} else if(inStr(me.attr,"auto")>=0 && rowPinned == undefined) {
			me.dispObj = gfnSetOpts(obj, me.refcd, me.option, me.defval);
		} else { /* 엔터키 이벤트를 추가해 줌 */
			me.obj.on("keyup",function(e){
				if(e.keyCode==13) {
					afnEH($(e.target).attr("colid"), "enter", me.getVal()); 
				}
			});
		} 
		/* auto select 선택되면 처리 */ 	
		me.obj.on("autoselect",function(e, aParam){
			if(aParam==gParam) return;
			/* sel, auto, pop 은 값 변경이 일어났을때 코드/명과 같은 쌍 컬럼값을 변경해 준다. */
			var cdVal = (!isNull(aParam) && !isNull(aParam.item))?nvl(aParam.item.cd,null):null;
			var nmVal = (!isNull(aParam) && !isNull(aParam.item))?nvl(aParam.item.nm,null):null; 
			setTimeout(function() {
				me.setPairVal(me.option.split(":")[1], cdVal);
				me.setPairVal(me.option.split(":")[2], nmVal); 
				afnEH(me.colid, "change", me.getVal());  
			},1); 
		});	
		/* auto select 선택되면 처리 */ 	
		me.obj.on("autoselect2",function(e, aParam){
			/* sel, auto, pop 은 값 변경이 일어났을때 코드/명과 같은 쌍 컬럼값을 변경해 준다. */
			var cdVal = (!isNull(aParam) && !isNull(aParam.item))?nvl(aParam.item.cd,null):null;
			var nmVal = (!isNull(aParam) && !isNull(aParam.item))?nvl(aParam.item.nm,null):null; 
			setTimeout(function() {
				me.setPairVal(me.option.split(":")[1], cdVal);
				me.setPairVal(me.option.split(":")[2], nmVal);  
				afnEH(me.colid, "change", me.getVal());  
			},1); 
		});
		//popup
		me.obj.on("searchPop",function(e, aParam) { //사용자조작에 의해 바뀔때 Invoke된다. 
			//사용자정의 팝업을 사용하려는 경우 바로 리턴한다. 
			if( !isNull(arguments) && !isNull(arguments[1]) && arguments[1] =="mypop") {
				afnEH(me.colid, "mypop", arguments);  
				return;
			}
			var cdVal = null;
			var nmVal = null;  
			//aParam은 데이터만 조회할떄와 팝업이 뜰떄가 달라서 사용안함 대신 gParam사용 
			if(!isNull(gParam) && !isNull(gParam.rtnData)) {
				cdVal = nvl(gParam.rtnData[0]["cd"],null);
				nmVal = nvl(gParam.rtnData[0]["nm"],null);
			} 
			if(me.colid==gParam.colcd) me.setVal(cdVal);
			else if(me.colid==gParam.colnm) me.setVal(nmVal); 
			 //변경발생시 데이터정제 
			setTimeout(function() { 
				me.setPairVal(me.option.split(":")[1], cdVal);
				me.setPairVal(me.option.split(":")[2], nmVal); 
				afnEH(me.colid, "change", me.getVal());  
			},1);
		});
		me.obj.on("change",function(e, aParam){ //사용자조작에 의해 바뀔때 Invoke된다. 
			/* sel, auto, pop 은 값 변경이 일어났을때 코드/명과 같은 쌍 컬럼값을 변경해 준다. */
			if (me.etype=="sel") { 
				if(me.agHack!="selRenderer") { 
					setTimeout(function() {
						var cdVal = me.obj.find("option:selected").val(); 
						var nmVal = me.obj.find("option:selected").attr("pairVal"); 					
						me.setPairVal(me.option.split(":")[1], cdVal);
						me.setPairVal(me.option.split(":")[2], nmVal); 
					},1);
				} //selRenderer 모드일때는 change event가 발생할 수 없고, 처리하지도 않는다. 
			}  
			if (inStr(me.attr,"auto") < 0 && inStr(me.attr,"pop") < 0) { 
				var val = me.dispVal();
				me.setVal(val); //변경발생시 데이터정제  
				afnEH(me.colid, "change", me.getVal());  
			}
		}); 
		me.focusHack = false;
		me.obj.on("focus",function(e){
			if(!me.focusHack) {
				me.focusHack = true;
				me.obj.select(); 
			}
		}); 

		/* 기본값 설정 */
		if(val!=undefined) me.setVal(val,true); //값이 있으면 값이 우선
		else if(!isNull(me.defval)) me.setVal(me.defval); //없으면 기본값을 세팅

		/* 활성상태 */
		if(inStr(me.attr,"readonly")>=0) me.setReadonly(true);
		if(inStr(me.attr,"disabled")>=0) me.setDisable(true);
		
		/* 크기 표시 */
		if(!isNull(me.w)) me.dispObj.attr("w",me.w); 
		// me.dispObj.css("flex", "1 1 "+me.w+"em"); 
		if(!isNull(me.h)) me.dispObj.css("height",me.h+"em");   

		/* select2 적용  */
		if(me.etype=="sel") {
			
			if(me.agHack!="selRenderer") {
				if(!isNull(me.oComponent) && !isNull(me.oComponent.componentId) && me.oComponent.componentId=="pageCond") {
					if(!isNull(me.oComponent) && !isNull(me.oComponent.componentId) && me.oComponent.componentId=="pageCond") {
					if((inStr(me.option,"multi")>=0)) {
						setTimeout(function(control,bMulti){$(control).select2({
							multiple: true,
							closeOnSelect : false,
							dropdownAutoWidth : true 
						})},5,me.obj);
					} else {
						setTimeout(function(control,bMulti){$(control).select2({
							dropdownAutoWidth : true 
						})},5,me.obj);
					}
					} 
				}
			}
		}

		/* tooltip추가 */
		if(!isNull(me.remark)) me.obj.attr("title",me.remark); 

		console.log("gfn2 테스트");
		
		return me;
	}  
	//값 변경시 데이터형식에 맞게 값 정제
	me.setter = function(val) {  
		// console.log("me.setter") ;
		if(me.dtype=="num") {
			if(inStr(me.attr,"dec1")>=0) return format(toNum(val),1);
			else if(inStr(me.attr,"dec2")>=0) return format(toNum(val),2);
			else if(inStr(me.attr,"dec3")>=0) return format(toNum(val),3);
			else if(inStr(me.attr,"dec4")>=0) return format(toNum(val),4);
			else return format(toNum(val));
		}
		else if (me.dtype=="ymd") {
			val=""+val;
			if(trim(val).length==8) return date(val,"yyyymmdd"); 
			else if(trim(val).length==4) return date((date("today").substr(0,4)+""+val),"yyyymmdd"); 
			else return date(val);
		}
		else if (me.dtype=="text") {
			if($.type(val)=="string") {
				if(inStr(me.attr, "upper")>=0) val = upper(val);
				else if(inStr(me.attr, "lower")>=0) val = lower(val);
				else if(inStr(me.attr,"biz_no")>=0) val = biz_no(val); 
				else if(inStr(me.attr,"ccard")>=0) val = ccard(val); 
				else if(inStr(me.attr,"nm")>=0) {
					me.cdnmVal = val;
					val = (val||"").split(":")[1];
				}
			}
			return val;
		} else if (me.etype=="cbx") {
			if(val==true||val=="on"||val=="Y") return "Y";
			else return "N";
		}
		return val;
	}
	//값 세팅
    me.setVal = function(val,bIinitialSkip) {
		// console.log("me.setVal") ;
		if( me.etype=="raw") {
			me.obj.includeObj(".aweCol").html(me.setter(val));
		} else if( me.etype=="pre") {
			me.obj.includeObj(".aweCol").html(me.setter(val));
		} else if(me.etype=="txt") {
			me.obj.includeObj(".aweCol").val(me.setter(val));
		} else if(me.etype=="pwd") {
			me.obj.includeObj(".aweCol").val(val);
		} else if(me.etype=="cbx") {  
			if(me.setter(val)=="Y") {
				me.obj.includeObj(".aweCol")[0].checked=true; 
				me.obj.includeObj(".aweCol").prop("checked",true);
			} else {
				me.obj.includeObj(".aweCol")[0].checked=false;  
				me.obj.includeObj(".aweCol").removeProp("checked");
			}
		} else if(me.etype=="sel") {
            if(me.agHack!="selRenderer") {
				me.obj.includeObj(".aweCol").val(val);
				setTimeout(function() {
					var cdVal = me.obj.find("option:selected").val(); 
					var nmVal = me.obj.find("option:selected").attr("pairVal"); 					
					me.setPairVal(me.option.split(":")[1], cdVal);
					me.setPairVal(me.option.split(":")[2], nmVal); 
				},1); 
			} else {  
				var pairVal = null;
				if(!isNull(me.colinfo)&&!isNull(me.refcd)&&!isNull(val)) {
					var disp = "cdnm"; 
					if(!isNull(me.colinfo)&&!isNull(me.option)&&!isNull(me.option.split(":")[3])) {
						disp = me.option.split(":")[3]; 
					}
					pairVal = gfnCdNm(me.refcd, val, "nm");
					if(disp=="cd") {
						me.obj.includeObj(".aweCol").html( me.setter( val ) );  
					} else if(disp=="nm") {
						me.obj.includeObj(".aweCol").html( pairVal );  
					} else {
						me.obj.includeObj(".aweCol").html( "["+me.setter( val )+"] " + pairVal );   
					} 
				} else {
					me.obj.includeObj(".aweCol").html( this.setter( val ) );  
				} 
				setTimeout(function() {
					me.setPairVal(me.option.split(":")[1], val);
					me.setPairVal(me.option.split(":")[2], pairVal); 
				},1); 
			} 
		} else if(me.etype=="tarea") {
			me.obj.includeObj(".aweCol").val(val);
		} else if(me.etype=="img") {
			me.obj.includeObj(".aweCol").attr("src",val);
		} else if(me.etype=="link") {
			me.obj.includeObj(".aweCol").attr("href",val);
		} else if(me.etype=="btn") {
			if(!isNull(val) && (isNull(me.colinfo) || isNull(me.colinfo.option))) { 
				var icon = nvl(me.obj.includeObj(".aweCol").children("i"),"");
				console.log(icon);
				me.obj.includeObj(".aweCol").html(val);
				if(!isNull(icon)) icon.prependTo(me.obj.includeObj(".aweCol"));
			}	
			me.obj.includeObj(".aweCol").data("val",val);
		} 
		if(rowid != undefined && !bIinitialSkip) { //agGrid일 경우 컨트롤이 변경된 경우 값을 agGrid쪽으로 값을 Sync해줘야함 
			if(oComponent.componentDef!=undefined && 
			   oComponent.componentDef.component_pgmid=="agGrid" &&
			   $.type(oComponent.setVal)=='function') {
				oComponent.setVal(rowid, me.colid, val);
			}
		}  
	}
	//표시값 가져오기 
	me.dispVal = function() {
		// console.log("me.disVal");

		var rtn = null;		
		if( me.etype=="raw") {
			rtn = me.obj.includeObj(".aweCol").html();
		} else if( me.etype=="pre") {
			rtn = me.obj.includeObj(".aweCol").html();
		} else if(me.etype=="txt") { 
			rtn = me.obj[0].value;
			// rtn = me.obj.includeObj(".aweCol").val();
			if(inStr(me.attr,"nm")>=0) rtn = me.cdnmVal; 
		} else if(me.etype=="pwd") {
			rtn = me.obj[0].value;
			// rtn = me.obj.includeObj(".aweCol").val();
		} else if(me.etype=="cbx") {
			if(me.obj.includeObj(".aweCol")[0].checked==true||me.obj.includeObj(".aweCol").prop("checked")==true) rtn = "Y";
			else rtn = "N";  
		} else if(me.etype=="sel") {
			rtn = me.obj.includeObj(".aweCol").val();
		} else if(me.etype=="tarea") {
			rtn = me.obj.includeObj(".aweCol").val();
		} else if(me.etype=="img") {
			rtn = me.obj.includeObj(".aweCol").attr("src");
		} else if(me.etype=="link") {
			rtn = me.obj.includeObj(".aweCol").attr("href");
		} else if(me.etype=="btn") {
			rtn = me.obj.includeObj(".aweCol").data("val"); 
		} 
		if($.type(rtn)=="string") {
			if(inStr(me.attr, "upper")>=0) rtn = upper(rtn);
			else if(inStr(me.attr, "lower")>=0) rtn = lower(rtn);
		}
		return rtn;
	}
	//데이터형식에 맞는 값 가져오기 
	me.getVal = function() {
		// console.log("me.getVal") ;
		var rtn = me.dispVal();
		if(me.dtype=="num") return toNum(rtn); 
		else if (me.dtype=="ymd") return date(rtn,"yyyy-mm-dd","yyyymmdd"); 
		return rtn;
	}  
	//ATTR에 따른 상태처리 
	me.setDisable = function(bLock) {
		// console.log("me.setDisable") ;
		if(bLock==true) {
			me.obj.includeObj(".aweCol").addClass("disabled");
			me.obj.includeObj(".aweCol").attr("disabled","disabled"); 
			me.obj.children(".aweColBtn").attr("disabled","disabled");
		} else {
			me.obj.includeObj(".aweCol").removeClass("disabled");
			me.obj.includeObj(".aweCol").removeAttr("disabled");
			me.obj.children(".aweColBtn").removeAttr("disabled");
		}
	} 
	me.setReadonly = function(bLock) {
		// console.log("me.setReadonly") ;
		if(bLock==true) {
			me.obj.includeObj(".aweCol").addClass("readonly");
			me.obj.includeObj(".aweCol").attr("readonly","readonly");
			me.obj.children(".aweColBtn").attr("disabled","disabled");
			if(me.etype == "sel") { me.obj.includeObj(".aweCol").attr("disabled","disabled"); }		
		
		} else {
			me.obj.includeObj(".aweCol").removeClass("readonly");
			me.obj.includeObj(".aweCol").removeAttr("readonly");
			me.obj.children(".aweColBtn").removeAttr("disabled");
			if(me.etype == "sel") { me.obj.includeObj(".aweCol").removeAttr("disabled"); }
		}
	}		
	me.setHidden = function(bHide) {
		// console.log("me.setHidden") ;
		if(bHide==true) {
			me.obj.hide();
			if(!isNull(me.dispObj)) me.dispObj.hide();
			me.obj.siblings(".select2").hide();
		} else {
			me.obj.show(); 
			if(!isNull(me.dispObj)) { me.dispObj.show(); me.dispObj.removeClass("hidden"); }
			me.obj.siblings(".select2").show().removeClass("hidden");
		}
	}	
	//컨트롤에 포커스 주기 
	me.focus = function() {
		console.log("me.focus") ;
		if(!me.obj.includeObj(".aweCol").is(":focus")) { 
			setTimeout(function() {
				//console.log("focus on me.obj:"+me.colinfo.colid);
				me.obj.includeObj(".aweCol").focus();
				//console.log("control focused");
				//me.obj.includeObj(".aweCol").select();
			},1); 
		}
	}
	//option을 변경해 줌
	me.refreshOptions  = function(arr) {
		// console.log("me.refreshOption") ;
		var obj = me.obj.includeObj(".aweCol"); 
		gfnSetOpts(obj, arr, me.option, me.getVal() );
	}
	//값이 Valid한지 Return
	me.chkValid = function(bWarn) { 
		// console.log("me.chkValid") ;
		return gfnChkValid(me.colinfo, me.getVal(), bWarn);
	}

	me.init(); //초기화호출
}
function workbenchForm(pageid, component_id, dataDef, afnEH, me, rowData, distinctRow) {

	// console.log("Workbench Form생성");
	// console.log(pageid);
	// console.log(component_id);
	// console.log(dataDef);
	// console.log(afnEH);
	// console.log(me);
	// console.log(rowData);
	// console.log(distinctRow);

	
	// 화면기능, 화면컴포넌트, 화면소스 구분
	var componentType = ""
	if(component_id == "pgm_func") componentType = "funcInfo";
	else if(component_id == "pgm_data") componentType = "dataInfo";
	else if(component_id == "pgm_src") componentType = "srcInfo";


	if(component_id == "pgm_func") {
		// 초기 데이터
		var colinfos = dataDef.content;
		var funcBtns = dataDef.workbenchForm.contentFunc;
		me.pageContentMain = {};
		me.pageContentMain[component_id] = {};
	
		// 기존 페이지 처리
		$(`.workBenchFormWrap.${pageid}.funcInfo`).remove();
		$(`.workBenchFormWrap.${pageid}.dataInfo`).remove();
		$(`.workBenchFormWrap.${pageid}.srcInfo`).hide();

		// Top 생성
		var pageContentMainTop = $(`<div class="pageContentMainTop"></div>`);
		var pageContentMainTitle = $(`<div class="pageContentMainTitle">${dataDef.data_nm} (추가)</div>`);
		var pageContentMainFunc = $(`<div class="pageContentMainFunc"></div>`);
		new gfnButtonSet(pageContentMainFunc, funcBtns, function(btnSet, evt, funcid, func) { 
			//이벤트를 바인딩해준다. 이때 이벤트유형은 componentFunc이다.
			var row = component_id + "#" + distinctRow
			afnEH(me.pageContentMain, evt, row, funcid, func);
		}); 
		pageContentMainTop.append(pageContentMainTitle);
		pageContentMainTop.append(pageContentMainFunc);
		
		// Body 생성
		var pageContentMainBody = $(`<div class="pageContentMainBody"></div>`);
	
		for(var i=0; i<colinfos.length; i++) {
			var colinfo = colinfos[i];

			if((colinfo.colnm == "더보기") || (colinfo.colid == "sort_seq") || (colinfo.colid == "data_icon")) continue;
	
			var pageContentMainInputWrap = $(`<div class="pageContentMainInputWrap ${colinfo.colid}"></div>`);
			var InputWrapTitle = $(`<div class="InputWrapTitle">${colinfo.colnm}</div>`);
			var InputWrapContent = $(`<div class="InputWrapContent"></div>`);
			
			me.pageContentMain[component_id][colinfo.colid] = new gfnControl(colinfo,function(colid, evt, newval){
				//이벤트를 바인딩해준다. 
				var row = component_id + "#" + distinctRow
				afnEH(me.pageContentMain, evt, row, colid, newval );
			});
			InputWrapContent.append( me.pageContentMain[component_id][colinfo.colid].dispObj );

			// agGrid의 값 넣기
			me.pageContentMain[component_id][colinfo.colid].setVal(rowData[colinfo.colid]);
			
			// 폭 조절
			// if(!isNull(colinfo.w)) {
			// 	pageContentMainInputWrap.css("flex-basis", `${colinfo.w}%`)
			// }
			// 높이 조절
			// if(!isNull(colinfo.h)) {
			// 	pageContentMainInputWrap.css("height", `${colinfo.w}em`)
			// }

			pageContentMainInputWrap.append(InputWrapTitle);
			pageContentMainInputWrap.append(InputWrapContent);
			pageContentMainBody.append(pageContentMainInputWrap);
		}

		var workBenchFormWrap = $(`<div class="workBenchFormWrap ${pageid}"></div>`);
		workBenchFormWrap.attr("rowid", distinctRow)
		workBenchFormWrap.addClass(componentType+distinctRow);
		workBenchFormWrap.addClass(componentType);
		workBenchFormWrap.append(pageContentMainTop);
		workBenchFormWrap.append(pageContentMainBody);
		$(`#${pageid} > .pageContent > .pageContentMain`).append(workBenchFormWrap);
	
		$(`.funcInfo[rowid != '${distinctRow}']`).hide(); // 나머지 숨기기
	} 
	else if(component_id == "pgm_data") {

		// 초기 데이터
		var colinfos = dataDef.content;
		var funcBtns = dataDef.workbenchForm.contentFunc;
		var componentOptions = dataDef.workbenchForm.componentOption;
		me.pageContentMain = {};
		me.pageContentMain[component_id] = {};
		me.pageContentMain[component_id]["componentOption"] = {};
	
		// 기존 페이지 처리
		$(`.workBenchFormWrap.${pageid}.funcInfo`).remove();
		$(`.workBenchFormWrap.${pageid}.dataInfo`).remove();
		$(`.workBenchFormWrap.${pageid}.srcInfo`).hide();

		// Top 생성
		var pageContentMainTop = $(`<div class="pageContentMainTop"></div>`);
		var pageContentMainTitle = $(`<div class="pageContentMainTitle">${dataDef.data_nm} (추가)</div>`);
		var pageContentMainFunc = $(`<div class="pageContentMainFunc"></div>`);
		new gfnButtonSet(pageContentMainFunc, funcBtns, function(btnSet, evt, funcid, func) { 
			//이벤트를 바인딩해준다. 이때 이벤트유형은 componentFunc이다.
			var row = component_id + "#" + distinctRow
			afnEH(me.pageContentMain, evt, row, funcid, func);
		}); 
		pageContentMainTop.append(pageContentMainTitle);
		pageContentMainTop.append(pageContentMainFunc);
		
		// Body 생성
		var pageContentMainBody = $(`<div class="pageContentMainBody"></div>`);
	
		for(var i=0; i<colinfos.length; i++) {
			var colinfo = colinfos[i];

			if((colinfo.colnm == "더보기") || (colinfo.colid == "sort_seq") || (colinfo.colid == "data_icon")) continue;
			
			var pageContentMainInputWrap = $(`<div class="pageContentMainInputWrap ${colinfo.colid}"></div>`);
			var InputWrapTitle = $(`<div class="InputWrapTitle">${colinfo.colnm}</div>`);
			var InputWrapContent = $(`<div class="InputWrapContent"></div>`);
			
			me.pageContentMain[component_id][colinfo.colid] = new gfnControl(colinfo,function(colid, evt, newval){
				//이벤트를 바인딩해준다. 
				var row = component_id + "#" + distinctRow
				afnEH(me.pageContentMain, evt, row, colid, newval );
			});
			InputWrapContent.append( me.pageContentMain[component_id][colinfo.colid].dispObj );

			// agGrid의 값 넣기
			if(colinfo.colid != "content") {
				me.pageContentMain[component_id][colinfo.colid].setVal(rowData[colinfo.colid]);
			}
			
			// 컴포넌트 옵션 
			if(colinfo.colid == "component_option") {
				
				InputWrapContent.empty();	// 기존내용 지우고 새로
				
				for(var j=0; j<componentOptions.length; j++) {

					var componentOption = componentOptions[j];
					
					var componentOptionWrap = $(`<div class="componentOptionWrap"></div>`);
					var componentOptionTitle = $(`<div class="componentOptionTitle">${componentOption.colnm}</div>`);
					var componentOptionBody = $(`<div class="componentOptionBody"></div>`);
					
					me.pageContentMain[component_id]["componentOption"][componentOption.colid] = new gfnControl(componentOption,function(colid, evt, newval){
						//이벤트를 바인딩해준다. 
						var row = component_id + "#" + distinctRow
						afnEH(me.pageContentMain[component_id]["componentOption"], evt, row, "component_option", newval );
					});
					componentOptionBody.append( me.pageContentMain[component_id]["componentOption"][componentOption.colid].dispObj );

					// agGrid의 값 넣기
					var component_option_data = JSON.parse(rowData.component_option);	// agGird에서 가져온 데이터
					console.log(component_option_data);
					if(!isNull(component_option_data)) {
						var value = component_option_data[componentOption.colid];
						if(value != undefined) {
							if(typeof(value) == "string") {
								// console.log("컴포넌트옵션에 값 넣기 - string");
								value = value;
							} else if(typeof(value) == "object") {
								// console.log("컴포넌트옵션에 값 넣기 - object");
								value = JSON.stringify(value);
							}
							me.pageContentMain[component_id]["componentOption"][componentOption.colid].setVal(value);
						}					
					}
					
					componentOptionWrap.append(componentOptionTitle);
					componentOptionWrap.append(componentOptionBody);
					InputWrapContent.append(componentOptionWrap);
				}
			} 
			
			// 폭 조절
			// if(!isNull(colinfo.w)) {
			// 	pageContentMainInputWrap.css("flex-basis", `${colinfo.w}%`)
			// }

			pageContentMainInputWrap.append(InputWrapTitle);
			pageContentMainInputWrap.append(InputWrapContent);
			pageContentMainBody.append(pageContentMainInputWrap);
		}

		pageContentMainInputWrap.append(InputWrapTitle);
		pageContentMainInputWrap.append(InputWrapContent);
		pageContentMainBody.append(pageContentMainInputWrap);
	
		var workBenchFormWrap = $(`<div class="workBenchFormWrap ${pageid}"></div>`);
		workBenchFormWrap.attr("rowid", distinctRow)
		workBenchFormWrap.addClass(componentType+distinctRow);
		workBenchFormWrap.addClass(componentType);

		workBenchFormWrap.append(pageContentMainTop);
		workBenchFormWrap.append(pageContentMainBody);
		
		$(`#${pageid} > .pageContent > .pageContentMain`).append(workBenchFormWrap);
	} 
	else if (component_id == "pgm_src") {
		console.log('소스에 들어옴');

		// 초기데이터
		var funcBtns = dataDef.contentForm.contentFunc;
		me.pageContentMain = {};
		me.pageContentMain[component_id] = {};

		// 페이지 중복 처리
		$(`.${pageid}.dataInfo`).hide();
		$(`.${pageid}.funcInfo`).hide();
		if($(".pageContentMain").children(`.${pageid}`).hasClass("srcInfo"+distinctRow)) {
			console.log("이미 작성중인 행입니다. 불러옵니다.");
			// $(`.srcInfo[rowid != '${distinctRow}']`).hide();
			$(`.srcInfo[rowid = '${distinctRow}']`).show();
			return "alreadyPage";
		}

		// Top 생성
		var pageContentMainTop = $(`<div class="pageContentMainTop"></div>`);
		var pageContentMainTitle = $(`<div class="pageContentMainTitle">${rowData.src_nm}</div>`);
		var pageContentMainFunc = $(`<div class="pageContentMainFunc"></div>`);
		new gfnButtonSet(pageContentMainFunc, funcBtns, function(btnSet, evt, funcid, func) { 
			//이벤트를 바인딩해준다. 이때 이벤트유형은 componentFunc이다.
			var row = component_id + "#" + distinctRow
			afnEH(me.pageContentMain, evt, row, funcid, func);
		}); 
		pageContentMainTop.append(pageContentMainTitle);
		pageContentMainTop.append(pageContentMainFunc);

		// Body 생성
		var pageContentMainBody = $(`<div class="pageContentMainBody"></div>`);

		// workBenchFormWrap 생성
		// if($(`#${pageid}`).)
		var workBenchFormWrap = $(`<div class="workBenchFormWrap ${pageid}"></div>`);
		workBenchFormWrap.attr("rowid", distinctRow)
		workBenchFormWrap.addClass(componentType+distinctRow);
		workBenchFormWrap.addClass(componentType);
		workBenchFormWrap.append(pageContentMainTop);
		workBenchFormWrap.append(pageContentMainBody);
		// $(`.pageContentMain`).append(workBenchFormWrap);
		$(`#${pageid} > .pageContent > .pageContentMain`).append(workBenchFormWrap);
		// console.log(`#${pageid} > .pageContent > .pageContentMain`);
	
		// $(`.srcInfo[rowid != '${distinctRow}']`).hide(); // 나머지 숨기기
		return workBenchFormWrap;
	}
}