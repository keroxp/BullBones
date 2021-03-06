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
    //　ガウシアン
    public static function gaussian3x3(): FilterFunc {
        return {
            name: "gaussian3x3",
            args:[]
        }
    }
    // ガウシアン5x5
    public static function gaussian5x5(): FilterFunc {
        return {
            name: "gaussian5x5",
            args:[]
        }
    }
    // 二値化
    public static function binalize(?t:Int = 128): FilterFunc {
        return {
            name: "binalize",
            args: [t]
        }
    }
    public static function transparent(?t:Int = 255): FilterFunc {
        return {
            name: "transparent",
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
    public static function edge1(grayed):FilterFunc {
        return sobel(5,grayed);
    }
    // エッジ検出（4近傍ラプラシアン）
    public static function edge2(grayed):FilterFunc {
        return sobel(0,grayed);
    }
    // ソーベル（第二引数に0を渡すと4近傍、5を渡すと8近傍ラプラシアン）
    public static function sobel(course:Int, grayed: Bool = false): FilterFunc {
        return {
            name: "sobel",
            args: [course, grayed]
        }
    }
}
