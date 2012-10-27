package net
{
    //==============================
    // Imports
    //==============================
    
    /**
     *
     */
    public class Peer
    {
        //==============================
        // Constants
        //==============================
        
        public static const HOST:String = "host";
        public static const CLIENT:String = "client";
        
        //==============================
        // Vars
        //==============================
        
        /**
         * IPv4 address.
         */
        public var ip:String;
        
        /**
         * Port.
         */
        public var port:int;
        
        //==============================
        // Properties
        //==============================
        
        //==============================
        // Constructor
        //==============================
        
        public function Peer(ip:String = '', port:int = -1)
        {
            this.ip = ip;
            this.port = port;
        }
        
        //==============================
        // Public Methods
        //==============================
        
        //==============================
        // Private, Protected Methods
        //==============================
        
        //==============================
        // Event Handlers
        //==============================
    }
}