package jellyPhysics;
import jellyPhysics.math.Vector2;

/**
 * ...
 * @author Michael Apfelbeck
 */
class Intersection
{
    //point of intersection between 2 lines.
    public var HitPoint:Vector2;
    
    //normalized distance on AB
    public var IntersectAB:Float;
    
    ////normalized distance on CD
    public var IntersectCD:Float;

    public function new(hitPoint:Vector2, intersectAB:Float, intersectCD:Float) 
    {
        HitPoint = hitPoint;
        IntersectAB = intersectAB;
        IntersectCD = intersectCD;
    }
    
}