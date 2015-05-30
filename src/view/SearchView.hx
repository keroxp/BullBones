package view;
import createjs.easeljs.Event;
import js.html.Image;
import jQuery.JQuery;
class SearchView {
  public var j: JQuery;
  private var jLoader: JQuery;
  private var jInput: JQuery;
  private var jResults: JQuery;
  private var mImages: Array<Dynamic>;
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
        mImages = data.d.results;
        render(data.d.results.map(function(e) { return e.Thumbnail.MediaUrl; }));
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
  public function render (urls: Array<String>) {
    var document = js.Browser.document;
    var fragment =  document.createDocumentFragment();
    var imgs = jResults.find("img").get();
    var imgCnt = imgs.length;
    if (imgCnt == 0) {
      // 最初
      var i = 0;
      while (i < urls.length-1) {
        var row = new JQuery("<div class='searchResultsRow'></div>");
        for (j in 0...3) {
          var cell;
          if (i < urls.length) {
            var url = urls[i];
            cell = new JQuery('<div class="searchResultsCell"><img src=\"$url\"></div>');
          } else {
            cell = new JQuery('<div class="searchResultsCell"></div>');
          }
          row.append(cell);
          i++;
        }
        fragment.appendChild(row.get()[0]);
      }
      jResults.get()[0].appendChild(fragment);
    } else {
      // 次
      for (i in 0...imgCnt) {
        var img: Image = cast imgs[i];
        img.src = urls[i];
      }
    }
  }
}
