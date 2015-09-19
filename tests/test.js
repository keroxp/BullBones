(function (console) { "use strict";
var $estr = function() { return js_Boot.__string_rec(this,''); };
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var EReg = function(r,opt) {
	opt = opt.split("u").join("");
	this.r = new RegExp(r,opt);
};
EReg.__name__ = ["EReg"];
EReg.prototype = {
	r: null
	,match: function(s) {
		if(this.r.global) this.r.lastIndex = 0;
		this.r.m = this.r.exec(s);
		this.r.s = s;
		return this.r.m != null;
	}
	,matched: function(n) {
		if(this.r.m != null && n >= 0 && n < this.r.m.length) return this.r.m[n]; else throw new js__$Boot_HaxeError("EReg::matched");
	}
	,__class__: EReg
};
var HxOverrides = function() { };
HxOverrides.__name__ = ["HxOverrides"];
HxOverrides.cca = function(s,index) {
	var x = s.charCodeAt(index);
	if(x != x) return undefined;
	return x;
};
HxOverrides.substr = function(s,pos,len) {
	if(pos != null && pos != 0 && len != null && len < 0) return "";
	if(len == null) len = s.length;
	if(pos < 0) {
		pos = s.length + pos;
		if(pos < 0) pos = 0;
	} else if(len < 0) len = s.length + len - pos;
	return s.substr(pos,len);
};
HxOverrides.indexOf = function(a,obj,i) {
	var len = a.length;
	if(i < 0) {
		i += len;
		if(i < 0) i = 0;
	}
	while(i < len) {
		if(a[i] === obj) return i;
		i++;
	}
	return -1;
};
HxOverrides.remove = function(a,obj) {
	var i = HxOverrides.indexOf(a,obj,0);
	if(i == -1) return false;
	a.splice(i,1);
	return true;
};
var List = function() {
	this.length = 0;
};
List.__name__ = ["List"];
List.prototype = {
	h: null
	,q: null
	,length: null
	,add: function(item) {
		var x = [item];
		if(this.h == null) this.h = x; else this.q[1] = x;
		this.q = x;
		this.length++;
	}
	,__class__: List
};
Math.__name__ = ["Math"];
var Reflect = function() { };
Reflect.__name__ = ["Reflect"];
Reflect.field = function(o,field) {
	try {
		return o[field];
	} catch( e ) {
		haxe_CallStack.lastException = e;
		if (e instanceof js__$Boot_HaxeError) e = e.val;
		return null;
	}
};
Reflect.callMethod = function(o,func,args) {
	return func.apply(o,args);
};
Reflect.isFunction = function(f) {
	return typeof(f) == "function" && !(f.__name__ || f.__ename__);
};
var haxe_unit_TestCase = function() {
};
haxe_unit_TestCase.__name__ = ["haxe","unit","TestCase"];
haxe_unit_TestCase.prototype = {
	currentTest: null
	,setup: function() {
	}
	,tearDown: function() {
	}
	,print: function(v) {
		haxe_unit_TestRunner.print(v);
	}
	,assertTrue: function(b,c) {
		this.currentTest.done = true;
		if(b != true) {
			this.currentTest.success = false;
			this.currentTest.error = "expected true but was false";
			this.currentTest.posInfos = c;
			throw new js__$Boot_HaxeError(this.currentTest);
		}
	}
	,assertFalse: function(b,c) {
		this.currentTest.done = true;
		if(b == true) {
			this.currentTest.success = false;
			this.currentTest.error = "expected false but was true";
			this.currentTest.posInfos = c;
			throw new js__$Boot_HaxeError(this.currentTest);
		}
	}
	,assertEquals: function(expected,actual,c) {
		this.currentTest.done = true;
		if(actual != expected) {
			this.currentTest.success = false;
			this.currentTest.error = "expected '" + Std.string(expected) + "' but was '" + Std.string(actual) + "'";
			this.currentTest.posInfos = c;
			throw new js__$Boot_HaxeError(this.currentTest);
		}
	}
	,__class__: haxe_unit_TestCase
};
var ScalarTests = function() {
	haxe_unit_TestCase.call(this);
};
ScalarTests.__name__ = ["ScalarTests"];
ScalarTests.__super__ = haxe_unit_TestCase;
ScalarTests.prototype = $extend(haxe_unit_TestCase.prototype,{
	v: function($float) {
		return $float * util_BrowserUtil.dpr;
	}
	,setup: function() {
		util_BrowserUtil.dpr = 2;
	}
	,testBase: function() {
		var s;
		var this1;
		this1 = geometry__$Scalar_Scalar_$Impl_$.conv(2);
		s = this1;
		this.assertEquals(2 * util_BrowserUtil.dpr,s,{ fileName : "ScalarTests.hx", lineNumber : 17, className : "ScalarTests", methodName : "testBase"});
		var this2;
		this2 = geometry__$Scalar_Scalar_$Impl_$.conv(3);
		s = this2;
		this.assertEquals(3 * util_BrowserUtil.dpr,s,{ fileName : "ScalarTests.hx", lineNumber : 19, className : "ScalarTests", methodName : "testBase"});
		var this3;
		this3 = geometry__$Scalar_Scalar_$Impl_$.conv(-100);
		s = this3;
		this.assertEquals(-100 * util_BrowserUtil.dpr,s,{ fileName : "ScalarTests.hx", lineNumber : 21, className : "ScalarTests", methodName : "testBase"});
		var this4;
		this4 = geometry__$Scalar_Scalar_$Impl_$.conv(0.1);
		s = this4;
		this.assertEquals(0.1 * util_BrowserUtil.dpr,s,{ fileName : "ScalarTests.hx", lineNumber : 23, className : "ScalarTests", methodName : "testBase"});
	}
	,testAdd: function() {
		var _g = this;
		var s;
		var this1;
		this1 = geometry__$Scalar_Scalar_$Impl_$.conv(2);
		s = this1;
		var t;
		var this2;
		this2 = geometry__$Scalar_Scalar_$Impl_$.conv(2);
		t = this2;
		var e = 4 * util_BrowserUtil.dpr;
		_g.assertEquals(e,(function($this) {
			var $r;
			var this3 = geometry__$Scalar_Scalar_$Impl_$.addf(s,2);
			$r = this3;
			return $r;
		}(this)),{ fileName : "ScalarTests.hx", lineNumber : 31, className : "ScalarTests", methodName : "testAdd"});
		_g.assertEquals(e,(function($this) {
			var $r;
			var this4 = geometry__$Scalar_Scalar_$Impl_$.add(s,t);
			$r = this4;
			return $r;
		}(this)),{ fileName : "ScalarTests.hx", lineNumber : 32, className : "ScalarTests", methodName : "testAdd"});
		_g.assertEquals(e,(function($this) {
			var $r;
			var this5 = geometry__$Scalar_Scalar_$Impl_$.add(t,s);
			$r = this5;
			return $r;
		}(this)),{ fileName : "ScalarTests.hx", lineNumber : 33, className : "ScalarTests", methodName : "testAdd"});
		var s1;
		var this6;
		this6 = geometry__$Scalar_Scalar_$Impl_$.conv(-10);
		s1 = this6;
		var t1;
		var this7;
		this7 = geometry__$Scalar_Scalar_$Impl_$.conv(5);
		t1 = this7;
		var e1 = -5 * util_BrowserUtil.dpr;
		_g.assertEquals(e1,(function($this) {
			var $r;
			var this8 = geometry__$Scalar_Scalar_$Impl_$.addf(s1,5);
			$r = this8;
			return $r;
		}(this)),{ fileName : "ScalarTests.hx", lineNumber : 31, className : "ScalarTests", methodName : "testAdd"});
		_g.assertEquals(e1,(function($this) {
			var $r;
			var this9 = geometry__$Scalar_Scalar_$Impl_$.add(s1,t1);
			$r = this9;
			return $r;
		}(this)),{ fileName : "ScalarTests.hx", lineNumber : 32, className : "ScalarTests", methodName : "testAdd"});
		_g.assertEquals(e1,(function($this) {
			var $r;
			var this10 = geometry__$Scalar_Scalar_$Impl_$.add(t1,s1);
			$r = this10;
			return $r;
		}(this)),{ fileName : "ScalarTests.hx", lineNumber : 33, className : "ScalarTests", methodName : "testAdd"});
		var s2;
		var this11;
		this11 = geometry__$Scalar_Scalar_$Impl_$.conv(0.3);
		s2 = this11;
		var t2;
		var this12;
		this12 = geometry__$Scalar_Scalar_$Impl_$.conv(0.11);
		t2 = this12;
		var e2 = 0.41 * util_BrowserUtil.dpr;
		_g.assertEquals(e2,(function($this) {
			var $r;
			var this13 = geometry__$Scalar_Scalar_$Impl_$.addf(s2,0.11);
			$r = this13;
			return $r;
		}(this)),{ fileName : "ScalarTests.hx", lineNumber : 31, className : "ScalarTests", methodName : "testAdd"});
		_g.assertEquals(e2,(function($this) {
			var $r;
			var this14 = geometry__$Scalar_Scalar_$Impl_$.add(s2,t2);
			$r = this14;
			return $r;
		}(this)),{ fileName : "ScalarTests.hx", lineNumber : 32, className : "ScalarTests", methodName : "testAdd"});
		_g.assertEquals(e2,(function($this) {
			var $r;
			var this15 = geometry__$Scalar_Scalar_$Impl_$.add(t2,s2);
			$r = this15;
			return $r;
		}(this)),{ fileName : "ScalarTests.hx", lineNumber : 33, className : "ScalarTests", methodName : "testAdd"});
	}
	,testSub: function() {
		var _g = this;
		var s;
		var this1;
		this1 = geometry__$Scalar_Scalar_$Impl_$.conv(2);
		s = this1;
		var t;
		var this2;
		this2 = geometry__$Scalar_Scalar_$Impl_$.conv(2);
		t = this2;
		_g.assertEquals(0 * util_BrowserUtil.dpr,(function($this) {
			var $r;
			var this3 = geometry__$Scalar_Scalar_$Impl_$.subf(s,2);
			$r = this3;
			return $r;
		}(this)),{ fileName : "ScalarTests.hx", lineNumber : 44, className : "ScalarTests", methodName : "testSub"});
		_g.assertEquals(0 * util_BrowserUtil.dpr,(function($this) {
			var $r;
			var this4 = geometry__$Scalar_Scalar_$Impl_$.sub(s,t);
			$r = this4;
			return $r;
		}(this)),{ fileName : "ScalarTests.hx", lineNumber : 45, className : "ScalarTests", methodName : "testSub"});
		_g.assertEquals(0 * util_BrowserUtil.dpr,(function($this) {
			var $r;
			var this5 = geometry__$Scalar_Scalar_$Impl_$.sub(t,s);
			$r = this5;
			return $r;
		}(this)),{ fileName : "ScalarTests.hx", lineNumber : 46, className : "ScalarTests", methodName : "testSub"});
		var s1;
		var this6;
		this6 = geometry__$Scalar_Scalar_$Impl_$.conv(-10);
		s1 = this6;
		var t1;
		var this7;
		this7 = geometry__$Scalar_Scalar_$Impl_$.conv(5);
		t1 = this7;
		_g.assertEquals(-15 * util_BrowserUtil.dpr,(function($this) {
			var $r;
			var this8 = geometry__$Scalar_Scalar_$Impl_$.subf(s1,5);
			$r = this8;
			return $r;
		}(this)),{ fileName : "ScalarTests.hx", lineNumber : 44, className : "ScalarTests", methodName : "testSub"});
		_g.assertEquals(-15 * util_BrowserUtil.dpr,(function($this) {
			var $r;
			var this9 = geometry__$Scalar_Scalar_$Impl_$.sub(s1,t1);
			$r = this9;
			return $r;
		}(this)),{ fileName : "ScalarTests.hx", lineNumber : 45, className : "ScalarTests", methodName : "testSub"});
		_g.assertEquals(15 * util_BrowserUtil.dpr,(function($this) {
			var $r;
			var this10 = geometry__$Scalar_Scalar_$Impl_$.sub(t1,s1);
			$r = this10;
			return $r;
		}(this)),{ fileName : "ScalarTests.hx", lineNumber : 46, className : "ScalarTests", methodName : "testSub"});
		var s2;
		var this11;
		this11 = geometry__$Scalar_Scalar_$Impl_$.conv(0.3);
		s2 = this11;
		var t2;
		var this12;
		this12 = geometry__$Scalar_Scalar_$Impl_$.conv(0.11);
		t2 = this12;
		_g.assertEquals(0.19 * util_BrowserUtil.dpr,(function($this) {
			var $r;
			var this13 = geometry__$Scalar_Scalar_$Impl_$.subf(s2,0.11);
			$r = this13;
			return $r;
		}(this)),{ fileName : "ScalarTests.hx", lineNumber : 44, className : "ScalarTests", methodName : "testSub"});
		_g.assertEquals(0.19 * util_BrowserUtil.dpr,(function($this) {
			var $r;
			var this14 = geometry__$Scalar_Scalar_$Impl_$.sub(s2,t2);
			$r = this14;
			return $r;
		}(this)),{ fileName : "ScalarTests.hx", lineNumber : 45, className : "ScalarTests", methodName : "testSub"});
		_g.assertEquals(-0.19 * util_BrowserUtil.dpr,(function($this) {
			var $r;
			var this15 = geometry__$Scalar_Scalar_$Impl_$.sub(t2,s2);
			$r = this15;
			return $r;
		}(this)),{ fileName : "ScalarTests.hx", lineNumber : 46, className : "ScalarTests", methodName : "testSub"});
	}
	,testMul: function() {
		var _g = this;
		var s;
		var this1;
		this1 = geometry__$Scalar_Scalar_$Impl_$.conv(2);
		s = this1;
		var t;
		var this2;
		this2 = geometry__$Scalar_Scalar_$Impl_$.conv(2);
		t = this2;
		_g.assertEquals(4 * util_BrowserUtil.dpr,s * 2,{ fileName : "ScalarTests.hx", lineNumber : 57, className : "ScalarTests", methodName : "testMul"});
		_g.assertEquals(2 * util_BrowserUtil.dpr * (2 * util_BrowserUtil.dpr),(function($this) {
			var $r;
			var this3 = geometry__$Scalar_Scalar_$Impl_$.mul(s,t);
			$r = this3;
			return $r;
		}(this)),{ fileName : "ScalarTests.hx", lineNumber : 58, className : "ScalarTests", methodName : "testMul"});
		_g.assertEquals(2 * util_BrowserUtil.dpr * (2 * util_BrowserUtil.dpr),(function($this) {
			var $r;
			var this4 = geometry__$Scalar_Scalar_$Impl_$.mul(t,s);
			$r = this4;
			return $r;
		}(this)),{ fileName : "ScalarTests.hx", lineNumber : 59, className : "ScalarTests", methodName : "testMul"});
		var s1;
		var this5;
		this5 = geometry__$Scalar_Scalar_$Impl_$.conv(-10);
		s1 = this5;
		var t1;
		var this6;
		this6 = geometry__$Scalar_Scalar_$Impl_$.conv(5);
		t1 = this6;
		_g.assertEquals(-50 * util_BrowserUtil.dpr,s1 * 5,{ fileName : "ScalarTests.hx", lineNumber : 57, className : "ScalarTests", methodName : "testMul"});
		_g.assertEquals(-10 * util_BrowserUtil.dpr * (5 * util_BrowserUtil.dpr),(function($this) {
			var $r;
			var this7 = geometry__$Scalar_Scalar_$Impl_$.mul(s1,t1);
			$r = this7;
			return $r;
		}(this)),{ fileName : "ScalarTests.hx", lineNumber : 58, className : "ScalarTests", methodName : "testMul"});
		_g.assertEquals(5 * util_BrowserUtil.dpr * (-10 * util_BrowserUtil.dpr),(function($this) {
			var $r;
			var this8 = geometry__$Scalar_Scalar_$Impl_$.mul(t1,s1);
			$r = this8;
			return $r;
		}(this)),{ fileName : "ScalarTests.hx", lineNumber : 59, className : "ScalarTests", methodName : "testMul"});
		var s2;
		var this9;
		this9 = geometry__$Scalar_Scalar_$Impl_$.conv(4.5);
		s2 = this9;
		var t2;
		var this10;
		this10 = geometry__$Scalar_Scalar_$Impl_$.conv(2.3);
		t2 = this10;
		_g.assertEquals(10.35 * util_BrowserUtil.dpr,s2 * 2.3,{ fileName : "ScalarTests.hx", lineNumber : 57, className : "ScalarTests", methodName : "testMul"});
		_g.assertEquals(4.5 * util_BrowserUtil.dpr * (2.3 * util_BrowserUtil.dpr),(function($this) {
			var $r;
			var this11 = geometry__$Scalar_Scalar_$Impl_$.mul(s2,t2);
			$r = this11;
			return $r;
		}(this)),{ fileName : "ScalarTests.hx", lineNumber : 58, className : "ScalarTests", methodName : "testMul"});
		_g.assertEquals(2.3 * util_BrowserUtil.dpr * (4.5 * util_BrowserUtil.dpr),(function($this) {
			var $r;
			var this12 = geometry__$Scalar_Scalar_$Impl_$.mul(t2,s2);
			$r = this12;
			return $r;
		}(this)),{ fileName : "ScalarTests.hx", lineNumber : 59, className : "ScalarTests", methodName : "testMul"});
	}
	,testDiv: function() {
		var _g = this;
		var s;
		var this1;
		this1 = geometry__$Scalar_Scalar_$Impl_$.conv(2);
		s = this1;
		var t;
		var this2;
		this2 = geometry__$Scalar_Scalar_$Impl_$.conv(2);
		t = this2;
		_g.assertEquals(util_BrowserUtil.dpr,s / 2,{ fileName : "ScalarTests.hx", lineNumber : 70, className : "ScalarTests", methodName : "testDiv"});
		_g.assertEquals(2 * util_BrowserUtil.dpr / (2 * util_BrowserUtil.dpr),(function($this) {
			var $r;
			var this3 = geometry__$Scalar_Scalar_$Impl_$.div(s,t);
			$r = this3;
			return $r;
		}(this)),{ fileName : "ScalarTests.hx", lineNumber : 71, className : "ScalarTests", methodName : "testDiv"});
		_g.assertEquals(2 * util_BrowserUtil.dpr / (2 * util_BrowserUtil.dpr),(function($this) {
			var $r;
			var this4 = geometry__$Scalar_Scalar_$Impl_$.div(t,s);
			$r = this4;
			return $r;
		}(this)),{ fileName : "ScalarTests.hx", lineNumber : 72, className : "ScalarTests", methodName : "testDiv"});
		var s1;
		var this5;
		this5 = geometry__$Scalar_Scalar_$Impl_$.conv(-10);
		s1 = this5;
		var t1;
		var this6;
		this6 = geometry__$Scalar_Scalar_$Impl_$.conv(5);
		t1 = this6;
		_g.assertEquals(-2. * util_BrowserUtil.dpr,s1 / 5,{ fileName : "ScalarTests.hx", lineNumber : 70, className : "ScalarTests", methodName : "testDiv"});
		_g.assertEquals(-10 * util_BrowserUtil.dpr / (5 * util_BrowserUtil.dpr),(function($this) {
			var $r;
			var this7 = geometry__$Scalar_Scalar_$Impl_$.div(s1,t1);
			$r = this7;
			return $r;
		}(this)),{ fileName : "ScalarTests.hx", lineNumber : 71, className : "ScalarTests", methodName : "testDiv"});
		_g.assertEquals(5 * util_BrowserUtil.dpr / (-10 * util_BrowserUtil.dpr),(function($this) {
			var $r;
			var this8 = geometry__$Scalar_Scalar_$Impl_$.div(t1,s1);
			$r = this8;
			return $r;
		}(this)),{ fileName : "ScalarTests.hx", lineNumber : 72, className : "ScalarTests", methodName : "testDiv"});
		var s2;
		var this9;
		this9 = geometry__$Scalar_Scalar_$Impl_$.conv(4.5);
		s2 = this9;
		var t2;
		var this10;
		this10 = geometry__$Scalar_Scalar_$Impl_$.conv(2.3);
		t2 = this10;
		_g.assertEquals(1.95652173913043503 * util_BrowserUtil.dpr,s2 / 2.3,{ fileName : "ScalarTests.hx", lineNumber : 70, className : "ScalarTests", methodName : "testDiv"});
		_g.assertEquals(4.5 * util_BrowserUtil.dpr / (2.3 * util_BrowserUtil.dpr),(function($this) {
			var $r;
			var this11 = geometry__$Scalar_Scalar_$Impl_$.div(s2,t2);
			$r = this11;
			return $r;
		}(this)),{ fileName : "ScalarTests.hx", lineNumber : 71, className : "ScalarTests", methodName : "testDiv"});
		_g.assertEquals(2.3 * util_BrowserUtil.dpr / (4.5 * util_BrowserUtil.dpr),(function($this) {
			var $r;
			var this12 = geometry__$Scalar_Scalar_$Impl_$.div(t2,s2);
			$r = this12;
			return $r;
		}(this)),{ fileName : "ScalarTests.hx", lineNumber : 72, className : "ScalarTests", methodName : "testDiv"});
	}
	,__class__: ScalarTests
});
var Std = function() { };
Std.__name__ = ["Std"];
Std.string = function(s) {
	return js_Boot.__string_rec(s,"");
};
Std.parseInt = function(x) {
	var v = parseInt(x,10);
	if(v == 0 && (HxOverrides.cca(x,1) == 120 || HxOverrides.cca(x,1) == 88)) v = parseInt(x);
	if(isNaN(v)) return null;
	return v;
};
var StringBuf = function() {
	this.b = "";
};
StringBuf.__name__ = ["StringBuf"];
StringBuf.prototype = {
	b: null
	,__class__: StringBuf
};
var StringTools = function() { };
StringTools.__name__ = ["StringTools"];
StringTools.htmlEscape = function(s,quotes) {
	s = s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
	if(quotes) return s.split("\"").join("&quot;").split("'").join("&#039;"); else return s;
};
StringTools.startsWith = function(s,start) {
	return s.length >= start.length && HxOverrides.substr(s,0,start.length) == start;
};
StringTools.isSpace = function(s,pos) {
	var c = HxOverrides.cca(s,pos);
	return c > 8 && c < 14 || c == 32;
};
StringTools.ltrim = function(s) {
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,r)) r++;
	if(r > 0) return HxOverrides.substr(s,r,l - r); else return s;
};
StringTools.rtrim = function(s) {
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,l - r - 1)) r++;
	if(r > 0) return HxOverrides.substr(s,0,l - r); else return s;
};
StringTools.trim = function(s) {
	return StringTools.ltrim(StringTools.rtrim(s));
};
var TestMain = function() { };
TestMain.__name__ = ["TestMain"];
TestMain.main = function() {
	var r = new haxe_unit_TestRunner();
	r.add(new ScalarTests());
	r.run();
};
var Type = function() { };
Type.__name__ = ["Type"];
Type.getClassName = function(c) {
	var a = c.__name__;
	if(a == null) return null;
	return a.join(".");
};
Type.getInstanceFields = function(c) {
	var a = [];
	for(var i in c.prototype) a.push(i);
	HxOverrides.remove(a,"__class__");
	HxOverrides.remove(a,"__properties__");
	return a;
};
var geometry__$Scalar_Scalar_$Impl_$ = {};
geometry__$Scalar_Scalar_$Impl_$.__name__ = ["geometry","_Scalar","Scalar_Impl_"];
geometry__$Scalar_Scalar_$Impl_$.valueOf = function($float) {
	var this1;
	this1 = geometry__$Scalar_Scalar_$Impl_$.conv($float);
	return this1;
};
geometry__$Scalar_Scalar_$Impl_$._new = function(value,scale) {
	if(scale == null) scale = true;
	var this1;
	if(scale) this1 = geometry__$Scalar_Scalar_$Impl_$.conv(value); else this1 = value;
	return this1;
};
geometry__$Scalar_Scalar_$Impl_$.conv = function(value) {
	return value * util_BrowserUtil.dpr;
};
geometry__$Scalar_Scalar_$Impl_$.toFloat = function(this1) {
	return this1;
};
geometry__$Scalar_Scalar_$Impl_$.toInt = function(this1) {
	return this1 | 0;
};
geometry__$Scalar_Scalar_$Impl_$.toScalar = function(this1) {
	var value = this1;
	var this2;
	this2 = value;
	return this2;
};
geometry__$Scalar_Scalar_$Impl_$.add = function(lhd,rhd) {
	var value = lhd + rhd;
	var this1;
	this1 = value;
	return this1;
};
geometry__$Scalar_Scalar_$Impl_$.sub = function(lhd,rhd) {
	var value = lhd - rhd;
	var this1;
	this1 = value;
	return this1;
};
geometry__$Scalar_Scalar_$Impl_$.mul = function(lhd,rhd) {
	var value = lhd * rhd;
	var this1;
	this1 = value;
	return this1;
};
geometry__$Scalar_Scalar_$Impl_$.div = function(lhd,rhd) {
	var value = lhd / rhd;
	var this1;
	this1 = value;
	return this1;
};
geometry__$Scalar_Scalar_$Impl_$.addf = function(this1,rhd) {
	var value = this1 + geometry__$Scalar_Scalar_$Impl_$.conv(rhd);
	var this2;
	this2 = value;
	return this2;
};
geometry__$Scalar_Scalar_$Impl_$.subf = function(this1,rhd) {
	var value = this1 - geometry__$Scalar_Scalar_$Impl_$.conv(rhd);
	var this2;
	this2 = value;
	return this2;
};
var haxe_StackItem = { __ename__ : true, __constructs__ : ["CFunction","Module","FilePos","Method","LocalFunction"] };
haxe_StackItem.CFunction = ["CFunction",0];
haxe_StackItem.CFunction.toString = $estr;
haxe_StackItem.CFunction.__enum__ = haxe_StackItem;
haxe_StackItem.Module = function(m) { var $x = ["Module",1,m]; $x.__enum__ = haxe_StackItem; $x.toString = $estr; return $x; };
haxe_StackItem.FilePos = function(s,file,line) { var $x = ["FilePos",2,s,file,line]; $x.__enum__ = haxe_StackItem; $x.toString = $estr; return $x; };
haxe_StackItem.Method = function(classname,method) { var $x = ["Method",3,classname,method]; $x.__enum__ = haxe_StackItem; $x.toString = $estr; return $x; };
haxe_StackItem.LocalFunction = function(v) { var $x = ["LocalFunction",4,v]; $x.__enum__ = haxe_StackItem; $x.toString = $estr; return $x; };
var haxe_CallStack = function() { };
haxe_CallStack.__name__ = ["haxe","CallStack"];
haxe_CallStack.getStack = function(e) {
	if(e == null) return [];
	var oldValue = Error.prepareStackTrace;
	Error.prepareStackTrace = function(error,callsites) {
		var stack = [];
		var _g = 0;
		while(_g < callsites.length) {
			var site = callsites[_g];
			++_g;
			if(haxe_CallStack.wrapCallSite != null) site = haxe_CallStack.wrapCallSite(site);
			var method = null;
			var fullName = site.getFunctionName();
			if(fullName != null) {
				var idx = fullName.lastIndexOf(".");
				if(idx >= 0) {
					var className = HxOverrides.substr(fullName,0,idx);
					var methodName = HxOverrides.substr(fullName,idx + 1,null);
					method = haxe_StackItem.Method(className,methodName);
				}
			}
			stack.push(haxe_StackItem.FilePos(method,site.getFileName(),site.getLineNumber()));
		}
		return stack;
	};
	var a = haxe_CallStack.makeStack(e.stack);
	Error.prepareStackTrace = oldValue;
	return a;
};
haxe_CallStack.exceptionStack = function() {
	return haxe_CallStack.getStack(haxe_CallStack.lastException);
};
haxe_CallStack.toString = function(stack) {
	var b = new StringBuf();
	var _g = 0;
	while(_g < stack.length) {
		var s = stack[_g];
		++_g;
		b.b += "\nCalled from ";
		haxe_CallStack.itemToString(b,s);
	}
	return b.b;
};
haxe_CallStack.itemToString = function(b,s) {
	switch(s[1]) {
	case 0:
		b.b += "a C function";
		break;
	case 1:
		var m = s[2];
		b.b += "module ";
		if(m == null) b.b += "null"; else b.b += "" + m;
		break;
	case 2:
		var line = s[4];
		var file = s[3];
		var s1 = s[2];
		if(s1 != null) {
			haxe_CallStack.itemToString(b,s1);
			b.b += " (";
		}
		if(file == null) b.b += "null"; else b.b += "" + file;
		b.b += " line ";
		if(line == null) b.b += "null"; else b.b += "" + line;
		if(s1 != null) b.b += ")";
		break;
	case 3:
		var meth = s[3];
		var cname = s[2];
		if(cname == null) b.b += "null"; else b.b += "" + cname;
		b.b += ".";
		if(meth == null) b.b += "null"; else b.b += "" + meth;
		break;
	case 4:
		var n = s[2];
		b.b += "local function #";
		if(n == null) b.b += "null"; else b.b += "" + n;
		break;
	}
};
haxe_CallStack.makeStack = function(s) {
	if(s == null) return []; else if(typeof(s) == "string") {
		var stack = s.split("\n");
		if(stack[0] == "Error") stack.shift();
		var m = [];
		var rie10 = new EReg("^   at ([A-Za-z0-9_. ]+) \\(([^)]+):([0-9]+):([0-9]+)\\)$","");
		var _g = 0;
		while(_g < stack.length) {
			var line = stack[_g];
			++_g;
			if(rie10.match(line)) {
				var path = rie10.matched(1).split(".");
				var meth = path.pop();
				var file = rie10.matched(2);
				var line1 = Std.parseInt(rie10.matched(3));
				m.push(haxe_StackItem.FilePos(meth == "Anonymous function"?haxe_StackItem.LocalFunction():meth == "Global code"?null:haxe_StackItem.Method(path.join("."),meth),file,line1));
			} else m.push(haxe_StackItem.Module(StringTools.trim(line)));
		}
		return m;
	} else return s;
};
var haxe_Log = function() { };
haxe_Log.__name__ = ["haxe","Log"];
haxe_Log.trace = function(v,infos) {
	js_Boot.__trace(v,infos);
};
var haxe_unit_TestResult = function() {
	this.m_tests = new List();
	this.success = true;
};
haxe_unit_TestResult.__name__ = ["haxe","unit","TestResult"];
haxe_unit_TestResult.prototype = {
	m_tests: null
	,success: null
	,add: function(t) {
		this.m_tests.add(t);
		if(!t.success) this.success = false;
	}
	,toString: function() {
		var buf_b = "";
		var failures = 0;
		var _g_head = this.m_tests.h;
		var _g_val = null;
		while(_g_head != null) {
			var test;
			test = (function($this) {
				var $r;
				_g_val = _g_head[0];
				_g_head = _g_head[1];
				$r = _g_val;
				return $r;
			}(this));
			if(test.success == false) {
				buf_b += "* ";
				if(test.classname == null) buf_b += "null"; else buf_b += "" + test.classname;
				buf_b += "::";
				if(test.method == null) buf_b += "null"; else buf_b += "" + test.method;
				buf_b += "()";
				buf_b += "\n";
				buf_b += "ERR: ";
				if(test.posInfos != null) {
					buf_b += Std.string(test.posInfos.fileName);
					buf_b += ":";
					buf_b += Std.string(test.posInfos.lineNumber);
					buf_b += "(";
					buf_b += Std.string(test.posInfos.className);
					buf_b += ".";
					buf_b += Std.string(test.posInfos.methodName);
					buf_b += ") - ";
				}
				if(test.error == null) buf_b += "null"; else buf_b += "" + test.error;
				buf_b += "\n";
				if(test.backtrace != null) {
					if(test.backtrace == null) buf_b += "null"; else buf_b += "" + test.backtrace;
					buf_b += "\n";
				}
				buf_b += "\n";
				failures++;
			}
		}
		buf_b += "\n";
		if(failures == 0) buf_b += "OK "; else buf_b += "FAILED ";
		buf_b += Std.string(this.m_tests.length);
		buf_b += " tests, ";
		if(failures == null) buf_b += "null"; else buf_b += "" + failures;
		buf_b += " failed, ";
		buf_b += Std.string(this.m_tests.length - failures);
		buf_b += " success";
		buf_b += "\n";
		return buf_b;
	}
	,__class__: haxe_unit_TestResult
};
var haxe_unit_TestRunner = function() {
	this.result = new haxe_unit_TestResult();
	this.cases = new List();
};
haxe_unit_TestRunner.__name__ = ["haxe","unit","TestRunner"];
haxe_unit_TestRunner.print = function(v) {
	var msg = js_Boot.__string_rec(v,"");
	var d;
	if(typeof(document) != "undefined" && (d = document.getElementById("haxe:trace")) != null) {
		msg = StringTools.htmlEscape(msg).split("\n").join("<br/>");
		d.innerHTML += msg + "<br/>";
	} else if(typeof process != "undefined" && process.stdout != null && process.stdout.write != null) process.stdout.write(msg); else if(typeof console != "undefined" && console.log != null) console.log(msg);
};
haxe_unit_TestRunner.customTrace = function(v,p) {
	haxe_unit_TestRunner.print(p.fileName + ":" + p.lineNumber + ": " + Std.string(v) + "\n");
};
haxe_unit_TestRunner.prototype = {
	result: null
	,cases: null
	,add: function(c) {
		this.cases.add(c);
	}
	,run: function() {
		this.result = new haxe_unit_TestResult();
		var _g_head = this.cases.h;
		var _g_val = null;
		while(_g_head != null) {
			var c;
			c = (function($this) {
				var $r;
				_g_val = _g_head[0];
				_g_head = _g_head[1];
				$r = _g_val;
				return $r;
			}(this));
			this.runCase(c);
		}
		haxe_unit_TestRunner.print(this.result.toString());
		return this.result.success;
	}
	,runCase: function(t) {
		var old = haxe_Log.trace;
		haxe_Log.trace = haxe_unit_TestRunner.customTrace;
		var cl;
		if(t == null) cl = null; else cl = js_Boot.getClass(t);
		var fields = Type.getInstanceFields(cl);
		haxe_unit_TestRunner.print("Class: " + Type.getClassName(cl) + " ");
		var _g = 0;
		while(_g < fields.length) {
			var f = fields[_g];
			++_g;
			var fname = f;
			var field = Reflect.field(t,f);
			if(StringTools.startsWith(fname,"test") && Reflect.isFunction(field)) {
				t.currentTest = new haxe_unit_TestStatus();
				t.currentTest.classname = Type.getClassName(cl);
				t.currentTest.method = fname;
				t.setup();
				try {
					Reflect.callMethod(t,field,[]);
					if(t.currentTest.done) {
						t.currentTest.success = true;
						haxe_unit_TestRunner.print(".");
					} else {
						t.currentTest.success = false;
						t.currentTest.error = "(warning) no assert";
						haxe_unit_TestRunner.print("W");
					}
				} catch( $e0 ) {
					haxe_CallStack.lastException = $e0;
					if ($e0 instanceof js__$Boot_HaxeError) $e0 = $e0.val;
					if( js_Boot.__instanceof($e0,haxe_unit_TestStatus) ) {
						var e = $e0;
						haxe_unit_TestRunner.print("F");
						t.currentTest.backtrace = haxe_CallStack.toString(haxe_CallStack.exceptionStack());
					} else {
					var e1 = $e0;
					haxe_unit_TestRunner.print("E");
					if(e1.message != null) t.currentTest.error = "exception thrown : " + Std.string(e1) + " [" + Std.string(e1.message) + "]"; else t.currentTest.error = "exception thrown : " + Std.string(e1);
					t.currentTest.backtrace = haxe_CallStack.toString(haxe_CallStack.exceptionStack());
					}
				}
				this.result.add(t.currentTest);
				t.tearDown();
			}
		}
		haxe_unit_TestRunner.print("\n");
		haxe_Log.trace = old;
	}
	,__class__: haxe_unit_TestRunner
};
var haxe_unit_TestStatus = function() {
	this.done = false;
	this.success = false;
};
haxe_unit_TestStatus.__name__ = ["haxe","unit","TestStatus"];
haxe_unit_TestStatus.prototype = {
	done: null
	,success: null
	,error: null
	,method: null
	,classname: null
	,posInfos: null
	,backtrace: null
	,__class__: haxe_unit_TestStatus
};
var js__$Boot_HaxeError = function(val) {
	Error.call(this);
	this.val = val;
	this.message = String(val);
	if(Error.captureStackTrace) Error.captureStackTrace(this,js__$Boot_HaxeError);
};
js__$Boot_HaxeError.__name__ = ["js","_Boot","HaxeError"];
js__$Boot_HaxeError.__super__ = Error;
js__$Boot_HaxeError.prototype = $extend(Error.prototype,{
	val: null
	,__class__: js__$Boot_HaxeError
});
var js_Boot = function() { };
js_Boot.__name__ = ["js","Boot"];
js_Boot.__unhtml = function(s) {
	return s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
};
js_Boot.__trace = function(v,i) {
	var msg;
	if(i != null) msg = i.fileName + ":" + i.lineNumber + ": "; else msg = "";
	msg += js_Boot.__string_rec(v,"");
	if(i != null && i.customParams != null) {
		var _g = 0;
		var _g1 = i.customParams;
		while(_g < _g1.length) {
			var v1 = _g1[_g];
			++_g;
			msg += "," + js_Boot.__string_rec(v1,"");
		}
	}
	var d;
	if(typeof(document) != "undefined" && (d = document.getElementById("haxe:trace")) != null) d.innerHTML += js_Boot.__unhtml(msg) + "<br/>"; else if(typeof console != "undefined" && console.log != null) console.log(msg);
};
js_Boot.getClass = function(o) {
	if((o instanceof Array) && o.__enum__ == null) return Array; else {
		var cl = o.__class__;
		if(cl != null) return cl;
		var name = js_Boot.__nativeClassName(o);
		if(name != null) return js_Boot.__resolveNativeClass(name);
		return null;
	}
};
js_Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) return o[0];
				var str2 = o[0] + "(";
				s += "\t";
				var _g1 = 2;
				var _g = o.length;
				while(_g1 < _g) {
					var i1 = _g1++;
					if(i1 != 2) str2 += "," + js_Boot.__string_rec(o[i1],s); else str2 += js_Boot.__string_rec(o[i1],s);
				}
				return str2 + ")";
			}
			var l = o.length;
			var i;
			var str1 = "[";
			s += "\t";
			var _g2 = 0;
			while(_g2 < l) {
				var i2 = _g2++;
				str1 += (i2 > 0?",":"") + js_Boot.__string_rec(o[i2],s);
			}
			str1 += "]";
			return str1;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			haxe_CallStack.lastException = e;
			if (e instanceof js__$Boot_HaxeError) e = e.val;
			return "???";
		}
		if(tostr != null && tostr != Object.toString && typeof(tostr) == "function") {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) {
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str.length != 2) str += ", \n";
		str += s + k + " : " + js_Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		return str;
	case "function":
		return "<function>";
	case "string":
		return o;
	default:
		return String(o);
	}
};
js_Boot.__interfLoop = function(cc,cl) {
	if(cc == null) return false;
	if(cc == cl) return true;
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0;
		var _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js_Boot.__interfLoop(i1,cl)) return true;
		}
	}
	return js_Boot.__interfLoop(cc.__super__,cl);
};
js_Boot.__instanceof = function(o,cl) {
	if(cl == null) return false;
	switch(cl) {
	case Int:
		return (o|0) === o;
	case Float:
		return typeof(o) == "number";
	case Bool:
		return typeof(o) == "boolean";
	case String:
		return typeof(o) == "string";
	case Array:
		return (o instanceof Array) && o.__enum__ == null;
	case Dynamic:
		return true;
	default:
		if(o != null) {
			if(typeof(cl) == "function") {
				if(o instanceof cl) return true;
				if(js_Boot.__interfLoop(js_Boot.getClass(o),cl)) return true;
			} else if(typeof(cl) == "object" && js_Boot.__isNativeObj(cl)) {
				if(o instanceof cl) return true;
			}
		} else return false;
		if(cl == Class && o.__name__ != null) return true;
		if(cl == Enum && o.__ename__ != null) return true;
		return o.__enum__ == cl;
	}
};
js_Boot.__nativeClassName = function(o) {
	var name = js_Boot.__toStr.call(o).slice(8,-1);
	if(name == "Object" || name == "Function" || name == "Math" || name == "JSON") return null;
	return name;
};
js_Boot.__isNativeObj = function(o) {
	return js_Boot.__nativeClassName(o) != null;
};
js_Boot.__resolveNativeClass = function(name) {
	return (Function("return typeof " + name + " != \"undefined\" ? " + name + " : null"))();
};
var util_BrowserUtil = function() { };
util_BrowserUtil.__name__ = ["util","BrowserUtil"];
util_BrowserUtil.ua = function() {
	return util_BrowserUtil.window.navigator.userAgent.toLowerCase();
};
util_BrowserUtil.isMobile = function() {
	return !util_BrowserUtil.isBrowser();
};
util_BrowserUtil.isBrowser = function() {
	return !util_BrowserUtil.isMobilePhone() && !util_BrowserUtil.isTablet();
};
util_BrowserUtil.isMobilePhone = function() {
	var u = util_BrowserUtil.ua();
	return u.indexOf("windows") != -1 && u.indexOf("phone") != -1 || u.indexOf("iphone") != -1 || u.indexOf("ipod") != -1 || u.indexOf("android") != -1 && u.indexOf("mobile") != -1 || u.indexOf("firefox") != -1 && u.indexOf("mobile") != -1 || u.indexOf("blackberry") != -1;
};
util_BrowserUtil.isTablet = function() {
	var u = util_BrowserUtil.ua();
	return u.indexOf("windows") != -1 && u.indexOf("touch") != -1 || u.indexOf("ipad") != -1 || u.indexOf("android") != -1 && u.indexOf("mobile") == -1 || u.indexOf("firefox") != -1 && u.indexOf("tablet") != -1 || u.indexOf("kindle") != -1 || u.indexOf("silk") != -1 || u.indexOf("playbook") != -1;
};
util_BrowserUtil.isFireFox = function() {
	return util_BrowserUtil.ua().indexOf("firefox") > -1;
};
util_BrowserUtil.isWebKit = function() {
	return util_BrowserUtil.ua().indexOf("webkit") > -1;
};
util_BrowserUtil.grabCursor = function() {
	if(util_BrowserUtil.isFireFox()) return "-moz-grab";
	if(util_BrowserUtil.isWebKit()) return "-webkit-grab";
	return "pointer";
};
util_BrowserUtil.grabbingCursor = function() {
	if(util_BrowserUtil.isFireFox()) return "-moz-grabbing";
	if(util_BrowserUtil.isWebKit()) return "-webkit-grabbing";
	return "pointer";
};
if(Array.prototype.indexOf) HxOverrides.indexOf = function(a,o,i) {
	return Array.prototype.indexOf.call(a,o,i);
};
String.prototype.__class__ = String;
String.__name__ = ["String"];
Array.__name__ = ["Array"];
var Int = { __name__ : ["Int"]};
var Dynamic = { __name__ : ["Dynamic"]};
var Float = Number;
Float.__name__ = ["Float"];
var Bool = Boolean;
Bool.__ename__ = ["Bool"];
var Class = { __name__ : ["Class"]};
var Enum = { };
js_Boot.__toStr = {}.toString;
util_BrowserUtil.window = window;
util_BrowserUtil.document = window.document;
util_BrowserUtil.dpr = util_BrowserUtil.window.devicePixelRatio;
TestMain.main();
})(typeof console != "undefined" ? console : {log:function(){}});
