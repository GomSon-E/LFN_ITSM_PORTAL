/*! awe common - v1 - 2018-07-27

isNull(obj)
nvl(val, rep) 
nzl(val, rep)
inStr(src, tgt) return iPos
isYmd(arg)
isYear(arg)
isNum(arg)

isSson(arg)
isComid(arg)
isDocNo(arg)
isArtcNo(arg)

String.prototype.string = function(len) 
String.prototype.zf = function(len) 
Number.prototype.zf = function(len) 
Date.prototype.format = function(format:(yyyy|yy|mm|dd|weekday|w|hh24|hh|mi|ss|ap)
String.prototype.toDate(format:(yyyy|yy|mm|dd|weekday|w|hh24|hh|mi|ss|ap)
dateDiff("2018-01-01","2018-01-31") = 31 날짜차이  
dateAdd("2018-01-01",10) = "2018-01-11" 날짜추가

toNum(val) trim하고 숫자인지 검사해서 숫자 또는 null return
rnd(aMax,aMin) 랜덤값 
format( number, decimals, dec_point, thousands_sep ) 숫자 소수점 처리, 날짜 yyyy-MM-dd처리 

slice("2018-01-01","yyyy-mm-dd","mm") = "01" 문자쪼개기
replace(val,replacer,alter) Replace without error
trim(val) trim 앞뒤의 모든 스페이스를 없애줌 

Array.prototype.last 배열의 마지막 요소 가져오기
subset(obj, attr, val, bLike) 배열에서 주어진 속성-값에 일치하는 건을 리턴함
extract(objarr, col, distinct) 오브젝트 배열에서 특정컬럼만 추출하여 배열 만들기  
arrayCalc(arr,gbn,remover,attr) gbn=sum,min,max :배열합,최대,최소
arrMove(arr, old_index, new_index) arr에서 element의 순서바꾸기

setCookie(cookieName, value, exdays)
deleteCookie(cookieName)
getCookie(cookieName)

eval2(objId) objId 또는 스트링값으로 objId를 넣었을때 eval이 되면 Obj를 리턴하고, 
             그렇지 않으면 스트링값/숫자값을 리턴한다. 
Object.equals(gUserinfo, eval2("gUserinfo")) 깊은 오브젝트 일치여부 체크에 사용

bLogger & logger(lv,msg,obj) : 특정 소스를 수정할때 사용법3 을 참조할 것
  사용법1: bLogger=true; logger("string", testObj); 
  사용법2: bLogger=true; logger( log/info/warn/error , "string", testObj );
  사용법3: bLogger="anyKeyword"; logger( "anyKeyword", "string", testObj );
                             
JQuery.prototype.isON("selector") returns .is("selector") or .parents("selector").length > 0 
  : 이벤트가 발생한 오브젝트(부모) 찾기

*/
/* 상수 */
const CR = "\r\n";
const TAB = "\t";

/** Object & Validator *************************************************************************************************************/
/* 오브젝트 하위속성의 갯수 가져오기 Object.prototype.length = Object.keys(this).length;   */
/* Null체크 */
function isNull(obj) {
	return (typeof obj == "undefined" || obj == null || obj == "");
}

/* null 체크하여 rep를 리턴 */
function nvl(val, rep) {
	return isNull(val)?rep:val;
}

/* 0이거나 값이 없으면 rep를 리턴 */
function nzl(val, rep) {
	return (isNull(val)||toNum(val)==0)?rep:val;
}

