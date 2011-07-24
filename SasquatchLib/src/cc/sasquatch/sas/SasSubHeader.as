package cc.sasquatch.sas {

	import flash.utils.*;
	
	public class SasSubHeader {
		// Subheader 'signatures'
		public static const ROWSIZE:uint = 0xf7f7f7f7;
		public static const COLSIZE:uint = 0xf6f6f6f6;
		public static const COLTEXT:uint = 0xFFFFFFFD;
		public static const COLATTR:uint = 0xFFFFFFFC;
		public static const COLNAME:uint = 0xFFFFFFFF;
		public static const COLLABS:uint = 0xFFFFFBFE;
		public static const SIGNATURE:uint = 0xFFFFFC00;
		public static const UNKNOWN_B:uint = 0xFFFFFFFE;
		
		public function SasSubHeader(rawData:ByteArray, sigData:ByteArray) {
			rawData.endian = Endian.LITTLE_ENDIAN;
			_bytes = rawData;
			
			sigData.endian = Endian.LITTLE_ENDIAN;
			_signature  = sigData.readUnsignedInt();	
		}
		
		private var _bytes:ByteArray;
		public function get bytes():ByteArray {
			return _bytes;
		}

		private var _signature:uint;
		public function get signature():uint {
			return _signature;
		}

				
	}
}