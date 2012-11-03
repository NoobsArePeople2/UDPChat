package net
{
    import flash.events.DatagramSocketDataEvent;
    import flash.events.TimerEvent;
    import flash.net.DatagramSocket;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.Timer;
    
    import util.Logger;

    /**
     * UDP server.
     */
    public class Server implements ISocketConnection
    {
        //==============================
        // Constants
        //==============================
        
        private const DELAY:int = 250;
        private const TIME_OUT:Number = 2 * 1000; // in ms
        
        //==============================
        // Vars
        //==============================
        
        private var sockets:Vector.<DatagramSocket>;
        private var socket:DatagramSocket;
        
        private var clients:Vector.<Peer>;
        
        private var messenger:Messenger;
        private var msg:ByteArray;
        
        private var accumulator:Number;
        
        private var timer:Timer;
        
        private var localSequence:int;
        private var remoteSequences:Dictionary;
        
        private var protocol:Protocol;
        
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
        
        public function init(messenger:Messenger, peer:Peer):void
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
            
            timer = new Timer(DELAY);
            timer.addEventListener(TimerEvent.TIMER, onTimer);
            
            localSequence = 0;
            remoteSequences = new Dictionary();
            protocol = new Protocol();
            
            var addresses:Vector.<Peer> = Net.findInterfaces();
            sockets = new Vector.<DatagramSocket>(addresses.length);
            var s:DatagramSocket;
            addresses.forEach(function(addr:Peer, index:int, vec:Vector.<Peer>):void
                {
                    s = new DatagramSocket();
                    s.addEventListener(DatagramSocketDataEvent.DATA, onSetup);
                    s.bind(peer.port, addr.ip);
                    s.receive();
                    sockets[index] = s;
                }
            );
        }
        
        public function disconnect():void
        {
            if (accumulator < 0)
            {
                return;
            }
            
            accumulator = -TIME_OUT;
            Logger.log("Disconnecting.");
            msg.position = 0;
            msg.length = 0;
            msg.writeUTFBytes("**DISCONNECTING**");
            
            clients.forEach(function(client:Peer, index:int, vec:Vector.<Peer>):void
                {
                    messenger.sendMessage(socket, msg, client);    
                }
            );
            
            shutdown();
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
            
            if (timer)
            {
                timer.stop();
                timer.removeEventListener(TimerEvent.TIMER, onTimer);
                timer = null;
            }
            
            accumulator = 0;
            msg = null;
            messenger = null;
            clients = null;
            
            localSequence = 0;
            remoteSequences = null;
            protocol = null;
            
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
            var peer:Peer = Net.isFromPeer(e.srcAddress, clients);
            if (!peer)
            {
                return;
            }
            
            accumulator = 0;
            Logger.log("Them (" + e.srcAddress + ": " + e.srcPort + "): " + e.data.readUTFBytes(e.data.bytesAvailable));
            
            protocol.readMessage(e.data);
            
            if (protocol.sequence > remoteSequences[peer.ip])
            {
                remoteSequences[peer.ip] = protocol.sequence;
            }
            
            messenger.sendMessage(socket, 
                protocol.composeMessage(localSequence, remoteSequences[peer.ip], "Received sequence " + protocol.sequence),
                peer);
            localSequence++;
        }
        
        private function onTimer(e:TimerEvent):void
        {
            accumulator += DELAY;
            Logger.log("Accumulator: " + accumulator);
            if (accumulator > TIME_OUT)
            {
                disconnect();
            }
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
                    accumulator = 0;
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
                    remoteSequences[client.ip] = 0;
                    
                    msg.position = 0;
                    msg.length = 0;
                    msg.writeUnsignedInt(Protocol.ID);
                    msg.writeUTFBytes("**WE BE CONNECTED**");
                    messenger.sendMessage(socket, msg, client);
                    
                    
                    
                    accumulator = 0;
                    timer.start();
                }
            }
        }
    }
}