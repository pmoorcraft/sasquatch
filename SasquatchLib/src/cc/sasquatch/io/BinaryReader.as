package cc.sasquatch.io {
	import flash.utils.*;
	
	/**
	 * Used to make reading BIFF files a little less painful.
	 */
	public class BinaryReader {
		private var stream:ByteArray;
		
		/**
		 * 
		 * @param stream A ByteArray containing a BIFF document as a stream. The ByteArray will be rewound and set to LITTLE_ENDIAN
		 * automatically.
		 * 
		 */
		public function BinaryReader(stream:ByteArray) {
			this.stream = stream;
			stream.endian = Endian.LITTLE_ENDIAN;
			stream.position = 0;
		}
		
		public function readByteAt(offset:int):uint {
			stream.position = offset;
			return stream.readByte();
		}
		
		public function readBytesAt(offset:int, length:int):ByteArray {
			stream.position = offset;
			var ba:ByteArray = new ByteArray();
			stream.readBytes(ba, 0, length);
			return ba;
		}
		
		public function readIntAt(offset:int):int {
			stream.position = offset;
			return stream.readInt();
		}
		
		public function readShortAt(offset:int):int {
			stream.position = offset;
			return stream.readShort();
		}
		
		public function readStringAt(offset:int, length:uint=0):String {
			stream.position = offset;
			if ( length < 1 )
				return stream.readUTF();
			else
				return stream.readUTFBytes(length);
		}
		
		public function readNumberAt(offset:int, len:int):Number {
			stream.position = offset;
			if (len == 1) {
				return stream.readByte();
			} else if (len == 2) {
				return stream.readShort();
			} else if (len == 4) {
				return stream.readInt();
			} else if (len == 8) {
				return stream.readDouble();
			} else {
				//MonsterDebugger.trace(this, "Number byte-length not supported: " + len);
				return 0;
			}
		}
		
	}
}