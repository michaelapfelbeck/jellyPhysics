package jellyPhysics;

/**
 * ...
 * @author Michael Apfelbeck
 */
class BodyPointMassRef
{
    public var BodyID:Int;
    public var PointMassIndex:Int;
    public var Distance:Float;
    public function new(bodyId:Int, pointMassIndex:Int, distance:Float) 
    {
        BodyID = bodyId;
        PointMassIndex = pointMassIndex;
        Distance = distance;
    }
    
}