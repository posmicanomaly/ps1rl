<#
Powershell Roguelike

#>

class Player {
    [int]$x
    [int]$y
}

$tileReferenceMap = @{}
$tileReferenceMap["0"] = "."
$tileReferenceMap["1"] = "#"

$operationReferenceMap = @{}
$operationReferenceMap[27] = "QUIT"
$operationReferenceMap[37] = "MV_WEST"
$operationReferenceMap[38] = "MV_NORTH"
$operationReferenceMap[39] = "MV_EAST"
$operationReferenceMap[40] = "MV_SOUTH"


$global:width = 50
$global:height = 20


$global:message = ""
$global:lastKey
$global:runGame = $true
$global:map = @()
$global:player = [Player]::new()
$global:player.x = $width / 2
$global:player.y = $height / 2

Function createRandomMap( $width, $height ) {
    Write-Host "Width: $width, Height: $height"
    $map = @()
    for( $y=0; $y -lt $height; $y++ ) {
        $line = ""
        for( $x=0; $x -lt $width; $x++) {
            if ( ( $y -eq 0 -or $y -eq $height - 1 ) -or ( $x -eq 0 -or $x -eq $width - 1 ) ) {
                $line = $line += "1"
            } else {
                $line = $line += "0"
            }
            
        }
        $map += $line
    }
    return $map
}

Function getInput {
    return $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

Function convertLine($line) {
    foreach( $key in $tileReferenceMap.Keys ) {
        $line = $line -replace $key, $tileReferenceMap[$key]
    }
    return $line
}

function insertPlayer ($convertedLine) {
    return $convertedLine.remove($global:player.x,1).insert($global:player.x,"@")
}

Function drawMap {
    Clear-Host
    Write-Host "PowerShell Roguelike!"
    $row = 0
    foreach( $line in $map ) {
        $convertedLine = convertLine( $line )
        if($row -eq $global:player.y) {
            $convertedLine = insertPlayer $convertedLine
        }
        Write-Host $convertedLine
        $row++
    }
    Write-Host "Message: $global:message"
    #Write-Host $global:lastKey.VirtualKeyCode
}

Function movePlayer ( $direction ) {
    $x = $global:player.x
    $y = $global:player.y
    switch ( $direction ) {
        "MV_WEST"   { $x--; break }
        "MV_NORTH"  { $y--; break }
        "MV_EAST"   { $x++; break }
        "MV_SOUTH"  { $y++; break }
    }
    if(($x -eq 0 -or $x -eq $global:width - 1) -or ($y -eq 0 -or $y -eq $global:height - 1)) {
        $global:message = "Ouch! Bumped into a wall!"
    } else {
        $global:player.x = $x
        $global:player.y = $y
        $global:message = ""
    }
}

$global:map = createRandomMap $width $height

Function gameLoop {
    drawMap
    $key = getInput
    $global:lastKey = $key
    
    $operation = $operationReferenceMap[$key.VirtualKeyCode]
    switch( $operation ) {
        "QUIT"      { $global:message = "Quitting the game"; $global:runGame = $false; break }
        "MV_WEST"   { movePlayer $operation; break }
        "MV_NORTH"  { movePlayer $operation; break }
        "MV_EAST"   { movePlayer $operation; break }
        "MV_SOUTH"  { movePlayer $operation; break }
        default     { $global:message = "Operation Unknown"; break }
    }
}

while( $global:runGame ) {
    gameLoop
}