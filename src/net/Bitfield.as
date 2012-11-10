package net
{
    import flash.utils.ByteArray;
    import flash.utils.Endian;

    /**
     * A Bitfield.
     */
    public class Bitfield
    {
        //==============================
        // Constants
        //==============================
        
        public static const BITS:Vector.<uint> = new <uint>[
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
        ];
        
        //==============================
        // Vars
        //==============================

        private var bits:Vector.<uint>;
        private var bytes:ByteArray;
        
        //==============================
        // Properties
        //==============================
        
        //==============================
        // Constructor
        //==============================
        
        public function Bitfield()
        {
            bits = new Vector.<uint>(4);
            bytes = new ByteArray();
            bytes.endian = Endian.LITTLE_ENDIAN;
        }
        
        //==============================
        // Public Methods
        //==============================
        
        /**
         * Set the bit at the specified <code>index</code>.
         * 
         * @param index Index of the bit to set.
         * @param value Value (1 or 0) to set on the bit.
         * @return This <code>Bitfield</code>.
         */ 
        public function setBitAt(index:uint, value:uint = 1):Bitfield
        {
            bits[getFieldIndex(index)] |= (value << convertIndex(index));
                        
            return this;
        }
        
        /**
         * Checks if the bit at the specified index is set.
         * 
         * @param index Index to test.
         * @return <code>true</code> if the bit is set, <code>false</code> if not.
         */ 
        public function hasBitAt(index:uint):Boolean
        {
            return (bits[getFieldIndex(index)] & (1 << convertIndex(index))) != 0;
        }
        
        /**
         * Clears the bit at the specified index.
         * 
         * @param index Index of the bit to clear.
         * @return This <code>Bitfield</code>. 
         */
        public function clearBitAt(index:uint):Bitfield
        {
            bits[getFieldIndex(index)] |= (0 << convertIndex(index));
            
            return this;
        }
        
        /**
         * Clears all bits on this field.
         * 
         * @return This <code>Bitfield</code>.
         */ 
        public function clearBits():Bitfield
        {
            bits[0] = 0;
            bits[1] = 0;
            bits[2] = 0;
            bits[3] = 0;
            
            return this;
        }
        
        /**
         * Writes this <code>Bitfield</code> to a ByteArray.
         * 
         * @return The ByteArray.
         */ 
        public function toBytes():ByteArray
        {
            bytes.position = 0;
            bytes.writeByte(bits[0]);
            bytes.writeByte(bits[1]);
            bytes.writeByte(bits[2]);
            bytes.writeByte(bits[3]);
            bytes.position = 0;
            
            return bytes;
        }
        
        /**
         * Reads a ByteArray from <code>toBytes()</code> into
         * this Bitfield.
         * 
         * @param ba Bytes to read.
         * @return This <code>Bitfield</code>.
         */ 
        public function fromBytes(ba:ByteArray):Bitfield
        {
            ba.position = 0;
            bits[0] = ba.readByte();
            bits[1] = ba.readByte();
            bits[2] = ba.readByte();
            bits[3] = ba.readByte();
            return this;
        }
        
        /**
         * String representation of this <code>Bitfield</code>.
         */
        public function toString():String
        {
            return bits[3].toString(2) + " " + bits[2].toString(2) + " " + bits[1].toString(2) + " " + bits[0].toString(2);
        }
        
        //==============================
        // Private, Protected Methods
        //==============================
        
        /**
         * Converts the index so we access the correct uint.
         */ 
        private function convertIndex(index:uint):uint
        {
            if (index < 8)
            {
                return index;
            }
            else if (index < 16)
            {
                return index - 8;
            }
            else if (index < 24)
            {
                return index - 16;
            }
            
            return index - 24;
        }
        
        /**
         * Gets the correct uint field based on the index.
         */ 
        private function getFieldIndex(index:uint):uint
        {
            if (index < 8)
            {
                return 0;
            }
            else if (index < 16)
            {
                return 1;
            }
            else if (index < 24)
            {
                return 2;
            }
            
            return 3;
        }
        
        //==============================
        // Event Handlers
        //==============================
    }
}