package view;
import figure.FigureType;
import view.MainCanvas;
import createjs.easeljs.DisplayObject;
import util.Log;
import util.BrowserUtil;
import js.html.DragEvent;
import jQuery.JQuery;
using util.ArrayUtil;
using util.FigureUtil;
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
        listenTo(Main.App.mainCanvas, "change:activeFigure", function(canvas: MainCanvas, fig: DisplayObject) {
            if (fig != null) {
                var ls: LayerItemView = layerItems.findFirst(function(li: LayerItemView) {
                    return li.display.id == fig.id;
                });
                ls.select();
            } else {
                deselectAll();
            }
        });
        listenTo(Main.App.mainCanvas, MainCanvas.ON_INSERT_EVENT, function(fig: DisplayObject) {
           add(fig);
        });
        listenTo(Main.App.mainCanvas, MainCanvas.ON_DELETE_EVENT, function(fig: DisplayObject) {
            remove(fig);
        });
    }

    public function deselectAll() {
        selectedItems.clear();
        jq.find(".layerItem.selected").removeClass("selected");
    }

    function add(fig: DisplayObject) {
        var layerItem = new LayerItemView(fig,this);
        layerItem.title = createTitle(fig);
        layerItems.push(layerItem);
        jq.prepend(layerItem.render().jq);
    }
    function remove(display: DisplayObject) {
        var rm: LayerItemView = layerItems.removeFirst(function(li: LayerItemView) {
           return li.display.id == display.id;
        });
        rm.jq.remove();
    }
    public function invalidate(display: DisplayObject) {
        layerItems.findFirst(function(li: LayerItemView) {
            return li.display == display;
        }).render();
    }
    function createTitle(fig: DisplayObject): String {
        var num = layerItems.filter(function(li: LayerItemView) {
           return li.display.type() == fig.type();
        }).length+1;
        var title = fig.typeString() + num;
        var dup = layerItems.filter(function(li: LayerItemView) {
            return li.title == title;
        });
        return title;
    }
}

private class LayerItemView extends ViewModel {
    var jVisibility: JQuery;
    var jThumbnail: JQuery;
    var jTitle: JQuery;
    var mLayerView: LayerView;
    public var title: String;
    public var display(default, null): DisplayObject;
    public function new (fig: DisplayObject, layerView: LayerView) {
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
        this.display = fig;
        mLayerView = layerView;
        jVisibility = jq.find(".layerItemVisibility i");
        jq.find(".layerItemVisibility").on("click", function (e) {
            var v = !display.isVisible();
            jVisibility.toggleClass("invisible");
            jVisibility.html(v ? "visibility" : "visibility_off");
            display.visible = v;
            Main.App.mainCanvas.extendDirtyRectWithDisplayObject(display);
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
            if (BrowserUtil.isFireFox()) {
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
                return li.display.id == display.id;
            });
            if (to < from) {
                to += 1;
            }
            mLayerView.layerItems.remove(self);
            mLayerView.layerItems.insert(to,self);
            Main.App.mainCanvas.moveLayer(display, mLayerView.layerItems.indexOf(self));
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
        Main.App.mainCanvas.isEditing = true;
        Main.App.mainCanvas.activeFigure = display;
    }
    public function render(): LayerItemView {
        jq.attr("id", 'layer-item-${display.id}');
        jq.attr("data-layer-id", display.id);
        jVisibility.html(display.isVisible() ? "visibility" : "visibility off");
        jThumbnail.attr("src", display.getCacheDataURL());
        jTitle.html(title);
        return this;
    }
}
