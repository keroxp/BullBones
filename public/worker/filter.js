(function(){
    function createTmpImage(w, h) {
        return new ImageData(new Uint8ClampedArray(4*w*h),w,h);
    }
    // alpha
    function alpha(a) {
        return function (inImg) {
            var out = createTmpImage(inImg.width,inImg.height);
            for (var i = 0, max = inImg.data.length;  i < max|0; i=(i+4)|0) {
                out.data[i] = inImg.data[i];
                out.data[i+1] = inImg.data[i+1];
                out.data[i+2] = inImg.data[i+2];
                out.data[i+3] = a;
            }
            return out;
        };
    }
    // グレスケ
    function gray() {
        return function (inImg) {
            var w = inImg.width;
            var h = inImg.height;
            var outImg = createTmpImage(w, h);
            for (var y = 0; y < h|0; y=(y+1)|0) {
                for (var x = 0; x < w|0; x=(x+1)|0) {
                    var i = (y * w + x) * 4;
                    // グレースケールの定数
                    var gray = 0;
                    gray += 0.299 * inImg.data[i];
                    gray += 0.587 * inImg.data[i + 1];
                    gray += 0.114 * inImg.data[i + 2];
                    outImg.data[i + 0] = gray;
                    outImg.data[i + 1] = gray;
                    outImg.data[i + 2] = gray;
                    outImg.data[i + 3] = inImg.data[i + 3];
                }
            }
            return outImg;
        };
    }
    // 二値化
    function binalize(t) {
        t = t || 128;
        return function (inImg) {
            var w = inImg.width;
            var h = inImg.height;
            var outImg = createTmpImage(w, h);
            for (var y = 0; y < h|0; y=(y+1)|0) {
                for (var x = 0; x < w|0; x=(x+1)|0) {
                    var i = (y + w + x) * 4;
                    if (inImg.data[i] < t) {
                        outImg.data[i] = 0;
                    } else {
                        outImg.data[i] = 255;
                    }
                }
            }
            return outImg;
        };
    }
    // ネガポジ
    function negaposi() {
        return function(inImg) {
            var w = inImg.width;
            var h = inImg.height;
            var outImg = createTmpImage(w, h);
            for (var y = 0; y < h|0; y=(y+1)|0) {
                for (var x = 0; x < w|0; x=(x+1)|0) {
                    var i = (y * w + x) * 4;
                    outImg.data[i] = 255 - inImg.data[i];
                    outImg.data[i + 1] = 255 - inImg.data[i + 1];
                    outImg.data[i + 2] = 255 - inImg.data[i + 2];
                    outImg.data[i + 3] = inImg.data[i + 3];
                }
            }
            return outImg;
        };
    }
    // エッジ検出（8近傍ラプラシアン）
    function edge1() {
        return sobel(5);
    }
    // エッジ検出（4近傍ラプラシアン）
    function edge2() {
        return sobel(0);
    }
    var SOBEL_MATRIXES = [
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
    function sobel(course) {
        course = course || 0;
        return function (inImg) {
            var w = inImg.width;
            var h = inImg.height;
            var S = SOBEL_MATRIXES[course];
            var outImg = createTmpImage(w, h);
            for (var y = 0; y < h|0; y=(y+1)|0) {
                for (var x = 0; x < w|0; x=(x+1)|0) {
                    for (var c = 0; c < 3|0; c=(c+1)|0) {
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
        };
    }
    function getFilter(f) {
        switch (f.name) {
            case "alpha": return apply.apply(this, f.args);
            case "gray": return gray.apply(this);
            case "negaposi": return negaposi.apply(this);
            case "binalize": return binalize.apply(this, f.args);
            case "edge1": return edge1.apply(this);
            case "edge2": return edge2.apply(this);
            case "sobel": return sobel.apply(this,f.args);
        }
    }
    /*
    e.data = {
        imageData: ImageData
        filters: Array<Filter>
    }
    Filter = {
        name: String,
        args: Array<Dynamic>
    }
    */
    onmessage = function (e) {
        var imageData = e.data.imageData;
        var filters = e.data.filters;
        if (!imageData || !filters) {
            throw new Error("imageData or filters is null.");
        } else {
            var ret = imageData;
            for (var i = 0, max = filters.length|0; i < max|0; i=(i+1)|0) {
                var f = getFilter(filters[i]);
                if (f) {
                    ret = f(ret);
                }
            }
            postMessage({
                result: ret
            });
        }
    };
})();
