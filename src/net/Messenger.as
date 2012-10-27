package net
{
    import flash.net.DatagramSocket;
    import flash.utils.ByteArray;
    
    import util.Logger;

    //==============================
    // Imports
    //==============================
    
    /**
     *
     */
    public class Messenger
    {
        //==============================
        // Constants
        //==============================
        
        //==============================
        // Vars
        //==============================
        
        //==============================
        // Properties
        //==============================
        
        //==============================
        // Constructor
        //==============================
        
        public function Messenger()
        {
        }
        
        //==============================
        // Public Methods
        //==============================
        
        public function sendMessage(socket:DatagramSocket, msg:ByteArray, dest:Peer):void
        {
            Logger.log("Sending message to: " + dest.ip + ":" + dest.port + " from " + socket.localAddress + ":" + socket.localPort.toString());
            socket.send(msg, 0, 0, dest.ip, dest.port);
        }
        
        //==============================
        // Private, Protected Methods
        //==============================
        
        //==============================
        // Event Handlers
        //==============================
    }
}