/* src안에 tgt이 있는지 검사하여 위치리턴, 없으면 -1 */
function inStr(src, tgt) {
	if($.type(src) == "string") {
		return src.indexOf(tgt);
	} else if($.type(src) == "number") {
		return (""+src).indexOf(tgt);
	} else if($.type(src) == "array") {
		if($.type(tgt)=="array") {
			var a = -1;
			for(var j=0; j < tgt.length; j++) {
				var b = false;
				for(var i=0; i < src.length; i++) {  
					if(inStr(src[i],tgt[j]) >= 0) {
						a++;
						b = true; 
						break;
					}
				}
				if(b==false) return -1;
			}
			return a; 
		} else if ($.type(tgt)=="string"||$.type(tgt)=="number") {  
			return src.indexOf(tgt);
		} else {
			for(var i=0; i < src.length; i++) {
				if(inStr(src[i],tgt) >= 0) return i;
			}
			return -1;
		}
	} else if($.type(src) == "object") {
		if($.type(tgt)=="object") { 
			var rtn=-1; 
			for(var key in src) {
				if( src.hasOwnProperty(key) ) {  
					if(!isNull(tgt[key])) { 
						if(inStr(src[key],tgt[key]) < 0) return -1;
						//if(JSON.stringify(src[key])!=JSON.stringify(tgt[key])) return -1;
						else rtn++;
					}
				}
			}
			return rtn;
		} else {
			var src2=[]; 
			for(var key in src) {
				if( src.hasOwnProperty(key) ) {  
					src2.push(src[key]);
				}
			}
			return inStr(src2,tgt);  
		} 
	} 	
} 

/* Validator */
function isYmd(arg) {
	if(!isNull(arg)) { 
		if (arg.length==10 && !isNull(arg.toDate("yyyy-mm-dd"))) return true;
		else if (arg.length==8 && !isNull(arg.toDate("yyyymmdd"))) return true;
	}  
	return false;
} 

function isYear(arg) {
	return ($.isNumeric(arg)&&(""+arg).length==4); 
}

function isNum(arg) {
	return $.isNumeric(toNum(arg)); 
}

function isSson(arg) {
	return (!isNull(arg) && arg.toUpperCase()==arg && arg.trim().length==2);
}
function isComid(arg) {
	return (!isNull(arg));
}

function isDocNo(arg) {  
	return (!isNull(arg) && arg.trim().length > 6);
}

function isArtcNo(arg) {
	return (!isNull(arg) && arg.trim().length > 6);
}

function isEmail(email) { 
	return String(email)
	  .toLowerCase()
	  .match(
		/^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
	  );
} 





/** Date ***************************************************************************************************************************/
/* 문자열 반복 "a".string(3) = "aaa" */
String.prototype.string = function(len){var s = '', i = 0; while (i++ < len) { s += this; } return s;};
function lpad(str,char,len) {
	var strlen = (function(s,b,i,c){
		//for(b=i=0;c=s.charCodeAt(i++);b+=c>>11?3:c>>7?2:1); 진짜Byte헤아릴때
		for(b=i=0;c=s.charCodeAt(i++);b+=c>>11?2:c>>7?2:1); //한글2글자취급할때
		return b
	})(nvl(str,""));
	var reqlen = len-strlen;
	if(reqlen <= 0) return str;
	return char.string(reqlen) + str;
}
/* 0채우기 "123".zf(5) = "00123" */
String.prototype.zf = function(len){return "0".string(len - this.length) + this;};
/* 0채우기 123.zf(5) = "00123" */
Number.prototype.zf = function(len){return this.toString().zf(len);};
/* Date타입을 Format에 맞춰서 표시 d.format("yyyy-mm-dd (weekday) hh24:mi:ss ap") */
Date.prototype.format = function(f) {
    if (!this.valueOf()) return null; 
    var weekdays = ["일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일"];
    var ws       = ["일", "월", "화", "수", "목", "금", "토"];
    var d = this; 
    return f.replace(/(yyyy|yy|mm|dd|weekday|w|hh24|hh|mi|ss|ap)/gi, function($1) {
    	switch ($1) {
    		case "yyyy":    return d.getFullYear();
    		case "yy":      return (d.getFullYear() % 1000).zf(2);
    		case "mm":      return (d.getMonth() + 1).zf(2);
    		case "dd":      return d.getDate().zf(2);
    		case "weekday": return weekdays[d.getDay()];
    		case "w" :      return ws[d.getDay()];
    		case "hh24":    return d.getHours().zf(2);
    		case "hh":      return ((h = d.getHours() % 12) ? h : 12).zf(2);
    		case "mi":      return d.getMinutes().zf(2);
    		case "ss":      return d.getSeconds().zf(2);
    		case "ap":      return d.getHours() < 12 ? "오전" : "오후";
    		default: return $1;
    	}
	});
};

