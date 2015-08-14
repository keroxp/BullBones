package view;
import view.MainCanvas;
import createjs.easeljs.DisplayObject;
import util.Log;
import util.BrowserUtil;
import js.html.DragEvent;
import backbone.haxe.BackboneCollection;
import backbone.Collection;
import figure.Layer;
import model.LayerDummy;
import jQuery.JQuery;
using util.ArrayUtil;
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
                layerItems.findFirst(function(li: LayerItemView) {
                    return li.layer.getDisplay() == fig;
                }).select();
            } else {
                jq.find(".layerItem.selected").removeClass("selected");
            }
        });
    }

    public function add(layer: Layer) {
        var layerItem = new LayerItemView(layer,this);
        layerItems.push(layerItem);
        jq.prepend(layerItem.render().jq);
    }
    public function remove(layer: Layer) {
        var rm: LayerItemView = layerItems.removeFirst(function(t: LayerItemView) {
           return layer == t.layer;
        });
        rm.jq.remove();
    }
    public function invalidate(layer: Layer) {
        layerItems.findFirst(function(l: LayerItemView) {
            return l.layer == layer;
        }).render();
    }
}

private class LayerItemView extends ViewModel {
    var jVisibility: JQuery;
    var jThumbnail: JQuery;
    var jTitle: JQuery;
    var mLayerView: LayerView;
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
            var v = !layer.getDisplay().isVisible();
            jVisibility.toggleClass("invisible");
            jVisibility.html(v ? "visibility" : "visibility_off");
            layer.getDisplay().visible = v;
            Main.App.mainCanvas.extendDirtyRectWithDisplayObject(layer.getDisplay());
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
        var lid = layer.getLayerId();
        jq.on("dragend", function(e) {
            jq.removeClass("dragging");
            var tgt = new JQuery(".layerItem.dragover");
            jq.insertBefore(tgt);
            new JQuery(".layerItem").removeClass("dragover");
            var tgtId = Std.parseInt(tgt.attr("data-layer-id"));
            var from = mLayerView.layerItems.indexOf(self);
            var to = mLayerView.layerItems.firstIndexOf(function(li: LayerItemView) {
                return li.layer.getLayerId() == tgtId;
            });
            if (to < from) {
                to += 1;
            }
            mLayerView.layerItems.remove(self);
            mLayerView.layerItems.insert(to,self);
            Main.App.mainCanvas.moveLayer(layer.getDisplay(), mLayerView.layerItems.indexOf(self));
            Main.App.mainCanvas.extendDirtyRectWithDisplayObject(layer.getDisplay());
            Main.App.mainCanvas.draw(false);
        });
        jq.on("dragover", function (e) {
            jq.addClass("dragover");
        });
        jq.on("dragleave", function (e) {
           jq.removeClass("dragover");
        });
    }
    public function select() {
        mLayerView.jq.find(".layerItem.selected").removeClass("selected");
        jq.addClass("selected");
        mLayerView.selectedItems.clear();
        mLayerView.selectedItems.push(this);
        Main.App.mainCanvas.isEditing = true;
        Main.App.mainCanvas.activeFigure = layer.getDisplay();
    }
    public function render(): LayerItemView {
        jq.attr("id", 'layer-item-${layer.getLayerId()}');
        jq.attr("data-layer-id", layer.getLayerId());
        jVisibility.html(layer.getDisplay().isVisible() ? "visibility" : "visibility off");
        jThumbnail.attr("src", layer.getImageURL());
        jTitle.html(layer.getTile());
        return this;
    }
}
