package cv;
import cv.ImageUtil;
import js.html.ImageData;

typedef FilterFunc = ImageData -> ImageData;

class FilterFactory {
    // alpha
    public static function alpha(a: Int) {
        return function (inImg: ImageData): ImageData {
            var out = ImageUtil.createTmpImage(inImg.width,inImg.height);
            var i = 0;
            while (i < inImg.data.length) {
                out.data[i] = inImg.data[i];
                out.data[i+1] = inImg.data[i+1];
                out.data[i+2] = inImg.data[i+2];
                out.data[i+3] = a;
                i += 4;
            }
            return out;
        }
    }
    // グレスケ
    public static function gray(): FilterFunc {
        return function (inImg:ImageData):ImageData {
            var w = inImg.width;
            var h = inImg.height;
            var outImg = ImageUtil.createTmpImage(w, h);
            for (y in 0...h) {
                for (x in 0...w) {
                    var i = (y * w + x) * 4;
                    // グレースケールの定数
                    var gray = 0
                    + 0.299 * inImg.data[i]
                    + 0.587 * inImg.data[i + 1]
                    + 0.114 * inImg.data[i + 2];
                    outImg.data[i + 0] = cast gray;
                    outImg.data[i + 1] = cast gray;
                    outImg.data[i + 2] = cast gray;
                    outImg.data[i + 3] = inImg.data[i + 3];
                }
            }
            return outImg;
        }
    }
    // 二値化
    public static function binalize(?t:Int = 128): FilterFunc {
        return function (inImg:ImageData):ImageData {
            var w = inImg.width;
            var h = inImg.height;
            var outImg = ImageUtil.createTmpImage(w, h);
            for (y in 0...h) {
                for (x in 0...w) {
                    var i = (y + w + x) * 4;
                    if (inImg.data[i] < t) {
                        outImg.data[i] = 0;
                    } else {
                        outImg.data[i] = 255;
                    }
                }
            }
            return outImg;
        }
    }
    // ネガポジ
    public static function negaposi(): FilterFunc {
        return function(inImg:ImageData):ImageData {
            var w = inImg.width;
            var h = inImg.height;
            var outImg = ImageUtil.createTmpImage(w, h);
            for (y in 0...h) {
                for (x in 0...w) {
                    var i = (y * w + x) * 4;
                    outImg.data[i] = 255 - inImg.data[i];
                    outImg.data[i + 1] = 255 - inImg.data[i + 1];
                    outImg.data[i + 2] = 255 - inImg.data[i + 2];
                    outImg.data[i + 3] = inImg.data[i + 3];
                }
            }
            return outImg;
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
    private static var SOBEL_MATRIXES = [
        [0, 1, 0, 1, -4, 1, 0, 1, 0], // 4近傍
        [0, -1, -2, 1, 0, -1, 2, 1, 0],
        [-1, -2, -1, 0, 0, 0, 1, 2, 1],
        [-2, -1, 0, -1, 0, 1, 0, 1, 2],
        [1, 0, -1, 2, 0, -2, 1, 0, -1],
        [1, 1, 1, 1, -8, 1, 1, 1, 1], // 8近傍
        [-1, 0, 1, -2, 0, 2, -1, 0, 1],
        [2, 1, 0, 1, 0, -1, 0, -1, -2],
        [1, 2, 1, 0, 0, 0, -1, -2, -1],
        [0, 1, 2, -1, 0, 1, -2, -1, 0]
    ];
    // ソーベル（第二引数に0を渡すと4近傍、5を渡すと8近傍ラプラシアン）
    public static function sobel(course:Int): FilterFunc {
        return function (inImg:ImageData): ImageData {
            var w = inImg.width;
            var h = inImg.height;
            var S = SOBEL_MATRIXES[course];
            var outImg = ImageUtil.createTmpImage(w, h);
            for (y in 0...h) {
                for (x in 0...w) {
                    for (c in 0...3) {
                        var i = (y * w + x) * 4 + c;
                        outImg.data[i] =
                        S[0] * inImg.data[i - w * 4 - 4] + S[1] * inImg.data[i - w * 4] + S[2] * inImg.data[i - w * 4 + 4] +
                        S[3] * inImg.data[i - 4] + S[4] * inImg.data[i] + S[5] * inImg.data[i + 4] +
                        S[6] * inImg.data[i + w * 4 - 4] + S[7] * inImg.data[i + w * 4] + S[8] * inImg.data[i + w * 4 + 4];
                    }
                    outImg.data[(y * w + x) * 4 + 3] = inImg.data[(y * w + x) * 4 + 3]; // alpha
                }
            }
            return outImg;
        }
    }
}
