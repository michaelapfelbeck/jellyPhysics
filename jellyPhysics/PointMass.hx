package jellyPhysics ;

import jellyPhysics.math.Vector2;

/**
 * ...
 * @author Michael Apfelbeck
 */
class PointMass
{
    public var Mass:Float;
    
    public var Position:Vector2;
    
    public var Velocity:Vector2;
    
    //Reset to 0 after each call to integrate()
    public var Force:Vector2;
        
    public function new(?mass:Float, ?position:Vector2)
    {
        Mass = (null == mass) ? 1 : mass;
        Position = (null == position) ? new Vector2(0, 0) : position;
        Velocity = new Vector2(0, 0);
        Force = new Vector2(0, 0);
    }
    
    public function IntegrateForce(elapsed: Float):Void
    {
        if(Mass != Math.POSITIVE_INFINITY){
            var elapMass:Float = elapsed / Mass;

            Velocity.x += (Force.x * elapMass);
            Velocity.y += (Force.y * elapMass);

            Position.x += (Velocity.x * elapsed);
            Position.y += (Velocity.y * elapsed);
            
            Force.x = 0;
            Force.y = 0;
        }
    }
}