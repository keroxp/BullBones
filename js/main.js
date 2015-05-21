(function () { "use strict";
var Main = function() {
};
Main.main = function() {
	var s = "hoge";
	var sub = new Sub();
	console.log(s);
};
var Sub = function() {
};
Sub.prototype = {
	hoge: function() {
		return 2;
	}
};
Main.main();
})();
