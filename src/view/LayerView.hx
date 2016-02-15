package view;
import canvas.events.DeleteLayerEvent;
import canvas.events.InsertLayerEvent;
import canvas.events.CopyLayerEvent;
import figure.Layer;
import canvas.MainCanvas;
import util.BrowserUtil;
import js.html.DragEvent;
import jQuery.JQuery;
using util.ArrayUtil;
using figure.Figures;
class LayerView extends ViewModel {
    var jListView: JQuery;
    public var selectedItems(default, null): Array<LayerItemView> = new Array<LayerItemView>();
    public var layerItems: Array<LayerItemView> = new Array<LayerItemView>();
    private var jLayerItemDummy: JQuery;
    public function new(jq: JQuery) {
        super(jq);
        jListView = jq.find("#layerListView");
        jLayerItemDummy = jq.find("#layerItemDummy");
        jLayerItemDummy.on("dragover", function (e) {
            jLayerItemDummy.addClass("dragover");
        });
        jLayerItemDummy.on("dragleave", function (e) {
            jLayerItemDummy.removeClass("dragover");
        });
    }

    override public function init() {
        listenTo(Main.App.mainCanvas, "change:activeLayer", onChangeActiveLayer);
        listenTo(Main.App.mainCanvas, MainCanvas.ON_INSERT_EVENT, add);
        listenTo(Main.App.mainCanvas, MainCanvas.ON_DELETE_EVENT, remove);
        listenTo(Main.App.mainCanvas, MainCanvas.ON_COPY_EVENT, copy);
    }

    public function deselectAll() {
        selectedItems.clear();
        jq.find(".layerItem.selected").removeClass("selected");
    }

    function onChangeActiveLayer(canvas: MainCanvas, layer: Layer, opts: Dynamic) {
        trace("onChangeActiveLayer");
        if (opts.changer == this) return;
        if (layer != null) {
            var ls: LayerItemView = layerItems.findFirst(function(li: LayerItemView) {
                return li.layer.id == layer.id;
            });
            ls.select();
        } else {
            deselectAll();
        }
    }
    function add(e: InsertLayerEvent) {
        var li = new LayerItemView(e.target,this);
        var regex = new EReg('^${e.target.typeString()}([0-9]*)$', "i");
        li.title = e.target.typeString() + calcNextTitlePostfix(li,regex);
        _add(li, e.at);
    }
    function copy(e: CopyLayerEvent) {
        var li = new LayerItemView(e.target,this);
        var src: LayerItemView = layerItems.findFirst(function(li: LayerItemView) {
            return e.src.id == li.layer.id;
        });
        var baseRegex = new EReg('^(.*)のコピー[0-9]*$', "i");
        var base = src.title;
        if (baseRegex.match(src.title)) {
            base = baseRegex.matched(1);
        }
        var indexRegex = new EReg('^${base}のコピー([0-9]*)$', "i");
        li.title = base + "のコピー" + calcNextTitlePostfix(li, indexRegex);
        _add(li, e.at);
    }
    // レイヤータイトルのpostfixの数字を動的に計算する
    function calcNextTitlePostfix(item: LayerItemView, regex: EReg): Int {
        var indexes = layerItems.filter(function(li: LayerItemView) {
            return li.layer.type() == item.layer.type() && regex.match(li.title);
        }).map(function(li: LayerItemView) {
            regex.match(li.title);
            return Std.parseInt(regex.matched(1));
        });
        indexes.sort(function(a: Int, b: Int) {
            if (a == b) return 0;
            return a < b ? -1 : 1;
        });
        var next = 1;
        for (i in indexes) {
            if (next != i) {
                break;
            }
            next += 1;
        }
        return next;
    }
    function _add(li: LayerItemView, at: Int) {
        if (layerItems.length == 0) {
            jq.prepend(li.render().jq);
        } else {
            if (at == layerItems.length) {
                jq.prepend(li.render().jq);
            } else {
                li.render().jq.insertBefore(layerItems[at].jq);
            }
        }
        layerItems.push(li);
    }

    function remove (e: DeleteLayerEvent) {
        var rm: LayerItemView = layerItems.removeFirst(function(li: LayerItemView) {
           return li.layer.id == e.target.id;
        });
        rm.jq.remove();
    }
    public function invalidate(display: Layer) {
        layerItems.findFirst(function(li: LayerItemView) {
            return li.layer == display;
        }).render();
    }
}

private class LayerItemView extends ViewModel {
    var jVisibility: JQuery;
    var jThumbnail: JQuery;
    var jTitle: JQuery;
    var mLayerView: LayerView;
    public var title: String;
    public var layer(default, null): Layer;
    public function new (layer: Layer, layerView: LayerView) {
        super(new JQuery('
        <li class="layerItem" draggable="true">
            <div class="layerItemVisibility" title="非表示にする">
                <i class="material-icons">visibility</i>
            </div>
            <div class="layerItemThumbnail">
                <img src="" draggable="false"/>
            </div>
            <div class="layerItemContent">
                <span class="layerTitle">title</span>
            </div>
        </li>
        '));
        this.layer = layer;
        mLayerView = layerView;
        jVisibility = jq.find(".layerItemVisibility i");
        jq.find(".layerItemVisibility").on("click", function (e) {
            var v = !layer.isVisible();
            jVisibility.toggleClass("invisible");
            jVisibility.html(v ? "visibility" : "visibility_off");
            layer.visible = v;
            Main.App.mainCanvas.extendDirtyRectWithDisplayObject(layer);
            Main.App.mainCanvas.draw(false);
        });
        jThumbnail = jq.find("img");
        jTitle = jq.find(".layerTitle");
        var self = this;
        jq.on("mousedown", function(e) {
            select();
        });
        jq.on("dragstart", function(e) {
            jq.addClass("dragging");
            if (BrowserUtil.isFireFox) {
                // FireFoxではこれをしないとドラッグイベントが始まらない
                var oe: DragEvent = e.originalEvent;
                oe.dataTransfer.setData("text", "dummy");
            }
        });
        jq.on("dragend", function(e) {
            jq.removeClass("dragging");
            var tgt = new JQuery(".layerItem.dragover");
            jq.insertBefore(tgt);
            new JQuery(".layerItem").removeClass("dragover");
            var tgtId = Std.parseInt(tgt.attr("data-layer-id"));
            var from = mLayerView.layerItems.indexOf(self);
            var to = mLayerView.layerItems.firstIndexOf(function(li: LayerItemView) {
                return li.layer.id == tgtId;
            });
            if (to < from) {
                to += 1;
            }
            mLayerView.layerItems.remove(self);
            mLayerView.layerItems.insert(to,self);
            Main.App.mainCanvas.moveLayer(layer,to);
        });
        jq.on("dragover", function (e) {
            jq.addClass("dragover");
        });
        jq.on("dragleave", function (e) {
           jq.removeClass("dragover");
        });
    }
    public function select() {
        mLayerView.deselectAll();
        jq.addClass("selected");
        mLayerView.selectedItems.push(this);
        if (!Main.App.mainCanvas.isEditing) {
            Main.App.mainCanvas.isEditing = true;
        }
        Main.App.mainCanvas.activeLayer = layer;
    }
    public function render(): LayerItemView {
        jq.attr("id", 'layer-item-${layer.id}');
        jq.attr("data-layer-id", layer.id);
        jVisibility.html(layer.isVisible() ? "visibility" : "visibility off");
        jThumbnail.attr("src", layer.getCacheDataURL());
        jTitle.html(title);
        return this;
    }
}
