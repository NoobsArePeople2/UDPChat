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
        
        public const ACK_IDS:Vector.<uint> = new <uint>[
            1 << 00,
            1 << 01,
            1 << 02,
            1 << 03,
            1 << 04,
            1 << 05,
            1 << 06,
            1 << 07,
            1 << 08,
            1 << 09,
            1 << 10,
            1 << 11,
            1 << 12,
            1 << 13,
            1 << 14,
            1 << 15,
            1 << 16,
            1 << 17,
            1 << 18,
            1 << 19,
            1 << 20,
            1 << 21,
            1 << 22,
            1 << 23,
            1 << 24,
            1 << 25,
            1 << 26,
            1 << 27,
            1 << 28,
            1 << 29,
            1 << 30,
            1 << 31
//            1,
//            2,
//            4,
//            8,
//            16,
//            32,
//            64,
//            128,
//            256,
//            512,
//            1024,
//            2048,
//            4096,
//            8192,
//            16384,
//            32768,
//            65536,
//            131072,
//            262144,
//            524288,
//            1048576,
//            2097152,
//            4194304,
//            8388608,
//            16777216,
//            33554432,
//            67108864,
//            134217728,
//            268435456,
//            536870912,
//            1073741824,
//            2147483648
          ];
//        public const ACK_00:uint = 1;
//        public const ACK_01:uint = 2;
//        public const ACK_02:uint = 4;
//        public const ACK_03:uint = 8;
//        public const ACK_04:uint = 16;
//        public const ACK_05:uint = 32;
//        public const ACK_06:uint = 64;
//        public const ACK_07:uint = 128;
//        public const ACK_08:uint = 256;
//        public const ACK_09:uint = 512;
//        public const ACK_10:uint = 1024;
//        public const ACK_11:uint = 2048;
//        public const ACK_12:uint = 4096;
//        public const ACK_13:uint = 8192;
//        public const ACK_14:uint = 16384;
//        public const ACK_15:uint = 32768;
//        public const ACK_16:uint = 65536;
//        public const ACK_17:uint = 131072;
//        public const ACK_18:uint = 262144;
//        public const ACK_19:uint = 524288;
//        public const ACK_20:uint = 1048576;
//        public const ACK_21:uint = 2097152;
//        public const ACK_22:uint = 4194304;
//        public const ACK_23:uint = 8388608;
//        public const ACK_24:uint = 16777216;
//        public const ACK_25:uint = 33554432;
//        public const ACK_26:uint = 67108864;
//        public const ACK_27:uint = 134217728;
//        public const ACK_28:uint = 268435456;
//        public const ACK_29:uint = 536870912;
//        public const ACK_30:uint = 1073741824;
//        public const ACK_31:uint = 2147483648;
        
        //==============================
        // Vars
        //==============================
        
        private var msg:ByteArray;
        
        public var sequence:int;
        public var ack:uint;
        public var message:String;
        
        public var acks:Vector.<uint>;
        public var ackBitfield:Bitfield;
//        public var ackUint:uint;
//        public var ackBytes:ByteArray;
        
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
//            ackBytes = new ByteArray();
//            ackBytes.endian = Endian.LITTLE_ENDIAN;
            ackBitfield = new Bitfield();
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
            if (message.length > 6)
            {
                message.position = 0;
                sequence = message.readShort();
                ack = message.readUnsignedInt();
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
            acks.forEach(function(theAck:uint, index:int, vec:Vector.<uint>):void
                {
                    vec[index] = 0;
                }
            );
        }
        
        //==============================
        // Private, Protected Methods
        //==============================
        
        public function composeAcks():ByteArray
        {
            ackBitfield.clearBits();
            var i:int = 31;
            while (i > -1)
            {
                ackBitfield.setBitAt(i, acks[i]);
                --i;
            }
            
            return ackBitfield.toBytes();
        }
        
        //==============================
        // Event Handlers
        //==============================
    }
}