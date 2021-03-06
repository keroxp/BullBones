package canvas.tools;
import geometry.Points;
import createjs.easeljs.Point;
import performance.GeneralObjectPool;
import figure.ShapeFigureSet;
import figure.ShapeFigure;
class BrushTool implements CanvasTool {
    private var drawingFigure: ShapeFigure;
    private var mirroringFigure: ShapeFigure;
    private static var sPointPool = Points.createPool(5);
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
            m.addPoint(
                mainCanvas.mirroringInfo.getMirrorX(p.x),
                mainCanvas.mirroringInfo.getMirrorY(p.y)
            );
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
                    mirroringFigure.isLine = true;
                    mainCanvas.extendDirtyRectWithRect(mirroringFigure.getTransformedBounds());
                }
                mainCanvas.extendDirtyRectWithRect(drawingFigure.getTransformedBounds());
            }
            mainCanvas.extendDirtyRectWithRadius(e.startX,e.startY,b.width.toFloat());
            mainCanvas.extendDirtyRectWithRadius(drawPoint.x,drawPoint.y,b.width.toFloat(),mainCanvas.mMainContainer);
        } else if (drawingFigure.isLine) {
            drawingFigure.isLine = false;
        }
        buf.graphics.setStrokeStyle(b.width,"round", "round");
        if (mainCanvas.mirroringInfo.enabled) {
            var mx = mainCanvas.mirroringInfo.getMirrorX(drawPoint.x);
            var my = mainCanvas.mirroringInfo.getMirrorY(drawPoint.y);
            mirroringFigure.addPoint(mx,my);
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
            if (mainCanvas.mirroringInfo.enabled) {
                var first = drawingFigure.render();
                var second = mirroringFigure.render();
                var set = ShapeFigureSet.createWithShapes([first,second]);
                mainCanvas.insertFigure(set.render());
                mainCanvas.extendDirtyRectWithDisplayObject(set);
            } else {
                drawingFigure.calcVertexes();
                mainCanvas.insertFigure(drawingFigure.render());
                mainCanvas.extendDirtyRectWithDisplayObject(drawingFigure);
            }
        }
        this.drawingFigure = null;
        this.mirroringFigure = null;
        buf.graphics.clear();
    }
}
