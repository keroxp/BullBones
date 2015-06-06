package ;
import backbone.Collection;
import backbone.Model;
class Model extends backbone.Model {
    public function new (?attr: Dynamic, ?options: Dynamic) {
        super(attr, options);
    }
    public function listenToOnChangeAttribute<T>(obj: Model, key: String, callback: OnChangeAttributeCallback<T>) {
        this.listenTo(obj,'change:$key',callback);
    }
}

/**
    Global Events
    "add" (model, collection, options) — when a model is added to a collection.
    "remove" (model, collection, options) — when a model is removed from a collection.
    "update" (collection, options) — single event triggered after any number of movels have been added or removed from a collection.
    "reset" (collection, options) — when the collection's entire contents have been replaced.
    "sort" (collection, options) — when the collection has been re-sorted.
    "change" (model, options) — when a model's attributes have changed.
    "change:[attribute]" (model, value, options) — when a specific attribute has been updated.
    "destroy" (model, collection, options) — when a model is destroyed.
    "request" (model_or_collection, xhr, options) — when a model or collection has started a request to the server.
    "sync" (model_or_collection, resp, options) — when a model or collection has been successfully synced with the server.
    "error" (model_or_collection, resp, options) — when a model's or collection's request to the server has failed.
    "invalid" (model, error, options) — when a model's validation fails on the client.
    "route:[name]" (params) — Fired by the router when a specific route is matched.
    "route" (route, params) — Fired by the router when any route has been matched.
    "route" (router, route, params) — Fired by history when any route has been matched.
    "all" — this special event fires for any triggered event, passing the event name as the first argument.
**/

typedef OnAddCallback = Model -> Collection -> Dynamic -> Void;
typedef OnRemoveCallback = Model -> Collection -> Dynamic -> Void;
typedef OnUpdateCallback = Collection -> Dynamic -> Void;
typedef OnRestCallback = Collection -> Dynamic -> Void;
typedef OnSortCallback = Collection -> Dynamic -> Void;
typedef OnChangeCallback = (Model -> Dynamic) -> Void;
typedef OnChangeAttributeCallback<T> = Model -> T -> Dynamic -> Void;
typedef OnDestoroyCallback = Model -> Collection -> Dynamic -> Void;
typedef OnAllCallback = String -> Void;