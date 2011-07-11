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
		public var offset:int;
		public var size:int;
		
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