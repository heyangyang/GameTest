////////////////////////////////////////////////////////////
// Stage3D Game Template - Chapter 3
// (c) by Christer Kaitila (http://www.mcfunkypants.com)
// http://www.mcfunkypants.com/molehill/chapter_3_demo/
////////////////////////////////////////////////////////////
// With grateful acknowledgements to:
// Thibault Imbert, Ryan Speets, Alejandro Santander, 
// Mikko Haapoja, Evan Miller and Terry Patton
// for their valuable contributions.
////////////////////////////////////////////////////////////
// Please buy the book:
// http://link.packtpub.com/KfKeo6
////////////////////////////////////////////////////////////
package
{
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import starling.utils.VertexData;

//	[SWF(width="640", height="480", frameRate="60", backgroundColor="#000000")]

	public class Stage3dGame extends Sprite
	{
		// constants used during inits
		private var swfWidth : int = 640;
		private var swfHeight : int = 480;

		// the 3d graphics window on the stage
		private var context3D : Context3D;
		// the compiled shader used to render our mesh
		private var shaderProgram : Program3D;
		// the uploaded verteces used by our mesh
		private var vertexBuffer : VertexBuffer3D;
		// the uploaded indeces of each vertex of the mesh
		private var indexBuffer : IndexBuffer3D;
		// the data that defines our 3d mesh model
		private var meshVertexData : Vector.<Number>;
		// the indeces that define what data is used by each vertex
		private var meshIndexData : Vector.<uint>;

		// matrices that affect the mesh location and camera angles
//		private var projectionMatrix : PerspectiveMatrix3D = new PerspectiveMatrix3D();
		private var modelMatrix : Matrix3D = new Matrix3D();
		private var viewMatrix : Matrix3D = new Matrix3D();
		private var modelViewProjection : Matrix3D = new Matrix3D();

		// a simple frame counter used for animation
		private var t : Number = 0;

		/* TEXTURE: Pure AS3 and Flex version:
		 * if you are using Adobe Flash CS5 comment out the next two lines of code */
		[Embed(source="mouse.jpg")]
		private var myTextureBitmap : Class;
		private var myTextureData : Bitmap = new myTextureBitmap();

		/* TEXTURE: Flash CS5 version:
		 * add the jpg to your library (F11)
		 * right click it and edit the advanced properties so
		 * it is exported for use in Actionscript and call it myTextureBitmap
		 * if using Flex/FlashBuilder/FlashDevlop comment out the next two lines of code */
		//private var myBitmapDataObject:myTextureBitmapData = new myTextureBitmapData(textureSize, textureSize);
		//private var myTextureData:Bitmap = new Bitmap(myBitmapDataObject);

		// The Stage3d Texture that uses the above myTextureData
		private var myTexture : Texture;

		public function Stage3dGame()
		{
			if (stage != null)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e : Event = null) : void
		{

			if (hasEventListener(Event.ADDED_TO_STAGE))
				removeEventListener(Event.ADDED_TO_STAGE, init);

			stage.frameRate = 60;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			swfWidth = stage.stageWidth; //= stage.f;
			swfHeight = stage.stageHeight; // = stage.fullScreenHeight;


			// and request a context3D from Stage3d
			stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, onContext3DCreate);
			stage.stage3Ds[0].requestContext3D();
		}

		private function onContext3DCreate(event : Event) : void
		{
			// Remove existing frame handler. Note that a context
			// loss can occur at any time which will force you
			// to recreate all objects we create here.
			// A context loss occurs for instance if you hit
			// CTRL-ALT-DELETE on Windows.			
			// It takes a while before a new context is available
			// hence removing the enterFrame handler is important!

			if (hasEventListener(Event.ENTER_FRAME))
				removeEventListener(Event.ENTER_FRAME, enterFrame);

			// Obtain the current context
			var t : Stage3D = event.target as Stage3D;
			context3D = t.context3D;

			if (context3D == null)
			{
				// Currently no 3d context is available (error!)
				return;
			}

			// Disabling error checking will drastically improve performance.
			// If set to true, Flash will send helpful error messages regarding
			// AGAL compilation errors, uninitialized program constants, etc.
			context3D.enableErrorChecking = true;

			// Initialize our mesh data
			initData();

			// The 3d back buffer size is in pixels
			context3D.configureBackBuffer(swfWidth, swfHeight, 0, true);

			// A simple vertex shader which does a 3D transformation
			var vertexShaderAssembler : AGALMiniAssembler = new AGALMiniAssembler();
			vertexShaderAssembler.assemble(Context3DProgramType.VERTEX,
				// 4x4 matrix multiply to get camera angle	
				"m44 op, va0, vc1\n"+
				"mov v0, vc0\n"+
				"mov v1, va2 "  );

			// A simple fragment shader which will use the vertex position as a color
			var fragmentShaderAssembler : AGALMiniAssembler = new AGALMiniAssembler();
			fragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT,
				// grab the texture color from texture fs0
				// using the UV coordinates stored in v1
				"tex ft1,  v1, fs0 <2d,repeat,miplinear>\n"
				+" mul  oc, ft1,  v0"
			);

			// combine shaders into a program which we then upload to the GPU
			shaderProgram = context3D.createProgram();
			shaderProgram.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);

			// upload the mesh indexes
			indexBuffer = context3D.createIndexBuffer(meshIndexData.length);
			indexBuffer.uploadFromVector(meshIndexData, 0, meshIndexData.length);

			// upload the mesh vertex data
			// since our particular data is 
			// x, y, z, u, v, nx, ny, nz
			// each vertex uses 8 array elements
			vertexBuffer = context3D.createVertexBuffer(meshVertexData.length / VertexData.ELEMENTS_PER_VERTEX, VertexData.ELEMENTS_PER_VERTEX);
			vertexBuffer.uploadFromVector(meshVertexData, 0, meshVertexData.length / VertexData.ELEMENTS_PER_VERTEX);

			// Generate mipmaps
			var ws : int = myTextureData.bitmapData.width;
			var hs : int = myTextureData.bitmapData.height;
			myTexture = context3D.createTexture(ws, hs, Context3DTextureFormat.BGRA, false);
			var level : int = 0;
			var tmp : BitmapData;
			var transform : Matrix = new Matrix();
			tmp = new BitmapData(ws, hs, true, 0x00000000);
			while (ws >= 1 && hs >= 1)
			{
				tmp.draw(myTextureData.bitmapData, transform, null, null, null, true);
				myTexture.uploadFromBitmapData(tmp, level);
				transform.scale(0.5, 0.5);
				level++;
				ws >>= 1;
				hs >>= 1;
				if (hs && ws)
				{
					tmp.dispose();
					tmp = new BitmapData(ws, hs, true, 0x00000000);
				}
			}
			tmp.dispose();

			// create projection matrix for our 3D scene
