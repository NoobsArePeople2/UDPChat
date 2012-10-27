package net
{
    import flash.events.DatagramSocketDataEvent;
    import flash.net.DatagramSocket;
    import flash.utils.ByteArray;
    
    import util.Logger;

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
        
        private var sockets:Vector.<DatagramSocket>;
        private var socket:DatagramSocket;
        
        private var host:Peer;
        
        private var messenger:Messenger;
        private var msg:ByteArray;
        
        //==============================
        // Properties
        //==============================
        
        //==============================
        // Constructor
        //==============================
        
        public function Client()
        {
        }
        
        //==============================
        // Public Methods
        //==============================
        
        public function init(messenger:Messenger, host:Peer):void
        {
            if (this.messenger)
            {
                // Connection already running
                Logger.log("ERROR: Cannot initialize client connection that is already running.");
                return;
            }
            
            this.messenger = messenger;
            msg = new ByteArray();
            this.host = host;
            
            var addresses:Vector.<Peer> = Net.findInterfaces();
            sockets = new Vector.<DatagramSocket>(addresses.length);
            var s:DatagramSocket;
            addresses.forEach(function(addr:Peer, index:int, vec:Vector.<Peer>):void
            {
                s = new DatagramSocket();
                s.addEventListener(DatagramSocketDataEvent.DATA, onSetup);
                s.bind(host.port, addr.ip);
                s.receive();
                sockets[index] = s;
                
                msg.position = 0;
                msg.length = 0;
                msg.writeUnsignedInt(Protocol.ID);
                msg.writeUTFBytes("**HELLO**");
                messenger.sendMessage(s, msg, host); 
            }
            );
        }
        
        public function shutdown():void
        {
            Logger.log("Shutting down client.");
            if (socket)
            {
                socket.removeEventListener(DatagramSocketDataEvent.DATA, onData);
                socket.close();
            }
            socket = null;
            
            if (sockets)
            {
                sockets.forEach(function(sock:DatagramSocket, index:int, vec:Vector.<DatagramSocket>):void
                {
                    sock.removeEventListener(DatagramSocketDataEvent.DATA, onSetup);
                    sock.close();
                }
                );
                sockets = null;
            }
            
            msg = null;
            messenger = null;
            host = null;
            Logger.log("Client shutdown.");
        }
        
        //==============================
        // Private, Protected Methods
        //==============================
        
        //==============================
        // Event Handlers
        //==============================
        
        private function onData(e:DatagramSocketDataEvent):void
        {
            // Filter connections
            if (e.srcAddress != host.ip)
            {
                return;
            }
            
            Logger.log("Them (" + e.srcAddress + ": " + e.srcPort + "): " + e.data.readUTFBytes(e.data.bytesAvailable));
        }
        
        private function onSetup(e:DatagramSocketDataEvent):void
        {
            if (e.data.bytesAvailable > 4)
            {
                if (e.data.readUnsignedInt() == Protocol.ID)
                {
                    Logger.log("CONNECTION FROM: " + e.srcAddress + ": " + e.srcPort);
                    
                    // This the socket to use
                    socket = e.target as DatagramSocket;
                    
                    // Clear out all other sockets
                    sockets.forEach(function(sock:DatagramSocket, index:int, vec:Vector.<DatagramSocket>):void
                        {
                            if (sock != socket)
                            {
                                sock.removeEventListener(DatagramSocketDataEvent.DATA, onSetup);
                                sock.close();
                            }
                        }
                    );
                    sockets = null;
                    
                    // Set up the socket
                    socket.removeEventListener(DatagramSocketDataEvent.DATA, onSetup);
                    socket.addEventListener(DatagramSocketDataEvent.DATA, onData);
                    
                    host.ip = e.srcAddress;
                    host.port = e.srcPort;
                    
                    msg.position = 0;
                    msg.length = 0;
                    msg.writeUTFBytes("**WE BE CONNECTED**");
                    messenger.sendMessage(socket, msg, host);
                }
            }
        }
    }
}