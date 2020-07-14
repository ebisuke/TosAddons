$addonname="advancedmoneyinput"
$emoji="📖"
$prefix="__"
$version="v0.0.2"

if (!(Test-Path bin)) {
    mkdir bin 
}

if (!(Test-Path obj)) {
    mkdir obj 
}
cd obj
if (!(Test-Path addon_d.ipf)) {
    mkdir addon_d.ipf 
}
cd addon_d.ipf 
if (!(Test-Path $addonname)  ) {
    mkdir $addonname
}
cd ../..
cp -Force src/* obj/addon_d.ipf/$addonname/ 

cd obj
$aswslpath = (Get-Location | Where {$_.Path}).ToString().Replace("\","/")

$aswslpath = wsl wslpath -a "$aswslpath"
echo $aswslpath

wsl ipf -c 9 tmp.ipf $aswslpath
cp -Force tmp.ipf ../bin/$prefix$addonname"-"$emoji"-"$version".ipf"
mv -Force tmp.ipf ../bin/$addonname"-"$version".ipf"
cd ../
