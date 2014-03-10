package  
{
	import Box2D.Dynamics.*;
	import Box2D.Collision.*;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.Contacts.b2ContactResult;
	/**
	 * ...
	 * @author Dwiz
	 */
public class MyContactListener extends b2ContactListener

{
	public var forDeletion:b2Body = null;
	public var ballHitFloor:Boolean = false;
	/**
	 * Called when two fixtures begin to touch.
	 */
//	override public function BeginContact(contact:b2Contact):void { }

	/**
	 * Called when two fixtures cease to touch.
	 */
	//override public function EndContact(contact:b2Contact):void { }

	/**
	 * This is called after a contact is updated. This allows you to inspect a
	 * contact before it goes to the solver. If you are careful, you can modify the
	 * contact manifold (e.g. disable contact).
	 * A copy of the old manifold is provided so that you can detect changes.
	 * Note: this is called only for awake bodies.
	 * Note: this is called even when the number of contact points is zero.
	 * Note: this is not called for sensors.
	 * Note: if you set the number of contact points to zero, you will not
	 * get an EndContact callback. However, you may get a BeginContact callback
	 * the next step.
	 */
	//override public function PreSolve(contact:b2Contact, oldManifold:b2Manifold):void {}

	/**
	 * This lets you inspect a contact after the solver is finished. This is useful
	 * for inspecting impulses.
	 * Note: the contact manifold does not include time of impact impulses, which can be
	 * arbitrarily large if the sub-step is small. Hence the impulse is provided explicitly
	 * in a separate data structure.
	 * Note: this is only called for contacts that are touching, solid, and awake.
	 */
	override public function PostSolve(contact:b2Contact, impulse:b2ContactImpulse):void 
	{
		
		var fixtureA:b2Fixture = contact.GetFixtureA();
		var fixtureB:b2Fixture = contact.GetFixtureB();
		//trace("fixtureA: " + fixtureA.GetBody().GetDefinition().userData);
		//trace("fixtureB: " + fixtureB.GetBody().GetDefinition().userData);
		
			if (fixtureA.GetBody().GetUserData() is BrickGfx && fixtureB.GetBody().GetUserData() is Ball )
			{
				//trace("brick collided!");
				forDeletion = fixtureA.GetBody();
				//trace(forDeletion.GetDefinition().userData);
			}
			else if (fixtureA.GetBody().GetUserData() is Ball && fixtureB.GetBody().GetUserData() is BrickGfx)
			{
				forDeletion = fixtureB.GetBody();
			}
			if (fixtureA.GetBody().GetDefinition().userData =="Floor" && fixtureB.GetBody().GetUserData() is Ball)
			{
				//trace("brick collided!");
				//forDeletion = fixtureA.GetBody();
				//trace(forDeletion.GetDefinition().userData);
				ballHitFloor = true;
			}
			else if (fixtureA.GetBody().GetUserData() is Ball && fixtureB.GetBody().GetDefinition().userData == "Floor")
			{
				ballHitFloor = true;
				//forDeletion = fixtureB.GetBody();
			}
		
	}
}
		
}