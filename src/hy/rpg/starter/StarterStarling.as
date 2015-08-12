package hy.rpg.starter
{
	import flash.display.Stage;
	
	import hy.game.GameFrameStart;
	import hy.game.cfg.Config;
	import hy.game.starter.SStartNode;
	
	import starling.base.Game3D;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.events.Event;

	/**
	 * 启动3D加速
	 * @author wait
	 *
	 */
	public class StarterStarling extends SStartNode
	{
		private var mStarling : Starling;

	 	public function StarterStarling()
		{
		}

		override public function onStart() : void
		{
			if (!Config.supportDirectX)
			{ 
				GameFrameStart.current.onStart();
				nextNode();
				return;
			}
			Starling.multitouchEnabled = false;
			var stage : Stage = Config.stage;
			mStarling = new Starling(Game3D, stage);
			mStarling.stage.stageWidth = stage.stageWidth;
			mStarling.stage.stageHeight = stage.stageHeight;
			mStarling.simulateMultitouch = false;
			mStarling.enableErrorChecking = false;
			mStarling.antiAliasing = 0;
			mStarling.addEventListener(Event.ROOT_CREATED, onRootCreated);
		}

		private function onRootCreated(event : Object, app : DisplayObject) : void
		{
			mStarling.removeEventListener(Event.ROOT_CREATED, onRootCreated);
			Config.supportDirectX = Starling.context.driverInfo.indexOf("Software") == -1;
			Game3D(app).start();
			mStarling.start();
			GameFrameStart.current.onStart();
			nextNode();
		}

		override public function get id() : String
		{
			return GameNodeEnmu.start_starling;
		}
	}
}