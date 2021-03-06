package net
{
    import flash.events.DatagramSocketDataEvent;
    import flash.events.TimerEvent;
    import flash.net.DatagramSocket;
    import flash.utils.ByteArray;
    import flash.utils.Timer;
    
    import util.Logger;

    /**
     *
     */
    public class Client implements ISocketConnection
    {
        //==============================
        // Constants
        //==============================
        
        private const DELAY:int = 250;
        private const TIME_OUT:Number = 2 * 1000; // ms
        
        //==============================
        // Vars
        //==============================
        
        /**
         * List of potential sockets to use when 
         * establishing a connection.
         * 
         * After a connection is successfully made
         * this will be nulled out.
         */ 
        private var sockets:Vector.<DatagramSocket>;
        
        /**
         * Socket used for communication once a 
         * connection is initialized.
         */
        private var socket:DatagramSocket;
        
        /**
         * The host computer.
         */
        private var host:Peer;
        
        /**
         * Helper class used to send messages.
         */ 
        private var messenger:Messenger;
        
        /**
         * Data to be sent by <code>messenger</code>.
         */ 
        private var msg:ByteArray;
        
        /**
         * Number of seconds since last received packet.
         */ 
        private var accumulator:Number;
        
        private var timer:Timer;
        
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
            
            timer = new Timer(DELAY);
            timer.addEventListener(TimerEvent.TIMER, onTimer);
            
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
            
            timer.start();
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
            messenger.sendMessage(socket, msg, host);
            
            shutdown();
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
            
            if (timer)
            {
                timer.stop();
                timer.removeEventListener(TimerEvent.TIMER, onTimer);
                timer = null;
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
            
            accumulator = 0;
            Logger.log("Them (" + e.srcAddress + ": " + e.srcPort + "): " + e.data.readUTFBytes(e.data.bytesAvailable));
            messenger.sendMessage(socket, e.data, host);
        }
        
        private function onTimer(e:TimerEvent):void
        {
            accumulator += DELAY;
            if (accumulator > TIME_OUT)
            {
                disconnect();
            }
        }
        
        private function onSetup(e:DatagramSocketDataEvent):void
        {
            if (e.data.bytesAvailable > 4)
            {
                if (e.data.readUnsignedInt() == Protocol.ID)
                {
                    accumulator = 0;
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