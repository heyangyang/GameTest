package hy.rpg.pak
{
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.events.EventDispatcher;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import hy.game.png.SJpegEncoder;
	import hy.game.png.SPngEncoder;

	/**
	 *
	 * 资源包编码器
	 *
	 */
	public class EncoderPak extends EventDispatcher
	{
		public var colorNumber : int;
		public var list : Array;
		public var type : int;
		public var quality : int;
		public var alphaQuality : int;
		public var alphaFilter : int;
		public var checkColorBounds : Boolean;
		public var bytes : ByteArray;
		private var _backgroundTransform : ColorTransform;
		private var _conBmds : Array;
		private var _alphaBmds : Array;

		public function EncoderPak(list : Array, type : int = 1, quality : int = 80, alphaFilter : int = 0, effectivePixels : Boolean = false, colorNumber : int = 0)
		{
			this.colorNumber = colorNumber;
			this.list = list;
			this.type = type;
			this.type = 2; //强制等于2
			this.quality = quality;
			this.alphaQuality = quality;
			this.alphaFilter = alphaFilter;
			this.checkColorBounds = effectivePixels;
			_backgroundTransform = new ColorTransform(1.0, 1.0, 1.0, 1.0, 0, 0, 0, 255);
			if (list)
				this.encode();
		}

		public function encode() : void
		{
			if (type == 1)
				encode1();
			else if (type == 2)
				encode2();
		}

		public function encodeByPak(pak : DecoderPak, start : int, len : int) : void
		{
			this.type = pak.type;
			this.quality = pak.quality;
			this.alphaQuality = pak.alphaQuality;
			this.alphaFilter = pak.alphaFilter;
			len = pak.length;
			var i : int = 0;
			var offest : Point;
			var size : Point;
			var data : ByteArray;
			var alphaData : ByteArray;

			if (type == 1)
			{
				bytes = new ByteArray();
				bytes.writeByte(type);
				bytes.writeShort(pak.width);
				bytes.writeShort(pak.height);
				bytes.writeByte(quality);
				bytes.writeByte(alphaQuality);
				bytes.writeByte(alphaFilter);
				bytes.writeShort(len);

				var rect : Rectangle = new Rectangle();
				for (i = 0; i < len; i++)
				{
					offest = pak.getOffest(i);
					size = pak.getSize(i);
					rect.x = offest.x;
					rect.y = offest.y;
					rect.width = size.x;
					rect.height = size.y;

					bytes.writeShort(rect.x);
					bytes.writeShort(rect.y);
					bytes.writeShort(rect.width);
					bytes.writeShort(rect.height);
				}

				if (quality == alphaQuality)
				{
					data = pak.loadDataList[0];
					bytes.writeUnsignedInt(data.length);
					bytes.writeBytes(data);
				}
				else
				{
					data = pak.loadDataList[0];
					bytes.writeUnsignedInt(data.length);
					bytes.writeBytes(data);

					if (alphaQuality)
					{
						alphaData = pak.loadDataList[1];
						bytes.writeUnsignedInt(alphaData.length);
						bytes.writeBytes(alphaData);

						bytes.writeUnsignedInt(alphaData.length);
						bytes.writeBytes(alphaData);
					}
					else
					{
						bytes.writeUnsignedInt(0);
					}
				}
			}
			else if (type == 2)
			{
				bytes = new ByteArray();
				bytes.writeByte(type);
				bytes.writeShort(pak.width);
				bytes.writeShort(pak.height);
				bytes.writeByte(quality);
				bytes.writeByte(alphaQuality);
				bytes.writeByte(alphaFilter);
				bytes.writeShort(len);

				var mh : int = 0;
				var tw : int = 0;
				var rects : Array = [];
				for (i = 0; i < len; i++)
				{
					offest = pak.getOffest(start + i);
					size = pak.getSize(start + i);
					bytes.writeShort(offest.x);
					bytes.writeShort(offest.y);
					bytes.writeShort(size.x);
					bytes.writeShort(size.y);

					if (alphaQuality == 0 || quality == alphaQuality)
					{
						data = pak.loadDataList[start + i];
						bytes.writeUnsignedInt(data.length);
						bytes.writeBytes(data);
					}
					else
					{
						data = pak.loadDataList[(start + i) * 2];
						bytes.writeUnsignedInt(data.length);
						bytes.writeBytes(data);

						if (alphaQuality)
						{
							alphaData = pak.loadDataList[(start + i) * 2 + 1];
							bytes.writeUnsignedInt(alphaData.length);
							bytes.writeBytes(alphaData);
						}
					}
				}
			}
		}

		private function encode1() : void //合并单张，透明图也合并成一张
		{
			bytes = new ByteArray();
			bytes.writeByte(type);
			bytes.writeShort(list[0].width);
			bytes.writeShort(list[0].height);
			bytes.writeByte(quality);
			bytes.writeByte(alphaQuality);
			bytes.writeByte(alphaFilter);
			bytes.writeShort(list.length);

			var mh : int = 0;
			var tw : int = 0;
			var rects : Array = [];
			for each (var bmd : BitmapData in list)
			{
				var rect : Rectangle;
				if (checkColorBounds)
				{
					var checkBitmap : BitmapData = bmd.clone();
					checkBitmap.threshold(checkBitmap, checkBitmap.rect, new Point(), ">", 0, 0xFFFFFFFF, 0xFFFFFFFF);
					rect = checkBitmap.getColorBoundsRect(0xFFFFFFFF, 0xFFFFFFFF, true); //上面两步获取有效像素，或者只用一步getColorBoundsRect(0xff000000, 0x00000000, false);
					rects.push(rect);
					checkBitmap.dispose();
				}
				else
				{
					rect = bmd.rect;
					rects.push(rect);
				}

				if (rect.height > mh)
					mh = rect.height;

				bytes.writeShort(rect.x);
				bytes.writeShort(rect.y);
				bytes.writeShort(rect.width);
				bytes.writeShort(rect.height);

				tw += rect.width;
			}

			_conBmds = [];
			_alphaBmds = [];
			var newBmd : BitmapData = new BitmapData(tw, mh, true, 0);
			var conBmd : BitmapData;
			var conData : ByteArray;
			var bgBmd : BitmapData;
			var alphaBmd : BitmapData;
			var sx : int = 0;
			for (var i : int = 0; i < list.length; i++)
			{
				bmd = list[i];
				rect = rects[i];

				newBmd.copyPixels(bmd, rect, new Point(sx, 0));

				sx += rect.width;
			}

			if (quality == alphaQuality)
			{
				if (quality == 100)
				{
					conBmd = new BitmapData(newBmd.width, newBmd.height, true, 0x00000000);
					conBmd.copyPixels(newBmd, newBmd.rect, new Point());

					conData = new SPngEncoder().encode(conBmd);
				}
				else
				{
					conBmd = new BitmapData(newBmd.width, newBmd.height * 2, false, 0xFFFFFFFF);
					bgBmd = newBmd.clone();
					bgBmd.colorTransform(bgBmd.rect, _backgroundTransform);
					conBmd.copyPixels(bgBmd, bgBmd.rect, new Point());
					conBmd.copyPixels(newBmd, newBmd.rect, new Point());

					alphaBmd = new BitmapData(newBmd.width, newBmd.height, false, 0);
					alphaBmd.copyChannel(newBmd, newBmd.rect, new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.RED);
					alphaBmd.copyChannel(newBmd, newBmd.rect, new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.GREEN);
					alphaBmd.copyChannel(newBmd, newBmd.rect, new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.BLUE);
					conBmd.copyPixels(alphaBmd, alphaBmd.rect, new Point(0, newBmd.height));
					alphaBmd.dispose();

					conData = new SJpegEncoder(quality).encode(conBmd);
				}

				bytes.writeUnsignedInt(conData.length);
				bytes.writeBytes(conData);
				_conBmds.push(conBmd);
			}
			else
			{
				if (quality == 100)
				{
					conBmd = new BitmapData(newBmd.width, newBmd.height, true, 0x00000000);
					conBmd.copyPixels(newBmd, newBmd.rect, new Point());
					conData = new SPngEncoder().encode(conBmd);
				}
				else
				{
					conBmd = new BitmapData(newBmd.width, newBmd.height, false, 0xFFFFFFFF);
					bgBmd = newBmd.clone();
					bgBmd.colorTransform(bgBmd.rect, _backgroundTransform);
					conBmd.copyPixels(bgBmd, bgBmd.rect, new Point());
					conBmd.copyPixels(newBmd, newBmd.rect, new Point());
					conData = new SJpegEncoder(quality).encode(conBmd);
				}
				bytes.writeUnsignedInt(conData.length);
				bytes.writeBytes(conData);
				_conBmds.push(conBmd);

				if (alphaQuality)
				{
					alphaBmd = new BitmapData(newBmd.width, newBmd.height, false, 0);
					alphaBmd.copyChannel(newBmd, newBmd.rect, new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.RED);
					alphaBmd.copyChannel(newBmd, newBmd.rect, new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.GREEN);
					alphaBmd.copyChannel(newBmd, newBmd.rect, new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.BLUE);
					var alphaData : ByteArray = alphaQuality == 100 ? new SPngEncoder().encode(alphaBmd) : new SJpegEncoder(alphaQuality).encode(alphaBmd);
					_alphaBmds.push(alphaBmd);
					bytes.writeUnsignedInt(alphaData.length);
					bytes.writeBytes(alphaData);
				}
				else
				{
					bytes.writeUnsignedInt(0);
				}
			}

			newBmd.dispose();
		}

		private function encode2() : void
		{
			bytes = new ByteArray();
			bytes.writeByte(type);
			bytes.writeShort(list[0].width);
			bytes.writeShort(list[0].height);
			bytes.writeByte(quality);
			bytes.writeByte(alphaQuality);
			bytes.writeByte(alphaFilter);
			bytes.writeShort(list.length);
			for each (var bmd : BitmapData in list)
			{
				var rect : Rectangle;
				var newBmb : BitmapData;
				var conBmd : BitmapData;
				var bgBmd : BitmapData;
				var alphaBmd : BitmapData;
				if (checkColorBounds)
				{
					var checkBitmap : BitmapData = bmd.clone();
					checkBitmap.threshold(checkBitmap, checkBitmap.rect, new Point(), ">", 0, 0xFFFFFFFF, 0xFFFFFFFF);
					rect = checkBitmap.getColorBoundsRect(0xFFFFFFFF, 0xFFFFFFFF, true); //上面两步获取有效像素，或者只用一步getColorBoundsRect(0xff000000, 0x00000000, false);
					if (rect.width == 0 || rect.height == 0)
						newBmb = new BitmapData(1, 1, true, 0);
					else
						newBmb = new BitmapData(rect.width, rect.height, true, 0);
					newBmb.copyPixels(bmd, rect, new Point());
					checkBitmap.dispose();
				}
				else
				{
					newBmb = bmd;
					rect = newBmb.rect;
				}

				bytes.writeShort(rect.x);
				bytes.writeShort(rect.y);
				bytes.writeShort(rect.width);
				bytes.writeShort(rect.height);

				if (quality == alphaQuality)
				{
					bgBmd = newBmb.clone();
					bgBmd.colorTransform(bgBmd.rect, _backgroundTransform);
					conBmd = new BitmapData(newBmb.width, newBmb.height * 2, false, 0xFFFFFFFF);
					conBmd.copyPixels(bgBmd, bgBmd.rect, new Point());
					conBmd.copyPixels(newBmb, newBmb.rect, new Point());
					alphaBmd = new BitmapData(newBmb.width, newBmb.height, false, 0);
					alphaBmd.copyChannel(newBmb, newBmb.rect, new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.RED);
					alphaBmd.copyChannel(newBmb, newBmb.rect, new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.GREEN);
					alphaBmd.copyChannel(newBmb, newBmb.rect, new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.BLUE);
					conBmd.copyPixels(alphaBmd, alphaBmd.rect, new Point(0, newBmb.height));
					alphaBmd.dispose();

					var conData : ByteArray = quality == 100 ? new SPngEncoder().encode(conBmd) : new SJpegEncoder(quality).encode(conBmd);
					bytes.writeUnsignedInt(conData.length);
					bytes.writeBytes(conData);

					conBmd.dispose();
				}
				else
				{
					bgBmd = newBmb.clone();
					bgBmd.colorTransform(bgBmd.rect, _backgroundTransform);
					conBmd = new BitmapData(newBmb.width, newBmb.height, false, 0xFFFFFFFF);
					conBmd.copyPixels(bgBmd, bgBmd.rect, new Point());
					conBmd.copyPixels(newBmb, newBmb.rect, new Point());
					var data : ByteArray = quality == 100 ? new SPngEncoder().encode(conBmd) : new SJpegEncoder(quality).encode(conBmd);
					conBmd.dispose();
					bytes.writeUnsignedInt(data.length);
					bytes.writeBytes(data);

					if (alphaQuality)
					{
						alphaBmd = new BitmapData(newBmb.width, newBmb.height, false, 0);
						alphaBmd.copyChannel(newBmb, newBmb.rect, new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.RED);
						alphaBmd.copyChannel(newBmb, newBmb.rect, new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.GREEN);
						alphaBmd.copyChannel(newBmb, newBmb.rect, new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.BLUE);
						var alphaData : ByteArray = alphaQuality == 100 ? new SPngEncoder().encode(alphaBmd) : new SJpegEncoder(alphaQuality).encode(alphaBmd);
						alphaBmd.dispose();
						bytes.writeUnsignedInt(alphaData.length);
						bytes.writeBytes(alphaData);
					}
					else
					{
						bytes.writeUnsignedInt(0);
					}
				}
				newBmb.dispose();
			}
		}

		public function get conBmds() : Array
		{
			return _conBmds;
		}

		public function get alphaBmds() : Array
		{
			return _alphaBmds;
		}

		public function dispose() : void
		{
			var bmd : BitmapData;
			if (_alphaBmds)
			{
				for each (bmd in _alphaBmds)
					bmd.dispose();
				_alphaBmds.length = 0;
				_alphaBmds = null;
			}
			if (_conBmds)
			{
				for each (bmd in _conBmds)
					bmd.dispose();
				_conBmds.length = 0;
				_conBmds = null;
			}
		}
	}
}