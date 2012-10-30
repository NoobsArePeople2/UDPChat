package net
{
    import flash.net.DatagramSocket;
    import flash.net.InterfaceAddress;
    import flash.net.NetworkInfo;
    import flash.net.NetworkInterface;
    
    import util.Logger;

    //==============================
    // Imports
    //==============================
    
    /**
     * Network helper utility.
     */
    public final class Net
    {
        //==============================
        // Constants
        //==============================
        
        private static const IP_V4_REGEX:RegExp = /\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/;
        
        //==============================
        // Vars
        //==============================
        
        //==============================
        // Properties
        //==============================
        
        //==============================
        // Constructor
        //==============================
                
        //==============================
        // Public Methods
        //==============================
        
        /**
         * Finds all network interfaces (i.e., IP addresses) on the local computer.
         * 
         * @return List of all interfaces.
         */
        public static function findInterfaces():Vector.<Peer>
        {
            var addrs:Vector.<Peer> = new Vector.<Peer>();
            var netInterfaces:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
            if (netInterfaces && netInterfaces.length > 0) 
            {    
                for each (var i:NetworkInterface in netInterfaces) 
                {
                    if (i.active) 
                    {
                        var addresses:Vector.<InterfaceAddress> = i.addresses;
                        for each (var j:InterfaceAddress in addresses) 
                        {
                            if (j.address.match(IP_V4_REGEX))
                            {
                                Logger.log("- Host : " + j.address);
                                var addr:Peer = new Peer(j.address);
                                addrs.push(addr);
                            }
                        }
                    }
                }
            }
            
            return addrs;
        }
        
        public static function isFromPeer(srcIp:String, peers:Vector.<Peer>):Peer
        {
            var i:int = peers.length - 1;
            while (i > -1)
            {
                if (peers[i].ip == srcIp)
                {
                    return peers[i];
                }
                --i;
            }
            
            return null;
        }
        
        //==============================
        // Private, Protected Methods
        //==============================
        
        //==============================
        // Event Handlers
        //==============================
    }
}