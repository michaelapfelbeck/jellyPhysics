package jellyPhysics;

import jellyPhysics.Body;
import jellyPhysics.ClosedShape;
import jellyPhysics.InternalSpring;
import lime.math.Vector2;

/**
 * ...
 * @author Michael Apfelbeck
 * The simplest type of Body, that tries to maintain its shape through 
 * shape-matching (global springs that try to keep the original shape), 
 * and internal springs for support.  Shape matching forces can be 
 * enabled / disabled at will.
 */
class SpringBody extends Body
{
    public var Springs:Array<InternalSpring>;

    // shape-matching on or off.
    private var shapeMatchingOn:Bool = true;
    public var ShapeMatchingOn(get, set):Bool;    
    public function get_ShapeMatchingOn():Bool 
    {
        return shapeMatchingOn;
    }
    public function set_ShapeMatchingOn(value:Bool):Bool
    {
        shapeMatchingOn = value;
        return shapeMatchingOn;
    }
    
    private var EdgeSpringK:Float;
    private var EdgeSpringDamp:Float;
    private var ShapeSpringK:Float;
    private var ShapeSpringDamp:Float;

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
    bodyShapeSpringDamp:Float, edgeSpringK:Float, edgeSpringDamp:Float)
    {
        super(bodyShape, massPerPoint, position, angleInRadians, bodyScale, isKinematic);
        Springs = new Array<InternalSpring>();
		EdgeSpringDamp = edgeSpringDamp;
        EdgeSpringK = edgeSpringK;
        ShapeSpringK = bodyShapeSpringK;
        ShapeSpringDamp = bodyShapeSpringDamp;
        
        super.SetPositionAngle(position, angleInRadians, bodyScale);
        
        BuildDefaultSprings();
    }
    override public function AccumulateInternalForces(elapsed:Float):Void 
    {
        super.AccumulateInternalForces(elapsed);

        if (!IsAsleep)
        {
            // internal spring forces.
            var force:Vector2 = new Vector2(0, 0);
            var s:InternalSpring;
            for (i in 0...Springs.length)
            {
                s = Springs[i];
                
                force = VectorTools.CalculateSpringForce(
                    PointMasses[s.pointMassA].Position, 
                    PointMasses[s.pointMassA].Velocity,
                    PointMasses[s.pointMassB].Position, 
                    PointMasses[s.pointMassB].Velocity,
                    s.springLen, s.springK, s.damping);

                PointMasses[s.pointMassA].Force.x += force.x;
                PointMasses[s.pointMassA].Force.y += force.y;

                PointMasses[s.pointMassB].Force.x -= force.x;
                PointMasses[s.pointMassB].Force.y -= force.y;
            }

            GlobalShape = BaseShape.transformVertices(DerivedPos, DerivedAngle, Scale);
            // shape matching forces.
            if (shapeMatchingOn)
            {
                for (i in 0...PointMasses.length)
                {
                    if (ShapeSpringK > 0)
                    {
                        if (!Kinematic)
                        {
                            force = VectorTools.CalculateSpringForce(
                                PointMasses[i].Position, 
                                PointMasses[i].Velocity,
                                GlobalShape[i], 
                                PointMasses[i].Velocity, 
                                0.0, 
                                ShapeSpringK, 
                                ShapeSpringDamp);
                        }
                        else
                        {
                            var kinVel:Vector2 = new Vector2(0, 0);
                            force = VectorTools.CalculateSpringForce(
                                PointMasses[i].Position, 
                                PointMasses[i].Velocity,
                                GlobalShape[i], 
                                kinVel, 
                                0.0, 
                                ShapeSpringK, 
                                ShapeSpringDamp);
                        }

                        PointMasses[i].Force.x += force.x;
                        PointMasses[i].Force.y += force.y;
                        //trace("force: [" + force.x + ", " + force.y + "]");
                    }
                }
            }
        }
        
    }
    
    private function BuildDefaultSprings():Void
    {
        for (i in 0...PointMasses.length){
            if (i < PointMasses.length - 1){
                AddInternalSpring(i, i + 1, EdgeSpringK, EdgeSpringDamp);
            }else{
                AddInternalSpring(i, 0, EdgeSpringK, EdgeSpringDamp);
            }
        }
    }
    
    // pointA: point mass on 1st end of the spring
    // pointB: point mass on 2nd end of the spring
    // springK: spring constant
    // springDamp: spring damping
    private function AddInternalSpring(pointA:Int, pointB:Int, springK:Float, springDamp:Float){
        var distVector:Vector2 = VectorTools.Subtract(PointMasses[pointB].Position, PointMasses[pointA].Position);
        var dist:Float = distVector.length;
        var spring:InternalSpring = new InternalSpring(pointA, pointB, dist, springK, springDamp);
        Springs.push(spring);
    }
}