/* 날짜로 변환 : "2018-01-01".toDate("yyyy-mm-dd") = 2018-01-01 00:00:00 */
String.prototype.toDate = function(f){
	if (f==undefined) f = "yyyy-mm-dd";
	var val = this;
	f = f.replace("hh24","hh");
	var d = new Date( slice(val,f,"yyyy"), toNum(slice(val,f,"mm"))-1, slice(val,f,"dd"), slice(val,f,"hh"), slice(val,f,"mi"), slice(val,f,"ss") );
	if (slice(val,f,"mm") != d.format("mm")) return null; //2.31, 4.31 등 변환안됨
	if (!d.valueOf()) return null; 
	return d;
};

/* 오늘 */
function date(arg, af, f) {
	if (f==undefined) f = "yyyy-mm-dd";
	if (af==undefined) af = "yyyy-mm-dd";
	if(arg==undefined||arg=="today") {
		return new Date().format(af);
	} else if (arg=="1st") {
		return ((new Date().format("yyyy-mm"))+"-01").toDate().format(af);
	} else if (arg=="last") { 
	    return	(dateAdd( date(), "last")).toDate().format(af);
	} else {
		try { 
		    var rtn = (arg.toDate(af)).format(f);
		    return rtn;
		} catch(e) {
			return null;
		}
	}
}

/* 날짜차이 dateDiff("2018-01-01","2018-01-31") = 31 */
function dateDiff( from, to, f ) {
	if (f==undefined) f = "yyyy-mm-dd";
	return parseInt((to.toDate(f)-from.toDate(f))/(1000*60*60*24));
}

/* 날짜추가 dateAdd("2018-01-01",10) = "2018-01-11" */
function dateAdd( d, days, f ) {
	if(f==undefined) f = "yyyy-mm-dd";
	var dd = d.toDate(f);
	if (dd==null || !dd.valueOf()) return null;
	if($.type(days)=="string" && days.toLowerCase().indexOf("last") >= 0) {
		dd.setMonth(dd.getMonth()+1); //1달을 더하고
		dd.setDate(1);                //1일로 만든후
		dd.setDate(dd.getDate()-1);   //하루를 뺴준다.
	    return dd.format(f); 	
	} else { 
	    return (new Date( dd.setDate(dd.getDate()+parseInt(days)) )).format(f);
	}
} 

function timeDiff( from, to ) {
	try { 
		var fromDT = date("today")+" "+from;
		var toDT = date("today")+" "+to;
		var nextdayDT = dateAdd(date("today"),1)+" "+to;
		var fromTime = fromDT.toDate("yyyy-mm-dd hh24:mi");
		var toTime   = toDT.toDate("yyyy-mm-dd hh24:mi");
		var nextdayTime = nextdayDT.toDate("yyyy-mm-dd hh24:mi");
		if(toTime < fromTime) toTime = nextdayTime;
		var gapTime  = parseInt((toTime - fromTime)/1000/60); //분단위
		var gapHour  = parseInt(gapTime/60);
		var gapMinute = gapTime%60;
		return gapHour+":"+((""+gapMinute).zf(2));

	} catch {
		return null;
	}
} 

function toYmd(arg) {
	if(!isNull(arg)) { 
		if (arg.length==10 && !isNull(arg.toDate("yyyy-mm-dd"))) return arg.toDate("yyyy-mm-dd").format("yyyy-mm-dd");
		else if (arg.length==8 && !isNull(arg.toDate("yyyymmdd"))) return arg.toDate("yyyymmdd").format("yyyy-mm-dd");
	}  
	return "";
}


