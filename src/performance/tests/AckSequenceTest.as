package performance.tests
{
    import com.gskinner.utils.PerformanceTest;
    
    import net.AckSequence;

    /**
     *
     */
    public class AckSequenceTest implements IPerformanceTest
    {
        //==============================
        // Constants
        //==============================
        
        //==============================
        // Vars
        //==============================
        
        private var pt:PerformanceTest;
        
        private var acks:AckSequence;
        private var sequence:int;
        
        //==============================
        // Properties
        //==============================
        
        //==============================
        // Constructor
        //==============================
        
        
        public function AckSequenceTest(pt:PerformanceTest)
        {
            this.pt = pt;
            acks = new AckSequence();
        }
        
        //==============================
        // Public Methods
        //==============================
        
        public function doTest():void
        {
            const iterations:int = 100000;
            pt.synchronous = true;
            sequence = 0;
            
            pt.testFunction(add, iterations, "add");
            pt.testFunction(writeBytes, iterations, "writeBytes");
        }
        
        //==============================
        // Private, Protected Methods
        //==============================
        
        private function add():void
        {
            acks.add(sequence);
            sequence++;
        }
        
        private function writeBytes():void
        {
            acks.writeBytes();
        }
        
        //==============================
        // Event Handlers
        //==============================
    }
}