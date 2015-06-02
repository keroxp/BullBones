package cv;
import js.html.ImageData;
import js.html.CanvasElement;

class Filter {
  private var bufImg: ImageData;
  private var orgImg: ImageData;
  private var w: Int;
  private var h: Int;
  public function new(orgImg: ImageData, w:Int, h: Int) {
    this.orgImg = orgImg;
    this.bufImg = orgImg;
    this.w = w;
    this.h = h;
  }
  private static function createTmpImage (w: Int, h: Int): ImageData {
    var dummyCanvas: CanvasElement = cast js.Browser.document.createElement("canvas");
    var dummyContext = dummyCanvas.getContext2d();
    var outImg = dummyContext.createImageData(w,h);
    for (y in 0...h) {
      for (x in 0...w) {
        var i = (y*w + x)*4;
        outImg.data[i] = 255;
        outImg.data[i+1] = 255;
        outImg.data[i+2] = 255;
        outImg.data[i+3] = 255;
      }
    }
    return outImg;
  }
  public function applyGray (): Filter {
    bufImg = gray(bufImg,w,h);
    return this;
  }
  public function applyNegaposi (): Filter {
    bufImg = negaposi(bufImg,w,h);
    return this;
  }
  public function applyBinalize (t: Int): Filter {
    bufImg = binalize(bufImg,w,h,t);
    return this;
  }
  public function applySobel (course: Int): Filter {
    bufImg = sobel(bufImg,w,h,course);
    return this;
  }
  public function applyEdge1 (): Filter {
    bufImg = edge1(bufImg,w,h);
    return this;
  }
  public function applyEdge2 (): Filter {
    bufImg = edge2(bufImg,w,h);
    return this;
  }
  public function get () : ImageData {
    return bufImg;
  }
  // グレスケ
  public static function gray (inImg: ImageData, w:Int, h: Int): ImageData {
    var outImg = createTmpImage(w,h);
    for (y in 0...h) {
      for (x in 0...w) {
        var i = (y*w + x)*4;
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
  // 二値化
  public static function binalize (inImg: ImageData, w:Int, h: Int, ?t: Int = 128): ImageData {
    var outImg = createTmpImage(w,h);
    for (y in 0...h) {
      for (x in 0...w) {
        var i = (y+w+x)*4;
        if (inImg.data[i] < t) {
          outImg.data[i] = 0;
        } else {
          outImg.data[i] = 255;
        }
      }
    }
    return outImg;
  }
  // ネガポジ
  public static function negaposi (inImg: ImageData, w: Int, h: Int): ImageData {
    var outImg = createTmpImage(w,h);
    for (y in 0...h) {
      for (x in 0...w) {
        var i = (y*w + x)*4;
        outImg.data[i] = 255 - inImg.data[i];
        outImg.data[i+1] = 255 - inImg.data[i+1];
        outImg.data[i+2] = 255 - inImg.data[i+2];
        outImg.data[i+3] = inImg.data[i+3];
      }
    }
    return outImg;
  }
  // エッジ検出（8近傍ラプラシアン）
  public static function edge1(inImg: ImageData, w: Int, h: Int): ImageData {
    return Filter.sobel(inImg,w,h,5);
  }
  // エッジ検出（4近傍ラプラシアン）
  public static function edge2(inImg: ImageData, w: Int, h: Int): ImageData {
    return Filter.sobel(inImg,w,h,0);
  }
  private static var SOBEL_MATRIXES = [
    [0, 1, 0, 1, -4, 1, 0, 1, 0],	// 4近傍
    [0, -1, -2, 1, 0, -1, 2, 1, 0],
    [-1, -2, -1, 0, 0, 0, 1, 2, 1],
    [-2, -1, 0, -1, 0, 1, 0, 1, 2],
    [1, 0, -1, 2, 0, -2, 1, 0, -1],
    [1, 1, 1, 1, -8, 1, 1, 1, 1],	// 8近傍
    [-1, 0, 1, -2, 0, 2, -1, 0, 1],
    [2, 1, 0, 1, 0, -1, 0, -1, -2],
    [1, 2, 1, 0, 0, 0, -1, -2, -1],
    [0, 1, 2, -1, 0, 1, -2, -1, 0]
  ];
  // ソーベル（第二引数に0を渡すと4近傍、5を渡すと8近傍ラプラシアン）
  public static function sobel (inImg: ImageData, w: Int, h: Int, course: Int): ImageData {
    var outImg = createTmpImage(w,h);
    var S = SOBEL_MATRIXES[course];
    for (y in 0...h) {
      for (x in 0...w) {
        for (c in 0...3) {
          var i = (y*w + x)*4 + c;
          outImg.data[i] =
          S[0]*inImg.data[i - w*4 - 4] + S[1]*inImg.data[i -w*4] + S[2]*inImg.data[i -w*4 + 4] +
          S[3]*inImg.data[i - 4] + S[4]*inImg.data[i] + S[5]*inImg.data[i + 4] +
          S[6]*inImg.data[i +w*4 - 4] + S[7]*inImg.data[i +w*4] + S[8]*inImg.data[i +w*4 + 4];
        }
        outImg.data[(y*w + x)*4 + 3] = inImg.data[(y*w + x)*4 + 3]; // alpha
      }
    }
    return outImg;
  }
}
