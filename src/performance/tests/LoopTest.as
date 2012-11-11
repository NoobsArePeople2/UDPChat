package performance.tests
{
    import com.gskinner.utils.PerformanceTest;

    /**
     *
     */
    public class LoopTest implements IPerformanceTest
    {
        //==============================
        // Constants
        //==============================
        
        //==============================
        // Vars
        //==============================
        
        private var pt:PerformanceTest;
        private var vec:Vector.<uint>;
        
        //==============================
        // Properties
        //==============================
        
        //==============================
        // Constructor
        //==============================
        
        public function LoopTest(pt:PerformanceTest)
        {
            this.pt = pt;
        }
        
        //==============================
        // Public Methods
        //==============================
        
        public function doTest():void
        {
            const iterations:int = 1000000;
            pt.synchronous = true;
            vec = new Vector.<uint>(32);
            
            pt.testFunction(forEachTest, iterations, "forEachTest");
            pt.testFunction(forTest, iterations, "forTest");
            pt.testFunction(forConstTest, iterations, "forConstTest");
            pt.testFunction(whileTest, iterations, "whileTest");
        }
        
        //==============================
        // Private, Protected Methods
        //==============================
        
        private function forEachTest():void
        {
            var val:int;
            vec.forEach(function(item:uint, index:int, vec:Vector.<uint>):void
                {
                    val = 1 + 1;
                }
            );
        }
        
        private function forTest():void
        {
            var len:int = vec.length;
            var val:int;
            for (var i:int = 0; i < len; ++i)
            {
                val = 1 + 1;
            }
        }
        
        private function forConstTest():void
        {
            const len:int = vec.length;
            var val:int;
            for (var i:int = 0; i < len; ++i)
            {
                val = 1 + 1;
            }
        }
        
        private function whileTest():void
        {
            var i:int = vec.length - 1;
            var val:int;
            while (i > -1)
            {
                val = 1 + 1;
                --i;
            }
        }
        
        //==============================
        // Event Handlers
        //==============================
    }
}