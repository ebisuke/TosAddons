

$xacdae="./xrconvertersmain.exe"
$files = Get-ChildItem -Recurse -Name

# 取得した情報を一つ一つ処理する
foreach($file in $files) {
    if( Test-Path $file -PathType Leaf ) {
        if ((Get-Item $file).Extension -eq ".xac"){
            
            $command="${xacdae} importxac .\ $file"
            echo $command
            Invoke-Expression $command 
        }
    }
}
