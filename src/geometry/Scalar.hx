package geometry;
import geometry.Scalar;
import util.BrowserUtil;
/*
    Retina対応のためdevicePixelRatioを加算したFloat
 */
abstract Scalar(Float) from Float to Float {
    public static inline function valueOf(float: Float): Float return new Scalar(float);
    public inline function new(value: Float, scale: Bool = true) {
        this = conv(value, scale);
    }
    private inline function conv(value: Float, flag: Bool): Float {
        return flag ? value * BrowserUtil.dpr : value;
    }

    @:to
    public inline function toInt(): Int return Std.int(this);

    @:to
    public inline function toFloat(): Float return this;

    @:op(A+B) @:commutive
    public static function add(lhd: Scalar, rhd: Scalar): Scalar {
        return new Scalar(lhd.toFloat()+rhd.toFloat(), false);
    }

    @:op(A-B) @:commutive
    public static function sub(lhd: Scalar, rhd: Scalar): Scalar {
        return new Scalar(lhd.toFloat()-rhd.toFloat(), false);
    }

    @:op(A*B) @:commutive
    public static function mul(lhd: Scalar, rhd: Scalar): Scalar {
        return new Scalar(lhd.toFloat()*rhd.toFloat(), false);
    }

    @:op(A/B) @:commutive
    public static function div(lhd: Scalar, rhd: Scalar): Scalar {
        return new Scalar(lhd.toFloat()/rhd.toFloat(), false);
    }

    @:op(A+B) @:commutive
    public static function addFloat(lhd: Scalar, rhd: Float): Scalar {
        return lhd+new Scalar(rhd);
    }

    @:op(A-B) @:commutive
    public static function subFloat(lhd: Scalar, rhd: Float): Scalar {
        return lhd-new Scalar(rhd);
    }

    @:op(A*B) @:commutive
    public static function mulFloat(lhd: Scalar, rhd: Float): Scalar {
        return lhd*new Scalar(rhd);
    }

    @:op(A/B) @:commutive
    public static function divFloat(lhd: Scalar, rhd: Float): Scalar {
        return lhd/new Scalar(rhd);
    }

}
