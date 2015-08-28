package
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	/**
	 * TEA，改良过的 对称性加密/解密
	 * tea算法
	 * 在安全学领域，TEA（Tiny Encryption Algorithm）是一种分组加密算法，它的实现非常简单，通常只需要很精短的几行代码。
	 * TEA 算法最初是由剑桥计算机实验室的 David Wheeler 和 Roger Needham 在 1994 年设计的。
	 * TEA算法使用64位的明文分组和128位的密钥，它使用Feistel分组加密框架，需要进行 64 轮迭代，尽管作者认为 32 轮已经足够了。
	 * 该算法使用了一个神秘常数δ作为倍数，它来源于黄金比率，以保证每一轮加密都不相同。
	 * 但δ的精确值似乎并不重要，这里 TEA 把它定义为 δ=「(√5 - 1)231」（也就是程序中的 0×9E3779B9）。
	 * 之后 TEA 算法被发现存在缺陷，作为回应，设计者提出了一个 TEA 的升级版本——XTEA（有时也被称为“tean”）。
	 * XTEA 跟 TEA 使用了相同的简单运算，但它采用了截然不同的顺序，为了阻止密钥表攻击，四个子密钥（在加密过程中，
	 * 原 128 位的密钥被拆分为 4 个 32 位的子密钥）采用了一种不太正规的方式进行混合，但速度更慢了。
	 *
	 */
	public class STeaEncrypt
	{
		private static var round : uint = 32;
		/**
		 * sunriseliuliming
		 * 115 117 110 114 105 115 101 108 105 117 108 105 109 105 110 103
		 * 73 75 6E 72 69 73 65 6C 69 75 6C 69 6D 69 6E 67
		 */
		private static var keyStr : String = "sunriseliuliming";
		private static var key : String = "73 75 6E 72 69 73 65 6C 69 75 6C 69 6D 69 6E 67"; //"3A DA 75 21 DB E3 DB B3 62 B7 49 01 A5 C6 EA D5";

		public static function teaEncrypt(enData : ByteArray) : ByteArray
		{
			enData.position = 0;
			var len : uint = Math.ceil(enData.length / 8);
			var step : uint = Math.ceil(len / 8); //llm$sunny 20130217 新增步进，分批，每批有步进
			var keyArr : Array = str2long(keyStr, false); //getKey(key);

			var resData : ByteArray = new ByteArray();
			resData.position = 0;
			resData.endian = Endian.LITTLE_ENDIAN;

			var nData : ByteArray = new ByteArray();
			nData.position = 0;
			nData.endian = Endian.LITTLE_ENDIAN;

			enData.position = 0;
			for (var i : uint = 0; i < len; i += step)
			{
				var enBytes : ByteArray = new ByteArray();
				enBytes.position = 0;
				enBytes.endian = Endian.LITTLE_ENDIAN;

				if (enData.bytesAvailable >= 8)
				{
					enData.readBytes(enBytes, 0, 8);
					var encrypted : ByteArray = new ByteArray();
					encrypted.position = 0;
					encrypted.endian = Endian.LITTLE_ENDIAN;

					encrypted = encrypt(enBytes, keyArr);

					resData.writeBytes(encrypted, 0, encrypted.length);
					encrypted.clear();
					encrypted = null;

					//llm$sunny 20130217 新增步进，分批，每批有步进
					var available : uint = (step - 1) * 8;
					if (available > 0)
					{
						enBytes.position = 0;
						enBytes.clear();

						if (enData.bytesAvailable >= available)
							enData.readBytes(enBytes, 0, available);
						else
							enData.readBytes(enBytes, 0, enData.bytesAvailable);
						resData.writeBytes(enBytes, 0, enBytes.length);
					}
				}
				else
				{
					enData.readBytes(nData, 0, enData.bytesAvailable);
				}
				enBytes.clear();
			}
			//keyBytes.clear();
			enData.clear();

			nData.position = 0;
			if (nData.length > 0)
			{
				resData.writeBytes(nData, 0, nData.length);
			}
			resData.position = 0;
			return resData;
		}

		public static function teaDecrypt(decData : ByteArray) : ByteArray
		{
			decData.position = 0;
			var len : uint = Math.ceil(decData.length / 8);
			var step : uint = Math.ceil(len / 8); //llm$sunny 20130217 新增步进，分批，每批有步进
			var keyArr : Array = str2long(keyStr, false); //getKey(key);
			var resData : ByteArray = new ByteArray();
			resData.position = 0;
			resData.endian = Endian.LITTLE_ENDIAN;

			var nData : ByteArray = new ByteArray();
			nData.position = 0;
			nData.endian = Endian.LITTLE_ENDIAN;

			for (var i : uint = 0; i < len; i += step)
			{
				var decBytes : ByteArray = new ByteArray();
				decBytes.position = 0;
				decBytes.endian = Endian.LITTLE_ENDIAN;
				if (decData.bytesAvailable >= 8)
				{
					decData.readBytes(decBytes, 0, 8);
					var decrypted : ByteArray = new ByteArray();
					decrypted.position = 0;
					decrypted.endian = Endian.LITTLE_ENDIAN;

					decrypted = decrypt(decBytes, keyArr);

					resData.writeBytes(decrypted, 0, decrypted.length);
					decrypted.clear();
					decrypted = null;

					//llm$sunny 20130217 新增步进，分批，每批有步进
					var available : uint = (step - 1) * 8;
					if (available > 0)
					{
						decBytes.position = 0;
						decBytes.clear();

						if (decData.bytesAvailable >= available)
							decData.readBytes(decBytes, 0, available);
						else
							decData.readBytes(decBytes, 0, decData.bytesAvailable);
						resData.writeBytes(decBytes, 0, decBytes.length);
					}
				}
				else
				{
					decData.readBytes(nData, 0, decData.bytesAvailable);
				}
				decBytes.clear();
			}
			decData.clear();

			if (nData.length > 0)
			{
				nData.readBytes(resData, resData.length, nData.length);
			}
			resData.position = 0;
			return resData;
		}

		private static function long2str(v : Array, w : Boolean) : String
		{
			var vl : uint = v.length;
			var sl : uint = v[vl - 1] & 0xffffffff;
			for (var i : uint = 0; i < vl; i++)
			{
				v[i] = String.fromCharCode(v[i] & 0xff, v[i] >>> 8 & 0xff, v[i] >>> 16 & 0xff, v[i] >>> 24 & 0xff);
			}
			if (w)
			{
				return v.join('').substring(0, sl);
			}
			else
			{
				return v.join('');
			}
		}

		private static function str2long(s : String, w : Boolean) : Array
		{
			var len : uint = s.length;
			var v : Array = new Array();
			for (var i : uint = 0; i < len; i += 4)
			{
				v[i >> 2] = s.charCodeAt(i) | s.charCodeAt(i + 1) << 8 | s.charCodeAt(i + 2) << 16 | s.charCodeAt(i + 3) << 24;
			}
			if (w)
			{
				v[v.length] = len;
			}
			return v;
		}

		private static function LongArrayToByteArray(data : Array, includeLength : Boolean) : ByteArray
		{
			var length : uint = data.length;

			var n : uint = (length - 1) << 2;
			if (includeLength)
			{
				var m : uint = data[length - 1];
				if ((m < n - 3) || (m > n))
				{
					return null;
				}
				n = m;
			}

			var result : ByteArray = new ByteArray();
			result.endian = Endian.LITTLE_ENDIAN;
			for (var i : uint = 0; i < length; i++)
			{
				result.writeUnsignedInt(data[i]);
			}
			if (includeLength)
			{

				result.length = n;
				return result;
			}
			else
			{
				return result;
			}
		}

		private static function ByteArrayToLongArray(data : ByteArray, includeLength : Boolean) : Array
		{
			var length : uint = data.length;
			var n : uint = length >> 2;
			if (length % 4 > 0)
			{
				n++;
				data.length += (4 - (length % 4));
			}
			data.endian = Endian.LITTLE_ENDIAN;
			data.position = 0;
			var result : Array = [];
			for (var i : uint = 0; i < n; i++)
			{
				result[i] = data.readUnsignedInt();
			}
			if (includeLength)
			{
				result[n] = length;
			}
			data.length = length;
			return result;
		}

		private static function encrypt(data : ByteArray, key : Array) : ByteArray
		{
			if (data.length == 0)
			{
				return new ByteArray();
			}
			var v : Array = ByteArrayToLongArray(data, false);
			var k : Array = key; //[987395361, 3689143219, 1656178945, 2781276885]; //密钥写死
			if (k.length < 4)
			{
				k.length = 4;
			}
			var n : uint = v.length - 1;
			var y : uint = v[0];
			var z : uint = v[1];

			var a : uint = k[0];
			var b : uint = k[1];
			var c : uint = k[2];
			var d : uint = k[3];
			var delta : uint = 0x9E3779B9; /* (sqrt(5)-1)/2*2^32 */

			var sum : uint = 0;

			for (var i : uint = 0; i < round; i++)
			{ /* basic cycle start */
				sum += delta;
				y += ((z << 4) + a) ^ (z + sum) ^ ((z >>> 5) + b);
				z += ((y << 4) + c) ^ (y + sum) ^ ((y >>> 5) + d); /* end cycle */
			}
			v[0] = y;
			v[1] = z;

			return LongArrayToByteArray(v, false);
		}

		private static function decrypt(data : ByteArray, key : Array) : ByteArray
		{
			if (data.length == 0)
			{
				return new ByteArray();
			}
			var v : Array = ByteArrayToLongArray(data, false);
			var k : Array = key; //[987395361, 3689143219, 1656178945, 2781276885]; //密钥写死
			if (k.length < 4)
			{
				k.length = 4;
			}
			var n : uint = v.length - 1;
			var y : uint = v[0];
			var z : uint = v[1];

			var a : uint = k[0];
			var b : uint = k[1];
			var c : uint = k[2];
			var d : uint = k[3];
			var delta : uint = 0x9E3779B9; /* (sqrt(5)-1)/2*2^32 */
			var sum : uint = 0xE3779B90;

			if (round == 32)
			{
				sum = 0xC6EF3720; //delta << 5
			}
			else if (round == 16)
			{
				sum = 0xE3779B90;
			} //delta << 4

			for (var i : uint = 0; i < round; i++)
			{ /* basic cycle start */
				z -= ((y << 4) + c) ^ (y + sum) ^ ((y >>> 5) + d);
				y -= ((z << 4) + a) ^ (z + sum) ^ ((z >>> 5) + b);

				sum -= delta;
			}
			v[0] = y;
			v[1] = z;
			return LongArrayToByteArray(v, false);
		}

		private static function getKey(keyStr : String) : Array
		{
			var key : String = keyStr;
			var arr : Array = new Array();
			var res : Array = new Array();

			var target : Array = new Array();

			arr = key.split(" ");

			var curStr : String = "";
			var len : uint = arr.length;
			for (var i : uint = 0; i < arr.length; i++)
			{
				var newArr : Array = new Array();
				curStr = arr[i];

				for (var j : uint = 0; j < 2; j++)
				{
					var char : String = curStr.charAt(j);
					newArr.push(char);
				}
				target.push(newArr);
			}

			for (i = 0; i < target.length; i++)
			{
				var a : int = isNumber(target[i][0]);
				var b : int = isNumber(target[i][1]);
				var resNum : int = a * 16 + b;
				res.push(resNum);
			}

			return res;
		}

		private static function isNumber(char : String) : int
		{
			var arr : Array = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];
			for (var i : uint = 0; i < arr.length; i++)
			{
				if (char == arr[i])
				{
					return int(char);
					break;
				}
			}
			var id : int = 0;
			switch (char)
			{
				case "A":
					id = 10;
					break;
				case "B":
					id = 11;
					break;
				case "C":
					id = 12;
					break;
				case "D":
					id = 13;
					break;
				case "E":
					id = 14;
					break;
				case "F":
					id = 15;
					break;
				default:
					break;
			}
			return id;
		}

		private static function intToHexChar(index : int) : String
		{
			var hex : Array = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'];
			return hex[index];
		}

		private static function intToHexString(arr : Array) : String
		{
			var myStr : String = "";
			for (var i : uint = 0; i < arr.length; ++i)
			{
				var t : uint = arr[i];
				var a : uint = Math.floor(t / 16);
				var b : uint = Math.floor(t % 16);

				myStr += intToHexChar(a);
				myStr += intToHexChar(b);
				myStr += " ";

			}
			return myStr;
		}
	}
}