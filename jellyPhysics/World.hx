package jellyPhysics;
import haxe.Constraints.Function;
import jellyPhysics.*;
import jellyPhysics.math.VectorTools;
import jellyPhysics.math.Vector2;

/**
 * ...
 * @author Michael Apfelbeck
 */
class World
{
    private var materialCount:Int;
    public var MaterialCount(get, null):Int;
    public function get_MaterialCount(){
        return materialCount;
    }
    
    public var NumberBodies(get, null):Int;
    public function get_NumberBodies(){
        return collider.Count;
    }
    private var collider:ColliderBase;
    
    public var externalAccumulator:Function;
    
    public var PhysicsIter:Int;
    
    private var minFPS = 40.0;
    public var MinFPS(get, null):Float;
    public function get_MinFPS(){
        return minFPS;
    }
    
    private var maxFPS = 120.0;
    public var MaxFPS(get, null):Float;
    public function get_MaxFPS(){
        return maxFPS;
    }
    
    private var BodyDamping:Float = .5;
    
    private var worldLimits:AABB;
    //used to give each body added to the physics world a unique id
    private var bodyCounter:Int;
    private var penetrationCount:Int;
    
    private var defaultMaterialPair:MaterialPair;
    private var materialPairs:MaterialMatrix;
    
    private var collisionList:Array<BodyCollisionInfo>;
    
    private var penetrationThreshold:Float;
    
    public function new(worldMaterialCount:Int, 
                        worldMaterialPairs:MaterialMatrix,
                        worldDefaultMaterialPair:MaterialPair,
                        worldPenetrationThreshhold:Float,
                        worldBounds: AABB)
    {
        collider = getBodyCollider(worldPenetrationThreshhold);
        
        collisionList = new Array<BodyCollisionInfo>();
        bodyCounter = 0;
        
        PhysicsIter = 4;
        
        // initialize materials
        materialCount = worldMaterialCount;
        materialPairs = worldMaterialPairs;
        defaultMaterialPair = worldDefaultMaterialPair;
        
        SetWorldLimits(worldBounds);
        
        penetrationThreshold = worldPenetrationThreshhold;
    }
    
    public function getBodyCollider(penetrationThreshhold:Float):ColliderBase
    {
        return new ArrayCollider(penetrationThreshhold);
    }
    
    public function SetWorldLimits(limits:AABB) : Void
    {
        worldLimits = limits;
    }
    
    public function AddBody(body:Body):Int
    {
        if (!collider.Contains(body)){
            body.VelocityDamping = BodyDamping;
            body.BodyNumber = bodyCounter;
            bodyCounter++;
            collider.Add(body);
            return body.BodyNumber;
        }
        
        return -1;
    }
    
    public function RemoveBody(body:Body):Void
    {
        if (collider.Contains(body)){
            collider.Remove(body);
            if (body.DeleteCallback != null){
                body.DeleteCallback(body);
            }
        }
    }
    
    public function GetBody(index:Int):Body
    {
        if (index < collider.Count){
            return collider.GetBody(index);
        }
        return null;
    }
    
    public function GetClosestPointMass(point:Vector2, ?ignoreStatic:Bool):BodyPointMassRef
    {
        var bodyID:Int = -1;
        var pmID:Int = -1;

        var closestD:Float = 1000.0;
        for (i in 0...collider.Count)
        {
            var body:Body = collider.GetBody(i);
            if (body.IsStatic && ignoreStatic){
                continue;
            }
            var pmRef:PointMassRef = body.GetClosestPointMass(point);
            if (pmRef.Distance < closestD)
            {
                closestD = pmRef.Distance;
                bodyID = i;
                pmID = pmRef.Index;
            }
        }
        
        if (bodyID == -1){
            return null;
        }
        
        return new BodyPointMassRef(bodyID, pmID, closestD);
    }
    
    public function GetBodyContaining(point:Vector2):Body
    {
        for (i in 0...collider.Count){
            if (collider.GetBody(i).Contains(point)){
                return collider.GetBody(i);
            }
        }
        return null;
    }
    
    function bracketFrameRate(elapsed:Float) 
    {
        var adjusted:Float;
        adjusted = Math.min(elapsed, 1.0 / minFPS);
        adjusted = Math.max(adjusted, 1 / maxFPS);
        return adjusted;
    }
    
