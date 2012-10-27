/**
 *
 * @author		Sean Monahan sean@seanmonahan.org
 * @created
 * @version		1.0.0
 */
package
{
    //==============================
    // Imports
    //==============================
    
    /**
     *
     */
    public class Client
    {
        //==============================
        // Constants
        //==============================
        
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
        
        public function Client(ip:String = '', port:int = -1)
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