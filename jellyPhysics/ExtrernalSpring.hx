package jellyPhysics;

/**
 * ...
 * @author Michael Apfelbeck
 */
class ExtrernalSpring extends InternalSpring
{
    public var BodyA:Body;
    public var BodyB:Body;
    
    public function new(bodyA:Body,bodyB:Body, ?pmA:Int, ?pmB:Int, ?length:Float, ?k:Float, ?damp:Float) 
    {
        super(pmA, pmB, length, k, damp);
        BodyA = bodyA;
        BodyB = bodyB;
    }  
}