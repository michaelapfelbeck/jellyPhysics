package jellyPhysics;

import haxe.Constraints.Function;
/**
 * ...
 * @author Michael Apfelbeck
 */
class MaterialMatrix
{
    private var count:Int;
    public var Count(get, null):Int;
    public function get_Count():Int{
        return count;
    }
    
    private var defaultMaterial:MaterialPair;
    public var DefaultMaterial(get, null):MaterialPair;
    public function get_DefaultMaterial():MaterialPair{
        return defaultMaterial;
    }
    
    private var materials:Array<Array<MaterialPair>>;
    
    public function new(defaultPair:MaterialPair, ?pairCount:Int)
    {
        if (null == pairCount){
            count = 1;
        }
        count = pairCount;
        defaultMaterial = defaultPair;
        
        materials = new Array<Array<MaterialPair>>();
        for (i in 0...count){
            var materialRow:Array<MaterialPair> = new Array<MaterialPair>();
            for (j in 0...count){
                materialRow.push(MaterialPair.clone(defaultMaterial));
            }
            materials.push(materialRow);
        }
    }
    
    public function Get(i:Int, j:Int):MaterialPair
    {
        if (i >= count || j >= count){
            throw "Out of bounds.";
            return null;
        }
        
        return materials[i][j];
    }
    
    public function AddMaterial(?newMaterial:MaterialPair):Void
    {
        var old:Array<Array<MaterialPair>> = materials;
        count++;
        
        var pair:MaterialPair = (null != newMaterial)?newMaterial:defaultMaterial;
        
        materials = new Array<Array<MaterialPair>>();
        for (i in 0...count){
            var materialRow:Array<MaterialPair> = new Array<MaterialPair>();
            for (j in 0...count){
                if ((i<count-1) && (j<count-1)){
                    materialRow.push(old[i][j]);
                }else{
                    materialRow.push(pair);
                }
            }
            materials.push(materialRow);
        }
    }
    
    // Ebable/disable collision
    public function SetMaterialPairCollide(a:Int, b:Int, collide:Bool):Void
    {
        if ((a >= 0) && (a < count) && (b >= 0) && (b < count))
        {
            materials[a][b].Collide = collide;
            materials[b][a].Collide = collide;
        }
    }
    
    public function SetMaterialPairData(a:Int, b:Int, friction:Float, elasticity:Float):Void
    {
        if ((a >= 0) && (a < count) && (b >= 0) && (b < count))
        {
            materials[a][b].Friction = friction;
            materials[b][a].Friction = friction;
            materials[a][b].Elasticity = elasticity;
            materials[b][a].Elasticity = elasticity;
        }
    }
    
    public function SetMaterialPairFilterCallback(a:Int, b:Int, collisionFilter:Function):Void
    {
        if ((a >= 0) && (a < count) && (b >= 0) && (b < count))
        {
            materials[a][b].CollisionFilter = collisionFilter;
            materials[b][a].CollisionFilter = collisionFilter;
        }
    }
}