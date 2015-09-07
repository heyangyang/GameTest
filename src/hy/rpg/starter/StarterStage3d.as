package hy.rpg.starter
{
	import flash.display.DisplayObject;
	
	import hy.game.GameFrameStart;
	import hy.game.cfg.Config;
	import hy.game.components.SCollisionComponent;
	import hy.game.core.event.SEvent;
	import hy.game.stage3D.SStage3D;
	import hy.game.starter.SStartNode;

	/**
	 * 启动3D加速
	 * @author wait
	 *
	 */
	public class StarterStage3d extends SStartNode
	{
		private var mStage3d : SStage3D;

		public function StarterStage3d()
		{
		}

		override public function onStart() : void
		{
			if (!Config.supportDirectX)
			{
				nextNode();
				return;
			}
			SStage3D.multitouchEnabled = false;
			mStage3d = new SStage3D(Config.stage);
			mStage3d.enableErrorChecking = false;
			mStage3d.antiAliasing = 0;
			mStage3d.addEventListener(SEvent.ROOT_CREATED, onRootCreated);
		}

		private function onRootCreated(event : Object, app : DisplayObject) : void
		{
			mStage3d.removeEventListener(SEvent.ROOT_CREATED, onRootCreated);
			mStage3d.start();
			Config.supportDirectX = SStage3D.context.driverInfo.indexOf("Software") == -1;
			nextNode();
		}

		protected override function nextNode() : void
		{
			if (!Config.supportDirectX)
				//地图宽度
				Config.TILE_WIDTH = Config.TILE_HEIGHT = 200;
			SCollisionComponent.init(Config.supportDirectX);
			GameFrameStart.current.onStart();
			super.nextNode();
		}

		override public function get id() : String
		{
			return GameNodeEnmu.start_starling;
		}
	}
}