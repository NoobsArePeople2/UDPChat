package performance.tests
{
    import com.gskinner.utils.PerformanceTest;
    
    import net.Bitfield;

    /**
     *
     */
    public class BitfieldTest implements IPerformanceTest
    {
        //==============================
        // Constants
        //==============================
        
        //==============================
        // Vars
        //==============================
        
        private var pt:PerformanceTest;
        
        private var bits:Bitfield;
        
        //==============================
        // Properties
        //==============================
        
        //==============================
        // Constructor
        //==============================
        
        public function BitfieldTest(pt:PerformanceTest)
        {
            this.pt = pt;
        }
        
        //==============================
        // Public Methods
        //==============================
        
        public function doTest():void
        {
            bits = new Bitfield();
            const iterations:int = 1000000;
            pt.synchronous = true;
            
            pt.testFunction(setBit, iterations, "setBit");
            pt.testFunction(hasBit, iterations, "hasBit");
            pt.testFunction(clearBit, iterations, "clearBit");
            pt.testFunction(clearBits, iterations, "clearBits");
            pt.testFunction(writeBytes, iterations, "writeBytes");
        }
        
        //==============================
        // Private, Protected Methods
        //==============================
        
        private function setBit():void
        {
            bits.setBitAt(8);
        }
        
        private function hasBit():void
        {
            bits.hasBitAt(13);
        }
        
        private function clearBit():void
        {
            bits.clearBitAt(24);
        }
        
        private function clearBits():void
        {
            bits.clearBits();
        }
        
        private function writeBytes():void
        {
            bits.writeBytes();
        }
        
        //==============================
        // Event Handlers
        //==============================
    }
}