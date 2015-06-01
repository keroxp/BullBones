package ;

import backbone.Events;
import jQuery.JQuery;
import js.html.Event;
import view.SearchView;
import js.Browser;

class App extends BackboneEvents {
  public function new() {
    super();
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
      var searchView = new SearchView("searchView");
      searchView.onSelectImage = canvas.onSelectImage;
      var searchButton = new JQuery("#searchButton");
      searchButton.on("click", function (e: Event) {
        searchView.toggle();
      });
    });
  }
  public function start () {
    once("app:start", function (a: Dynamic) {
      trace("BullBones started!");
    });
    trigger("app:start");
  }
}
