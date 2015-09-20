package platformer.main.element;

import flambe.math.FMath;

import nape.callbacks.CbType;
import nape.dynamics.InteractionFilter;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Polygon;
import nape.space.Space;
import nape.shape.Shape;
import nape.geom.AABB;

import platformer.pxlSq.Utils;

/**
 * ...
 * @author Anthony Ganzon
 */
class GameBody extends GameElement
{
	public var gameBody(default, null): Body;
	public var gameBodyShape(default, null): Polygon;
	
	private var gameBodyMaterial: Material;
	
	public function new() {
		super();
		//this.gameBodyMaterial = new Material(0.1, 0.02, 0.01, 0.05, 0.0001);
		//this.gameBodyMaterial = new Material(0, 0, 0, 1, 0.001);
		this.gameBodyMaterial = new Material();
	}
	
	public function InitBody(bodyType: BodyType, space: Space, verts: Array<Vec2>): Void {			
		gameBody = new Body(bodyType, Vec2.weak(x._, y._));
		gameBodyShape = new Polygon(verts, gameBodyMaterial);
		gameBody.shapes.add(gameBodyShape);
		
		gameBody.space = space;
		gameBody.allowRotation = false;
	}
	
	public function SetCollisionMask(mask: Int): Void {
		for (shape in gameBody.shapes) {
			shape.filter.collisionMask = mask;
		}
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