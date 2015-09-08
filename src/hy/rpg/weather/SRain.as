package hy.rpg.weather
{
	import flash.display.BitmapData;
	import flash.display.Shape;

	import hy.game.cfg.Config;
	import hy.game.core.STime;
	import hy.game.render.SDirectBitmap;
	import hy.game.render.SDirectBitmapData;
	import hy.game.stage3D.texture.STexture;

	public class SRain extends SDirectBitmap
	{
		private static var sTexture : STexture;
		private var mSpeed : Number;
		private var mIsEnd : Boolean;

		public function SRain()
		{
			if (sTexture == null)
			{
				var shape : Shape = new Shape();
				shape.graphics.beginFill(0xffffff, 0.3);
				shape.graphics.drawRoundRect(0, 0, 4, 40, 10, 4);
				shape.graphics.endFill();
				var bit : BitmapData = new BitmapData(shape.width, shape.height, true, 0);
				bit.draw(shape);
				sTexture = SDirectBitmapData.fromDirectBitmapData(bit);
			}
			mSpeed = 1;
			super(sTexture);
		}

		public function update() : void
		{
			y += mSpeed * STime.deltaTime;
			mIsEnd = y >= Config.screenHeight;
		}

		public function get isEnd() : Boolean
		{
			return mIsEnd;
		}

		public function get speed() : Number
		{
			return mSpeed;
		}

		public function set speed(value : Number) : void
		{
			mSpeed = value;
		}

	}
}