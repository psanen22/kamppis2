# Set input and output paths
$inputFolder = "C:\Users\domus\Pictures\dnd"
$outputBase = "C:\Users\domus\Pictures\dnd\images"
$gsPath = "C:\Program Files\gs\gs10.05.1\bin\gswin64c.exe"  # Update to your install path
$resolution = 150

# Ensure Ghostscript exists
if (!(Test-Path $gsPath)) {
    Write-Error "Ghostscript not found at $gsPath"
    exit 1
}

# Create output base folder if needed
if (!(Test-Path $outputBase)) {
    New-Item -ItemType Directory -Path $outputBase | Out-Null
}

# Process PDFs in a queue (one at a time)
$pdfFiles = Get-ChildItem -Path $inputFolder -Filter *.pdf

foreach ($file in $pdfFiles) {
    $pdfPath = $file.FullName
    $pdfName = $file.BaseName
    $pdfOutputFolder = Join-Path $outputBase $pdfName

    if (!(Test-Path $pdfOutputFolder)) {
        New-Item -ItemType Directory -Path $pdfOutputFolder | Out-Null
    }

    $outputPattern = Join-Path $pdfOutputFolder "page_%03d.png"

    # Build Ghostscript argument string
    $arguments = @(
        "-dNOPAUSE",
        "-dBATCH",
        "-sDEVICE=png16m",
        "-r$resolution",
        "-sOutputFile=$outputPattern",
        "`"$pdfPath`""
    )

    Write-Host "Converting '$pdfName.pdf'..."
    $command = "& `"$gsPath`" $($arguments -join ' ')"
    Write-Host $command

    # Invoke Ghostscript directly
    $exitCode = & $gsPath @arguments

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Conversion failed for '$pdfName.pdf'"
    } else {
        Write-Host "✅ Done: $pdfName.pdf"
    }

    Start-Sleep -Seconds 1  # Small delay to ensure stability
}
