package view;
import figure.Selection;
import figure.FigureType;
import canvas.MainCanvas;
import createjs.easeljs.DisplayObject;
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
        listenTo(Main.App.mainCanvas, "change:activeFigure", onChangeActiveFigure);
        listenTo(Main.App.mainCanvas, MainCanvas.ON_INSERT_EVENT, add);
        listenTo(Main.App.mainCanvas, MainCanvas.ON_DELETE_EVENT, remove);
        listenTo(Main.App.mainCanvas, MainCanvas.ON_COPY_EVENT, copy);
    }

    public function deselectAll() {
        selectedItems.clear();
        jq.find(".layerItem.selected").removeClass("selected");
    }

    function onChangeActiveFigure(canvas: MainCanvas, fig: DisplayObject, opts: Dynamic) {
        if (opts.changer == this) return;
        if (fig != null) {
            if (fig.type() == FigureType.Selection) {
                var sel = cast(fig, Selection);
                for (item in layerItems) {
                    for (s in sel.figures) {
                        if (item.display.id == s.id) {
                            item.select();
                        }
                    }
                }
            } else {
                var ls: LayerItemView = layerItems.findFirst(function(li: LayerItemView) {
                    return li.display.id == fig.id;
                });
                deselectAll();
                ls.select();
            }
        } else {
            deselectAll();
        }
    }
    function add(e: InsertEvent) {
        var li = new LayerItemView(e.target,this);
        var regex = new EReg('^${e.target.typeString()}([0-9]*)$', "i");
        li.title = e.target.typeString() + calcNextTitlePostfix(li,regex);
        _add(li, e.at);
    }
    function copy(e: CopyEvent) {
        var li = new LayerItemView(e.target,this);
        var src: LayerItemView = layerItems.findFirst(function(li: LayerItemView) {
            return e.src.id == li.display.id;
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
            return li.display.type() == item.display.type() && regex.match(li.title);
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

    function remove (e: DeleteEvent) {
        var rm: LayerItemView = layerItems.removeFirst(function(li: LayerItemView) {
           return li.display.id == e.target.id;
        });
        rm.jq.remove();
    }
    public function invalidate(display: DisplayObject) {
        layerItems.findFirst(function(li: LayerItemView) {
            return li.display == display;
        }).render();
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
                return li.display.id == tgtId;
            });
            if (to < from) {
                to += 1;
            }
            mLayerView.layerItems.remove(self);
            mLayerView.layerItems.insert(to,self);
            Main.App.mainCanvas.moveLayer(display,to);
        });
        jq.on("dragover", function (e) {
            jq.addClass("dragover");
        });
        jq.on("dragleave", function (e) {
           jq.removeClass("dragover");
        });
    }
    public function select() {
        jq.addClass("selected");
        mLayerView.selectedItems.push(this);
//        if (!Main.App.mainCanvas.isEditing) {
//            Main.App.mainCanvas.isEditing = true;
//        }
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
