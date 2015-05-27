package ;

import jQuery.JQuery;
import js.Browser;
import js.html.*;

class Main {
    public function new() {
    }
    public static function main () {
        new JQuery(function () {
            var document = Browser.document;
            var window = Browser.window;
            var w: Float = window.innerWidth;
            var h: Float = window.innerHeight;
            trace("w: "+w+" h: "+h);
            var canvasDom = new JQuery("#mainCanvas");
            canvasDom.attr({
                width : w,
                height: h
            });
            var canvas = new MainCanvas("mainCanvas",w,h);
            trace("Hello Haxe!!");
        });
    }
}
