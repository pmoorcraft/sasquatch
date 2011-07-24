package cc.sasquatch.sas
{
	import spark.components.gridClasses.GridColumn;

	public class SasColumn extends GridColumn
	{
		public function SasColumn(columnName:String=null){
			super(columnName);
			this.minWidth = 120;
		}
		
		public var index:int;
		
		public var type:int;
		
		public function get ctype():String{
			switch ( type ) {
				case SasType.CHARACTER: return "Char"; break;
				case SasType.NUMERIC: return "Num"; break;
				default: return "Unk";
			}
		}
		
		public var offset:int;
		public var size:int;
		public var fsize:int;
		
		private var _format:String;
		public function get format():String {
			if (!_format){
				switch ( type ) {
					case SasType.CHARACTER: 
						return "$CHAR"+size+"."; 
						break;
					case SasType.NUMERIC: 
						return fsize+"."; 
						break;
				}
			}
			return _format + length +".";
		}
		
		public function get length():int{
			return Math.max(size, fsize);
		}
		
		public function set format(value:String):void {
			_format = value; 
		}
		
		private var _name:String;
		public function get name():String {
			return _name;
		}

		public function set name(value:String):void {
			_name = value;
			this.dataField = value;
		}
		
		private var _label:String;
		public function get label():String {
			return _label;
		}

		public function set label(value:String):void {
			_label = value;
			if ( value )
				this.headerText = value;
		}
		
		
	}
}