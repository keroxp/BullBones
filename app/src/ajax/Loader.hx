package ajax;
import util.Log;
import js.Error;
import cv.ImageWrap;
import util.BrowserUtil;
import js.html.DOMError;
import js.html.ProgressEvent;
import js.html.File;
import js.html.FileReader;
import deferred.Promise;
import deferred.Deferred;
import js.html.Image;
using util.ArrayUtil;
class Loader {
    public static function loadImage(src: String): Promise<ImageWrap, Dynamic, Int> {
        var def = new Deferred<ImageWrap, Dynamic, Int>();
        var img = new Image();
        img.onload = (function(_img){
            return function (e) {
                try {
                    def.resolve(new ImageWrap(_img));
                } catch (e: Error) {
                    def.reject(e);
                }
            }
        })(img);
        img.onerror = function (e) {
            def.reject(e);
        }
        if (src.substr(0,4) == "http" && src.indexOf(BrowserUtil.window.location.host) == -1) {
            // external resource
            var encoded: String = js.Lib.eval('encodeURIComponent("$src")');
            img.src = '/proxy?url=$encoded';
        } else {
            img.src = src;
        }
        return def;
    }
    public static function loadFile(file: File): Promise<ImageWrap, Error, ProgressEvent> {
        if (file.type.indexOf("image/") > -1) {
            var reader = new FileReader();
            var def = new Deferred<ImageWrap, Error, ProgressEvent>();
            reader.onload = (function (f) {
                return function (ev) {
                    var img = new Image();
                    img.onload = (function(_img){
                        return function(e) {
                            def.resolve(new ImageWrap(_img));
                        }
                    })(img);
                    img.onerror = function(e) {
                        Log.e(e);
                        def.reject(new Error("画像を読み込めませんでした。"));
                    }
                    img.src = ev.target.result;
                }
            })(file);
            reader.onprogress = function(p) {
                def.notify(p);
            }
            reader.onerror = function (ev) {
                Log.e(reader.error);
                def.reject(new Error("画像を読み込めませんでした。"));
            }
            reader.readAsDataURL(file);
            return def;
        }
        var ext = "この";
        if (file.type.indexOf("/") > -1) {
            ext = file.type.split("/").last();
        }
        throw new Error("申し訳ありませんが、本アプリでは"+ext+"形式のファイルは開くことができません。");
    }
}
