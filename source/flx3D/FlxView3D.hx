package flx3D;

import away3d.library.Asset3DLibrary;
import away3d.events.LoaderEvent;
import away3d.entities.SegmentSet;
import away3d.cameras.Camera3D;
import away3d.entities.TextureProjector;
import away3d.containers.ObjectContainer3D;
import away3d.primitives.SkyBox;
import away3d.lights.LightBase;
import away3d.library.Asset3DLibraryBundle;
import away3d.loaders.misc.AssetLoaderToken;
import away3d.entities.Mesh;
import away3d.library.assets.Asset3DType;
import away3d.loaders.parsers.*;
import away3d.materials.TextureMaterial;
import away3d.loaders.misc.AssetLoaderContext;
import openfl.Assets;
import away3d.events.Asset3DEvent;
import away3d.containers.View3D;
import away3d.library.assets.IAsset;
import flixel.FlxG;
import flixel.FlxSprite;
import openfl.display.BitmapData;
import away3d.utils.Cast;

/**
 * @author Ne_Eo 
 * @see https://twitter.com/Ne_Eo_Twitch
 * 
 * Edited by lunarclient
 * @see https://twitter.com/lunarcleint
 */
class FlxView3D extends FlxSprite
{
	private static var allIDs:Int = 0;

	@:noCompletion private var bmp:BitmapData;

	/**
	 * The Away3D View 
	 */
	public var view:View3D;

	/**
	 * Set this flag to true to force the View3D to update during the `draw()` call.
	 */
	 public var dirty3D:Bool = true;

	private var meshes:Array<Mesh> = [];

	private var curID:Int;

	/**
	 * Creates a new instance of a View3D from Away3D and renders it as a FlxSprite
	 * ! Call Flx3DUtil.is3DAvailable(); to make sure a 3D stage is usable
	 * @param x 
	 * @param y 
	 * @param width Leave as -1 for screen width
	 * @param height Leave as -1 for screen height
	 */
	public function new(x:Float = 0, y:Float = 0, width:Int = -1, height:Int = -1)
	{
		super(x, y);

		if (!Flx3DUtil.is3DAvailable())
			throw '[FlxView3D] 3D is not availale at the moment! Current using sprites: ${Flx3DUtil.getTotal3D()}. Max sprites allowed: ${FlxG.stage.stage3Ds.length}';

		view = new View3D();
		view.visible = false;

		view.width = width == -1 ? FlxG.width : width;
		view.height = height == -1 ? FlxG.height : height;

		view.backgroundAlpha = 0;
		FlxG.stage.addChildAt(view, 0);

		bmp = new BitmapData(Std.int(view.width), Std.int(view.height), true, 0x0);
		loadGraphic(bmp);

		curID = allIDs++;
	}

	public function addModel(assetPath:String, callback:Asset3DEvent->Void, ?texturePath:String, smoothTexture:Bool = true)
	{
		var model = Assets.getBytes(assetPath);
		if (!Assets.exists('${assetPath.removeAfter('.')}.mtl'))
			throw 'Model at ${assetPath.removeAfter('.')} was not found.';

		var context = new AssetLoaderContext();
		context.mapUrlToData('${assetPath.removeAfter('.')}.mtl', '${assetPath.removeAfter('.')}.mtl');

		var material:TextureMaterial = null;
		if (texturePath != null)
			material = new TextureMaterial(Cast.bitmapTexture(texturePath), smoothTexture);

		return loadData(model, context, switch (assetPath.removeAfter('.'))
		{
			case "dae": new DAEParser();
			case "md2": new MD2Parser();
			case "md5": new MD5MeshParser();
			case "awd": new AWDParser();
			default: new OBJParser();
		}, (event:Asset3DEvent) ->
			{
				if (event.asset != null && event.asset.assetType == Asset3DType.MESH)
				{
					var mesh:Mesh = cast(event.asset, Mesh);
					if (material != null)
						mesh.material = material;
					meshes.push(mesh);
				}
				if (callback != null)
					callback(event);
			});
	}

