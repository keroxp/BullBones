package view;
import js.html.Event;
import js.html.EventListener;
import js.html.MouseEvent;
import js.Browser;
import jQuery.JQuery;
class ModalView extends ViewModel {
    public static var ADD_TO_HOMESCREEN = "BullBones:ADD_TO_HOMESCREEN";
    public function new(jq: JQuery) {
        super(jq);
        var html = '
            <div class="modal-content">
                <h4 id="modal-title"></h4>
                <p id="modal-message"></p>
                <div id="modal-optional-html"></div>
            </div>
            <div class="modal-footer">
            </div>
            ';
        jq.append(new JQuery(html));
    }
    private function addToHomescreen (): ModalView {
        return render(
            "BullBonesをアプリで使いましょう",
            "もしiPadやiPhoneをお使いの場合は、BullBonesのショートカットをホーム画面に追加するとアプリとしてお使いいただけます。",
            "<p><img src=\"img/tutorial/add-to-homescreen-1.png\"></p>
            <p><img src=\"img/tutorial/add-to-homescreen-2.png\"></p>"
        );
    }
    public function confirmExporting (src: String, callback: Bool -> Void): ModalView {
        return render(
            "この画像を保存しますか？",
            "保存された画像はあなただけが見ることができます。また、Webで公開することもできます。",
            '<div class="scrollable" style="text-align:center;"><img style="border:2px solid #000; max-width: 100%" src="$src"></div>',
            [new ModalButton("やめる", function(e) {
                callback(false);
            }),
            new ModalButton("保存する", function(e) {
                callback(true);
            })]
        );
    }
    public function beginExporting(callback: Bool -> Void): ModalView {
        return render(
            "画像の保存を開始します",
            "画像の保存したい部分をマウスまたはタッチで切り取ってください。",
            '<div class="scrollable" style="text-align:center;">
                <img style="border:2px solid #000; max-width: 100%" src="/img/tutorial/export-1.jpg">
            </div>',
            [new ModalButton("やめる", function(e) {
                callback(false);
            }),
            new ModalButton("始める", function(e) {
                callback(true);
            })]
        );
    }
    public function open() {
        var openModal = Reflect.field(jq,"openModal");
        Reflect.callMethod(this.jq, openModal, []);
    }
    public static function clearOpenOnceFlags() {
        Browser.getLocalStorage().removeItem(ADD_TO_HOMESCREEN);
    }
    public function openOnce(tag: String) {
        var storage = Browser.getLocalStorage();
        if (storage.getItem(tag) != "true") {
            if (tag == ADD_TO_HOMESCREEN) {
                addToHomescreen().open();
            }
            storage.setItem(tag, "true");
        }
    }
    public function close() {
        var closeModal = Reflect.field(jq,"closeModal");
        Reflect.callMethod(this.jq, closeModal, []);
    }
    public function render(title: String, msg: String, ?optionalHtml: String = "", ?buttons: Array<ModalButton>): ModalView {
        jq.find("#modal-title").html(title);
        jq.find("#modal-message").html(msg);
        jq.find("#modal-optional-html").html(optionalHtml);
        jq.find(".modal-footer").html("");
        if (buttons == null) {
            jq.find(".modal-footer").append(ModalButton.OKButton().jq);
        } else {
            var jFooter: JQuery = jq.find(".modal-footer");
            for (b in buttons) {
                jFooter.prepend(b.jq);
            }
        }
        return this;
    }
}

class ModalButton extends ViewModel {
    var title: String;
    public static function OKButton(?callback: Event -> Void): ModalButton {
        return new ModalButton("OK",callback);
    }
    public function new (title: String, callback: Event -> Void) {
        super(new JQuery(
            '<a href="#!" class=" modal-action modal-close waves-effect waves-green btn-flat">$title</a>'
        ));
        jq.on("click", callback);
    }
}