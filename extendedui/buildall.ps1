$addonname="extendedui"
$emoji="📖"
$prefix="__"
$version="v3.0.0"

if (!(Test-Path bin)) {
    mkdir bin 
}

if (!(Test-Path obj)) {
    mkdir obj 
}

cp -Force -Recurse src/* obj/ 

cd obj
$aswslpath = (Get-Location | Where {$_.Path}).ToString().Replace("\","/")

$aswslpath = wsl wslpath -a "$aswslpath"
echo $aswslpath

wsl ipf -c 9 tmp.ipf $aswslpath
cp -Force tmp.ipf ../bin/$prefix$addonname"-"$emoji"-"$version".ipf"
mv -Force tmp.ipf ../bin/$addonname"-"$version".ipf"
cd ../
