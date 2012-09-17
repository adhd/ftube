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
    import flash.net.URLLoader;
    import flash.events.MouseEvent;
	
	
	public class fTube extends Sprite 
	{	
		private const DEFAULT_FEED:String = "http://gdata.youtube.com/feeds/api/playlists/PLATjbKChjE_SfvQaDTkE6FizNT_rYQ4as?alt=rss&format=5&max-results=5";
		
		public var thumb0:Sprite;
		public var thumb1:Sprite;
		public var thumb2:Sprite;
		public var thumb3:Sprite;
		public var thumb4:Sprite;
		
		private var youTubeLoader:Loader;
		private var youTubePlayer:Object;
		
		private var videoId:String;
		private var clipboardString:String;
		
		private var feedLoader:URLLoader;
		private var data_xml:XML;

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
			feedLoader = new URLLoader();
			feedLoader.addEventListener(Event.COMPLETE, feedHandler);
			feedLoader.load(new URLRequest(DEFAULT_FEED));
			
			youTubeLoader = new Loader();
			youTubeLoader.contentLoaderInfo.addEventListener(Event.INIT, loaderHandler);
			
			var thumb:Sprite;
			for (var i:int = 0; i < 5; i++)
			{
				thumb = this["thumb" + i.toString()];
				thumb["num"] = i;
				thumb.addEventListener(MouseEvent.CLICK, thumbHandler);
			}
		}
		
		private function thumbHandler(e:MouseEvent):void
		{
			var thumbNum:int = e.currentTarget.num;
			// trace(thumbNum);
			// trace(data_xml.channel.item[thumbNum].link);
			loadVideoById(parseLink(data_xml.channel.item[thumbNum].link));
		}
		
		private function feedParse():void
		{
			// rss_txt.text = "";
			
			var body:String = "";
			var item:XML;
			
			// trace(data_xml);
			
			var mediaNS:Namespace = data_xml.namespace("media"); // new Namespace("media", "http://search.yahoo.com/mrss/");
			// trace(mediaNS);
			
			for (var i:int = 0; i < data_xml.channel.item.length(); i++)
			{
				item = data_xml.channel.item[i];

				trace(item.title);
				trace(item.mediaNS::group.mediaNS::thumbnail[1].@url);
				
				var loader:Loader = new Loader();
				loader.load(new URLRequest(item.mediaNS::group.mediaNS::thumbnail[1].@url));
				
				this["thumb" + i.toString()].label_txt.text = item.title;
				this["thumb" + i.toString()].thumb_mc.addChild(loader);
				
				
				body += "<b><a href='event:" + item.link + "'>" + item.title + "</a></b><br/>";
				body += "- - - - - - - - - - - -<br/>";
				// body += item.description + "<br/>";
				
				// trace(data_xml.channel.item.length());
			}
			
			// rss_txt.htmlText = body;
		}
		
		private function feedHandler(e:Event):void
		{
			data_xml = XML(feedLoader.data);
			feedParse();
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
				youTubeLoader.load(new URLRequest("http://www.youtube.com/v/" + v + "?version=3&modestbranding=1&authide=1&theme=light")); // 
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
