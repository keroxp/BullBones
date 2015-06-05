package backbone;
import js.html.XMLHttpRequest;

@:native("Backbone.Model")
extern class Model implements Events {

    public function new (?attributes: Dynamic, ?options: Dynamic): Void;

    public function initialize (?attributes: Dynamic, ?options: Dynamic): Void;

    public var attributes(get, null): Dynamic;

    // A hash of attributes whose current and previous value differ.
    public var changed(get, null): Dynamic;

    // The value returned during the last failed validation.
    public var validationError(get, null): Dynamic;

    public var idAttribute(get,set): String;

    // The prefix is used to create the client id which is used to identify models locally.
    // You may want to override this if you're experiencing name clashes with model ids.
    public var cidPrefix(get,set): String;

    // Return a copy of the model's `attributes` object.
    public function toJSON(?options: Dynamic): Dynamic;

    // Proxy `Backbone.sync` by default -- but override this if you need
    // custom syncing semantics for *this* particular model.
    public function sync(): Model;

    // Get the value of an attribute.
    public function get(attr: String): Dynamic;

    // Get the HTML-escaped value of an attribute.
    public function escape(attr: Dynamic): Bool;

    // Returns `true` if the attribute contains a value that is not null
    // or undefined.
    public function has(attr: Dynamic): Bool;

    // Special-cased proxy to underscore's `_.matches` method.
    public function matches(attrs: Dynamic): Bool;

    // Set a hash of model attributes on the object, firing `"change"`. This is
    // the core primitive operation of a model, updating the data and notifying
    // anyone who needs to know about the change in state. The heart of the beast.
    public function set(key: String, val: Dynamic, ?options: Dynamic): Model;


    // Remove an attribute from the model, firing `"change"`. `unset` is a noop
    // if the attribute doesn't exist.
    public function unset(attr: String, ?options: Dynamic): Void;

    // Clear all attributes on the model, firing `"change"`.
    public function clear(?options: Dynamic): Model;

    // Determine if the model has changed since the last `"change"` event.
    // If you specify an attribute name, determine if that attribute has changed.
    public function hasChanged(attr: String): Bool;


    // Return an object containing all the attributes that have changed, or
    // false if there are no changed attributes. Useful for determining what
    // parts of a view need to be updated and/or what attributes need to be
    // persisted to the server. Unset attributes will be set to undefined.
    // You can also pass an attributes object to diff against the model,
    // determining if there *would be* a change.
    public function changedAttributes(diff: Dynamic): Dynamic;


    // Get the previous value of an attribute, recorded at the time the last
    // `"change"` event was fired.
    public function previous(attr: Dynamic): Dynamic;


    // Get all of the attributes of the model at the time of the previous
    // `"change"` event.
    public function previousAttributes(): Dynamic;


    // Fetch the model from the server, merging the response with the model's
    // local attributes. Any changed attributes will trigger a "change" event.
    public function fetch(?options: Dynamic): Model;


    // Set a hash of model attributes, and sync the model to the server.
    // If the server returns an attributes hash that differs, the model's
    // state will be `set` again.
    public function save(?key: String, ?val: Dynamic, ?options: Dynamic): XMLHttpRequest;


    // Destroy this model on the server if it was already persisted.
    // Optimistically removes the model from its collection, if it has one.
    // If `wait: true` is passed, waits for the server to respond before removal.
    public function destroy(?options: Dynamic): XMLHttpRequest;


    // Default URL for the model's representation on the server -- if you're
    // using Backbone's restful methods, override this to change the endpoint
    // that will be called.
    public function url(): String;

    // **parse** converts a response into the hash of attributes to be `set` on
    // the model. The default implementation is just to pass the response along.
    public function parse(resp: Dynamic, ?options: Dynamic): Dynamic;


    // Create a new model with identical attributes to this one.
    public function clone(): Model;

    // A model is new if it has never been saved to the server, and lacks an id.
    public function isNew(): Bool;

    // Check if the model is currently in a valid state.
    public function isValid(?options: Dynamic): Bool;

    // Backbone.Events
    public function on(name: String, callback: Dynamic, ?context: Dynamic): Events;
    public function listenTo(obj: Events, name: String, callback: Dynamic): Events;
    public function off(name: String, callback: Dynamic, ?context: Dynamic): Events;
    public function stopListening(obj: Events, name: String, callback: Dynamic): Events;
    public function once(name: String, callback: Dynamic, ?context: Dynamic): Events;
    public function listenToOnce(obj: Events, name: String, callback: Dynamic): Events;
    public function trigger<T>(name: String, ?value: T, ?options: Dynamic): Events;
    public function bind(name: String, callback: Dynamic, ?context: Dynamic): Events;
    public function unbind(name: String, callback: Dynamic, ?context: Dynamic): Events;
}
