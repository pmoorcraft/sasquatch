# Example #

```
	protected var file:File;
	private var stream:FileStream;
		
	public function openFile(event:Event):void {
		file = new File();
		file.addEventListener(Event.SELECT, fileOpenSelected);
		file.browseForOpen("Open File");
	}
		
	/**
	 * Called when the user selects the currentFile in the FileOpenPanel control. The method passes 
	 * File object pointing to the selected currentFile, and opens a FileStream object in read mode (with a FileMode
	 * setting of READ), and modify's the title of the application window based on the filename.
	 */
	protected function fileOpenSelected(event:Event=null):void { 
		file.removeEventListener(Event.SELECT, fileOpenSelected);
		file = event.target as File;
			
		stream = new FileStream();
		stream.openAsync(file, FileMode.READ);
		stream.addEventListener(Event.COMPLETE, fileReadHandler);
		stream.addEventListener(IOErrorEvent.IO_ERROR, readIOErrorHandler);
	}
		
	/**
	 * Called when the stream object has finished reading the data from the currentFile (in the openFile()
	 * method). This method reads the data as UTF data, converts the system-specific line ending characters
	 * in the data to the "\n" character, and displays the data in the mainTextField Text component.
	 */
	private function fileReadHandler(event:Event):void {
		file.removeEventListener(Event.COMPLETE, fileReadHandler);
		
		var bytes:ByteArray = new ByteArray();
		stream.readBytes(bytes);
		stream.close();
			
		var sas:SasFile = new SasFile(bytes);
		// Do something with the SAS file
	}
		
	/**
	 * Handles I/O errors that may come about when opening the currentFile.
	 */
	private function readIOErrorHandler(event:Event):void {
		trace("The specified currentFile cannot be opened.");
	}

```