    public function Update(elapsed:Float)
    {
        //stability hack
        //If the framerate drops too low or too high the system looses
        //stability, so keep updates bracketed inside a 20-120 FPS range
        var physicsElapsed:Float = bracketFrameRate(elapsed);
        
        var iterElapsed = physicsElapsed / PhysicsIter;
        
        for (iter in 0...PhysicsIter){
            penetrationCount = 0;
            
            if (null != externalAccumulator){
                externalAccumulator(iterElapsed);
            }
            
            var deleteThese:Array<Body> = new Array<Body>();
            for (i in 0...collider.Count){
                var body:Body = collider.GetBody(i);
                if (body != null && body.DeleteThis){
                    deleteThese.push(body);
                }
            }
            for (i in 0...deleteThese.length){
                collider.Remove(deleteThese[i]);
                if (deleteThese[i].DeleteCallback != null){
                    deleteThese[i].DeleteCallback(deleteThese[i]);
                }
            }
            deleteThese = null;
            
            AccumulateAndIntegrate(iterElapsed);
            
            var collisions:Array<BodyCollisionInfo> = collider.BuildCollisions();
            //trace("collision count: " + collisions.length);
            HandleCollisions(collisions);
            
            for (i in 0...collider.Count){
                collider.GetBody(i).DampenVelocity(iterElapsed);
            }
        }
        
        for (i in 0...collider.Count){
            collider.GetBody(i).Update(elapsed);
        }
        
        for (i in 0...collider.Count){
            collider.GetBody(i).ResetExternalForces();
        }
    }
    
    public function SetBodyDamping(float:Float) 
    {
        BodyDamping = float;
        for (i in 0...NumberBodies){
            var body:Body = GetBody(i);
            body.VelocityDamping = float;
        }
    }

    private function AccumulateAndIntegrate(iterElapsed:Float):Void
    {
        AccumulateAndIntegrateForces(0, collider.Count, iterElapsed);
    }

    private function AccumulateAndIntegrateForces(start:Int, end:Int, elapsed:Float):Void
    {
        for (i in start...end)
        {
            var body = collider.GetBody(i);
            if (!body.IsStatic)
            {
                body.DerivePositionAndAngle(elapsed);
                body.AccumulateExternalForces(elapsed);
                body.AccumulateInternalForces(elapsed);
                body.Integrate(elapsed);
                body.UpdateAABB(elapsed, false);
            }
        }
    }

    private function AccumulateForces(start:Int, end:Int, elapsed:Float):Void
    {
        for (i in start...end)
        {
            var body = collider.GetBody(i);
            if (!body.IsStatic)
            {
                body.DerivePositionAndAngle(elapsed);
                body.AccumulateExternalForces(elapsed);
                body.AccumulateInternalForces(elapsed);
            }
        }
    }
    
