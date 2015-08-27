package hy.rpg.starter
{
	import flash.display.DisplayObject;
	
	import hy.game.GameFrameStart;
	import hy.game.cfg.Config;
	import hy.game.core.event.SEvent;
	import hy.game.stage3D.SStage3D;
	import hy.game.starter.SStartNode;

	/**
	 * 启动3D加速
	 * @author wait
	 *
	 */
	public class StarterStarling extends SStartNode
	{
		private var stage3d : SStage3D;

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
			SStage3D.multitouchEnabled = false;
			stage3d = new SStage3D(Config.stage);
			stage3d.enableErrorChecking = false;
			stage3d.antiAliasing = 0;
			stage3d.addEventListener(SEvent.ROOT_CREATED, onRootCreated);
		}

		private function onRootCreated(event : Object, app : DisplayObject) : void
		{
			stage3d.removeEventListener(SEvent.ROOT_CREATED, onRootCreated);
			stage3d.start();
			Config.supportDirectX = SStage3D.context.driverInfo.indexOf("Software") == -1;
			GameFrameStart.current.onStart();
			nextNode();
		}

		override public function get id() : String
		{
			return GameNodeEnmu.start_starling;
		}
	}
}