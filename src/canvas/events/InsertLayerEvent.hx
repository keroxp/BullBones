package canvas.events;
import figure.Layer;
typedef InsertLayerEvent = {
    public var target: Layer;
    public var at: Int;
}