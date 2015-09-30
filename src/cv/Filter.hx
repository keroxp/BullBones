package cv;

import util.BrowserUtil;
import js.html.MessageEvent;
import js.html.ErrorEvent;
import js.html.Worker;
import deferred.Deferred;
import deferred.Promise;
import haxe.Json;
import protocol.Clonable;
import cv.FilterFactory.FilterFunc;
import js.html.ImageData;

class Filter implements Clonable {
    public var funcs: Array<FilterFunc>;
    public function new(?filters: Array<FilterFunc>) {
        funcs = filters;
        if (funcs == null) {
            funcs = [];
        }
    }

    public function clone():Dynamic {
        return new Filter(Json.parse(Json.stringify(this)));
    }

    public function applyToImageData (inImg: ImageData): Promise<ImageData,ErrorEvent,Dynamic> {
        var def = new Deferred<ImageData,ErrorEvent,Dynamic>();
        var worker = new Worker("/worker/filter.js");
        worker.onmessage = function (e: MessageEvent) {
            def.resolve(e.data.result);
        }
        worker.onerror = function (e: ErrorEvent) {
            def.reject(e);
        }
        worker.postMessage({
            imageData: inImg,
            filters: funcs
        });
        return def;
    }
}