//			projectionMatrix.identity();
//			// 45 degrees FOV, 640/480 aspect ratio, 0.1=near, 100=far
//			projectionMatrix.perspectiveFieldOfViewRH(45.0, swfWidth / swfHeight, 0.01, 100.0);

			// create a matrix that defines the camera location
			viewMatrix.identity();
			// move the camera back a little so we can see the mesh
			viewMatrix.appendTranslation(0, 0, -4);
context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			// start animating
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}

		private var m_x : int = 100;
		private var m_y : int = 100;
		private var m_w : int = 512;
		private var m_h : int = 512;
		private static var sRenderAlpha:Vector.<Number> = new <Number>[
			1.0, 1.0, 1.0, 0.5
			,1.0, 1.0, 1.0, 0.5
			,1.0, 1.0, 1.0, .5
			,1.0, 1.0, 1.0, .5
		];
		
		private function enterFrame(e : Event) : void
		{
			// clear scene before rendering is mandatory
			context3D.clear(1, 1, 1);

			context3D.setProgram(shaderProgram);

			// create the various transformation matrices
			modelMatrix.identity();
			modelMatrix.appendRotation(t * 0.7, Vector3D.Y_AXIS);
			modelMatrix.appendRotation(t * 0.6, Vector3D.X_AXIS);
			modelMatrix.appendRotation(t * 1.0, Vector3D.Y_AXIS);
			modelMatrix.appendTranslation(0.0, 0.0, 0.0);
			modelMatrix.appendRotation(90.0, Vector3D.X_AXIS);

			// rotate more next frame
			t += 2.0;

			// clear the matrix and append new angles
//			modelViewProjection.identity();
//			modelViewProjection.copyRawDataFrom(m_positon);
//			modelViewProjection.append(modelMatrix);
//			modelViewProjection.append(viewMatrix);
//			modelViewProjection.append(projectionMatrix);

			// pass our matrix data to the shader program
			context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, sRenderAlpha);
			context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 1, mProjectionMatrix3D,true);

			// associate the vertex data with current shader program
			// position
			context3D.setVertexBufferAt(0, vertexBuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
			// tex coord
			//context3D.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_4);
			
			context3D.setVertexBufferAt(2, vertexBuffer, VertexData.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2);

			// which texture should we use?
			context3D.setTextureAt(0, myTexture);

			// finally draw the triangles
			context3D.drawTriangles(indexBuffer, 0, meshIndexData.length / 3);

			// present/flip back buffer
			context3D.present();
		}

		private function initData() : void
		{
			setProjectionMatrix(
				0,
				0,
				stage.stageWidth,
				stage.stageHeight,
				stage.stageWidth, stage.stageHeight, null);
			var mTransformationMatrix:Matrix=new Matrix();
			var mRotation:Number=Math.PI/180*30;
			var mScaleX:Number=1;
			var mScaleY:Number=1;
			var mPivotX:int=0;
			var mPivotY:int=0;
			var mX:int=0;
			var mY:int=0;
			var mWidth:int;
			var mHeight:int;
			
			mRotation=0;
			mWidth=mHeight=200;
			mX=mY=200;
			
			if (mRotation == 0.0)
			{
				mTransformationMatrix.setTo(mScaleX, 0.0, 0.0, mScaleY, 
					mX - mPivotX * mScaleX, mY - mPivotY * mScaleY);
			}
			else
			{
				var cos:Number = Math.cos(mRotation);
				var sin:Number = Math.sin(mRotation);
				var a:Number   = mScaleX *  cos;
				var b:Number   = mScaleX *  sin;
				var c:Number   = mScaleY * -sin;
				var d:Number   = mScaleY *  cos;
				var tx:Number  = mX - mPivotX * a - mPivotY * c;
				var ty:Number  = mY - mPivotX * b - mPivotY * d;
				
				mTransformationMatrix.setTo(a, b, c, d, tx, ty);
			}
			
			var vertexData:VertexData=new VertexData(4,true);
			vertexData.setPosition(0, 0.0, 0.0);
			vertexData.setPosition(1, mWidth, 0.0);
			vertexData.setPosition(2, mWidth, mHeight);
			vertexData.setPosition(3, 0.0, mHeight);
//			vertexData.setUniformColor(0xffffff);
			vertexData.setTexCoords(0, 0.0, 0.0);
			vertexData.setTexCoords(1, 1.0, 0.0);
			vertexData.setTexCoords(2, 1.0, 1.0);
			vertexData.setTexCoords(3, 0.0, 1.0);
//			vertexData.scaleAlpha(0,0.5,4);
			
			var mVertexData:VertexData=new VertexData(4,true);
			vertexData.copyTransformedTo(mVertexData,0,mTransformationMatrix);
			modelViewProjection.identity();
			//modelViewProjection.copyRawDataFrom(m_positon);
			// Defines which vertex is used for each polygon
			// In this example a square is made from two triangles
//			mProjectionMatrix3D.prependTranslation(mX,mY,0);
			meshIndexData = Vector.<uint>([0, 1, 2, 0, 2, 3,]);
			meshVertexData = mVertexData.rawData;
		}
		
		private static var sPoint3D:Vector3D = new Vector3D();
		private var mProjectionMatrix:Matrix;
		private var mProjectionMatrix3D:Matrix3D;
		
		private static var sMatrixData:Vector.<Number> = 
			new <Number>[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
		
		public function setProjectionMatrix(x:Number, y:Number, width:Number, height:Number,
											stageWidth:Number=0, stageHeight:Number=0,
											cameraPos:Vector3D=null):void
		{
			if (cameraPos == null)
			{
				cameraPos = sPoint3D;
				cameraPos.setTo(
					stageWidth / 2, stageHeight / 2,   // -> center of stage
					stageWidth / Math.tan(0.5) * 0.5); // -> fieldOfView = 1.0 rad
			}
			mProjectionMatrix=new Matrix();
			// set up 2d (orthographic) projection
			mProjectionMatrix.setTo(2.0/width, 0, 0, -2.0/height,
				-(2*x + width) / width, (2*y + height) / height);
			
			var focalLength:Number = Math.abs(cameraPos.z);
			var offsetX:Number = cameraPos.x - stageWidth  / 2;
			var offsetY:Number = cameraPos.y - stageHeight / 2;
			var far:Number    = focalLength * 20;
			var near:Number   = 1;
			var scaleX:Number = stageWidth  / width;
			var scaleY:Number = stageHeight / height;
			
			// set up general perspective
			sMatrixData[ 0] =  2 * focalLength / stageWidth;  // 0,0
			sMatrixData[ 5] = -2 * focalLength / stageHeight; // 1,1  [negative to invert y-axis]
			sMatrixData[10] =  far / (far - near);            // 2,2
			sMatrixData[14] = -far * near / (far - near);     // 2,3
			sMatrixData[11] =  1;                             // 3,2
//			
//			// now zoom in to visible area
//			sMatrixData[0] *=  scaleX;
//			sMatrixData[5] *=  scaleY;
//			sMatrixData[8]  =  scaleX - 1 - 2 * scaleX * (x - offsetX) / stageWidth;
//			sMatrixData[9]  = -scaleY + 1 + 2 * scaleY * (y - offsetY) / stageHeight;
			
			mProjectionMatrix3D=new Matrix3D();
			mProjectionMatrix3D.copyRawDataFrom(sMatrixData);
			mProjectionMatrix3D.prependTranslation(
				-stageWidth /2.0 - offsetX,
				-stageHeight/2.0 - offsetY,
				focalLength);
		}
	}
}