/** Number ***********************************************************************************************************************/
/* trim하고 숫자인지 검사해서 숫자 또는 null return */
function toNum(val,dec) {
	var rtn = (typeof(val)=="number")?val:parseFloat( trim(val).replace( /,/g ,"") ); //콤마제거후
	if(isNaN(rtn)) return null;
	if(dec < 0) { //                            6:백만자리 라운드,8:억자리라운드 
		var digit = [1,10,100,1000,10000,100000,1000000,10000000,100000000,1000000000];
		rtn = format( _toNum( rtn, digit[Math.abs(dec)] ),0); //format을 씌우면 정해진 자리수 만큼 "#,#00"으로 만들어 줌 
	} else if(dec == 0) {
		return Math.round(rtn);
	} else {
		if(isNull(dec)) dec = 1;
		var digit = [1,0.1,0.01,0.001,0.0001,0.0001,0.00001];
		rtn = format( _toNum( rtn, digit[dec]), dec);  //format을 씌우면 정해진 자리수 만큼 "#,###.#"으로 만들어 줌 
	}   
	return parseFloat(rtn.replace( /,/g ,""));
} 

function _toNum(val, digit) { /* javascript 부동소수점 오류 HACK */
	return Math.round( val / digit) * digit;
}

/* 랜덤값 */
function rnd(aMax,aMin) {
	var min = 0, max = 1;
	if(aMin!=undefined) min=aMin;
	if(aMax!=undefined) max=aMax;
	return Math.floor(Math.random()*(max-min+1))+min;
}

/* 숫자 소수점 처리, 날짜 yyyy-MM-dd처리 */
function format( number, decimals, dec_point, thousands_sep ) {
	if (number==null) return null;
	if (decimals == "YYYYMMDD") {
		if (number.length != 8) return ""; 
		return date(number,"yyyymmdd");			
	} else {  
		var n = number, prec = decimals, dec = dec_point, sep = thousands_sep;
		if (isNaN(n)) { 
			n = 0; 
		}else{
			n = Number(n);
		} 
		n = n + 0.0000;        //1000.2000
		prec = (prec == undefined||prec == "undefined"||prec==""||prec==null) ? 0 : prec;
		var s = n.toFixed(prec);    //1000.20 
		sep = sep == undefined ? ',' : sep;
		dec = dec == undefined ? '.' : dec; 
		var regx = new RegExp(/(-?\d+)(\d{3})/);
		var strArr = (""+n).split('.');
		while(regx.test(strArr[0])){
			strArr[0] = strArr[0].replace(regx,"$1,$2");  //1,000
		}
		if (prec > 0) {
			var sPrec = strArr[1];
			if (sPrec==undefined||sPrec=="undefined") {
				sPrec="";
				for (var i = 0; i < prec; i++) sPrec += "0";
			} else {
				sPrec= sPrec.substring(0,prec);
			}
			s = strArr[0] + dec + sPrec;
		} else {
			s = strArr[0];
		}
		return s;
	}
}


/** String ************************************************************************************************************/
/* 문자 쪼개기 : slice("2018-01-01","yyyy-mm-dd","mm") = "01" */
function slice( val, ff, f ) {
	if (val.length != ff.length ) return null;
	if (ff.indexOf(f) < 0) return null;
	return val.substr( ff.indexOf(f), f.length );
}

/* Replace with out error */
function replace(val,replacer,alter) {
	if(isNull(val)) return ""; 
	try {
		val = val.toString().replace(replacer,alter);
		return val;
	} catch (e) {
		return val;
	}
}

/* trim 앞뒤의 모든 스페이스를 없애줌 */
function trim(val) {
	if(isNull(val)) return ""; 
	return val.toString().trim();
} 

function upper(val) {
	if(isNull(val)) return ""; 
	return val.toString().toUpperCase();
}

function lower(val) {
	if(isNull(val)) return "";
	return val.toString().toLowerCase();
}

function biz_no(val) {
	if(isNull(val)) return "";
	return val.toString().replace(/(\d{3})(\d{2})(\d{5})/g, '$1-$2-$3');
}


