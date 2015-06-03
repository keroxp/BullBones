package backbone;

import jQuery.JQuery;
@:native("Backbone.Events")
extern interface Events {
  // Bind an event to a `callback` function. Passing `"all"` will bind
  // the callback to all events fired.
  public function on(name: String, callback: Dynamic, ?context: Dynamic): Events;

  // Inversion-of-control versions of `on`. Tell *this* object to listen to
  //  an event in another object... keeping track of what it's listening to.
  public function listenTo(obj: Events, name: String, callback: Dynamic): Events;

  // Remove one or many callbacks. If `context` is null, removes all
  // callbacks with that function. If `callback` is null, removes all
  // callbacks for the event. If `name` is null, removes all bound
  // callbacks for all events.
  public function off(name: String, callback: Dynamic, ?context: Dynamic): Events;


  // Tell this object to stop listening to either specific events ... or
  // to every object it's currently listening to.
  public function stopListening(obj: Events, name: String, callback: Dynamic): Events;

  // Bind an event to only be triggered a single time. After the first time
  // the callback is invoked, it will be removed. When multiple events are
  // passed in using the space-separated syntax, the event will fire once for every
  // event you passed in, not once for a combination of all events
  public function once(name: String, callback: Dynamic, ?context: Dynamic): Events;

  // Inversion-of-control versions of `once`.
  public function listenToOnce(obj: Events, name: String, callback: Dynamic): Events;

  // Trigger one or many events, firing all bound callbacks. Callbacks are
  // passed the same arguments as `trigger` is, apart from the event name
  // (unless you're listening on `"all"`, which will cause your callback to
  // receive the true name of the event as the first argument).
  public function trigger(name: String): Events;

  // Aliases for backwards compatibility.
  public function bind(name: String, callback: Dynamic, ?context: Dynamic): Events;
  public function unbind(name: String, callback: Dynamic, ?context: Dynamic): Events;
}

class BackboneEvents implements Events {
  private var __backbone_events: Events;
  public function new () {
    __backbone_events = JQuery._static.extend({}, backbone.Backbone.Events);
  }
  public function on(name: String, callback: Dynamic -> Void, ?context: Dynamic): Events {
    return __backbone_events.on(name,callback,context);
  }
  public function listenTo(obj: Events, name: String, callback: Dynamic -> Void): Events {
    return __backbone_events.listenTo(obj,name,callback);
  }
  public function off(name: String, callback: Dynamic -> Void, ?context: Dynamic): Events {
    return __backbone_events.off(name,callback,context);
  }
  public function stopListening(obj: Events, name: String, callback: Dynamic -> Void): Events {
    return __backbone_events.stopListening(obj,name,callback);
  }
  public function once(name: String, callback: Dynamic -> Void, ?context: Dynamic): Events {
    return __backbone_events.once(name,callback,context);
  }
  public function listenToOnce(obj: Events, name: String, callback: Dynamic -> Void): Events {
    return __backbone_events.listenToOnce(obj,name,callback);
  }
  public function trigger(name: String): Events {
    return __backbone_events.trigger(name);
  }
  public function bind(name: String, callback: Dynamic -> Void, ?context: Dynamic): Events {
    return __backbone_events.bind(name,callback,context);
  }
  public function unbind(name: String, callback: Dynamic -> Void, ?context: Dynamic): Events {
    return __backbone_events.unbind(name,callback,context);
  }
}