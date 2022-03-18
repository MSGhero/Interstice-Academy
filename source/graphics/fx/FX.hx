package graphics.fx;

import timing.Updater;

@:forward
abstract FX(Array<Updater>) from Array<Updater> to Array<Updater> {
	public function new() this = [];
}