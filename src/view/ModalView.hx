package view;
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
                <a href="#!" class=" modal-action modal-close waves-effect waves-green btn-flat">OK</a>
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
    public function render(title: String, msg: String, ?optionalHtml: String = ""): ModalView {
        jq.find("#modal-title").html(title);
        jq.find("#modal-message").html(msg);
        jq.find("#modal-optional-html").html(optionalHtml);
        return this;
    }
}
