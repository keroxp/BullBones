package deferred;
@:native("jQuery.Promise")
extern class Promise <D,E,P> {
    /**
		Add handlers to be called when the Deferred object is resolved, rejected, or still in progress.
	**/
    @:jQueryVersion({ added : "1.8" })
    public function then(doneCallbacks: D -> Void, failCallbacks: E -> Void, ?progressFilter: P -> Void):Promise<D,E,P>;
    /**
		 Add handlers to be called when the Deferred object is rejected.
	**/
    @:jQueryVersion({ added : "1.5" })
    public function fail(failCallbacks: E -> Void):Deferred<D,E,P>;
    /**
		 Add handlers to be called when the Deferred object generates progress notifications.
	**/
    @:jQueryVersion({ added : "1.7" })
    public function progress(progressCallbacks: P -> Void, ?progressCallbacks: Array<P->Void>): Deferred<D,E,P>;
    /**
		Determine the current state of a Deferred object.
	**/
    @:jQueryVersion({ added : "1.7" })
    public function state():String;
    /**
		 Add handlers to be called when the Deferred object is resolved.
	**/
    @:jQueryVersion({ added : "1.5" })
    public function done(doneCallbacks: D -> Void): Promise<D,E,P>;
    /**
		 Add handlers to be called when the Deferred object is either resolved or rejected.
	**/
    @:jQueryVersion({ added : "1.6" })
    public function always(alwaysCallbacks: Void -> Void, ?alwaysCallbacks: Array<Void -> Void>): Promise<D,E,P>;

}
