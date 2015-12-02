package view;
import jQuery.JQuery;
enum LoadingOverlayType {
    Bar;
    Dot;
}
class LoadingOverlay {
    public var id: String;
    public var type: LoadingOverlayType = LoadingOverlayType.Bar;
    public var width: Int = 50;
    public var height: Int = 50;
    public var jq: JQuery;
    public var color: String;
    public function new() {}
    public function render(): LoadingOverlay {
        var src = switch(type) {
            case LoadingOverlayType.Bar: "loading.svg";
            case LoadingOverlayType.Dot: "loading-dot.svg";
        }
        var dom = '
        <div id="$id" class="loadingPanel" class="cyan accent-2" style="display: none; background-color: $color" >
            <div class="loadingPanelInner">
                <div>
                    <img src="img/$src" width="$width" height="$height"/>
                </div>
            </div>
        </div>
        ';
        this.jq = new JQuery(dom);
        return this;
    }
}

class LoadingOverlayBuilder {
    private var ret :LoadingOverlay;
    public function new (?id: String) {
        ret = new LoadingOverlay();
        if (id != null) ret.id = id;
    }
    public function type (type: LoadingOverlayType): LoadingOverlayBuilder {
        ret.type = type;
        return this;
    }
    public function width (w: Int): LoadingOverlayBuilder {
        ret.width = w;
        return this;
    }
    public function height (h: Int): LoadingOverlayBuilder {
        ret.height = h;
        return this;
    }
    public function color (c: String): LoadingOverlayBuilder {
        ret.color = c;
        return this;
    }
    public function build (): LoadingOverlay {
        return ret.render();
    }
}