function ccard(val) {
	if(isNull(val)) return "";
	return val.toString().replace(/(\d{4})(\d{4})(\d{4})(\d{4})/g, '$1-$2-$3-$4');
}

/*** 배열 ***********************************************************************************************************************/
/* 배열의 마지막 요소 가져오기 */
if (!Array.prototype.last){
    Array.prototype.last = function(){
        return this[this.length - 1];
    };
};
/* 배열에서 주어진 속성-값에 일치하는 건을 리턴함 */
function subset(objarr, attr, val, bLike) { 
	if ($.type(objarr) != "array") objarr = $.makeArray(objarr); 
	var arr = [];
	for(var i=0; i < objarr.length; i++) {
		var objel = $.extend({},objarr[i]);
		attr = $.makeArray(attr);
		for(var j=0; j < attr.length; j++) {
			var att = attr[j];
			if(objel[att]==undefined) continue;
			if(objel[att]==val && inStr(arr,objel) < 0) {
				arr.push(objel); 
			} else if(bLike==true && inStr(objel[att],val) >=0 && inStr(arr,objel) < 0) { 
				arr.push(objel);  
			}
		} 
	}
    return arr;
}  
/* subset Prototype하기 */
Array.prototype.subset = function(attr,val,bLike) {
	return subset(this, attr, val, bLike);
}

/* 특정컬럼을 기준으로 Sort한다. */
function sort(objarr, col) {
	if($.type(objarr) != "array") return objarr;
	objarr.sort(function(a,b) {
		if(isNum(a[col]) && isNum(b[col])) {
			if (toNum(a[col]) > toNum(b[col])) return 1;
			else if (toNum(a[col]) < toNum(b[col])) return -1;
			else return 0; 
		} else {
			if (a[col] > b[col]) return 1;
			else if (a[col] < b[col]) return -1;
			else return 0;
		}
	});
	return objarr;
}

/* 오브젝트 배열에서 특정컬럼만 추출하여 배열 만들기 */
function extract(objarr, col, distinct) {
	var rtn = new Array(); 
	if(isNull(objarr)) return rtn;
	if($.type(col)!="array") {
		for(var i=0; i < objarr.length; i++) { 
			if(!isNull(objarr[i][col])) rtn.push(objarr[i][col]);
		}  
	} else {
		for(var i=0; i < objarr.length; i++) { 
			var el = {};
			for(var j=0; j < col.length; j++) {
				var attr = col[j];
				el[attr] = objarr[i][attr]; 
			}
			rtn.push(el);
		} 
	} 
	if(distinct=="distinct") {
		var rtn2 = []; 
		for(var i=0; i < rtn.length; i++) { 
			if(inStr(rtn2,rtn[i]) < 0) {  
				if(!isNull(rtn[i])) rtn2.push(rtn[i]);  
			}
		} 
		return rtn2;
	}  
	return rtn;
} 

/* 오브젝트 배열에서 키=값 인 요소를 제거함 */
function pop(objarr, key, val) {
	for(var i=objarr.length-1; i >= 0; i--) {
		if(objarr[i][key]==val) objarr.pop(i); 
	}
}

