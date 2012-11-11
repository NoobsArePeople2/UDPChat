package net
{
    import flash.utils.ByteArray;

    /**
     *
     */
    public class AckSequence
    {
        //==============================
        // Constants
        //==============================
        
        //==============================
        // Vars
        //==============================
        
        public var sequence:uint;
        private var queue:Vector.<uint>;
        
        private var bits:Bitfield;
        
        //==============================
        // Properties
        //==============================
        
        //==============================
        // Constructor
        //==============================
        
        public function AckSequence()
        {
            sequence = 0;
            queue = new Vector.<uint>(32);
            bits = new Bitfield();
        }
        
        //==============================
        // Public Methods
        //==============================
        
        /**
         * Adds an ack to the queue.
         * 
         * @param ack Ack to add.
         * @return This <code>AckSequence</code>.
         */ 
        public function add(ack:int):AckSequence
        {
            if (ack > sequence)
            {
                var oldSequence:uint = sequence;
                sequence = ack;
                shift(ack - oldSequence);
                insert(oldSequence);
            }
            else if (ack < 0)
            {
                // Do nothing
            }
            else
            {
                insert(ack);
            }
            
            return this;
        }
        
        /**
         * Clears the sequence.
         * 
         * @return This <code>AckSequence</code>.
         */ 
        public function clear():AckSequence
        {
            var len:int = queue.length;
            for (var i:int = 0; i < len; ++i)
            {
                queue[i] = 0;
            }
            
            return this;
        }
        
        /**
         * Writes the <code>AckSequence</code> as a ByteArray.
         * 
         * @return The ByteArray.
         */ 
        public function writeBytes():ByteArray
        {
            bits.clearBits();
            
            var len:int = queue.length;
            for (var i:int = 0; i < len; ++i)
            {
//                bits.setBitAt(i, queue[i]);
                // This is much faster than the above.
                // Avg time: 0.08ms vs 0.01ms
                if (queue[i] > 0)
                {
                    bits.setBitAt(i);
                }
            }
            
            return bits.writeBytes();
        }
        
        /**
         * Reads an <code>AckSequence</code> from a ByteArray.
         * 
         * @param bytes Bytes to read.
         */ 
        public function readBytes(bytes:ByteArray):void
        {
            bits.readBytes(bytes);
            clear();
            
            var len:int = queue.length;
            for (var i:int = 0; i < len; ++i)
            {
                queue[i] = bits.hasBitAt(i) ? 1 : 0;
            }
        }
        
        public function toString():String
        {
            var s:String = "Sequence: " + sequence;

            var len:int = queue.length;
            for (var i:int = 0; i < len; ++i)
            {
                s += ", [" + i + "]: " + queue[i];
            }
            
            return s;  
        }
        
        //==============================
        // Private, Protected Methods
        //==============================
        
        /**
         * Shifts queue by the specified amount.
         * 
         * @param amount Number of places to shift.
         */ 
        private function shift(amount:uint):void
        {
            var len:int = queue.length;
            var index:int;
            for (var i:int = 0; i < len; ++i)
            {
                index = i + amount;
                if (index >= len)
                {
                    queue[i] = 0;
                }
                else
                {
                    queue[i] = queue[index];
                }
            }
        }
        
        /**
         * Inserts a new ack.
         * 
         * @param ack Ack to insert.
         */ 
        private function insert(ack:uint):void
        {
            // var pos:int = sequence - ack;
            // queue[queue.length - (sequence - ack)] = ack;
            queue[queue.length - (sequence - ack)] = 1;
        }
        
        //==============================
        // Event Handlers
        //==============================
    }
}