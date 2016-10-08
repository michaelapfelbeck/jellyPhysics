package jellyPhysics.math;

/**
 * ...
 * @author Michael Apfelbeck
 */
class Vector2
{
    public var x:Float;
    public var y:Float;
    
    public function new(X:Float = 0, Y:Float = 0){
        x = X;
        y = Y;
    }
    
    public function length():Float{
        return Math.sqrt(x * x + y * y);
    }
    
    public function lengthSquared():Float{
        return x * x + y * y;
    }
	
	public function add(v:Vector2) : Vector2
	{
		x += v.x;
        y += v.y;
        return this;
	}
	
	public function subtract(v:Vector2) : Vector2
	{
		x -= v.x;
        y -= v.y;
        return this;
	}
    
    public function normalize():Vector2{        
		var length:Float = length();
		if (length < 0.00001)
		{
            x = 0;
            y = 0;
			return this;
		}
		var invLength:Float = 1.0 / length;
		x *= invLength;
		y *= invLength;
		
		return this;
    }
    
}