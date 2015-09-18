package platformer.main.element;

import flambe.animation.AnimatedFloat;
import flambe.Component;
import flambe.Disposer;
import flambe.Entity;
import flambe.scene.Scene;

import platformer.pxlSq.Utils;

/**
 * ...
 * @author Anthony Ganzon
 */
class GameElement extends Component
{
	public var alpha(default, null): AnimatedFloat;
	
	public var x(default, null): AnimatedFloat;
	public var y(default, null): AnimatedFloat;
	
	public var scale(default, null): AnimatedFloat;
	public var scaleX(default, null): AnimatedFloat;
	public var scaleY(default, null): AnimatedFloat;
	
	public var rotation(default, null): AnimatedFloat;
	
	public var parent(default, null): Entity;
	
	private var elementEntity: Entity;
	private var elementScene: Scene;
	private var elementDisposer:Disposer;
	
	public function new() {
		this.alpha = new AnimatedFloat(1.0);
		this.x = new AnimatedFloat(0.0);
		this.y = new AnimatedFloat(0.0);
		this.scale = new AnimatedFloat(1.0);
		this.scaleX = new AnimatedFloat(1.0);
		this.scaleY = new AnimatedFloat(1.0);
		this.rotation = new AnimatedFloat(0.0);
	}
	
	public function Init(): Void { 
		this.elementEntity = new Entity()
			.add(this.elementScene = new Scene(false))
			.add(this.elementDisposer = new Disposer());
	}
	
	public function Draw(): Void { }
	
	public function AddToEntity(component: Component, append: Bool = true): Void {
		if (component == null) {
			Utils.ConsoleLog("Cannot add nulled components. [" + component.name + "]");
			return;
		}
		
		elementEntity.addChild(new Entity().add(component), append);
	}
	
	public function RemoveEntity(component: Component): Void {
		if (component == null) {
			Utils.ConsoleLog("Cannot remove nulled components. [" + component.name + "]");
			return;
		}
		
		elementEntity.removeChild(new Entity().add(component));
	}
	
	public function RemoveAndDispose(component: Component): Void {
		RemoveEntity(component);
		component.dispose();
	}
	
	public function GetNaturalHeight(): Float {
		return 0.0;
	}
	
	public function GetNaturalWidth(): Float {
		return 0.0;
	}
	
	public function SetAlpha(alpha: Float): GameElement {
		this.alpha._ = alpha;
		return this;
	}
	
	public function SetXY(x: Float, y: Float): GameElement {
		this.x._ = x;
		this.y._ = y;
		return this;
	}
	
	public function SetScale(scale: Float): GameElement {
		this.scale._ = scale;
		return this;
	}
	
	public function SetScaleXY(scaleX: Float, scaleY: Float): GameElement {
		this.scaleX._ = scaleX;
		this.scaleY._ = scaleY;
		return this;
	}
	
	public function SetRotation(rotation: Float): GameElement {
		this.rotation._ = rotation;
		return this;
	}
	
	public function SetParent(parent: Entity): GameElement {
		this.parent = parent;
		return this;
	}
	
	public function SetVisibility(visible: Bool): GameElement {
		return this;
	}
	
	override public function onAdded() {
		super.onAdded();
		
		Init();
		owner.addChild(elementEntity);
		
		elementDisposer = owner.get(Disposer);
		if (elementDisposer == null) {
			owner.add(elementDisposer = new Disposer());
		}
	}
	
	override public function onStart() {
		super.onStart();
		Draw();
	}
	
	override public function onUpdate(dt:Float) {
		super.onUpdate(dt);
		this.alpha.update(dt);
		this.x.update(dt);
		this.y.update(dt);
		this.scale.update(dt);
		this.scaleX.update(dt);
		this.scaleY.update(dt);
		this.rotation.update(dt);
	}
	
	override public function dispose() {
		super.dispose();
		elementEntity.dispose();
	}
	
	public function AlphaToString(): String {
		return "Alpha [" + this.alpha + "]";
	}
	
	public function PositionToString(): String {
		return "Position [" + this.x._ + "," + this.y._ + "]";
	}
	
	public function ScaleToString(): String {
		return "Scale [" + this.scale._ + "]";
	}
	
	public function ScaleXYToString(): String {
		return "Scale XY [" + this.scaleX._ + "," + this.scaleY._ + "]";
	}
	
	public function RotationToString(): String {
		return "Rotation [" + this.rotation + "]";
	}
}