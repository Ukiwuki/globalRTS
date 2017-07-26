package
{
    public class EmbeddedMap
    {
        /** ATTENTION: Naming conventions!
         *  
         *  - Classes for embedded IMAGES should have the exact same name as the file,
         *    without extension. This is required so that references from XMLs (atlas, bitmap font)
         *    won't break.
         *    
         *  - Atlas and Font XML files can have an arbitrary name, since they are never
         *    referenced by file name.
         * 
         */
        
		
        [Embed(source="../bin/assets/tile1.jpg")]
        public static const tile1:Class;
        [Embed(source="../bin/assets/tile2.jpg")]
        public static const tile2:Class;
    }
}