Param( $FileToCompile = "${workspace}\Experts\Test123.mq4")

Clear-Host
$LogFile = $FileToCompile + ".log"
$initialLogFile = "Initial Test"
$initialLogFile | Out-File $LogFile

if ($FileToCompile.Contains(" ")) {
    "";"";
    Write-Host "ERROR!  Impossible to Compile! Your Filename or Path contains SPACES!" -ForegroundColor Red;
    "";
    Write-Host $FileToCompile -ForegroundColor Red;
    "";"";
    return;
}

& "dependencies\metaeditor.exe" /compile:"$FileToCompile" /log:"$LogFile" /inc:${workspace} | Out-Null

"";"";"";"";""
$JustTheFileName = Split-Path $FileToCompile -Leaf
Write-Host "Compiling........: $JustTheFileName"
""

$Log = Get-Content -Path $LogFile | Where-Object {$_ -ne ""} | Select-Object -Skip 1

$WhichColor = "Red"
$Log | ForEach-Object { if ($_.Contains("0 error(s), 0 warning(s)")) { $WhichColor="Green" } }

$Log | ForEach-Object {
     if (-Not $_.Contains("information:")) {
           Write-Host $_ -ForegroundColor $WhichColor
     }
}
