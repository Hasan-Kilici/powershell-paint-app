[reflection.assembly]::LoadWithPartialName( "System.Windows.Forms")
[reflection.assembly]::LoadWithPartialName( "System.Drawing")

$mypen = new-object Drawing.Pen black
$mypen.color = "red"

$draw = 0
$penWidth = 1
$penHeight = 1
$prevX = $null
$prevY = $null

$form = New-Object Windows.Forms.Form
$form.Text = "Paint"
$form.ClientSize = New-Object System.Drawing.Size(600, 600)

$formGraphics = $form.createGraphics()

$ColorButton = New-Object System.Windows.Forms.Button 
$ColorButton.Location = New-Object System.Drawing.Point(10,10)
$ColorButton.Size = New-Object System.Drawing.Size(150,20)
$ColorButton.Text = "Choose Pen color"

$ColorButton.Add_Click({
    $global:penWidth = 1;
    $colorDialog = New-Object System.Windows.Forms.ColorDialog
    $colorDialog.ShowDialog() | Out-Null
    $mypen.color = $colorDialog.Color
})

$EraseButton = New-Object System.Windows.Forms.Button
$EraseButton.Location = New-Object System.Drawing.Point(150,10)
$EraseButton.Size = New-Object System.Drawing.Size(100,20)
$EraseButton.Text = "Eraser"

$EraseButton.Add_Click({
    $global:penWidth = 10;
    $mypen.color = "White"
    $mypen.width = $global:penWidth
})

$SizeButton1 = New-Object System.Windows.Forms.Button
$SizeButton1.Location = New-Object System.Drawing.Point(250,10)
$SizeButton1.Size = New-Object System.Drawing.Size(100,20)
$SizeButton1.Text = "1px Pen"

$SizeButton1.Add_Click({
    $global:penWidth = 1
    $global:penHeight = 1
})

$SizeButton2 = New-Object System.Windows.Forms.Button
$SizeButton2.Location = New-Object System.Drawing.Point(350,10)
$SizeButton2.Size = New-Object System.Drawing.Size(100,20)
$SizeButton2.Text = "3px Pen"

$SizeButton2.Add_Click({
    $global:penWidth = 3
    $global:penHeight = 3
})

$SizeButton3 = New-Object System.Windows.Forms.Button
$SizeButton3.Location = New-Object System.Drawing.Point(450,10)
$SizeButton3.Size = New-Object System.Drawing.Size(100,20)
$SizeButton3.Text = "5px Pen"

$SizeButton3.Add_Click({
    $global:penWidth = 5
    $global:penHeight = 5
})

$selectedPenWidth = $comboBox.SelectedItem
$penHeight = $selectedPenWidth
$penWidth = $selectedPenHeight
Write-Host "Selected Option: $selectedPenWidth"

$form.Add_MouseDown({
    $global:draw = 1
    write-host $_.Location $prevX $prevY $draw
    $prevX = $_.Location.X
    $prevY = $_.Location.Y
})

$form.Add_MouseMove({
    if($global:draw){
        $mypen.width = $global:penWidth
        $formGraphics.DrawLine($mypen,$_.Location.X-$penHeight,$_.Location.Y-$penHeight, $_.Location.X, $_.Location.Y-10)
        $prevX = $_.Location.X
        $prevY = $_.Location.Y
    }
})

$form.Add_MouseUp({
    $global:draw = 0
    $prevX = $null
    $prevY = $null
    write-host $_.Location $prev $draw
})

$form.Controls.Add($EraseButton)
$form.Controls.Add($ColorButton)
$form.Controls.Add($SizeButton1)
$form.Controls.Add($SizeButton2)
$form.Controls.Add($SizeButton3)

$form.ShowDialog()
