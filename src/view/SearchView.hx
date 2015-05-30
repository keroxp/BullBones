package view;
import js.html.Node;
import createjs.easeljs.Event;
import js.html.Image;
import jQuery.JQuery;
class SearchView {
  public var j: JQuery;
  private var jLoader: JQuery;
  private var jInput: JQuery;
  private var jResults: JQuery;
  private var mImages: Array<Dynamic> = [];
  private var mLoading: Bool;
  private var mCurrentQ: String;
  public function new(id: String) {
    j = new JQuery("#"+id);
    jLoader = j.find("#searchingIndicator");
    jInput = j.find("#searchInput");
    jResults = j.find("#searchResults");
    jInput.bind("change", onSearch);
    jInput.bind("input", onInput);
  }
  private function onInput (e: Event) {
    var val: String = cast jInput.val();
    if (val.length == 0) {
      jResults.addClass("hidden");
      mCurrentQ = null;
    }
  }
  private function onSearch (e: Event) {
    e.preventDefault();
    e.stopPropagation();
    var q = jInput.val();
    if (!mLoading && q != mCurrentQ) {
      trace('start searching \"$q\"');
      setLoading(true);
      mLoading = true;
      ajax.BingSearch.search(q).done(function(data: Dynamic) {
        setLoading(false);
        render(data.d.results.map(function(e) { return e.Thumbnail.MediaUrl; }));
        mImages = data.d.results;
      }).fail(function(jxhr: jQuery.JqXHR) {
        setLoading(false);
        trace("error!");
      }).always(function(){
        mLoading = false;
      });
      mCurrentQ = q;
    }
  }
  public function setLoading (loading: Bool) {
    if (loading) {
      jResults.addClass("hidden");
      jLoader.removeClass("hidden");
    } else {
      jLoader.addClass("hidden");
      jResults.removeClass("hidden");
    };
  }
  private static var WHITE_IMG = "data:image/gif;base64,R0lGODlhAQABAIAAAP///////yH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==";
  public function render (urls: Array<String>) {
    var document = js.Browser.document;
    var fragment =  document.createDocumentFragment();
    var imgs = jResults.find("img").get();
    var i = 0;
    var diff = urls.length-mImages.length;
    // 検索結果が少ない場合必要のないrowは非表示にする
    var a = Math.floor(urls.length/3);
    var b = Math.floor(mImages.length/3);
    jResults.find(".searchResultsRow").each(function(i: Int, el: Node) {
      if (diff < 0 && a < i) {
        // 前回よりも減った場合
        new JQuery(el).addClass("hidden");
      } else if (0 < diff && b < i){
        // 増えた場合
        new JQuery(el).removeClass("hidden");
      }
    });
    for (j in 0...imgs.length) {
      var img:Image = cast imgs[j];
      img.src = j < urls.length ? urls[j] : WHITE_IMG;
      i++;
    }
    while (i < urls.length-1) {
      var row = new JQuery("<div class='searchResultsRow'></div>");
      for (j in 0...3) {
        var url = i < urls.length ? urls[i] : WHITE_IMG;
        var cell = new JQuery('<div class="searchResultsCell"><img src=\"$url\"></div>');
        row.append(cell);
        i++;
      }
      fragment.appendChild(row.get()[0]);
    }
    jResults.get()[0].appendChild(fragment);
  }
}
