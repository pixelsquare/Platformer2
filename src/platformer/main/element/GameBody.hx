package platformer.main.element;

import nape.callbacks.CbType;
import nape.dynamics.InteractionGroup;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;
import nape.phys.Material;
import nape.space.Space;
import nape.dynamics.InteractionFilter;

import flambe.math.FMath;
import platformer.main.utils.GameConstants;
import platformer.pxlSq.Utils;
import nape.util.Debug;

/**
 * ...
 * @author Anthony Ganzon
 */
class GameBody extends GameElement
{
	public var gameBody(default, null): Body;
	public var gameBodyLayer(default, null): Int;
	
	public function new() {
		super();
		this.gameBodyLayer = 0;
	}
	
	public function InitBody(width: Float, height: Float, space: Space): Void {		
		gameBody = new Body(Vec2.weak(x._, y._));
		gameBody.shapes.add(new Polygon(
			Polygon.box(width, height), 
			new Material(0.01, 0.02, 0.1, 0.9)
		));
		
		gameBody.space = space;
		gameBody.allowRotation = false;
	}
	
	public function SetBodyFilter(bodyFilter: InteractionFilter): Void {
		gameBodyLayer = bodyFilter.collisionGroup;
		gameBody.setShapeFilters(bodyFilter);
	}
	
	public function SetBodyMaterial(material: Material): Void {
		gameBody.setShapeMaterials(material);
	}
	
	public function SetBodyCbType(cbtype: CbType): Void {
		gameBody.cbTypes.add(cbtype);
	}
	
	public function SetBodyType(bodyType: BodyType): Void {
		gameBody.type = bodyType;
	}
	
	override public function onUpdate(dt:Float) {
		super.onUpdate(dt);
		
		if(gameBody != null) {
			var pos: Vec2 = gameBody.position;
			x._ = pos.x;
			y._ = pos.y;
			rotation._ = FMath.toDegrees(gameBody.rotation);
		}
	}
	
	override public function onRemoved() {
		super.onRemoved();
		if(gameBody != null) {
			gameBody.space = null;
		}
	}
}