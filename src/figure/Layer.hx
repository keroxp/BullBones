package figure;
import js.html.CanvasRenderingContext2D;
import js.html.CanvasElement;
import createjs.easeljs.Container;
import js.Browser;
import cv.ImageWrap;
import model.ImageEditor;
import js.html.ImageData;
import cv.Images;
import deferred.Deferred;
import deferred.Promise;
import cv.Filter;
import util.RectangleUtil;
import createjs.easeljs.Rectangle;
import createjs.easeljs.DisplayObject;
using util.RectangleUtil;
using util.ArrayUtil;
class Layer extends Container implements Figure {
    public var editor(default,null): ImageEditor = new ImageEditor();
    public var layerScaleX(default,null): Float = 1.0;
    public var layerScaleY(default,null): Float = 1.0;
    private static var sTempRect = new Rectangle();
    public var leftObject(default,null): DisplayObject;
    public var topObject(default,null): DisplayObject;
    public var rightObject(default,null): DisplayObject;
    public var bottomObject(default,null): DisplayObject;

    public static function fromImage(image: ImageWrap): Layer {
        var ret = new Layer();
        ret.addChild(new ImageFigure(image));
        return ret;
    }

    public function new() {
        super();
        setBounds(0,0,0,0);
    }

    override public function clone(): Layer {
        var ret = new Layer();
        for (child in children) {
            ret.addChild(child.clone());
        }
        ret.editor = editor.clone();
        ret.layerScaleX = layerScaleX;
        ret.layerScaleY = layerScaleY;
        var _clone = Reflect.field(this, "_cloneProps");
        ret = Reflect.callMethod(this, _clone,[ret]);
        // do depp copy _bounds because easeljs.DisplayObject#clone does not :(
        Reflect.setField(ret, "_bounds", getBounds().clone());
        ret.uncache();
        ret.cache(0,0,ret.getTransformedBounds().width,ret.getTransformedBounds().height);
        return cast ret.render();
    }

    private function updateBounds(x: Float, y: Float, w: Float = 0, h: Float = 0) {
        if (getBounds() == null) {
            setBounds(x,y,w,h);
        } else {
            var bounds = getBounds().clone();
            bounds.extend(x,y,w,h);
            setBounds(bounds.x,bounds.y,bounds.width,bounds.height);
        }
    }

    public override function addChild(child:DisplayObject):DisplayObject {
        return addChildAt(child, children.length);
    }

    public override function addChildAt(child:DisplayObject, index:Float):DisplayObject {
        var hasNoChild = getNumChildren() == 0;
        var ex: Float = 0;
        var ey: Float = 0;
        if (hasNoChild) {
            leftObject = rightObject = topObject = bottomObject = child;
        } else {
            if (child.x < x) { leftObject = child; }
            if (getTransformedBounds().right() < child.x) { rightObject = child; }
            if (child.y < y) { topObject = child; }
            if (getTransformedBounds().bottom() < child.y) { bottomObject = child; }
        }
        if (child.x < x || hasNoChild) {
            var diff = x - child.x;
            x = child.x;
            child.x = 0;
            for (child in children) {
                child.x += diff;
                if (ex < child.x) {
                    ex = child.x;
                }
            }
        } else {
            child.x -= x;
            ex = child.x;
        }
        if (child.y < y || hasNoChild) {
            var diff = y - child.y;
            y = child.y;
            child.y = 0;
            for (child in children) {
                child.y += diff;
                if (ey < child.y) {
                    ey = child.y;
                }
            }
        } else {
            child.y -= y;
            ey = child.y;
        }
        super.addChild(child);
        var b = getBounds();
        var cb = child.getBounds();
        if (hasNoChild) {
            b = cb.clone();
        } else {
            b.extend(ex,ey,cb.width,cb.height);
        }
        setBounds(0,0,~~b.width,~~b.height);
        return child;
    }

    override public function draw(ctx:CanvasRenderingContext2D, ?ignoreCache:Bool):Bool {
        if (filteredCanvas != null) {
            ctx.save();
            updateContext(ctx);
            ctx.drawImage(filteredCanvas,0,0);
            ctx.restore();
            return true;
        }
        if (super.draw(ctx,ignoreCache)) return true;
        return false;
    }

    private var filteredCanvas: CanvasElement;
    public function setFilterAsync(filter: Filter): Promise<ImageData,Dynamic,Float> {
        var pr = new Deferred<ImageData,Dynamic,Float>();
        var self = this;
        filter.applyToImageData(Images.getImageData(cacheCanvas))
        .done(function(filtered: ImageData){
            if (filteredCanvas == null) {
                filteredCanvas = cast Browser.document.createElement("canvas");
            }
            var ctx = filteredCanvas.getContext2d();
            ctx.putImageData(filtered,0,0);
            pr.resolve(filtered);
        }).fail(function(e) {
            pr.reject(e);
        });
        return pr;
    }

    public function applyScale(sx: Float, sy: Float): Layer {
        return this;
    }

    public function render(): DisplayObject {
        return this;
    }

    public function setActive(bool:Bool):Void {

    }

    public function hasContent(): Bool {
        return children.length > 0 || (getBounds().width > 0 && getBounds().height > 0);
    }

    override public function toString():String {
        return '[Layer id="$id" bounds="${getTransformedBounds().toString()}"]';
    }


}
