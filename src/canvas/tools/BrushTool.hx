package canvas.tools;
import createjs.easeljs.Point;
import performance.GeneralObjectPool;
import figure.ShapeFigureSet;
import figure.ShapeFigure;
class BrushTool implements CanvasTool {
    private var drawingFigure: ShapeFigure;
    private var mirroringFigure: ShapeFigure;
    private static var sPointPool = new GeneralObjectPool<Point>(5, function() {
        return new Point();
    }, function (p: Point) {
        p.x = p.y = 0;
    });
    public function new() {
    }

    public function onMouseDown(mainCanvas:MainCanvas, e:CanvasMouseEvent):Void {
        var f =  new ShapeFigure();
        var p = e.getLocal(mainCanvas.mMainContainer);
        f.addPoint(p.x,p.y);
        f.width = Main.App.model.brush.width;
        f.color = Main.App.model.brush.color;
        if (mainCanvas.mirroringInfo.enabled) {
            var m = new ShapeFigure();
            m.addPoint(mainCanvas.mirroringInfo.getMirrorX(p.x), p.y);
            m.width = Main.App.model.brush.width;
            m.color = Main.App.model.brush.color;
            this.mirroringFigure = m;
        }
        this.drawingFigure = f;
    }

    public function onMouseMove(mainCanvas:MainCanvas, e:CanvasMouseEvent):Void {
        sPointPool.mark("BrushTool#onMouseMove");
        var b = Main.App.model.brush;
        var drawPoint = e.getLocal(mainCanvas.mMainContainer);
        var drawPointPrev = e.getLocalPrev(mainCanvas.mMainContainer);
        if (mainCanvas.modifiedByShift()) {
            drawPointPrev = e.getLocalStart(mainCanvas.mMainContainer);
            var isAlignedToXAxis = Math.abs(e.totalDeltaX) > Math.abs(e.totalDeltaY);
            if (isAlignedToXAxis) {
                drawPoint.y  = drawPointPrev.y;
            } else {
                drawPoint.x  = drawPointPrev.x;
            }
            mainCanvas.mBufferShape.graphics.clear();
            if (!drawingFigure.isLine) {
                drawingFigure.isLine = true;
                if (mainCanvas.mirroringInfo.enabled) {
                    mirroringFigure.isLine = true;
                    mainCanvas.extendDirtyRectWithRect(mirroringFigure.getTransformedBounds());
                }
                mainCanvas.extendDirtyRectWithRect(drawingFigure.getTransformedBounds());
            }
            var p_g_drawing = mainCanvas.mMainContainer.localToGlobal(drawPoint.x,drawPoint.y,sPointPool.take());
            mainCanvas.extendDirtyRect(e.startX,e.startY);
            mainCanvas.extendDirtyRect(p_g_drawing.x,p_g_drawing.y);
            var pad = b.width.toFloat()*.5;
            mainCanvas.mDirtyRect.pad(pad,pad,pad,pad);
        } else if (drawingFigure.isLine) {
            drawingFigure.isLine = false;
        }
        mainCanvas.mBufferShape.graphics.setStrokeStyle(b.width,"round", "round");
        if (mainCanvas.mirroringInfo.enabled) {
            var mx = mainCanvas.mirroringInfo.getMirrorX(drawPoint.x);
            var my = drawPoint.y;
            mirroringFigure.addPoint(mx,my);
            var mpx = mainCanvas.mirroringInfo.getMirrorX(drawPointPrev.x);
            var mpy = drawPointPrev.y;
            mainCanvas.mBufferShape.graphics
            .beginStroke(b.color)
            .moveTo(mpx,mpy)
            .lineTo(mx,my)
            .endStroke();
            var gm = mainCanvas.mMainContainer.localToGlobal(mx,my,sPointPool.take());
            mainCanvas.extendDirtyRect(gm.x,gm.y);
        }
        mainCanvas.mBufferShape.graphics
        .beginStroke(b.color)
        .moveTo(drawPointPrev.x,drawPointPrev.y)
        .lineTo(drawPoint.x,drawPoint.y)
        .endStroke();
        mainCanvas.extendDirtyRect(e.x,e.y);
        drawingFigure.addPoint(drawPoint.x,drawPoint.y);
        sPointPool.unmark();
    }

    public function onMouseUp(mainCanvas:MainCanvas, e:CanvasMouseEvent):Void {
        if (drawingFigure.points.length > 1) {
            if (mainCanvas.mirroringInfo.enabled) {
                var first = drawingFigure.render();
                var second = mirroringFigure.render();
                var set = ShapeFigureSet.createWithShapes([first,second]);
                mainCanvas.insertFigure(set.render());
                mainCanvas.extendDirtyRectWithDisplayObject(set, set.getTransformedBounds());
            } else {
                drawingFigure.calcVertexes();
                mainCanvas.insertFigure(drawingFigure.render());
                mainCanvas.extendDirtyRectWithDisplayObject(drawingFigure,mainCanvas.mBufferShape.getTransformedBounds());
            }
        }
        this.drawingFigure = null;
        this.mirroringFigure = null;
    }
}
