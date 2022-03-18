@echo off

copy assets.pak C:\Users\Nick\Documents\Projects\Haxe\Valentine\export\js
copy preload.pak C:\Users\Nick\Documents\Projects\Haxe\Valentine\export\js
cd export
7z a bin.zip js
start .