package jellyPhysics.math;
import jellyPhysics.math.Vector2;
import jellyPhysics.math.Vector3;
import jellyPhysics.Intersection;

/**
 * ...
 * @author Michael Apfelbeck
 */
class VectorTools
{
    public static function RotateVector(vector: Vector2, angleInRadians:Float):Vector2
    {
        var result:Vector2 = new Vector2();
        var c:Float = Math.cos(angleInRadians);
        var s:Float = Math.sin(angleInRadians);
        result.x = (c * vector.x) - (s * vector.y);
        result.y = (c * vector.y) + (s * vector.x);
        return result;
    }

    //Reflect a vector about a normal. Normal must be a unit vector.
    public static function ReflectVector(vector: Vector2, normal:Vector2):Vector2
    {
        var result:Vector2 = new Vector2(vector.x, vector.y);
        var twiceDot:Float = 2.0 * Dot(vector, normal);
        result.x -= normal.x * twiceDot;
        result.y -= normal.y * twiceDot;
        
        return result;
    }
    
    //Vector dot product.
    public static function Dot(vectorA: Vector2, vectorB:Vector2):Float
    {
        return (vectorA.x * vectorB.x) + (vectorA.y * vectorB.y);
    }
    
    public static function Distance(vectorA: Vector2, vectorB:Vector2):Float
    {
        return new Vector2(vectorA.x - vectorB.x, vectorA.y - vectorB.y).length();
    }
    
    public static function DistanceSquared(vectorA: Vector2, vectorB:Vector2):Float
    {
        var dist = Distance(vectorA, vectorB);
        return dist * dist;
    }
    
    //Get a vector perpendicular to the passed in vector
    public static function GetPerpendicular(vector:Vector2):Vector2
    {
        return new Vector2( -vector.y, vector.x);
    }
    
    //Is rotating from A to B Counter-clockwise?
    public static function IsCCW(vectorA:Vector2, vectorB:Vector2):Bool
    {
        //vectorA.x *=-1;
        //vectorB.x *=-1;
        var perp:Vector2 = GetPerpendicular(vectorA);
        var dot:Float = Dot(vectorB, perp);
        return dot >= 0.0;
    }
    
    public static function Vec4FromVec2(vector:Vector2, ?z:Float):Vector3{
        return new Vector3(vector.x, vector.y, (null == z)?0: z);
    }
    
    /// see if 2 line segments intersect. (line AB collides with line CD)
    // pointA: first point on line AB
    // pointB: second point on line AB
    // pointC: first point on line CD
    // pointD: second point on line CD
    // return: Intersection object. Null if no intersection.
    public static function LineIntersect(pointA:Vector2, pointB:Vector2, pointC:Vector2, pointD:Vector2):Intersection
    {
        var denom:Float = ((pointD.y - pointC.y) * (pointB.x - pointA.x)) - ((pointD.x - pointC.x) * (pointB.y - pointA.y));

        // if denom == 0, lines are parallel - being a bit generous on this one..
        if (Math.abs(denom) < 0.000001)
            return null;
            
        var Ua:Float;
        var Ub:Float;

        var UaTop:Float = ((pointD.x - pointC.x) * (pointA.y - pointC.y)) - ((pointD.y - pointC.y) * (pointA.x - pointC.x));
        var UbTop:Float = ((pointB.x - pointA.x) * (pointA.y - pointC.y)) - ((pointB.y - pointA.y) * (pointA.x - pointC.x));

        Ua = UaTop / denom;
        Ub = UbTop / denom;

        if ((Ua >= 0.0) && (Ua <= 1.0) && (Ub >= 0.0) && (Ub <= 1.0))
        {
            // these lines intersect!
            var hitX:Float = pointA.x + ((pointB.x - pointA.x) * Ua);
            var hitY:Float = pointA.y + ((pointB.y - pointA.y) * Ua);
            
            var hitPt:Vector2 = new Vector2(hitX, hitY);
            var intersect:Intersection = new Intersection(hitPt, Ua, Ub);
            return intersect;
        }
        
        return null;
    }
    
    public static function CalculateSpringForce(posA:Vector2, velA:Vector2, posB:Vector2, velB:Vector2, springLen:Float, springK:Float, damping:Float):Vector2
    {
        var BtoA:Vector2 = new Vector2();
        BtoA.x = posA.x - posB.x;
        BtoA.y = posA.y - posB.y;

        var dist:Float = BtoA.length();
        if (dist > 0.0001)
        {
            BtoA.x /= dist;
            BtoA.y /= dist;
        }else{
            BtoA.x = 0;
            BtoA.y = 0;
            return BtoA;
        }
        
        dist = springLen - dist;

        //Vector2 relVel = velA - velB;
        var relVel:Vector2 = new Vector2();
        relVel.x = velA.x - velB.x;
        relVel.y = velA.y - velB.y;
        
        var totalRelVel:Float;
        totalRelVel = Dot(relVel, BtoA);

        BtoA.x *= ((dist * springK) - (totalRelVel * damping));
        BtoA.y *= ((dist * springK) - (totalRelVel * damping));
        return BtoA; 
    }
    
    public static function Subtract(vectorA:Vector2, vectorB:Vector2):Vector2
    {
        return new Vector2(vectorA.x - vectorB.x, vectorA.y - vectorB.y);
    }
    
    public static function Add(vectorA:Vector2, vectorB:Vector2):Vector2
    {
        return new Vector2(vectorA.x + vectorB.x, vectorA.y + vectorB.y);
    }
    
    public static function Multiply(vector:Vector2, scalar:Float):Vector2
    {
        return new Vector2(vector.x * scalar, vector.y * scalar);
    }
    
    public static function LengthSquared(vector:Vector2):Float
    {
        return (vector.x * vector.x) + (vector.y + vector.y);
    }
}