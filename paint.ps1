[reflection.assembly]::LoadWithPartialName( "System.Windows.Forms")
[reflection.assembly]::LoadWithPartialName( "System.Drawing")

function Save-Image {
    param (
        [string]$filePath
    )
    $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $saveFileDialog.Filter = "PNG Image|*.png|Bitmap Image|*.bmp|JPEG Image|*.jpg"
    if ($filePath) {
        $saveFileDialog.FileName = $filePath
    }
    if ($saveFileDialog.ShowDialog() -eq "OK") {
        $bitmap = New-Object System.Drawing.Bitmap($form.ClientSize.Width, $form.ClientSize.Height)
        $form.DrawToBitmap($bitmap, $form.ClientRectangle)
        
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        
        $graphics.Clear($form.BackColor)
        foreach ($line in $global:lines) {
            $graphics.DrawLine($line.Pen, $line.X1, $line.Y1, $line.X2, $line.Y2)
        }
        
        $format = [System.Drawing.Imaging.ImageFormat]::Png
        switch ($saveFileDialog.FilterIndex) {
            2 { $format = [System.Drawing.Imaging.ImageFormat]::Bmp }
            3 { $format = [System.Drawing.Imaging.ImageFormat]::Jpeg }
        }
        $bitmap.Save($saveFileDialog.FileName, $format)
        $global:savedFilePath = $saveFileDialog.FileName
        $graphics.Dispose()
    }
}

$mypen = new-object Drawing.Pen black
$mypen.color = "red"

$draw = 0
$global:penWidth = 1
$global:penHeight = 1
$penWidth = 1
$penHeight = 1
$prevX = $null
$prevY = $null

$global:lines = New-Object System.Collections.ArrayList
$global:drawingGroups = New-Object System.Collections.ArrayList

$form = New-Object Windows.Forms.Form
$form.Text = "Paint"
$form.WindowState = 'Maximized'
$form.FormBorderStyle = 'Sizable'

$formGraphics = $form.createGraphics()

function Redraw-Form {
    $formGraphics.Clear($form.BackColor)
    foreach ($line in $global:lines) {
        $formGraphics.DrawLine($line.Pen, $line.X1, $line.Y1, $line.X2, $line.Y2)
    }
}

$SaveButton = New-Object System.Windows.Forms.Button
$SaveButton.Location = New-Object System.Drawing.Point(530,10)
$SaveButton.Size = New-Object System.Drawing.Size(70,20)
$SaveButton.Text = "Save"
$SaveButton.BackColor = "LightGray"
$SaveButton.FlatStyle = "Flat"

$SaveButton.Add_Click({
    Save-Image
})

$ColorButton = New-Object System.Windows.Forms.Button 
$ColorButton.Location = New-Object System.Drawing.Point(10,10)
$ColorButton.Size = New-Object System.Drawing.Size(150,20)
$ColorButton.Text = "Choose Pen color"
$ColorButton.BackColor = "LightGray"
$ColorButton.FlatStyle = "Flat"

$ColorButton.Add_Click({
    $colorDialog = New-Object System.Windows.Forms.ColorDialog
    $colorDialog.AllowFullOpen = $true
    if($colorDialog.ShowDialog() -eq "OK"){
        $mypen.color = $colorDialog.Color
    }
})

$ClearButton = New-Object System.Windows.Forms.Button 
$ClearButton.Location = New-Object System.Drawing.Point(450,10)
$ClearButton.Size = New-Object System.Drawing.Size(70,20)
$ClearButton.Text = "Clear"
$ClearButton.BackColor = "LightGray"
$ClearButton.FlatStyle = "Flat"

$ClearButton.Add_Click({
    $global:lines.Clear()
    $global:drawingGroups.Clear()
    $global:undoneDrawingGroups.Clear()
    Redraw-Form
})

