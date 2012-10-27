package util
{
    //==============================
    // Imports
    //==============================
    
    /**
     * A utility for logging stuff.
     */
    public final class Logger
    {
        //==============================
        // Constants
        //==============================
        
        //==============================
        // Vars
        //==============================
        
        private static var logFunction:Function;
        
        //==============================
        // Properties
        //==============================
        
        //==============================
        // Constructor
        //==============================
                
        //==============================
        // Public Methods
        //==============================
        
        public static function init(func:Function):void
        {
            logFunction = func;
        }
        
        public static function log(msg:String):void
        {
            trace(msg);
            if (logFunction != null)
            {
                logFunction(msg);
            }
        }
        
        //==============================
        // Private, Protected Methods
        //==============================
        
        //==============================
        // Event Handlers
        //==============================
    }
}