package net
{
    import com.adobe.crypto.MD5;
    
    import flash.utils.ByteArray;
    import flash.utils.Endian;
    
    import util.Logger;
    
    /**
     *
     */
    public class Protocol
    {
        //==============================
        // Constants
        //==============================
        
        public static const ID:uint = uint("0x" + MD5.hash("UDPChat!!!!").substr(0, 8).toUpperCase());
        
        //==============================
        // Vars
        //==============================
        
        private var msg:ByteArray;
        
        public var sequence:int;
        public var ack:uint;
        public var message:String;
        
        public var acks:Vector.<uint>;
        public var ackBitfield:Bitfield;
        
        public var remoteAcks:Vector.<uint>;
        public var remoteAckBitfield:Bitfield;
        

        //==============================
        // Properties
        //==============================
        
        //==============================
        // Constructor
        //==============================
        
        public function Protocol()
        {
            msg = new ByteArray();
            msg.endian = Endian.LITTLE_ENDIAN;
            
            acks = new Vector.<uint>(32);
            ackBitfield = new Bitfield();
            
            remoteAcks = new Vector.<uint>(32);
            remoteAckBitfield = new Bitfield();
        }
        
        //==============================
        // Public Methods
        //==============================
        
        /**
         * Composes a message used to initialize a connection.
         * 
         * @param message Message to write.
         * @return The ByteArray message to send.
         */ 
        public function composeInitMessage(message:String):ByteArray
        {
            msg.position = 0;
            msg.length = 0;
            
            msg.writeUnsignedInt(Protocol.ID);
            msg.writeUTFBytes(message);
            return msg;
        }
        
        /**
         * Compose a message that adheres to our protocol.
         * 
         * @param sequence The sequence number of the local computer.
         * @param ack The ack from the local computer.
         * @param message The message to send to the remote computer.
         * @return The ByteArray message to send.
         */
        public function composeMessage(sequence:int, ack:uint, message:String):ByteArray
        {
            msg.position = 0;
            msg.length = 0;
            
            msg.writeShort(sequence);
            msg.writeUnsignedInt(ack);
            msg.writeBytes(composeAcks(), 0, 4);
            msg.writeUTFBytes(message);
            
            return msg;
        }
        
        /**
         * Reads a message from a remote computer.
         * 
         * @param message The message bytes to read.
         * @return The response as a <code>Protocol</code> object.
         */ 
        public function readMessage(message:ByteArray):Protocol
        {
            if (message.length > 10)
            {
                message.position = 0;
                sequence = message.readShort();
                ack = message.readUnsignedInt();
                remoteAckBitfield.readBytes(message);
                this.message = message.readUTFBytes(message.bytesAvailable);
            }
            else
            {
                sequence = -1;
            }
            
            return this;
        }
        
        /**
         * Clears the list of acks.
         */ 
        public function clearAcks():void
        {
//            acks.forEach(function(theAck:uint, index:int, vec:Vector.<uint>):void
//                {
//                    vec[index] = 0;
//                }
//            );
//            
            var len:int = acks.length;
            for (var i:int = 0; i < len; ++i)
            {
                acks[i] = 0;
            }
        }
        
        //==============================
        // Private, Protected Methods
        //==============================
        
        /**
         * Composes the acks <code>Bitfield</code.
         */ 
        private function composeAcks():ByteArray
        {
            ackBitfield.clearBits();
            var i:int = 31;
            while (i > -1)
            {
                ackBitfield.setBitAt(i, acks[i]);
                --i;
            }
            
            return ackBitfield.writeBytes();
        }
        
        //==============================
        // Event Handlers
        //==============================
    }
}