package;

import ecs.Universe;
import ecs.Entity;

class ECS {
	
	public static var eventity:Entity = Entity.none; // should throw an error if forgot to set
	public static var ecs:Universe = null;
	
	static var eventQueue:Array<Event> = [];
	
	public static function event(type:Event) {
		
		// events need to be queued in case multiple dispatch in the same call
		eventQueue.push(type);
		
		// following events don't need to loop since first one handles it
		if (eventQueue.length == 1) {
			
			var et:Event;
			while (eventQueue.length > 0) {
				
				et = eventQueue[0];
				
				// trigger onAdded where events are handled within systems, then remove since it's not needed
				ecs.setComponents(eventity, et); 
				ecs.removeComponents(eventity, et);
				
				eventQueue.shift(); // shift after setting so queue doesn't go empty
			}
		}
	}
}