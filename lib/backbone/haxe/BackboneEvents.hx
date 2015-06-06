package backbone.haxe;

import jQuery.JQuery;
class BackboneEvents implements Events {
    public function new () {
        JQuery._static.extend(true, this, backbone.Backbone.Events);
    }
    public function on(name: String, callback: Dynamic -> Void, ?context: Dynamic): Events {
        return null;
    }
    public function listenTo(obj: Events, name: String, callback: Dynamic): Events {
        return null;
    }
    public function off(name: String, callback: Dynamic, ?context: Dynamic): Events {
        return null;
    }
    public function stopListening(obj: Events, name: String, callback: Dynamic): Events {
        return null;
    }
    public function once(name: String, callback: Dynamic, ?context: Dynamic): Events {
        return null;
    }
    public function listenToOnce(obj: Events, name: String, callback: Dynamic): Events {
        return null;
    }
    public function trigger<T>(name: String, ?value: T, ?options: Dynamic): Events {
        return null;
    }
    public function bind(name: String, callback: Dynamic, ?context: Dynamic): Events {
        return null;
    }
    public function unbind(name: String, callback: Dynamic, ?context: Dynamic): Events {
        return null;
    }
}