$EraseButton = New-Object System.Windows.Forms.Button
$EraseButton.Location = New-Object System.Drawing.Point(170,10)
$EraseButton.Size = New-Object System.Drawing.Size(70,20)
$EraseButton.Text = "Eraser"
$EraseButton.BackColor = "LightGray"
$EraseButton.FlatStyle = "Flat"

$EraseButton.Add_Click({
    $global:penWidth = 10;
    $mypen.color = $form.BackColor
    $mypen.width = $global:penWidth
})

$trackBar = New-Object System.Windows.Forms.TrackBar
$trackBar.Location = New-Object System.Drawing.Point(250, 10)
$trackBar.Size = New-Object System.Drawing.Size(200, 20)
$trackBar.Minimum = 1
$trackBar.Maximum = 20
$trackBar.Value = 1
$trackBar.TickStyle = 'None'

$trackBar.Add_Scroll({
    $global:penWidth = $trackBar.Value
    $global:penHeight = $trackBar.Value
})

$form.Add_KeyDown({
    if ($_.Control -and $_.KeyCode -eq "Z") {
        if ($global:drawingGroups.Count -gt 0) {
            $lastDrawingGroup = $global:drawingGroups[-1]
            
            if ($global:undoneDrawingGroups -eq $null) {
                $global:undoneDrawingGroups = New-Object System.Collections.ArrayList
            }
            [void]$global:undoneDrawingGroups.Add($lastDrawingGroup)

            foreach ($line in $lastDrawingGroup) {
                [void]$global:lines.Remove($line)
            }
            [void]$global:drawingGroups.RemoveAt($global:drawingGroups.Count - 1)
            Redraw-Form
        }
    }
    if ($_.Control -and $_.KeyCode -eq "Y") {
        if ($global:undoneDrawingGroups -and $global:undoneDrawingGroups.Count -gt 0) {
            $lastUndoneGroup = $global:undoneDrawingGroups[-1]
            
            foreach ($line in $lastUndoneGroup) {
                [void]$global:lines.Add($line)
            }
            
            [void]$global:drawingGroups.Add($lastUndoneGroup)
            
            [void]$global:undoneDrawingGroups.RemoveAt($global:undoneDrawingGroups.Count - 1)
            
            Redraw-Form
        }
        if ($_.Control -and $_.KeyCode -eq "S") {
            if ($global:savedFilePath) {
                Save-Image $global:savedFilePath
            } else {
                Save-Image
            }
        }
    }
})

$form.Add_MouseDown({
    $global:draw = 1
    write-host $_.Location $global:prevX $global:prevY $draw
    $global:prevX = $_.Location.X
    $global:prevY = $_.Location.Y
    $currentDrawing = New-Object System.Collections.ArrayList
    $global:currentDrawing = $currentDrawing
    [void]$global:drawingGroups.Add($currentDrawing)
})

$form.Add_MouseMove({
    if($global:draw -and ($global:prevX -ne $null) -and ($global:prevY -ne $null)){
        $mypen.width = $global:penWidth
        $formGraphics.DrawLine($mypen, $global:prevX, $global:prevY, $_.Location.X, $_.Location.Y)

        $line = New-Object PSObject -Property @{
            Pen = $mypen.Clone();
            X1 = $global:prevX;
            Y1 = $global:prevY;
            X2 = $_.Location.X;
            Y2 = $_.Location.Y
        }
        [void]$global:lines.Add($line)
        [void]$global:currentDrawing.Add($line)

        $global:prevX = $_.Location.X
        $global:prevY = $_.Location.Y
    }
    else {
        $global:prevX = $_.Location.X
        $global:prevY = $_.Location.Y
    }
})

$form.Add_MouseUp({
    $global:draw = 0
    $global:prevX = $null
    $global:prevY = $null
    write-host $_.Location $global:prevX $draw
})

$form.Controls.Add($trackBar)
$form.Controls.Add($EraseButton)
$form.Controls.Add($ColorButton)
$form.Controls.Add($ClearButton)
$form.Controls.Add($SaveButton)

$form.KeyPreview = $true

$form.ShowDialog()
