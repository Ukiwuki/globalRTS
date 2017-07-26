package
{
    public class EmbeddedAssets
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
        

        [Embed(source="../bin/assets/towns.xml", mimeType="application/octet-stream")]
        public static const towns:Class;
		
        [Embed(source="../bin/assets/icons.xml", mimeType="application/octet-stream")]
        public static const iconsXml:Class;
		
        [Embed(source="../bin/assets/nuke.xml", mimeType="application/octet-stream")]
        public static const nukeXml:Class;
		
        [Embed(source="../bin/assets/units.xml", mimeType="application/octet-stream")]
        public static const unitsXml:Class;
		
        [Embed(source="../bin/assets/icons.png")]
        public static const icons:Class;
        [Embed(source="../bin/assets/nuke.png")]
        public static const nuke:Class;
        [Embed(source="../bin/assets/units.png")]
        public static const units:Class;
    }
}