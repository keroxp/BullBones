package backbone;
@:native("Backbone.Collection")

extern class Collection<T : Model> implements Events {

    @:overload(function(?opts: Dynamic): Collection<T>{})
    @:overload(function(?models: Array<T>): Collection<T>{})
    public function new (?models: Array<Dynamic>): Void {}
    // The default model for a collection is just a **Backbone.Model**.
    // This should be overridden in most cases.
    @:isVar public var model: T;

    // Initialize is an empty function by default. Override it with your own
    // initialization logic.
    public function initialize(): Dynamic;

    // The JSON representation of a Collection is an array of the
    // models' attributes.
    public function toJSON(options: Dynamic): Dynamic;

    // Proxy `Backbone.sync` by default.
    public function sync(): Dynamic;

    // Add a model, or list of models to the set.
    @:overload(function(model: T, ?options: Dynamic): T{})
    public function add(models: Array<Model>, ?options: Dynamic): Array<T>;

    // Remove a model, or a list of models from the set.
    @:overload(function(model: T, ?options: Dynamic): T{})
    @:overload(function(id: String, ?options: Dynamic): T{})
    @:overload(function(query: Dynamic, ?options: Dynamic): Array<T>{})
    public function remove(models: Array<Model>, ?options: Dynamic): Dynamic;

    // Update a collection by `set`-ing a new list of models, adding new ones,
    // removing models that are no longer present, and merging models that
    // already exist in the collection, as necessary. Similar to **Model#set**,
    // the core operation for updating the data contained by the collection.
    @:overload(function(model: T, ?options: Dynamic): T {})
    public function set(models: Array<T>, ?options: Dynamic): Array<T>;
    // When you have more items than you want to add or remove individually,
    // you can reset the entire set with a new list of models, without firing
    // any granular `add` or `remove` events. Fires `reset` when finished.
    // Useful for bulk operations and optimizations.
    @:overload(function(model: T, ?options: Dynamic): T {})
    public function reset(models: Array<T>, ?options: Dynamic): Array<T>;

    // Add a model to the end of the collection.
    public function push(model: T, ?options: Dynamic): T;

    // Remove a model from the end of the collection.
    public function pop(?options: Dynamic): T;
    // Add a model to the beginning of the collection.
    public function unshift(model: T, ?options: Dynamic): T;
    // Remove a model from the beginning of the collection.
    public function shift(?options: Dynamic): T;
    // Slice out a sub-array of models from the collection.
    public function slice(): Array<T>;
    // Get a model from the set by id.
    @:overload(function(id: String): T{})
    public function get(obj: T): T;
    // Get the model at the given index.
    public function at(index: Int): T;
    // Return models with matching attributes. Useful for simple cases of
    // `filter`.
    public function where(attrs: Dynamic, ?first: Bool = false): Array<T>;
    // Return the first model with matching attributes. Useful for simple cases
    // of `find`.
    public function findWhere(attrs: Dynamic): T;
    // Force the collection to re-sort itself. You don't need to call this under
    // normal circumstances, as the set will maintain sort order as each item
    // is added.
    public function sort(?options: Dynamic): Collection<T>;
    // Pluck an attribute from each model in the collection.
    public function pluck<A>(attr: Dynamic): Array<A>;
    // Fetch the default set of models for this collection, resetting the
    // collection when they arrive. If `reset: true` is passed, the response
    // data will be passed through the `reset` method instead of `set`.
    public function fetch(?options: Dynamic): Dynamic;
    // Create a new instance of a model in this collection. Add the model to the
    // collection immediately, unless `wait: true` is passed, in which case we
    // wait for the server to agree.
    public function create(model: Dynamic, ?options: Dynamic): T;
    // **parse** converts a response into a list of models to be added to the
    // collection. The default implementation is just to pass it through.
    public function parse(resp: Dynamic, ?options: Dynamic): Dynamic;
    // Create a new collection with an identical list of models as this one.
    public function clone(): Collection<T>;
    // Define how to uniquely identify models in the collection.
    public function modelId(attrs: Dynamic): String;

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