package canvas.tools;
import createjs.easeljs.Shape;
import geometry.Points;
import createjs.easeljs.Point;
import performance.GeneralObjectPool;
import figure.ShapeFigure;
class BrushTool implements CanvasTool {
    private static var sPointPool = Points.createPool(5);
    private var drawingFigure: ShapeFigure;
    private var mirrorFigure: ShapeFigure;
    private var isEraser = false;

    public function new(isEraser: Bool = false) {
        this.isEraser = isEraser;
    }

    public function onMouseDown(mainCanvas:MainCanvas, e:CanvasMouseEvent):Void {
        var p = e.getLocal(mainCanvas.mMainContainer);
        drawingFigure = new ShapeFigure();
        drawingFigure.width = Main.App.model.brush.width;
        drawingFigure.color = Main.App.model.brush.color;
        drawingFigure.compositeOperation = isEraser ? "destination-out" : "source-over";
        drawingFigure.addPoint(p.x,p.y);
        if (Main.App.mainCanvas.mirroringInfo.enabled) {
            mirrorFigure = new ShapeFigure();
            mirrorFigure.width = Main.App.model.brush.width;
            mirrorFigure.color = Main.App.model.brush.color;
            mirrorFigure.compositeOperation = isEraser ? "destination-out" : "source-over";
            mirrorFigure.addPoint(p.x,p.y);
        }
    }

    public function onMouseMove(mainCanvas:MainCanvas, e:CanvasMouseEvent):Void {
        sPointPool.mark("BrushTool#onMouseMove");
        var b = Main.App.model.brush;
        var drawPoint = e.getLocal(mainCanvas.mMainContainer);
        var drawPointPrev = e.getLocalPrev(mainCanvas.mMainContainer);
        var buf = mainCanvas.getBufferShape(mainCanvas.mMainContainer);
        if (mainCanvas.modifiedByShift()) {
            drawPointPrev = e.getLocalStart(mainCanvas.mMainContainer);
            var isAlignedToXAxis = Math.abs(e.totalDeltaX) > Math.abs(e.totalDeltaY);
            if (isAlignedToXAxis) {
                drawPoint.y  = drawPointPrev.y;
            } else {
                drawPoint.x  = drawPointPrev.x;
            }
            buf.graphics.clear();
            if (!drawingFigure.isLine) {
                drawingFigure.isLine = true;
                if (mainCanvas.mirroringInfo.enabled) {
                    mirrorFigure.isLine = true;
                    mainCanvas.extendDirtyRectWithRect(mirrorFigure.getTransformedBounds());
                }
                mainCanvas.extendDirtyRectWithRect(drawingFigure.getTransformedBounds());
            }
            mainCanvas.extendDirtyRectWithRadius(e.startX,e.startY,b.width.toFloat());
            mainCanvas.extendDirtyRectWithRadius(drawPoint.x,drawPoint.y,b.width.toFloat(),mainCanvas.mMainContainer);
        } else if (drawingFigure.isLine) {
            drawingFigure.isLine = false;
        }
        buf.graphics.setStrokeStyle(b.width,"round", "round");
        buf.compositeOperation = isEraser ? "destination-out" : "source-over";
        if (mainCanvas.mirroringInfo.enabled) {
            var mx = mainCanvas.mirroringInfo.getMirrorX(drawPoint.x);
            var my = mainCanvas.mirroringInfo.getMirrorY(drawPoint.y);
            mirrorFigure.addPoint(mx,my);
            var mpx = mainCanvas.mirroringInfo.getMirrorX(drawPointPrev.x);
            var mpy = mainCanvas.mirroringInfo.getMirrorY(drawPointPrev.y);
            buf.graphics
            .beginStroke(b.color)
            .moveTo(mpx,mpy)
            .lineTo(mx,my)
            .endStroke();
            mainCanvas.extendDirtyRectWithRadius(mx,my,b.width.toFloat(),mainCanvas.mMainContainer);
        }
        buf.graphics
        .beginStroke(b.color)
        .moveTo(drawPointPrev.x,drawPointPrev.y)
        .lineTo(drawPoint.x,drawPoint.y)
        .endStroke();
        mainCanvas.extendDirtyRectWithRadius(e.x,e.y,b.width.toFloat());
        drawingFigure.addPoint(drawPoint.x,drawPoint.y);
        sPointPool.unmark();
    }

    public function onMouseUp(mainCanvas:MainCanvas, e:CanvasMouseEvent):Void {
        var buf = mainCanvas.getBufferShape(mainCanvas.mMainContainer);
        if (drawingFigure.points.length > 1) {
            var layer = mainCanvas.activeLayer;
            if (mainCanvas.mirroringInfo.enabled) {
                layer.addChild(drawingFigure.render());
                layer.addChild(mirrorFigure.render());
                mainCanvas.extendDirtyRectWithDisplayObject(drawingFigure);
                mainCanvas.extendDirtyRectWithDisplayObject(mirrorFigure);
            } else {
                layer.addChild(drawingFigure.render());
                mainCanvas.extendDirtyRectWithDisplayObject(drawingFigure);
            }
            layer.cache(0,0,layer.getTransformedBounds().width,layer.getTransformedBounds().height);
            Main.App.layerView.invalidate(layer);
        }
        this.drawingFigure = null;
        this.mirrorFigure = null;
        buf.graphics.clear();
    }

    public function toString():String {
        return "[BrushTool]";
    }

}
