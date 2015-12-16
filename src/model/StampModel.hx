package model;
import cv.ImageWrap;
import figure.ShapeFigure;
class StampModel extends BaseModel {
    public var figureId: Float = -1;
    public var sizeJitter: Float = 0;
    public var alphaJitter: Float = 0;
    public var minSize: Float = 0;
    public var space: Float = 25;
    public var image: ImageWrap;
    public function new(figureId: Float, image: ImageWrap) {
        super();
        this.figureId = figureId;
        this.image = image;
    }
}
