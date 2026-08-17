A widget which can group other widgets in a grid structure where you can move them by drag-and-dropping.
You can also add it to a pop-up panel and have widgets stack horizontally and vertically which plasma panels can't do.
Still in development, expect bugs.

![screenshot](https://github.com/Illuminat10n/Container-Grid-Plasmoid/blob/master/screenshot.png?raw=true)

-- Build instructions --

cd /where/your/applet/is/generated
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=MYPREFIX .. 
make 
make install

(MYPREFIX is where you install your Plasma setup, replace it accordingly)

Restart plasma to load the applet 
(in a terminal type: 
kquitapp plasmashell 
and then
plasmashell)

or view it with 
plasmoidviewer -a YourAppletName

-- Tutorials and resources --
The explanation of the template
https://techbase.kde.org/Development/Tutorials/Plasma5/QML2/GettingStarted

Plasma QML API explained
https://techbase.kde.org/Development/Tutorials/Plasma2/QML2/API
