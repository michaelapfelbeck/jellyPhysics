package jellyPhysics;

import jellyPhysics.math.VectorTools;
import jellyPhysics.math.Vector2;

/**
 * ...
 * @author Michael Apfelbeck
 * a subclass of SpringBody, with the added element of pressurized gas inside the body.  
 * The amount of pressure can be adjusted at will to inflate / deflate the object.  
 * The object will not deflate much smaller than the original size of the Shape if 
 * shape matching is enabled.
 */
class PressureBody extends SpringBody
{
    public var Volume:Float;
    public var GasAmount:Float;
    public var NormalList:Array<Vector2>;
    public var EdgeLengthList:Array<Float>;

    //bodyShape: ClosedShape shape for this body
    //massPerPoint: mass per PointMass.
    //position: global position
    //angleinRadians: global angle
    //bodyScale: scale
    //isKinematic: kinematic control boolean
    //bodyShapeSpringK: shape-matching spring constant
    //bodyShapeSpringDamp: shape-matching spring damping
    //edgeSpringK: spring constant for edges
    //edgeSpringDamp: spring damping for edges
    public function new(bodyShape:ClosedShape, massPerPoint:Float, position:Vector2, 
        angleInRadians:Float, bodyScale:Vector2, isKinematic:Bool, bodyShapeSpringK:Float, 
        bodyShapeSpringDamp:Float, edgeSpringK:Float, edgeSpringDamp:Float, gasPressure:Float) 
    {
        super(bodyShape, massPerPoint, position, angleInRadians, bodyScale, isKinematic, 
        bodyShapeSpringK, bodyShapeSpringDamp, edgeSpringK, edgeSpringDamp);
        
		GasAmount = gasPressure;
        
        InitArrays();
    }
    
    private function InitArrays()
    {        
        NormalList = new Array<Vector2>();
        EdgeLengthList = new Array<Float>();
        
        for (i in 0...PointMasses.length){
            NormalList.push(new Vector2(0, 0));
            EdgeLengthList.push(0);
        }
    }
    override public function AccumulateInternalForces(elapsed:Float):Void 
    {
        super.AccumulateInternalForces(elapsed);
        
        if (!IsAsleep)
        {
            // Internal forces based on pressure equations.  We need 2 loops to do this.  
            // One to find the overall volume of the body, and 1 to apply forces.  we need 
            // the normals for the edges in both loops, so we will cache them and remember them.
            Volume = 0;

            for (i in 0...PointMasses.length)
            {
                var prev:Int = (i > 0) ? i - 1 : PointMasses.length - 1;
                var next:Int = (i < PointMasses.length - 1) ? i + 1 : 0;

                // currently we are talking about the edge from i --> j.
                // first calculate the volume of the body, and cache normals as we go.
                var edge1N:Vector2 = new Vector2(PointMasses[i].Position.x - PointMasses[prev].Position.x,
                                                 PointMasses[i].Position.y - PointMasses[prev].Position.y);
                edge1N = VectorTools.GetPerpendicular(edge1N);

                var edge2N:Vector2 = new Vector2(PointMasses[next].Position.x - PointMasses[i].Position.x,
                                                 PointMasses[next].Position.y - PointMasses[i].Position.y);
                edge2N = VectorTools.GetPerpendicular(edge2N);

                var norm:Vector2 = new Vector2(edge1N.x + edge2N.x, edge1N.y + edge2N.y);
                norm.normalize();

                var edgeL:Float = Math.sqrt((edge2N.x * edge2N.x) + (edge2N.y * edge2N.y));

                // cache normal and edge length
                NormalList[i] = norm;
                EdgeLengthList[i] = edgeL;

                var xdist:Float = Math.abs(PointMasses[i].Position.x - PointMasses[next].Position.x);

                var volumeProduct:Float = xdist * Math.abs(norm.x) * edgeL;

                // add to volume
                Volume += 0.5 * volumeProduct;
            }

            // now loop through, adding forces!
            var invVolume:Float = -1.0 / Volume;

            for (i in 0...PointMasses.length)
            {
                var j:Int = (i < PointMasses.length - 1) ? i + 1 : 0;

                var pressureV:Float = (invVolume * EdgeLengthList[i] * GasAmount);
                PointMasses[i].Force.x += NormalList[i].x * pressureV;
                PointMasses[i].Force.y += NormalList[i].y * pressureV;

                PointMasses[j].Force.x += NormalList[j].x * pressureV;
                PointMasses[j].Force.y += NormalList[j].y * pressureV;
            }
        }
    }
}