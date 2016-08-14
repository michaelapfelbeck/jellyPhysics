package jellyPhysics.math;

/**
 * ...
 * @author Michael Apfelbeck
 */
class Vector3
{
    public var x:Float;
    public var y:Float;
    public var z:Float;
    
    public function new(X:Float = 0.0, Y:Float = 0.0, Z:Float = 0.0){
        x = X;
        y = Y;
        z = Z;
    }
    
    //(a1,a2,a3) x (b1,b2,b3) = (a2*b3 - a3*b2, a3*b1 - a1*b3, a1*b2 - a2*b1)
    public function crossProduct(v:Vector3):Vector3{
        var result:Vector3 = new Vector3();
        result.x = this.y * v.z - this.z * v.y;
        result.y = this.z * v.x - this.x * v.z;
        result.z = this.x * v.y - this.y * v.x;
        return result;
    }
}