    private function HandleCollisions(collisions:Array<BodyCollisionInfo>):Void
    {
        // handle all collisions!
        for (i in 0...collisions.length)
        {
            var info:BodyCollisionInfo = collisions[i];

            if (info.BodyA == null || info.BodyB == null)
            {
                continue;
            }

            if (info.BodyA.CollisionCallback != null)
            {
                info.BodyA.CollisionCallback(info.BodyB);
            }
            
            //ToDo: track down the bug that leads to bad values in the 
            // collision info object and makes this function blow up
            if (info.BodyAPointMass == -1 || info.BodyBPointMassA == -1 || info.BodyBPointMassB == -1){
                trace("There's a good chance something has gone horribly wrong.");
                continue;
            }

            var A:PointMass = info.BodyA.GetPointMass(info.BodyAPointMass);
            var B1:PointMass = info.BodyB.GetPointMass(info.BodyBPointMassA);
            var B2:PointMass = info.BodyB.GetPointMass(info.BodyBPointMassB);

            // velocity changes as a result of collision.
            var bVel:Vector2 = new Vector2((B1.Velocity.x + B2.Velocity.x) * 0.5,
                                            (B1.Velocity.y + B2.Velocity.y) * 0.5);

            var relVel:Vector2 = new Vector2(A.Velocity.x - bVel.x,
                                             A.Velocity.y - bVel.y);

            var relDot:Float = VectorTools.Dot(relVel, info.Normal);

            // collision filter!
            var materialPair:MaterialPair = materialPairs.Get(info.BodyA.Material,
                                                                info.BodyB.Material);
            if (!materialPair.Collide){
                continue;
            }
            if (materialPair != null && materialPair.CollisionFilter != null &&
            materialPair.CollisionFilter(info.BodyA, info.BodyAPointMass, info.BodyB, info.BodyBPointMassA, info.BodyBPointMassB, info.HitPoint, relDot)){
                continue;
            }

            if (info.Penetration > penetrationThreshold)
            {
                //trace("penetration above Penetration Threshold!!  penetration={0}  threshold={1} difference={2}",
                //    info.penetration, mPenetrationThreshold, info.penetration-mPenetrationThreshold);

                penetrationCount++;
                continue;
            }

            var b1inf:Float = 1.0 - info.EdgeD;
            var b2inf:Float = info.EdgeD;

            var b2MassSum:Float = 1.0;
            if ((B1.Mass==Math.POSITIVE_INFINITY) || (B2.Mass==Math.POSITIVE_INFINITY)){
                b2MassSum = Math.POSITIVE_INFINITY;
            }else{
                b2MassSum = B1.Mass + B2.Mass;
            }
            
            var massSum:Float = A.Mass + b2MassSum;
            
            var Amove:Float;
            var Bmove:Float;
            if (A.Mass == Math.POSITIVE_INFINITY)
            {
                Amove = 0;
                Bmove = (info.Penetration) + 0.001;
            }
            else if (b2MassSum == Math.POSITIVE_INFINITY)
            {
                Amove = (info.Penetration) + 0.001;
                Bmove = 0;
            }
            else
            {
                Amove = (info.Penetration * (b2MassSum / massSum));
                Bmove = (info.Penetration * (A.Mass / massSum));
            }

            var B1move:Float = Bmove * b1inf;
            var B2move:Float = Bmove * b2inf;

            var AinvMass:Float = (A.Mass==Math.POSITIVE_INFINITY) ? 0.0 : 1.0 / A.Mass;
            var BinvMass:Float = (b2MassSum==Math.POSITIVE_INFINITY) ? 0.0 : 1.0 / b2MassSum;

            var jDenom:Float = AinvMass + BinvMass;
            var numV:Vector2 = new Vector2(0, 0);
            var elas:Float = 1.0 + materialPairs.Get(info.BodyA.Material, info.BodyB.Material).Elasticity;
            numV.x = relVel.x * elas;
            numV.y = relVel.y * elas;

            var jNumerator:Float = VectorTools.Dot(numV, info.Normal);
            jNumerator = -jNumerator;

            var j:Float = jNumerator / jDenom;

            if (A.Mass!=Math.POSITIVE_INFINITY)
            {
                A.Position.x -= info.Normal.x * Amove;
                A.Position.y -= info.Normal.y * Amove;
            }

            if (B1.Mass!=Math.POSITIVE_INFINITY)
            {
                B1.Position.x += info.Normal.x * B1move;
                B1.Position.y += info.Normal.y * B1move;
            }

            if (B2.Mass!=Math.POSITIVE_INFINITY)
            {
                B2.Position.x += info.Normal.x * B2move;
                B2.Position.y += info.Normal.y * B2move;
            }
            
            var tangent:Vector2 = VectorTools.GetPerpendicular(info.Normal);
            
            var friction:Float = materialPair.Friction;
            var fNumerator:Float = VectorTools.Dot(relVel, tangent);
            
            fNumerator *= friction;
            var f:Float = fNumerator / jDenom;

            // adjust velocity if relative velocity is moving toward each other.
            if (relDot >= 0.0001)
            {
                if (A.Mass != Math.POSITIVE_INFINITY)
                {
                    A.Velocity.x += (info.Normal.x * (j / A.Mass)) - (tangent.x * (f / A.Mass));
                    A.Velocity.y += (info.Normal.y * (j / A.Mass)) - (tangent.y * (f / A.Mass));
                }

                if (b2MassSum != Math.POSITIVE_INFINITY)
                {
                    B1.Velocity.x -= (info.Normal.x * (j / b2MassSum) * b1inf) - (tangent.x * (f / b2MassSum) * b1inf);
                    B1.Velocity.y -= (info.Normal.y * (j / b2MassSum) * b1inf) - (tangent.y * (f / b2MassSum) * b1inf);
                }

                if (b2MassSum != Math.POSITIVE_INFINITY)
                {
                    B2.Velocity.x -= (info.Normal.x * (j / b2MassSum) * b2inf) - (tangent.x * (f / b2MassSum) * b2inf);
                    B2.Velocity.y -= (info.Normal.y * (j / b2MassSum) * b2inf) - (tangent.y * (f / b2MassSum) * b2inf);
                }
            }
        }
    }
}