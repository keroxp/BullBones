package ajax;
import js.html.XMLHttpRequest;
import haxe.Json;
import js.Error;
import util.StringUtil;
import js.html.FormData;
import util.Log;
import jQuery.JQuery;
import js.html.Blob;
import js.html.Uint8Array;
import js.html.ArrayBuffer;
import util.BrowserUtil;
import deferred.Deferred;
import jQuery.JqXHR;
import deferred.Promise;


typedef SignedUrl = {
    var url: String;
    var expires: String;  // Date
}

typedef UploadedAsset = {
    var encoding: String;   //"7bit"
    var extension: String;  //"png"
    var mimetype: String;   //"image/png"
    var name: String;       //"b705411a93ac5a16ffe1b2e0c2acdf13.png"
    var path: String;       //"uploads/b705411a93ac5a16ffe1b2e0c2acdf13.png"
    var size:  Int;         //218929
    var displayId: String;  //b705411a93ac5a16ffe1b2e0c2acdf13
    var host: String;        //assets.bullbones.pics
    var createdAt: String;  // Date
}

class Uploader {
    private static function encodeBlob(dataUrl :String, filetype: String): Blob {
        var base64Data = dataUrl.split(',')[1];
        var data = BrowserUtil.window.atob(base64Data);
        var buff = new ArrayBuffer(data.length);
        var arr = new Uint8Array(buff);
        for(i in 0...data.length) {
            arr[i] = data.charCodeAt(i);
        }
        var blob = new Blob([arr], {type: filetype});
        return blob;
    }
    public static function uploadImage (dataurl: String, filetype: String): Promise<UploadedAsset,XMLHttpRequest,Float> {
        var def = new Deferred<UploadedAsset,XMLHttpRequest,Float>();
        var ext = filetype.split("/")[1];
        if (ext != "png" && ext != "jpg") {
            throw new Error("mimetypes are png or jpg. but "+filetype);
        }
        JQuery._static.ajax({
            url: "/export/signed_url",
            dataType: "json"
        }).done(function(signedUrl: Dynamic) {
            var url: String = signedUrl.url;
            var filename = "image." + ext;
            var blob = encodeBlob(dataurl,filetype);
            var formData = new FormData();
            formData.append("file", blob, filename);
            JQuery._static.ajax({
                url: url,
                data: formData,
                processData: false,
                contentType: false,
                method: "POST"
            }).done(function(asset: UploadedAsset){
                JQuery._static.ajax({
                    url: "/export",
                    method: "POST",
                    data: asset
                }).done(function(uploaded: UploadedAsset) {
                    def.resolve(uploaded);
                }).fail(function(e) {
                    def.reject(e);
                });
            }).fail(function(e){
                def.reject(e);
            });
        }).fail(function(e) {
            def.reject(e);
        });
        return def;
    }
}