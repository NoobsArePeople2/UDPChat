package performance.tests
{
    import com.gskinner.utils.PerformanceTest;
    
    import flash.utils.ByteArray;
    import flash.utils.CompressionAlgorithm;
    
    import net.AckSequence;

    /**
     *
     */
    public class ByteArrayTest implements IPerformanceTest
    {
        //==============================
        // Constants
        //==============================
        
        //==============================
        // Vars
        //==============================
        
        private var pt:PerformanceTest;
        private var bytes:ByteArray;
        private var compressedBytes:ByteArray;
        private var acks:AckSequence;
        
        private var log:Function;
        
        private var totalBytes:Number;
        private var totalCompressedBytes:Number;
        
        //==============================
        // Properties
        //==============================
        
        //==============================
        // Constructor
        //==============================
        
        public function ByteArrayTest(pt:PerformanceTest)
        {
            this.pt = pt;

            if (this.pt.logger is Function)
            {
                log = this.pt.logger as Function;
            }
            else
            {
                log = trace;
            }
        }
        
        //==============================
        // Public Methods
        //==============================
        
        public function doTest():void
        {
            pt.synchronous = true;
            bytes = new ByteArray();
            acks = new AckSequence();
            
            compressedBytes = new ByteArray();
            compressedBytes.position = 0;
            compressedBytes.length = 0;
            compressedBytes.writeShort(123);
            compressedBytes.writeUnsignedInt(12345676);
            compressedBytes.writeBytes(acks.writeBytes());
            compressedBytes.writeUTFBytes("Some string");
            
            const iterations:int = 10000;
            
            pt.testFunction(compressionLZMA, iterations, "compressionLZMA");
            pt.testFunction(compressionZLIB, iterations, "compressionZLIB");
            pt.testFunction(compressionDeflate, iterations, "compressionDeflate");
            
            pt.testFunction(uncompressLZMA, iterations, "uncompressLZMA");
            pt.testFunction(uncompressZLIB, iterations, "uncompressZLIB");
            pt.testFunction(uncompressDeflate, iterations, "uncompressDeflate");
            
            pt.testFunction(sizeTest, 1, "sizeTest");
            
            compressedBytes.position = 0;
            compressedBytes.length = 0;
            compressedBytes.writeShort(123);
            compressedBytes.writeUnsignedInt(12345676);
            compressedBytes.writeBytes(acks.writeBytes());
            compressedBytes.writeUTFBytes("Some string");
            
            // 41 iterations gets us to 1497 bytes, 3 shy 
            // of the typical 1500 MTU size
            for (var i:int = 0; i < 41; ++i)
            {
                // Randomize data to kinda-sorta simulate what might
                // flow through a socket.
                compressedBytes.writeFloat(Math.random());
                compressedBytes.writeFloat(Math.random());
                compressedBytes.writeFloat(Math.random());
                compressedBytes.writeFloat(Math.random());
                compressedBytes.writeFloat(Math.random());
                compressedBytes.writeFloat(Math.random());
                compressedBytes.writeFloat(Math.random());
                compressedBytes.writeFloat(Math.random());
                compressedBytes.writeFloat(Math.random());
            }
            totalBytes = 0;
            totalCompressedBytes = 0;
            pt.testFunction(sizeLZMA, iterations, "sizeLZMA");
            log("LZMA Avg Size......Compressed/Uncompressed........" + (totalCompressedBytes/iterations) + " / " + (totalBytes/iterations));
            
            totalBytes = 0;
            totalCompressedBytes = 0;
            pt.testFunction(sizeZLIB, iterations, "sizeZLIB");
            log("ZLIB Avg Size......Compressed/Uncompressed........" + (totalCompressedBytes/iterations) + " / " + (totalBytes/iterations));
            
            totalBytes = 0;
            totalCompressedBytes = 0;
            pt.testFunction(sizeDeflate, iterations, "sizeDeflate");
            log("Deflate Avg Size...Compressed/Uncompressed........" + (totalCompressedBytes/iterations) + " / " + (totalBytes/iterations));
            
            pt.testFunction(readFromCompressed, 1, "readFromCompressed");
            pt.testFunction(readFromUncompressed, 1, "readFromUncompressed");
            
        }
        
        //==============================
        // Private, Protected Methods
        //==============================
        
        private function compressionLZMA():void
        {
            bytes.position = 0;
            bytes.length = 0;
            bytes.writeBytes(compressedBytes);
            bytes.compress(CompressionAlgorithm.LZMA);
        }
        
        /**
         * WAAAAAY faster than LZMA
         */  
        private function compressionZLIB():void
        {
            bytes.position = 0;
            bytes.length = 0;
            bytes.writeBytes(compressedBytes);
            bytes.compress(CompressionAlgorithm.ZLIB);
        }
        
        /**
         * Similar performance to ZLIB.
         * Will always be 6 Bytes smaller than the same data
         * ZLIB'd.
         * 
         * See: http://stackoverflow.com/questions/10166122/zlib-differences-detween-the-deflate-and-compress-functions
         */ 
        private function compressionDeflate():void
        {
            bytes.position = 0;
            bytes.length = 0;
            bytes.writeBytes(compressedBytes);
            bytes.compress(CompressionAlgorithm.DEFLATE);
        }
        
        private function uncompressLZMA():void
        {
            compressedBytes.compress(CompressionAlgorithm.LZMA);
            compressedBytes.uncompress(CompressionAlgorithm.LZMA);
        }
        
        private function uncompressZLIB():void
        {
            compressedBytes.compress(CompressionAlgorithm.ZLIB);
            compressedBytes.uncompress(CompressionAlgorithm.ZLIB);
        }
        
        private function uncompressDeflate():void
        {
            compressedBytes.compress(CompressionAlgorithm.DEFLATE);
            compressedBytes.uncompress(CompressionAlgorithm.DEFLATE);
        }
        
        private function sizeLZMA():void
        {            
            totalBytes += compressedBytes.length;
            
            compressedBytes.compress(CompressionAlgorithm.LZMA);
            totalCompressedBytes += compressedBytes.length;
            compressedBytes.uncompress(CompressionAlgorithm.LZMA);
        }
        
        private function sizeZLIB():void
        {
            totalBytes += compressedBytes.length;
            
            compressedBytes.compress(CompressionAlgorithm.ZLIB);
            totalCompressedBytes += compressedBytes.length;
            compressedBytes.uncompress(CompressionAlgorithm.ZLIB);
        }
        
        private function sizeDeflate():void
        {
            totalBytes += compressedBytes.length;
            
            compressedBytes.compress(CompressionAlgorithm.DEFLATE);
            totalCompressedBytes += compressedBytes.length;
            compressedBytes.uncompress(CompressionAlgorithm.DEFLATE);
        }
        
        private function readFromCompressed():void
        {
            compressedBytes.compress(CompressionAlgorithm.DEFLATE);
            
            try
            {
                compressedBytes.readShort();
                log("Read from compressed ByteArray");
            }
            catch(e:Error)
            {
                log("Error reading from compressed ByteArray");
            }
            
            compressedBytes.uncompress(CompressionAlgorithm.DEFLATE);
        }
        
        private function readFromUncompressed():void
        {
            compressedBytes.compress(CompressionAlgorithm.DEFLATE);
            compressedBytes.uncompress(CompressionAlgorithm.DEFLATE);
            
            try
            {
                var value:uint = compressedBytes.readShort();
                log("Read '" + value + "' from compressed ByteArray");
            }
            catch(e:Error)
            {
                log("Error reading from compressed ByteArray");
            }
        }
        
        /**
         * Reset position AND length to clear out a ByteArray.
         */ 
        private function sizeTest():void
        {
            bytes.position = 0;
            bytes.length = 0;
            bytes.writeShort(123);
            bytes.writeUnsignedInt(12345676);
            bytes.writeBytes(acks.writeBytes());
            bytes.writeUTFBytes("Some string");
            
            log("After write..........Length: " + bytes.length + ".......Bytes Available: " + bytes.bytesAvailable);
            
            bytes.position = 0;
            log("After position=0.....Length: " + bytes.length + ".......Bytes Available: " + bytes.bytesAvailable);
            
            bytes.length = 0;
            log("After pos/len=0......Length: " + bytes.length + ".......Bytes Available: " + bytes.bytesAvailable);
            
            bytes.position = 0;
            bytes.length = 0;
            bytes.writeShort(123);
            bytes.writeUnsignedInt(12345676);
            bytes.writeBytes(acks.writeBytes());
            bytes.writeUTFBytes("Some string");
            bytes.position = 0;
            bytes.writeShort(456);
            
            log("After reset/write....Length: " + bytes.length + ".......Bytes Available: " + bytes.bytesAvailable);
        }
        
        //==============================
        // Event Handlers
        //==============================
    }
}