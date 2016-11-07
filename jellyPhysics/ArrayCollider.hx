package jellyPhysics;
import jellyPhysics.AABB;
import jellyPhysics.Body;
import jellyPhysics.BodyCollisionInfo;

/**
 * ...
 * @author Michael Apfelbeck
 */
class ArrayCollider implements ColliderBase
{
    private var bodies:Array<Body>;
    
    private var penetrationThreshold:Float;    
    public var PenetrationThreshold(get, null):Float;
    function get_PenetrationThreshold():Float{
        return penetrationThreshold;
    }
    
    public var Count(get, null):Int;
    function get_Count():Int{
        return bodies.length;
    }
    
    public function GetBody(index:Int):Body 
    {
        if (index >= bodies.length){
            return null;
        }
        return bodies[index];
    }
    
    public function Add(body:Body):Void 
    {
        bodies.push(body);
    }
    
    public function Remove(body:Body):Void 
    {
        bodies.remove(body);
    }
    
    public function Contains(body:Body):Bool 
    {
        var index = bodies.indexOf(body);
        return -1 != index;
    }
    
    public function Clear():Void 
    {
        bodies = null;
        bodies = new Array<Body>();
    }
    
    public function BuildCollisions():Array<BodyCollisionInfo> 
    {
        var collisions:Array<BodyCollisionInfo> = new Array<BodyCollisionInfo>();
        
        for (i in 0...bodies.length){
            for (j in (i + 1)...bodies.length){
                var bodyA:Body = bodies[i];
                var bodyB:Body = bodies[j];
                
                var boxA:AABB = bodyA.BoundingBox;
                var boxB:AABB = bodyB.BoundingBox;
                
                if (!boxA.Intersects(boxB)){
                    continue;
                }
                
                var aCollide:Array<BodyCollisionInfo> = Body.BodyCollide(bodyA, bodyB, penetrationThreshold);
                /*for (i in 0...aCollide.length){
                    var info:BodyCollisionInfo = aCollide[i];
                    if (info == null || info.BodyA == null || info.BodyB == null || info.BodyAPointMass ==-1 || info.BodyBPointMassA ==-1 || info.BodyBPointMassB ==-1){
                        trace("what the hell broke?");
                    }
                }*/
                collisions = collisions.concat(aCollide);
                var bCollide:Array<BodyCollisionInfo> = Body.BodyCollide(bodyB, bodyA, penetrationThreshold);       
                /*for (i in 0...bCollide.length){
                    var info:BodyCollisionInfo = bCollide[i];
                    if (info == null || info.BodyA == null || info.BodyB == null || info.BodyAPointMass ==-1 || info.BodyBPointMassA ==-1 || info.BodyBPointMassB ==-1){
                        trace("what the hell broke?");
                    }
                }*/
                collisions = collisions.concat(bCollide);
            }
        }
        //trace("collisions created: " + collisions.length);
        return collisions;
    }
    
    public function new(penThreshold:Float) 
    {
        penetrationThreshold = penThreshold;
        bodies = new Array<Body>();
    }
    
}