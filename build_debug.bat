@echo off

odin build . -debug -build-mode:dll -out:reaper_alkamist.dll
move /y "C:\Users\corey\Documents\OdinStuff\alkamist_extension\reaper_alkamist.dll" "C:\Users\corey\AppData\Roaming\REAPER\UserPlugins\"
move /y "C:\Users\corey\Documents\OdinStuff\alkamist_extension\reaper_alkamist.pdb" "C:\Users\corey\AppData\Roaming\REAPER\UserPlugins\"
del "C:\Users\corey\Documents\OdinStuff\alkamist_extension\reaper_alkamist.exp"
del "C:\Users\corey\Documents\OdinStuff\alkamist_extension\reaper_alkamist.lib"

pause