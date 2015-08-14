package view;
import backbone.haxe.BackboneCollection;
import backbone.Collection;
import figure.Layer;
import model.LayerDummy;
import jQuery.JQuery;
using util.ArrayUtil;
class LayerView extends ViewModel {
    var jListView: JQuery;
    public var layers(default, null): Collection<LayerDummy> = BackboneCollection.extend(new LayerDummy(-1));
    public var layerItems: Array<LayerItemView> = [];
    public function new(jq: JQuery) {
        super(jq);
        jListView = jq.find("#layerListView");
    }
    public function add(layer: Layer) {
        layers.add(new LayerDummy(layer.getLayerId()));
        var layerItem = new LayerItemView(layer);
        layerItems.push(layerItem);
        jListView.append(layerItem.render().jq);
    }
    public function remove(layer: Layer) {
        layers.remove({
            layerId: layer.getLayerId()
        });
        var rm: LayerItemView = layerItems.removeFirst(function(t: LayerItemView) {
           return layer.getLayerId() == t.layer.getLayerId();
        });
        rm.jq.remove();
    }
    function move (layer: Layer, index: Int) {

    }
}

class LayerItemView extends ViewModel {
    var jVisibility: JQuery;
    var jThumbnail: JQuery;
    var jTitle: JQuery;
    public var layer(default, null): Layer;
    public function new (layer: Layer) {
        super(new JQuery('
        <li class="layerItem" draggable="true">
            <div class="layerItemVisivility" title="非表示にする">
                <i class="material-icons">visibility</i>
            </div>
            <div class="layerItemThumbnail">
                <img src="" />
            </div>
            <div class="layerItemContent">
                <span class="layerTitle">title</span>
            </div>
        </li>
        '));
        this.layer = layer;
        jq.find(".layerItemVisivility").on("click", function(e) {
           
        });
        jVisibility = jq.find(".layerItemVisivility > i");
        jThumbnail = jq.find("img");
        jTitle = jq.find(".layerTitle");
    }
    public function render (): LayerItemView {
        jq.attr("data-layer-id", layer.getLayerId());
        jVisibility.html(layer.isVisible() ? "visibility" : "visibility off");
        jThumbnail.attr("src", layer.getImageURL());
        jTitle.html(layer.getTile());
        return this;
    }
}