	/**
	 * Disposes (destroys) the asset and returns null
	 * @param obj 
	 * @return T null
	 */
	public static function dispose<T:IAsset>(obj:Null<T>):T
	{
		return Flx3DUtil.dispose(obj);
	}

	/**
	 * Disposes of all the Away3D assets associated with the FlxView3D
	 */
	override function destroy()
	{
		if (meshes != null)
			for (mesh in meshes)
				mesh.dispose();

		var bundle = Asset3DLibraryBundle.getInstance('Flx3DView-${curID}');
		bundle.stopAllLoadingSessions();
		@:privateAccess {
			if (bundle._loadingSessions != null)
			{
				for (load in bundle._loadingSessions)
				{
					load.dispose();
				}
			}
			Asset3DLibrary._instances.remove('Flx3DView-${curID}');
		}
		
		FlxG.stage.removeChild(view);
		super.destroy();

		if (bmp != null)
		{
			bmp.dispose();
			bmp = null;
		}

		if (view != null) 
		{
			view.dispose();
			view = null;
		}
	
	}

	@:noCompletion override function draw()
	{
		super.draw();

		if (dirty3D)
		{
			view.visible = false;
			FlxG.stage.addChildAt(view, 0);

			var old = FlxG.game.filters;
			FlxG.game.filters = null;

			view.renderer.queueSnapshot(bmp);
			view.render();

			FlxG.game.filters = old;
			FlxG.stage.removeChild(view);
		}
	}

	@:noCompletion override function set_width(newWidth:Float):Float
	{
		super.set_width(newWidth);
		return view != null ? view.width = width : width;
	}

	@:noCompletion override function set_height(newHeight:Float):Float
	{
		super.set_height(newHeight);
		return view != null ? view.height = height : height;
	}


	private var _loaders:Map<Asset3DLibraryBundle, AssetLoaderToken> = [];
	private function loadData(data:Dynamic, context:AssetLoaderContext, parser:ParserBase, onAssetCallback:Asset3DEvent->Void):AssetLoaderToken
	{
		var token:AssetLoaderToken;

		var lib:Asset3DLibraryBundle;
		lib = Asset3DLibraryBundle.getInstance('Flx3DView-${curID}');
		token = lib.loadData(data, context, null, parser);

		token.addEventListener(Asset3DEvent.ASSET_COMPLETE, (event:Asset3DEvent) ->
		{
			// ! Taken from Loader3D https://github.com/openfl/away3d/blob/master/away3d/loaders/Loader3D.hx#L207-L232
			if (event.type == Asset3DEvent.ASSET_COMPLETE)
			{
				var obj:ObjectContainer3D = null;
				switch (event.asset.assetType)
				{
					case Asset3DType.LIGHT:
						obj = #if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end (event.asset, LightBase) ? cast event.asset : null;
					case Asset3DType.CONTAINER:
						obj = #if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end (event.asset, ObjectContainer3D) ? cast event.asset : null;
					case Asset3DType.MESH:
						obj = #if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end (event.asset, Mesh) ? cast event.asset : null;
					case Asset3DType.SKYBOX:
						obj = #if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end (event.asset, SkyBox) ? cast event.asset : null;
					case Asset3DType.TEXTURE_PROJECTOR:
						obj = #if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end (event.asset, TextureProjector) ? cast event.asset : null;
					case Asset3DType.CAMERA:
						obj = #if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end (event.asset, Camera3D) ? cast event.asset : null;
					case Asset3DType.SEGMENT_SET:
						obj = #if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end (event.asset, SegmentSet) ? cast event.asset : null;
				}
				if (obj != null && obj.parent == null)
					view.scene.addChild(obj);
			}

			if (onAssetCallback != null)
				onAssetCallback(event);
		});

		token.addEventListener(LoaderEvent.RESOURCE_COMPLETE, (_) ->
		{
			trace("Loader Finished...");
		});

		_loaders.set(lib, token);

		return token;
	}

	public inline function addChild(c)
		view.scene.addChild(c);
}
