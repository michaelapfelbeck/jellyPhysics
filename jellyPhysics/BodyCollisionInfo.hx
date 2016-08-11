package jellyPhysics;
import jellyPhysics.Body;
import lime.math.Vector2;

/**
 * ...
 * @author Michael Apfelbeck
 */
class BodyCollisionInfo
{
    public var BodyA:Body;
    public var BodyB:Body;
    public var BodyAPointMass:Int;
    public var BodyBPointMassA:Int;
    public var BodyBPointMassB:Int;
    public var HitPoint:Vector2;
    public var EdgeD:Float;
    public var Normal:Vector2;
    public var Penetration:Float;
    
    public function new() 
    {
        
    }
    
    public function Clear():Void
    {
        BodyA = null;
        BodyB = null;
        BodyAPointMass =-1;
        BodyBPointMassA =-1;
        BodyBPointMassB =-1;
        HitPoint = null;
        EdgeD = -1.0;
        Normal = null;
        Penetration = -1.0;
    }
    
}