
. "./buildvars.ps1"
$emoji="📖"
$prefix="__"
rm -Force -Recurse obj/
if (!(Test-Path bin)) {
    mkdir bin 
}

if (!(Test-Path obj)) {
    mkdir obj 
}
# cd obj
# if (!(Test-Path addon_d.ipf)) {
#     mkdir addon_d.ipf 
# }
# cd addon_d.ipf 
# if (!(Test-Path $addonname)  ) {
#     mkdir $addonname
# }
#  cd ../..

#cp -Force src/* obj/addon_d.ipf/$addonname/ 
cp -Force -Recurse src/* obj/

cd obj
$aswslpath = (Get-Location | Where {$_.Path}).ToString().Replace("\","/")

$aswslpath = wsl wslpath -a "$aswslpath"
echo $aswslpath

wsl ipf -c 9 tmp.ipf $aswslpath
cp -Force tmp.ipf ../bin/$prefix$addonname"-"$emoji"-"$version".ipf"
mv -Force tmp.ipf ../bin/$addonname"-"$version".ipf"
cd ../
