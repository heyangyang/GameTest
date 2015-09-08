package hy.rpg.weather
{
	import hy.game.cfg.Config;
	import hy.game.core.SUpdate;
	import hy.game.manager.SLayerManager;
	import hy.game.stage3D.display.SImage;
	import hy.game.stage3D.display.SQuadBath;

	public class SRainWeather extends SUpdate
	{
		private static var instance : SRainWeather;

		public static function getInstance() : SRainWeather
		{
			if (instance == null)
				instance = new SRainWeather();
			return instance;
		}
		private const mMaxCount : int = 500;
		private const mUpdateCreate : int = 10;
		private var mChildren : Vector.<SRain>;
		private var mNumChildren : int;
		private var mQuadBath : SQuadBath;

		public function SRainWeather()
		{
			mNumChildren = 0;
			mChildren = new Vector.<SRain>();
			mQuadBath = new SQuadBath();
			SLayerManager.getInstance().addChild(SLayerManager.LAYER_WEATHER, mQuadBath);
		}

		public override function update() : void
		{
			var rain : SRain;
			for (var i : int = 0; i < mNumChildren; i++)
			{
				rain = mChildren[i];
				rain && rain.update();
				mQuadBath.updateImage(rain);
				if (rain.isEnd)
				{
					rain.x = int(Math.random() * Config.screenWidth);
					rain.y = 0;
				}
			}
			createRain();
		}

		private function createRain() : void
		{
			if (mNumChildren >= mMaxCount)
				return;
			var i : int = Math.min(mMaxCount - mNumChildren, mUpdateCreate);
			var rain : SRain;
			for (; i > 0; i--)
			{
				rain = new SRain();
				rain.x = int(Math.random() * Config.screenWidth);
				rain.y = 0;
				rain.speed = Math.random() * 0.5 + 0.5;
				mQuadBath.addImage(rain);
				mChildren.push(rain);
				mNumChildren++;
			}
		}
	}
}