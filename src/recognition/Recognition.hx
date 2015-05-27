package recognition;
import geometry.Vector2D;
import geometry.Point;
class Recognition {
    public static function line (points: Array<Point>): Float {
        var s = points[0];
        var e = points[points.length-1];
        var se = new Vector2D(e.x-s.x,e.y-s.y);
        var leftMax: Float = 0;
        var rightMax: Float = 0;
        // 始点から終点のベクトル(SE->)と、始点と各点のベクトル(SP->)の法線の長さを計算する
        //x2 = x1 * cos(α) - y1 * sin(α)
        //y2 = x1 * sin(α) + y1 * cos(α)
        var n1 = new Vector2D(
            se.dx*Math.cos(Math.PI/2) - se.dy * Math.sin(Math.PI/2),
            se.dx*Math.sin(Math.PI/2) + se.dy * Math.cos(Math.PI/2)
        ).normalize();
        var n2 = new Vector2D(
            se.dx*Math.cos(-Math.PI/2) - se.dy * Math.sin(-Math.PI/2),
            se.dx*Math.sin(-Math.PI/2) + se.dy * Math.cos(-Math.PI/2)
        ).normalize();
        for (i in 1...points.length-2) {
            var sp = new Vector2D(points[i].x-s.x,points[i].y-s.y);
            var cos = se.dot(sp)/(se.power()*sp.power());
            var sin = Math.sin(Math.acos(cos));
            var w = sp.power()*sin;
            var n1p = sp.sub(se.add(n1)).power();
            var n2p = sp.sub(se.add(n2)).power();
            if (n1p > n2p && rightMax < w) {
                rightMax = w;
            } else if (leftMax < w){
                leftMax = w;
            }
        }
        trace("rmax: "+rightMax+" lmax: "+leftMax);
        return rightMax+leftMax;
    }
}
