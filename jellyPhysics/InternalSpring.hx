package jellyPhysics;

/**
 * ...
 * @author Michael Apfelbeck
 */
class InternalSpring
{
    /// <summary>
    /// First PointMass the spring is connected to.
    /// </summary>
    public var pointMassA:Int;

    /// <summary>
    /// Second PointMass the spring is connected to.
    /// </summary>
    public var pointMassB:Int;

    /// <summary>
    /// The "rest length" (deisred length) of the spring.  at this length, no force is exerted on the points.
    /// </summary>
    public var springLen:Float;

    /// <summary>
    /// spring constant, or "strength" of the spring.
    /// </summary>
    public var springK:Float;

    /// <summary>
    /// coefficient for damping, to reduce overshoot.
    /// </summary>
    public var damping:Float;

    public function new(?pmA:Int, ?pmB:Int, ?length:Float, ?k:Float, ?damp:Float) 
    {
        pointMassA = (null == pmA) ? 0 : pmA;
        pointMassB = (null == pmB) ? 0 : pmB;
        springLen = (null == length) ? 0 : length;
        springK = (null == k) ? 0 : k;
        damping = (null == damp) ? 0 : damp;
    }
}