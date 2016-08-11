package jellyPhysics;
import jellyPhysics.Body;
import jellyPhysics.BodyCollisionInfo;

/**
 * ...
 * @author Michael Apfelbeck
 */
interface ColliderBase
{
    public var PenetrationThreshold(get, null):Float;
    public var Count(get, null):Int;
    function GetBody(index:Int):Body;    
    function Add(body:Body):Void;
    function Remove(body:Body):Void;
    function Contains(body:Body):Bool;
    function BuildCollisions():Array<BodyCollisionInfo>;
    function Clear():Void;
}