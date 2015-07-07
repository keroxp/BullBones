package cv;

typedef FilterFunc = {
    name: String,
    args: Array<Dynamic>
}

class FilterFactory {
    // alpha
    public static function alpha(a: Int): FilterFunc {
        return {
            name: "alpha",
            args:[a]
        }
    }
    // グレスケ
    public static function gray(): FilterFunc {
        return {
            name: "gray",
            args: []
        }
    }
    // 二値化
    public static function binalize(?t:Int = 128): FilterFunc {
        return {
            name: "binalize",
            args: [t]
        }
    }
    // ネガポジ
    public static function negaposi(): FilterFunc {
        return {
            name: "negaposi",
            args: []
        }
    }
    // エッジ検出（8近傍ラプラシアン）
    public static function edge1():FilterFunc {
        return sobel(5);
    }
    // エッジ検出（4近傍ラプラシアン）
    public static function edge2():FilterFunc {
        return sobel(0);
    }
    // ソーベル（第二引数に0を渡すと4近傍、5を渡すと8近傍ラプラシアン）
    public static function sobel(course:Int): FilterFunc {
        return {
            name: "sobel",
            args: [course]
        }
    }
}
