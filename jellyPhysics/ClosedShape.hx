package jellyPhysics;
import lime.math.Vector2;

/**
 * ...
 * @author Michael Apfelbeck
 */
class ClosedShape
{
    //vertexes define the collision geometry. The shape connects the vertexes in
    //order, closing the last vertex to the first.
    public var LocalVertices:Array<Vector2>;
    
    public function new(?verts: Array<Vector2>) 
    {
        LocalVertices = verts;
        if (null == LocalVertices){
            LocalVertices = new Array<Vector2>();
        }
    }
    
    public function Begin():Void{
        while (LocalVertices.length > 0){
            LocalVertices.shift();
        }
    }
    
    public function AddVertex(vert: Vector2):Int{
        LocalVertices.push(vert);
        return LocalVertices.length;
    }
    
    public function Finish(recenter:Bool):Void{
        if (recenter){
            var center:Vector2 = new Vector2(0, 0);
        
            for (i in 0 ... LocalVertices.length){
                center = center.add(LocalVertices[i]);
            }
            
            center.x /= LocalVertices.length;
            center.y /= LocalVertices.length;
            
            for (i in 0 ... LocalVertices.length){
                LocalVertices[i].x -= center.x;
                LocalVertices[i].y -= center.y;
            }
        }
    }
    
    // Get a new list of vertices, transformed by the given position, angle, and scale.
    // transformation is applied in the following order:  scale -> rotation -> position.
    public function transformVertices(worldPosition: Vector2, angleInRadians:Float, localScale:Vector2):Array<Vector2>{
        var result:Array<Vector2> = new Array<Vector2>();
        
        for (i in 0 ... LocalVertices.length)
        {
            var v:Vector2 = new Vector2();
            
            // rotate the point, and then translate.
            v.x = LocalVertices[i].x * localScale.x;
            v.y = LocalVertices[i].y * localScale.y;
            v = VectorTools.RotateVector(v, angleInRadians);

            v.x += worldPosition.x;
            v.y += worldPosition.y;
            result.push(v);
        }
        return result;
    }
}