package backbone.haxe;
class BackboneCollection {
    public static function extend<T: Model>(model: T): Collection<T> {
        return new Collection<T>({
            model: model
        });
    }
}