/* 배열합,최대,최소 */
function arrayCalc(arr,gbn,remover,attr) {
	var rtn;
	if(gbn.toLowerCase()=="sum") { 
		rtn = 0;
		for (var i=0; i < arr.length; i++ ) { 
			if(attr!=undefined) {
				rtn += toNum( replace(arr[i][attr],remover,"") );	
			} else {
				rtn += toNum( replace(arr[i],remover,"") );	
			} 
		}
	} else if (gbn.toLowerCase()=="max") { 
		if(isNull(arr[0])) return;
		if(attr!=undefined) {
			rtn = isNum(replace(arr[0][attr],remover,""))?toNum(replace(arr[0][attr],remover,"")):replace(arr[0][attr],remover,"");
			for(var i = 0; i < arr.length; i++) { 
				if( rtn < replace(arr[i][attr],remover,"") ) {
					rtn = replace(arr[i][attr],remover,""); // breaking point test
				}
			}
		} else {
			rtn = isNum(replace(arr[0],remover,""))?toNum(replace(arr[0],remover,"")):replace(arr[0],remover,"");
			for(var i = 0; i < arr.length; i++) { 
				if( rtn < replace(arr[i],remover,"") ) {
					rtn = replace(arr[i],remover,""); // breaking point test
				}  
			}
		} 
	} else if (gbn.toLowerCase()=="min") { 
		if(isNull(arr[0])) return;
		if(attr!=undefined) {
			rtn = isNum(replace(arr[0][attr],remover,""))?toNum(replace(arr[0][attr],remover,"")):replace(arr[0][attr],remover,"");
			if( rtn > replace(arr[i][attr],remover,"") ) {
				rtn = replace(arr[i][attr],remover,""); // breaking point test
			}
		} else {
			rtn = isNum(replace(arr[0],remover,""))?toNum(replace(arr[0],remover,"")):replace(arr[0],remover,"");
			if( rtn > replace(arr[i],remover,"") ) {
				rtn = replace(arr[i],remover,""); // breaking point test
			} 
		}  
	}
	return rtn; 
}

/* 배열계산 */
function arrFormula(rows,sFormula) {
	try {
		var data = [];
		for(var i=0; i < rows.length; i++) {
			if(!isNull(rows[i]) && !isNull(rows[i].subsumrow)) continue;
			var row = $.extend({},rows[i]);
			for(var key in row) {
				if(isNum(row[key])) row[key] = toNum(row[key]);
			}
			data.push(row);
		}
		if(data.length==0) return null;
		var sum = function(sFormula) {  //ex: sFormula = sum('row.colid1 * row.colid2') : 두 컬럼을 곱한 값의 합
			var rtn = 0;
			for(var i=0; i < data.length; i++) {
				var row = data[i];
				rtn += eval(sFormula);
			}
			return rtn;
		}
		var avg = function(sFormula) { //ex: sFormula = avg('row.colid1') : 컬럼값의 평균
			return sum(sFormula)/data.length;
		}
		var count = function(sFormula) { //ex: sFormula = count(['colid1','colid2']) : 두 컬럼의 distinct한 count
			return extract( rows, sFormula, "distinct").length;
		}
		var countRow = function(sFormula) { //ex: sFormula = count(['colid1','colid2']) : 두 컬럼의 distinct한 count
			return data.length+"건";
		}		
		return eval(sFormula);
	} catch {
		return null;
	}
}
/** arr에서 element의 순서바꾸기 **/
function arrMove(arr, old_index, new_index) {
    if (new_index >= arr.length) {
        var k = new_index - arr.length + 1;
        while (k--) {
            arr.push(undefined);
        }
    }
    arr.splice(new_index, 0, arr.splice(old_index, 1)[0]);
    return arr; // for testing
};

/** getIndex : object array에서 column=value인 row의 index를 리턴함  */
function getIndex(arr, colid, value) {
	if($.type(arr)!='array') return -1;
	for(var i=0; i < arr.length; i++) {
		if($.type(arr[i])!='object') return -1;
		if(arr[i][colid]==value) return i;
	}
	return -1;
}

