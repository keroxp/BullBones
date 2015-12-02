package deferred;
import deferred.Promise;
@:native("jQuery.Deferred")
extern class Deferred<D,E,P> extends Promise<D,E,P> {
    /**
		 Reject a Deferred object and call any failCallbacks with the given <code>args</code>.
	**/
    @:jQueryVersion({ added : "1.5" })
    public function reject(?args:E):Deferred <D,E,P>;
    /**
		 Determine whether a Deferred object has been rejected.
	**/
    @:jQueryVersion({ added : "1.5", deprecated : "1.7", removed : "1.8" })
    public function isRejected():Bool;
    /**
		 Determine whether a Deferred object has been resolved.
	**/
    @:jQueryVersion({ added : "1.5", deprecated : "1.7", removed : "1.8" })
    public function isResolved():Bool;
    /**
		 Resolve a Deferred object and call any doneCallbacks with the given <code>context</code> and <code>args</code>.
	**/
    @:jQueryVersion({ added : "1.5" })
    public function resolveWith(context:Dynamic, ?args:Array<Dynamic>):Deferred <D,E,P>;
    /**
		 A factory function that returns a chainable utility object with methods to register multiple callbacks into callback queues, invoke callback queues, and relay the success or failure state of any synchronous or asynchronous function.
	**/
    @:selfCall
    @:jQueryVersion({ added : "1.5" })
    public function new(?beforeStart:Deferred<D,P,E> -> Void):Void;
    /**
		 Call the progressCallbacks on a Deferred object with the given <code>args</code>.
	**/
    @:jQueryVersion({ added : "1.7" })
    public function notify(args:P): Deferred<D,E,P>;
    /**
		 Call the progressCallbacks on a Deferred object with the given context and <code>args</code>.
	**/
    @:jQueryVersion({ added : "1.7" })
    public function notifyWith(context:Dynamic, ?args:Array<Dynamic>):Deferred <D,E,P>;
    /**
		 Reject a Deferred object and call any failCallbacks with the given <code>context</code> and <code>args</code>.
	**/
    @:jQueryVersion({ added : "1.5" })
    public function rejectWith(context:Dynamic, ?args:Array<Dynamic>):Deferred <D,E,P>;
    /**
		 Return a Deferred's Promise object.
	**/
    @:jQueryVersion({ added : "1.5" })
    public function promise(?target:Dynamic):Promise<D,E,P>;
    /**
		 Resolve a Deferred object and call any doneCallbacks with the given <code>args</code>.
	**/
    @:jQueryVersion({ added : "1.5" })
    public function resolve(?args:D):Deferred <D,E,P>;

}
