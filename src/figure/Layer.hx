package figure;
import util.BrowserUtil;
import js.Error;
import ajax.Loader;
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
using util.CreateJSExt;
class Layer extends Container implements Figure {
    public var editor(default,null): ImageEditor = new ImageEditor();
    private static var sTempRect = new Rectangle();

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
        var _clone = Reflect.field(this, "_cloneProps");
        ret = Reflect.callMethod(this, _clone,[ret]);
        ret.uncache();
        ret.cache(0,0,ret.getTransformedBounds().width,ret.getTransformedBounds().height);
        return cast ret.render();
    }

    public override function addChild(child:DisplayObject):DisplayObject {
        return addChildAt(child, children.length);
    }

    public override function addChildAt(child:DisplayObject, index:Float):DisplayObject {
        var hasNoChild = getNumChildren() == 0;
        if (hasNoChild) {
            x = child.x;
            y = child.y;
            child.x = 0;
            child.y = 0;
            this.setSize(child.getWidth(),child.getHeight());
        } else {
            if (child.x < x) {
                var diff = x - child.x;
                x = child.x;
                child.x = 0;
                for (c in children) {
                    c.x += diff;
                }
                this.setWidth(this.getWidth()+diff);
            } else {
                var diff = child.getRight() - this.getRight();
                if (diff > 0) {
                    this.setWidth(this.getWidth()+diff);
                }
                child.x -= x;
            }
            if (child.y < y) {
                var diff = y - child.y;
                y = child.y;
                child.y = 0;
                for (c in children) {
                    c.y += diff;
                }
                this.setHeight(this.getHeight()+diff);
            } else {
                var diff = child.getBottom() - this.getBottom();
                if (diff > 0) {
                    this.setHeight(this.getHeight()+diff);
                }
                child.y -= y;
            }
        }
        super.addChild(child);
        cache(child.x,child.y,child.getWidth(),child.getHeight());
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
    public function applyScale(): Promise<Layer,Error,Void> {
        var _x = x;
        var _y = y;
        x = 0;
        y = 0;
        var cvs = BrowserUtil.createCanvas();
        cvs.width = Std.int(this.getWidth());
        cvs.height = Std.int(this.getHeight());
        var ctx = cvs.getContext2d();
        updateContext(ctx);
        draw(ctx,true);
        var url = cvs.toDataURL();
        var ret = new Deferred<Layer,Error,Void>();
        Loader.loadImage(url).done(function(iw: ImageWrap) {
            var imf = new ImageFigure(iw);
            uncache();
            removeAllChildren();
            addChild(imf);
            x = ~~_x;
            y = ~~_y;
            scaleX = 1.0;
            scaleY = 1.0;
            ret.resolve(this);
        }).fail(ret.reject);
        return ret;
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
        var ret = '<Layer id="$id" bounds="${getTransformedBounds().toString()}>\n';
        for (child in children) {
            ret += '\t${child.toString()}';
        }
        ret += "</Layer>";
        return ret;
    }


}
