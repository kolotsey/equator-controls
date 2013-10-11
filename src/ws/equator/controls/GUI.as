package ws.equator.controls{
	import flash.events.ErrorEvent;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.HTTPStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.EventDispatcher;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	
	public class GUI extends EventDispatcher{
		
		static private var root:DisplayObjectContainer=null;
		private var xml:XML;
		private var status:Object=null;
		private var success:Boolean=false;
		private var loadCompleted:Boolean=false;
		private var parent_object:DisplayObjectContainer;
		private var urlLoader:URLLoader=null;
		public var controls:Object=null;
	
		public static var unknownControlHandler:Function=null; //function( type:String):Class{return null;};
		
		private static function trim(s: String): String{
			while(s.length>0 && (s.charCodeAt(0)==32/*space*/ ||s.charCodeAt(0)==13/*cr*/ ||s.charCodeAt(0)==10/*lf*/ ||s.charCodeAt(0)==9/*tab*/)){
				s=s.substr(1);
			}
			while(s.length>0 && (s.charCodeAt(s.length-1)==32 ||s.charCodeAt(s.length-1)==13 ||s.charCodeAt(s.length-1)==10 ||s.charCodeAt(s.length-1)==9)){
				s=s.substr(0, s.length-1);
			}
			return s;
		}
	
		private static function firstXmlNode(xml:XML, node:String, caseSensitive:Boolean=true):XML{
			var i:int;
			if(caseSensitive) node=node.toLowerCase();
			for( i=0; i<xml.children().length(); i++){
				if ((xml.children()[i] as XML).nodeKind() == "element" && 
						( (caseSensitive && ((xml.children()[i] as XML).localName() as String).toLowerCase()==node) ||
						  (!caseSensitive && (xml.children()[i] as XML).localName()==node))) {
					return xml.children()[i];
				}
			}
			return null;
		}
		
		private static function toBoolean( s:String):Boolean{
			s=s.toLowerCase();
			return (s=="yes" || s=="y" || s=="true" || s=="on" || ( !isNaN( Number(s)) && Number( s) !=0));
		}
		
		private static function toAlign( s:String):int{
			var ret:int=0;
			if( !isNaN( Number(s))){
				ret=Number( s);
			}else{
				var i:int, i1:int, i2:int;
				var ptr:String;
			
				s=s.toLowerCase();
				do{
					i1=s.indexOf(",");
					i2=s.indexOf("|");
					if(i1 !=-1 && i2 !=-1){
						i=Math.min(i1, i2);
					}else if(i1 !=-1){
						i=i1;
					}else if(i2 !=-1){
						i=i2;
					}else{
						i=-1;
					}
					if( -1==i){
						ptr=trim(s);
					}else{
						ptr=trim(s.substr(0, i)).toLowerCase();
						s=s.substr(i+1);
					}
					if( ptr=="left"){
						ret |= ControlAlign.LEFT;
					}else if(ptr=="right"){
						ret |= ControlAlign.RIGHT;
					}else if(ptr=="top"){
						ret |= ControlAlign.TOP;
					}else if(ptr=="bottom"){
						ret |= ControlAlign.BOTTOM;
					}
				}while( i !=-1);
			}
			return ret;
		}
		
		private static function toBehaviour( s:String):int{
			s=s.toLowerCase();
			if( s=="auto"){
				return ControlBehaviour.AUTO;
			}else if( s=="fixed"){
				return ControlBehaviour.FIXED;
			}else if( s=="stretch"){
				return ControlBehaviour.STRETCH;
			}else {
				if( !isNaN( Number(s))){
					var n:int;
					n=Number( s);
					if( n==ControlBehaviour.AUTO || n==ControlBehaviour.FIXED || n==ControlBehaviour.STRETCH){
						return n;
					}
				}
				return ControlBehaviour.AUTO;
			}
		}
		
		private static function toResizeMehod(s:String):int{
			s=s.toLowerCase();
			if( s.substr( 0, 3)=="min"){
				return SwapBox.RESIZE_TO_MIN_POSSIBLE;
			}else if( s.substr(0, 3)=="max"){
				return SwapBox.RESIZE_TO_MAX_CHILD;
			}else {
				if( !isNaN( Number(s))){
					var n:int;
					n=Number( s);
					if( n==SwapBox.RESIZE_TO_MAX_CHILD ||n==SwapBox.RESIZE_TO_MIN_POSSIBLE){
						return n;
					}
				}
				return SwapBox.RESIZE_TO_MIN_POSSIBLE;
			}
		}
		
		private static function setBehaviour( control:Control, attributes:XMLList):void{
			var i:int;
			for( i=0; i<attributes.length(); i++){
				switch( ((attributes[i] as XML).localName() as String).toLowerCase()){
					case "behaviourx":
						control.behaviourX=toBehaviour( attributes[i]);
						break;
					case "behavioury":
						control.behaviourY=toBehaviour( attributes[i]);
						break;
					case "behaviour":
						control.behaviour=toBehaviour( attributes[i]);
						break;
					default:
						break;
				}
			}
		}
		
		private static function setControlAtrribute(control:Control, attribute:String, value:String):Boolean{
			var ret:Boolean=true;
			switch(attribute.toLowerCase()){
				case "disabled":
					control.enabled=!toBoolean( value);
					break;
				case "enabled":
					control.enabled= toBoolean( value);
					break;
				case "align":
					control.align=toAlign( value);
					break;
				case "x":
					if( !isNaN( Number(value))) control.x=Number( value);
					break;
				case "y":
					if( !isNaN( Number(value))) control.y=Number( value);
					break;
				case "width":
					if( !isNaN( Number(value))) control.width=Number( value);
					break;
				case "height":
					if( !isNaN( Number(value))) control.height=Number( value);
					break;
				case "resizemethod":
					if( control is SwapBox){
						(control as SwapBox).resizeMethod=toResizeMehod( value);
					}
					break;
				case "innerpadding":
					if( control is TabControl){
						if( !isNaN( Number(value))) (control as TabControl).innerPadding=Number( value);
					}
					break;
				case "caption":
					if( control is Button){
						(control as Button).caption=value;
					}else if(control is Label){
						(control as Label).caption=value;
					}else if(control is Checkbox){
						(control as Checkbox).caption=value;
					}else if(control is Panel){
						(control as Panel).caption=value;
					}
					break;
				case "text":
					if( control is Edit){
						(control as Edit).text=value;
					}
					break;
				case "toggle":
					if( control is Button){
						(control as Button).toggle=toBoolean( value);
					}else if( control is Checkbox){
					} 
					break;
				case "selected":
					if( control is Button){
						(control as Button).selected=toBoolean( value);
					}else if( control is Checkbox){
						(control as Checkbox).selected=toBoolean( value);
					} 
					break;
				case "selectedindex":
					if((control is Combobox || control is SwapBox ||control is TabControl) && !isNaN(Number(value)) && int(value)>=0){
						if( control is Combobox){
							(control as Combobox).selectedIndex=int(value);
						}else if(control is SwapBox){
							(control as SwapBox).selectedIndex=int(value);
						}else if(control is TabControl){
							(control as TabControl).selectedIndex=int(value);
						}
					}
					break;
				default:
					ret=false;
					break;
			}
			return ret;
		}
			
		private static function setBasicBoxAtrribute(control:BasicBox, attribute:String, value:String):Boolean{
			var ret:Boolean=true;

			switch(attribute.toLowerCase()){
				case "padding":
					if( !isNaN( Number(value))) control.padding=Number( value);
					break;
				case "paddingtop":
					if( !isNaN( Number(value))) control.paddingTop=Number(value);
					break;
				case "paddingright":
					if( !isNaN( Number(value))) control.paddingRight=Number(value);
					break;
				case "paddingbottom":
					if( !isNaN( Number(value))) control.paddingBottom=Number(value);
					break;
				case "paddingleft":
					if( !isNaN( Number(value))) control.paddingLeft=Number(value);
					break;
				default:
					ret=setControlAtrribute( control as Control, attribute, value);
					break;
			}
			return ret;
		}
		
		private static function setStackBoxAtrribute(control:StackBox, attribute:String, value:String):Boolean{
			var ret:Boolean=true;
			switch(attribute.toLowerCase()){
				case "spacing":
					if( !isNaN( Number(value))) control.spacing=Number(value);
					break;
				case "homogeneous":
					control.homogeneous=toBoolean( value);
					break;
				default:
					ret=setBasicBoxAtrribute( control as BasicBox, attribute, value);
					break;
			}
			return ret;
		}
		
		
		private static function addComboboxItems( combo:Combobox, nodes:XMLList):void{
			var i:int;
			var node:XML;
			
			for(i=0; i<nodes.length(); i++){
				node=nodes[i] as XML;
				if( node.localName() && (node.localName() as String).toLowerCase() =="item" && node.attribute("caption") !=undefined){
					combo.addItem( node.attribute("caption"), node.attribute("data")==undefined? null : node.attribute("data"));
				}
			}
		}
		
		private static function parseNode( caller:DisplayObjectContainer, parent:DisplayObjectContainer, node:XML):Object{
			var ret:Object=new Object();
			var item:String;
			var i:int;
			var j:String;
			var n:Object; 
			var f:Class=null;
			
			item=node.localName();
			if( item !=null){
				item=item.toLowerCase();
	
				if( undefined !=node.attribute("parent")){
					var nodeParent:String=node.attribute("parent");
					if(nodeParent=="_root" || nodeParent=="root"){
						parent=root;
					}else if( root.getChildByName(nodeParent) && root.getChildByName(nodeParent) is DisplayObjectContainer){
						parent=root.getChildByName(nodeParent) as DisplayObjectContainer;
					}else if( caller.getChildByName(nodeParent) && caller.getChildByName( nodeParent) is DisplayObjectContainer){
						parent= caller.getChildByName( nodeParent) as DisplayObjectContainer;
					}
				}
				
				if( item=="box" ||item=="basicbox" ||item=="panel" ||item=="basicpanel" ||item=="swapbox" 
						||item=="verticalbox" ||item=="vbox" ||item=="horizontalbox" ||item=="hbox" ||item=="tabcontrol"){
					var children:Object;
					var box:BasicContainer=undefined; 
					
					switch( item){
						case "box":
						case "basicbox":      f=BasicBox; break;
						case "panel":         f=Panel; break;
						case "swapbox":       f=SwapBox; break;
						case "hbox":
						case "horizontalbox": f=HorizontalBox; break;
						case "vbox":
						case "verticalbox":   f=VerticalBox; break;
						case "tabcontrol":    f=TabControl; break;
						default: break;
					}
					box=new f();
					if( parent is TabControl){
						(parent as TabControl).addTab( box);
					}else{
						parent.addChild( box);
					}

					if(node.attribute("name") !=undefined){
						ret[node.attribute("name")]=box;
						box.name=node.attribute("name");
					}
					
					for( i=0; i<node.children().length(); i++){
						if ((node.children()[i] as XML).nodeKind() == "element") {
							children=parseNode(caller, box, node.children()[i]);
							if( children !=null){
								for(j in children){
									ret[j]=children[j];
								}
							}
						}
					}
					setBehaviour(box, node.attributes());
					for( i=0; i<node.attributes().length(); i++){
						n=(node.attributes()[i] as XML).localName();
						if( n !=null){
							if( box is StackBox){
								setStackBoxAtrribute( box as StackBox, n as String, node.attributes()[i]);
							}else if( box is BasicBox){
								setBasicBoxAtrribute( box as BasicBox, n as String, node.attributes()[i]);
							}else{
								setControlAtrribute( box, n as String, node.attributes()[i]);
							}
						}
					} 
					
				}else{
					switch( item){
						case "control":     f=Control;  break;
						case "button":      f=Button;   break;
						case "checkbox":    f=Checkbox; break;
						case "combobox":    f=Combobox; break;
						case "edit":        f=Edit;     break;
						case "label":       f=Label;    break;
						case "gridcanvas":  f=GridCanvas; break;
						case "polarcanvas": f=PolarCanvas; break;
//						case "map":         f=Map; break;
						case "scrollbar":   f=Scrollbar; break;
						default: 
							if( null !=unknownControlHandler){
								f=unknownControlHandler(item);
							}
							break;
					}
					if(f !=null){
						var control:Control=undefined;
						
						control=new f();
						if( parent is TabControl){
							(parent as TabControl).addTab( control);
						}else{
							parent.addChild( control);
						}
						
						if(node.attribute("name") !=undefined){
							ret[node.attribute("name")]=control;
							control.name=node.attribute("name");
						}
						setBehaviour(control, node.attributes());
						if( "combobox"==item && node.children().length()){
							addComboboxItems( control as Combobox, node.children());
						}
						for( i=0; i<node.attributes().length(); i++){
							n=(node.attributes()[i] as XML).localName();
							if( n !=null){
								setControlAtrribute( control, n as String, node.attributes()[i]);
							}
						}
					}
				}
			}
			return ret;
		}
		
		public static function parseXML(parent:DisplayObjectContainer, xml:XML):Object{
			var node:XML;
			var ret:Object=new Object();
			var i:int=0;
			var j:String;
			var children:Object;
			var localName:String;
			
			if(parent==null){
				return null;
			}
			
			if( (localName=xml.localName())==null){			
				return null;
			}
			if(localName.toLowerCase()=="gui"){
				node=xml;
			}else{
				node=firstXmlNode( xml, "gui", false);
			}
			if( null==node){
				return null;
			}
			
			
			root=parent;
			while( root.parent !=null && root.parent !=root){
				root=root.parent;
			}
			
			for( i=0; i<node.children().length(); i++){
				if((node.children()[i] as XML).nodeKind()=="element"){
					children=parseNode(parent, parent, node.children()[i]);
					for( j in children){
						ret[j]=children[j];
					
					}
				}
			}
			return ret;
		}
		
		public function get error():Object{
			return status;
		}
		
		
		
		
		private function schemeEvent(ev:Event): void{
			if( ev.type==HTTPStatusEvent.HTTP_STATUS){
				if((ev as HTTPStatusEvent).status ==200 ||(ev as HTTPStatusEvent).status ==0){
					return;
				}
			}
			var loader:Loader=ev.target["loader"];
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, schemeEvent);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, schemeEvent);
			loader.contentLoaderInfo.removeEventListener(HTTPStatusEvent.HTTP_STATUS, schemeEvent);
			loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, schemeEvent);
			if( ev.type==Event.COMPLETE){
				loadComplete( null, true, loader.content);
			}else{
				loader.close();
				loadComplete( null, true, null);
			}
		}
		
		
		
		private function loadEvent(ev:Event): void{
			if( ev.type==HTTPStatusEvent.HTTP_STATUS && ((ev as HTTPStatusEvent).status ==200 ||(ev as HTTPStatusEvent).status ==0)){
				return;
			}
			if(ev.type==IOErrorEvent.IO_ERROR){
				status="I/O error ("+(ev as ErrorEvent).text+")";
			}else if( ev.type==SecurityErrorEvent.SECURITY_ERROR){
				status="Security error ("+(ev as ErrorEvent).text+")";
			}else if( ev.type==HTTPStatusEvent.HTTP_STATUS){
				status="File load error. Server returned status "+(ev as HTTPStatusEvent).status;
			}
			loadCompleted=true;
			dispatchEvent( new Event(Event.COMPLETE));
		}
		
		//URL loader handler
		private function loadComplete(ev:Event, schemeLoaded:Boolean=false, scheme:DisplayObject=null):void{
			var node:XML;
			var localName:String;

			if( !loadCompleted || schemeLoaded==true){
				loadCompleted=true;
				//check if XML is parsed without errors
				try{
					xml = new XML(urlLoader.data);
				}catch(e:Error){
					status=e.message;
					dispatchEvent( new Event(Event.COMPLETE));
					return;
				}
				if( xml==null || (localName=xml.localName())==null){
					status="Could not properly parse XML-UI file";
				
				}else{
					//check if root node exists
					if( localName.toLowerCase()=="gui"){
						node=xml;
					}else{
						node=firstXmlNode( xml, "gui", false);
					}
					if( null==node){
						status="XML-UI file is invalid";
						
					}else{
						success=true;
						//check if there is a style scheme required
						if(undefined !=node.attribute("style")){
							if( true ==schemeLoaded){
								if(scheme !=null && scheme.hasOwnProperty("controlStyleClass") && scheme["controlStyleClass"] is Class){
									var controlStyleClass:Class=scheme["controlStyleClass"] as Class;
									Control.defaultStyle = controlStyleClass;
								}
								
							}else{
								var loader:Loader = new Loader();
								loader.contentLoaderInfo.addEventListener(Event.COMPLETE, schemeEvent);
								loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, schemeEvent);
								loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, schemeEvent);
								loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, schemeEvent);
								loader.load( new URLRequest( node.attribute("style")));
								return;
							}
						}
						controls=parseXML( parent_object, xml);
						urlLoader=null;
					}
				}
				dispatchEvent( new Event(Event.COMPLETE));
			}
		}

		public function loadFromURL( url:*, parent:DisplayObjectContainer):void{
			var urlRequest:URLRequest;
			
			if( urlLoader==null){
				status=null;
				success=false;
				loadCompleted=false;
				controls=null;
				
				if( null==parent){
					status="Passed parent object is undefined";
					loadCompleted=true;
					dispatchEvent(new Event(Event.COMPLETE));
					return;
				}
				
				parent_object=parent;
							
				if( url is URLRequest){
					urlRequest=url;
				}else{
					urlRequest= new URLRequest( url);
				}
				urlLoader = new URLLoader();
				urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
				urlLoader.addEventListener(Event.COMPLETE, loadComplete);
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR, loadEvent);
				urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, loadEvent);
				urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadEvent);
				urlLoader.load(urlRequest);
			}
		}

		
			
			
		public function GUI(){
		}
	}
	
}	
	

