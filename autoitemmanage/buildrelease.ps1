$addonname="autoitemmanage"
$emoji="📖"
$prefix=""
$version="v0.0.2"
cd E:\ToSProject\TosAddons\autoitemmanage
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
cp  src/* obj/addon_d.ipf/$addonname/ 

cd obj
$aswslpath = (Get-Location | Where {$_.Path}).ToString().Replace("\","/")

$aswslpath = wsl wslpath -a "$aswslpath"
echo $aswslpath

wsl ipf -c 9 tmp.ipf $aswslpath

mv -Force tmp.ipf ../bin/$prefix$addonname"-"$emoji"-"$version".ipf"
cd ../
