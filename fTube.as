/*
	fTube
	AD&HD, Inc. 2012
*/

package  
{
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.desktop.Clipboard;
    import flash.desktop.ClipboardFormats;
    import flash.desktop.ClipboardTransferMode;
	
	
	public class fTube extends Sprite 
	{		
		private var youTubeLoader:Loader;
		private var youTubePlayer:Object;
		
		private var videoId:String;
		private var clipboardString:String;

		public function fTube()
		{
			stage.nativeWindow.alwaysInFront = true;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, resizeHandler);
			
			initPlayer();
			
			addEventListener(Event.ENTER_FRAME, frameHandler);
		}
		
		private function initPlayer():void
		{
			youTubeLoader = new Loader();
			youTubeLoader.contentLoaderInfo.addEventListener(Event.INIT, loaderHandler);
		}
		
		private function update():void
		{
			checkClipboard();
		}
		
		private function resizeTo(w:int, h:int):void
		{
			if (youTubePlayer)
				youTubePlayer.setSize(stage.stageWidth, stage.stageHeight);
		}
		
		private function checkClipboard():void
		{
			if (Clipboard.generalClipboard.hasFormat(ClipboardFormats.TEXT_FORMAT))
			{
				var clip:String = String(Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT));
				if (clip != clipboardString)
				{
					// New string in clipboard
					// trace("New Clip: " + clip);
					
					var v:String = parseLink(clip);
					if (v && v != videoId)
					{
						loadVideoById(v);
					}
					
					clipboardString = clip;
				}
			}
		}
		
		private function loadVideoById(v:String):void
		{
			videoId = v;
			
			if (youTubePlayer)
			{
				// Loading new video into loaded player
				youTubePlayer.loadVideoById(v);
			}
			else
			{
				// New Loader
				youTubeLoader.load(new URLRequest("http://www.youtube.com/v/" + v + "?version=3"));
			}
		}
		
		private function parseLink(url:String):String
		{
			var d:String = unescape(url);
			var v:String;
			
			trace(d);
			
			if (d.indexOf("v=") > 0)
			{
				v = d.substring(d.indexOf("v=") + 2);
				if (v.indexOf("&") > 0) v = v.substr(0, v.indexOf("&"));
			} else {
				trace("Video id not found in link");
			}
			
			trace(v);
			
			return v;
		}
		
		
		// Event Handlers -----------------------------------------------------------
		
		private function frameHandler(e:Event):void
		{
			update();
		}
		
		private function resizeHandler(e:Event):void
		{
			resizeTo(stage.stageWidth, stage.stageHeight);
		}
		
		
		// Initialization Handlers --------------------------------------------------
		
		private function loaderHandler(e:Event):void
		{
			addChild(youTubeLoader);
			youTubeLoader.content.addEventListener("onReady", readyHandler);
		}
		
		private function readyHandler(e:Event):void
		{
			trace("YouTube Player Ready");
			youTubePlayer = youTubeLoader.content;
			youTubePlayer.setSize(stage.stageWidth, stage.stageHeight);
			youTubePlayer.playVideo();
		}

	}
	
}
