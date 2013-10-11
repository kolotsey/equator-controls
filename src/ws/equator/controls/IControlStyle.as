package ws.equator.controls{
	import flash.text.TextFormat;
	import flash.geom.Rectangle;
	import flash.display.Sprite;
	
	public interface IControlStyle{
		
		function button( state:int):Sprite;
		function buttonFocusRect():Sprite;
		function checkbox(state:int):Sprite;
		function checkboxFocusRect():Sprite;
		function edit( state:int): Sprite;
		function editFocusRect():Sprite;
		function combobox( state:int):Sprite;
		function comboboxFocusRect():Sprite;
		function comboboxDrawer():Sprite;
		function comboboxDrawerItemsMask():Sprite;
		function drawComboboxItem( sprite:Sprite, rect:Rectangle, state:int):void;
		function tab( state:int):Sprite;
		function tabPanel():Sprite;
		function panel():Sprite;
		function tabFocusRect():Sprite;
		
		function controlTextFormat( state: int):TextFormat;
	}
}
