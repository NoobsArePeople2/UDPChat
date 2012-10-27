package net
{
    import flash.events.DatagramSocketDataEvent;
    import flash.net.DatagramSocket;
    import flash.utils.ByteArray;
    
    import util.Logger;

    /**
     * UDP server.
     */
    public class Server
    {
        //==============================
        // Constants
        //==============================
        
        //==============================
        // Vars
        //==============================
        
        private var sockets:Vector.<DatagramSocket>;
        private var socket:DatagramSocket;
        
        private var clients:Vector.<Peer>;
        
        private var messenger:Messenger;
        private var msg:ByteArray;
        
        //==============================
        // Properties
        //==============================
        
        //==============================
        // Constructor
        //==============================
        
        public function Server()
        {
        }
        
        //==============================
        // Public Methods
        //==============================
        
        public function init(messenger:Messenger, port:int):void
        {
            if (this.messenger)
            {
                // Server is already running
                Logger.log("ERROR: Cannot initialize server that is already running.");
                return;
            }
            this.messenger = messenger; 
            msg = new ByteArray();
            clients = new Vector.<Peer>();
            
            var addresses:Vector.<Peer> = Net.findInterfaces();
            sockets = new Vector.<DatagramSocket>(addresses.length);
            var s:DatagramSocket;
            addresses.forEach(function(addr:Peer, index:int, vec:Vector.<Peer>):void
                {
                    s = new DatagramSocket();
                    s.addEventListener(DatagramSocketDataEvent.DATA, onSetup);
                    s.bind(port, addr.ip);
                    s.receive();
                    sockets[index] = s;
                }
            );
        }
        
        public function shutdown():void
        {
            Logger.log("Shutting down server.");
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
            clients = null;
            Logger.log("Server shutdown.");
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
            if (!Net.isFromPeer(e.srcAddress, clients))
            {
                return;
            }
            
            Logger.log("Them (" + e.srcAddress + ": " + e.srcPort + "): " + e.data.readUTFBytes(e.data.bytesAvailable));
        }
        
        /**
         * Handles the client/server socket set up.
         */ 
        private function onSetup(e:DatagramSocketDataEvent):void
        {
            if (e.data.bytesAvailable > 4)
            {
                if (e.data.readUnsignedInt() == Protocol.ID)
                {
                    Logger.log("CONNECTION FROM: " + e.srcAddress + ": " + e.srcPort);
                    // The socket that's getting data
                    socket = e.target as DatagramSocket;
                    
                    // Clear out all the others
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
                    
                    // Add the port that sent this to the list of clients
                    var client:Peer = new Peer(e.srcAddress, e.srcPort);
                    clients.push(client);
                    msg.position = 0;
                    msg.length = 0;
                    msg.writeUnsignedInt(Protocol.ID);
                    msg.writeUTFBytes("**WE BE CONNECTED**");
                    messenger.sendMessage(socket, msg, client);
                }
            }
        }
    }
}