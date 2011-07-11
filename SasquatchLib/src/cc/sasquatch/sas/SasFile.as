package cc.sasquatch.sas {
	//import com.demonsters.debugger.MonsterDebugger;
	import cc.sasquatch.io.BinaryReader;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.collections.IList;
	
	public class SasFile {
		
		private static const MAGIC:Array = [0x0, 0x0, 0x0, 0x0, 0x0,
			0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xc2, 0xea, 0x81, 0x60, 0xb3,
			0x14, 0x11, 0xcf, 0xbd, 0x92, 0x8, 0x0, 0x9, 0xc7, 0x31, 0x8c,
			0x18, 0x1f, 0x10, 0x11];

		public var closeable:Boolean = true;
		public var label:String = "tmp";
		public var header:SasHeader;
		
		public var columns:ArrayCollection;
		public var dataProvider:ArrayCollection;
		
		public function SasFile(bytes:ByteArray=null) {
			if ( bytes ){
				loadFromByteArray(bytes);
			}
		}
		
		/**
		 * Loads the sheets from a ByteArray containing an Excel file. If the ByteArray contains a CDF file the Workbook stream
		 * will be extracted and loaded.
		 * 
		 * @see com.as3xls.cdf.CDFReader
		 */
		public function loadFromByteArray(data:ByteArray):void {
			var head:ByteArray = new ByteArray();
			data.readBytes(head, 0, 1024);
			readHeader(head);
			readPages(data);
		}
		
		private function readHeader(bytes:ByteArray):void {
			if (bytes.length != 1024) {
				//MonsterDebugger.trace(this, "Header too short (not a sas7bdat file?): " + bytes.toString());
			}
			/*
			if (!isMagicNumber(header)) {
				throw new SasReaderException("Magic number mismatch!");
			}
			*/
			
			header = new SasHeader();
			var reader:BinaryReader = new BinaryReader(bytes);
			
			header.pageSize = reader.readIntAt(200);
			if (header.pageSize < 0) {
				//MonsterDebugger.trace(this, "Page size is negative: " + header.pageSize);
				throw new Error("Page size is negative: " + header.pageSize);
			}
			
			header.pageCount = reader.readIntAt(204);
			if (header.pageCount < 1) {
				//MonsterDebugger.trace(this, "Page count is not positive: " + header.pageCount);
				throw new Error("Page count is not positive: " + header.pageCount);
			}
			
			header.domain = reader.readStringAt(92, 64);
			header.filetype = reader.readStringAt(156, 8);
			header.release = reader.readStringAt(216, 8);
			header.host = reader.readStringAt(224, 8);
			
			label = header.domain;
			//return new SasHeader(sasRelease, sasHost, pageSize, pageCount);
		}
		
		private function readPages(bytes:ByteArray):void {
			var subHeaders:ArrayList = new ArrayList();
			var subHeadersParsed:Boolean = false;
			
			//MonsterDebugger.trace(this, "Bytes Available -- " + bytes.bytesAvailable );
			//MonsterDebugger.trace(this, "Length -- " + bytes.length );
			//MonsterDebugger.trace(this, "pagesize -- " + header.pageSize );
			//MonsterDebugger.trace(this, "Position -- " + bytes.position );
			var rowCount:int = 0;
			
			// these variables will define the default amount of rows per page and other defaults
			var row_count:int = 0;
			var max_row_count:int = 0;
			var row_length:int = 0;
			var col_count:int = 0;
			
			var colText:SasSubHeader;
			var colName:SasSubHeader;
			var colAttrs:SasSubHeader;
			var colLabels:ArrayList = new ArrayList();
			
			columns = new ArrayCollection();
			dataProvider = new ArrayCollection();
			
			for (var page:int = 0; page < header.pageCount; page++) { 
				//MonsterDebugger.trace(this, "Reading page no. -- " + page );
				var pageData:ByteArray = new ByteArray();
				bytes.readBytes(pageData, 0, header.pageSize);
				//MonsterDebugger.trace(this, "Position -- " + bytes.position );
				
				if (pageData.length == -1) {
					//MonsterDebugger.trace(this, "End of File");
					break;
				}
				
				var reader:BinaryReader = new BinaryReader(pageData);
				var pageType:int = reader.readByteAt(17);
				
				switch (pageType) {
					case 0:
					case 1:
					case 2:
						//MonsterDebugger.trace(this, "page type supported: " + pageType);
						break;
					case 4:
						//MonsterDebugger.trace(this, "page type not fully supported: " + pageType);
						break;
					default:
						//MonsterDebugger.trace(this, "Page : " + page + " has unknown type: " + pageType);
				}
				
				if (pageType == 0 || pageType == 2) {
					// Read subheaders
					var subhCount:int = reader.readIntAt(20);
					for (var subHeaderNumber:int = 0; subHeaderNumber < subhCount; subHeaderNumber++) {
						var base:int = 24 + subHeaderNumber * 12;
						var offset:int = reader.readIntAt(base);
						var length:int = reader.readIntAt(base + 4);
						
						//MonsterDebugger.trace(this, "Reading SubHeader at " + base + " with " + offset + " for " + length + " bytes.");		
						if (length > 0) {
							var rawData:ByteArray = reader.readBytesAt( offset, length );
							var signatureData:ByteArray = new ByteArray();
							
							//pageData.readBytes(rawData, offset, length);
							rawData.readBytes(signatureData, 0, 4);
							
							var sub:SasSubHeader = new SasSubHeader(rawData, signatureData);
							subHeaders.addItem(sub);
						}
					}
				}
				
				if ((pageType == 1 || pageType == 2)) {
					if (!subHeadersParsed) {
						// Parse subheaders
						var subreader:BinaryReader;
						for each ( var subhead:SasSubHeader in subHeaders.toArray()) {
							subreader = new BinaryReader(subhead.bytes);
							
							switch ( subhead.signature ) {
								case SasSubHeader.ROWSIZE:
									row_length = subreader.readIntAt(20);
									row_count = subreader.readIntAt(24);
									col_count = subreader.readIntAt(36);
									max_row_count = subreader.readIntAt(60);
									break;
								case SasSubHeader.COLSIZE:
									col_count = subreader.readIntAt(4);
									break;
								case SasSubHeader.COLTEXT:
									colText = subhead;
									break;
								case SasSubHeader.COLATTR:
									colAttrs = subhead;
									break;
								case SasSubHeader.COLNAME:
									colName = subhead;
									break;
								case SasSubHeader.COLLABS:
									colLabels.addItem( subhead );
									break;
								default:
									break;
							} 
						}
						
						//MonsterDebugger.trace(this, "Column Count: " + col_count);
						for (var i:int = 0; i < col_count; i++) {
							var base:int = 12 + i * 8;
							var column:SasColumn = new SasColumn();
							
							if (colName.bytes.length > 0) {
								var r:BinaryReader = new BinaryReader(colName.bytes);
								var off:int = r.readShortAt(base + 2) + 4;
								var len:int = r.readShortAt(base + 4);
								
								var t:BinaryReader = new BinaryReader(colText.bytes);
								column.name = t.readStringAt(off, len);
							} else {
								column.name = "COL" + i;
							}
							
							// MonsterDebugger.trace(this, "Created Column: " + column.name);
							// Read column labels
							if ( colLabels.length > 0 ) { 
								base = 42;
								var l:BinaryReader = new BinaryReader(colLabels.getItemAt(i).bytes);
								var off:int = l.readShortAt(base) + 4;
								var len:int = l.readShortAt(base + 2);
								
								if (len > 0) {
									var c:BinaryReader = new BinaryReader(colText.bytes);
									column.label = c.readStringAt(off, len);
								} else {
									column.label = null;
								}
							} else {
								column.label = null;
							}
							
							// Read column offset, width, type (required)
							base = 12 + i * 12;
							var attrreader:BinaryReader = new BinaryReader(colAttrs.bytes);
							
							column.offset = attrreader.readIntAt(base);
							column.size = attrreader.readIntAt(base + 4);
							column.type = attrreader.readShortAt(base + 10);
							
							columns.addItem(column);
						}
						
						subHeadersParsed = true;
					}
					
					// Read data
					var row_count_p:int;
					var base:int;
					
					if (pageType == 2) {
						row_count_p =  max_row_count;
						var subhCount:int = reader.readIntAt(20);
						base = 24 + subhCount * 12;
						base = base + base % 8;
					} else {
						row_count_p = reader.readIntAt(18);
						base = 24;
					}
					
					if (row_count_p > row_count) {
						row_count_p = row_count;
					}
					
					//MonsterDebugger.trace(this, "Row Count: " + row_count_p);
					for (var row:int = 0; row < row_count_p; row++) {
						var object:Object = new Object();
						
						for each ( var column:SasColumn in columns.toArray()){
							var off:int = base + column.offset;
							if (column.size > 0) {
								var raw:BinaryReader = new BinaryReader(reader.readBytesAt(off, column.size));
								if ( column.type == SasType.NUMERIC && column.size < 8){
									//if its not working we need to allocate 8 bytes to read it 
									//len = 8;
									//MonsterDebugger.trace(this, "if its not working we need to allocate 8 bytes to read it.");
								}
								
								if ( column.type == SasType.CHARACTER ) {
									object[column.name] = raw.readStringAt(0, column.size);
									//object[column.name].value = str.replace( /^([\s|\t|\n]+)?(.*)([\s|\t|\n]+)?$/gm, "$2" );
								} else {
									 var valnum:Number = raw.readNumberAt(0, column.size);
									 if ( !isNaN(valnum) ) { 
									 	object[column.name] = valnum;
									 } else {
										object[column.name] = ".";
									 }
								}
							}
						}
						dataProvider.addItem(object);
						
						rowCount++;
						base = base + row_length;
					}
				}
			}
		}
	}
}