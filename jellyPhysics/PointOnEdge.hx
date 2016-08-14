package jellyPhysics;
import jellyPhysics.math.Vector2;

/**
 * Represents a point on the edge of a Body
 * @author Michael Apfelbeck
 */
class PointOnEdge
{
    // Edge number on the body, 1 = edge between points 1 and 2, 2 between 2 and 3...
    public var EdgeNum:Int;
    // Distance in global space from point and hit point
    public var Distance:Float;
    // Point on edge in global space
    public var Point:Vector2;
    // Normal on Edge in global space
    public var Normal:Vector2;
    // Normalized distance between start and end point
    public var EdgeDistance:Float;
    
    public function new(edgeNum:Int, distance:Float, point:Vector2, normal:Vector2, edgeDistance:Float) 
    {
        EdgeNum = edgeNum;
        Distance = distance;
        Point = point;
        Normal = normal;
        EdgeDistance = edgeDistance;
    }
    
}