package geometry;
import geometry.Scalar;
import util.BrowserUtil;
/*
    Retina対応のためdevicePixelRatioを加算したFloat
 */
abstract Scalar(Float) {
    public static inline function valueOf(float: Float): Scalar return new Scalar(float);
    public inline function new(value: Float, scale: Bool = true) {
        this = scale ? conv(value) : value;
    }
    private static function conv(value: Float): Float {
        return value * BrowserUtil.dpr;
    }

    @:to
    public inline function toFloat(): Float return this;

    @:to
    public inline function toInt(): Int return Std.int(this);

    private inline function toScalar(): Scalar return new Scalar(toFloat(), false);

    @:op(A+B)
    public static function add(lhd: Scalar, rhd: Scalar): Scalar {
        return new Scalar(lhd.toFloat()+rhd.toFloat(), false);
    }

    @:op(A-B)
    public static function sub(lhd: Scalar, rhd: Scalar): Scalar {
        return new Scalar(lhd.toFloat()-rhd.toFloat(), false);
    }

    @:op(A*B)
    public static function mul(lhd: Scalar, rhd: Scalar): Scalar {
        return new Scalar(lhd.toFloat()*rhd.toFloat(), false);
    }

    @:op(A/B)
    public static function div(lhd: Scalar, rhd: Scalar): Scalar {
        return new Scalar(lhd.toFloat()/rhd.toFloat(), false);
    }

    public function addf(rhd: Float): Scalar {
        return new Scalar(toFloat()+conv(rhd), false);
    }

    public function subf(rhd: Float): Scalar {
        return new Scalar(toFloat()-conv(rhd), false);
    }

}
