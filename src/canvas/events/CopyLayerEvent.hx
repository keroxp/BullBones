package canvas.events;

import figure.Layer;
typedef CopyLayerEvent = {
    public var src: Layer;
    public var target: Layer;
    public var at: Int;
}