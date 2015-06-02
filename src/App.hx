package ;

import js.html.DOMWindow;
import backbone.Events;
import jQuery.JQuery;
import js.html.MouseEvent;
import view.SearchView;
import js.Browser;

class App extends BackboneEvents {
  public function new() {
    super();
    new JQuery(function () {
      var document = Browser.document;
      var window: DOMWindow = Browser.window;
      var w: Float = window.innerWidth;
      var h: Float = window.innerHeight;
      var canvasDom = new JQuery("#mainCanvas");
      canvasDom.attr({
        width : w,
        height: h
      });
      var canvas = new MainCanvas("mainCanvas",w,h);
      // 検索ビュー
      var searchView = new SearchView("searchView");
      searchView.onSelectImage = canvas.onSelectImage;
      // 検索ボタン
      var searchButton = new JQuery("#searchButton");
      searchButton.on("click", function (e: MouseEvent) {
        searchView.toggle();
      });
      // 編集ボタン
      var editButton = new JQuery("#editButton");
      editButton.on("click", function (e: MouseEvent) {
        canvas.setEdit(!canvas.editing);
      });
      // デバッグボタン
      var debugButton = new JQuery("#debugButton");
      debugButton.on("click", function (e: MouseEvent){

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