/** Object prototype **/
Object.equals = function(x, y) { 
	if (x === y) return true; // if both x and y are null or undefined and exactly the same 
	if (!(x instanceof Object) || !(y instanceof Object)) return false;  // if they are not strictly equal, they both need to be Objects 
	if (x.constructor !== y.constructor) return false; // they must have the exact same prototype chain, the closest we can do is 
	// test there constructor. 
	for (var p in x) { 
		if (!x.hasOwnProperty(p)) continue; // other properties were tested using 
		x.constructor === y.constructor 
		if (!y.hasOwnProperty(p)) return false; // allows to compare x[ p ] and y[ p ] when set to undefined 
		if (x[p] === y[p]) continue; // if they have the same strict value or identity then they are equal 
		if (typeof(x[p]) !== "object") return false; // Numbers, Strings, Functions, Booleans must be strictly equal 
		if (!Object.equals(x[p], y[p])) return false; // Objects and Arrays must be tested recursively 
	} 
	for (p in y) { 
		if (y.hasOwnProperty(p) && !x.hasOwnProperty(p)) return false; // allows x[ p ] to be set to undefined 
	} 
	return true; 
} 
//eval가능한 스트링은 eval하여 object로 리턴하고, 그렇지 않으면 스트링을 리턴 
function eval2(str) {
	var rtn = str;
	try{
		rtn = eval(str);
	} catch(e) {
		rtn = str;
	}  
	return nvl(rtn,"");
} 

/** JQuery Hack **/
//JQuery오브젝트가 selector와 같거나 selector의 children인지 체크 T/F 
$.prototype.isON = function(sel) {
	if( this.is(sel) || this.parents(sel).length > 0 ) return true;
	else return false;
}
//JQuery오브젝트가 selector와 같거나 selector의 children인 경우 parent를 리턴
$.prototype.exactObj = function(sel) {
	if( this.is(sel) ) return this;
	else if (this.parents(sel).length > 0) return $(this.parents(sel)[0]); 
	else return $("not exists"); 
}
//JQuery오브젝트가 selector와 같거나 selector의 parent인 경우 child를 리턴
$.prototype.includeObj = function(sel) {
	if( this.is(sel)) return this;
	else if(this.children(sel).length > 0) return $(this.children(sel)[0]);
	else return $("not exists");
}
//JQuery오브젝트에 바인드된 이벤트 핸들러 순서를 변경하고자 할때
$.fn.onFirst = function(name, fn) {
    this.on(name, fn);
    var handlers = $._data(this[0]).events[name.split('.')[0]]; 
    var handler = handlers.pop(); 
    handlers.splice(0, 0, handler);
};

/** Cookie **/
function setCookie(cookieName, value, exdays){
    var exdate = new Date();
    exdate.setDate(exdate.getDate() + exdays);
    var cookieValue = escape(value) + ((exdays==null) ? "" : "; expires=" + exdate.toGMTString());
    document.cookie = cookieName + "=" + cookieValue;
}
 
function deleteCookie(cookieName){
    var expireDate = new Date();
    expireDate.setDate(expireDate.getDate() - 1);
    document.cookie = cookieName + "= " + "; expires=" + expireDate.toGMTString();
}
 
function getCookie(cookieName) {
    cookieName = cookieName + '=';
    var cookieData = document.cookie;
    var start = cookieData.indexOf(cookieName);
    var cookieValue = '';
    if(start != -1){
        start += cookieName.length;
        var end = cookieData.indexOf(';', start);
        if(end == -1)end = cookieData.length;
        cookieValue = cookieData.substring(start, end);
    }
    return unescape(cookieValue);
}

/** logger **/
var bLogger = false; //로그를 표시할 것인지 Flag
var log   = "log";
var info  = "info";
var warn  = "warn";
var error = "error"; 
function logger(lv,msg,obj) {
	var lLv, lMsg, lObj;
	/* 기존에 lv없이 호출되는 건이 있기 때문에 씌워줘야함 */
	if(!(lv==log||lv==info||lv==warn||lv==error||lv==bLogger)) {
		lLv = log;
		lMsg = lv;
		lObj = msg;
	} else {
		if(lv==bLogger) lLv = log;
		else lLv = lv;
		lMsg = msg;
		lObj = obj;
	}
	/* bLogger상태가 true이거나 
		특정로그를 보기 위해서 bLogger를 lv키워드로 지정한 경우에만
		console을 표시함 */
	if(bLogger == true || bLogger == lv) {
		console.dir(logger.caller);
		console[lLv](lMsg+"***********************************");
		if(lObj!=undefined) console.table(lObj); 
	}
} 
