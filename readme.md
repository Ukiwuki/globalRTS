Global RTS map prototype.

Done on Starling engine 2.2.
Heavily relies on MeshBatch render class to outpur large number of map symbols.
In the root there is FlashDevelop IDE project file, but code can be compiled in any suitable IDE (main document class is Demo_Web.as).

Towns are loaded from bin/assets/towns.xml. Lines between towns are calculated at startup. All towns within predefined radius get connected.
Units spawn in capital towns (press Space).
To launch Nuke press Shift+click anythere on map.

Images are embedded for web deployment purposes. You can switch to separate images loading - see method loadAssets() in Demo_Web.as.