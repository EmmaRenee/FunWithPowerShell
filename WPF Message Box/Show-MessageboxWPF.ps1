$currentdir = Split-Path $($MyInvocation.MyCommand.Path)

$xaml = @'
<Window
   xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
   xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
   Width="525"
   SizeToContent="Height"
   Title="Reboot Scheduled" Topmost="True">
    <DockPanel>
      <Canvas Background="#fff" Height="275" VerticalAlignment="top">
        <Image x:Name="Image" Height="50" Width="50" Canvas.Top="10" Canvas.Left="10" />
        <TextBlock Canvas.Left="70" TextWrapping="Wrap" Canvas.Top="10" Width="425">
          <Run FontSize="16" Text="Your system has been scheduled to reboot in 20 minutes. Please save your work! "/>
          <LineBreak/><Run FontSize="14"/><LineBreak/>
          <Run FontSize="12" TextBlock.FontWeight="Bold" Text="Why is this happening? " /><LineBreak/>
          <BulletDecorator Margin="0,10,0,10">
            <BulletDecorator.Bullet>
              <Rectangle Width="5" Height="5" Fill="Gray" />
            </BulletDecorator.Bullet>
            <TextBlock TextWrapping="Wrap" Margin="20,0,0,0">If your workstation hasn’t been rebooted within a 72hour window, you will get a notification (20min prior) reminding you to save your work and it will reboot your workstation.</TextBlock>
          </BulletDecorator>
          <BulletDecorator>
            <BulletDecorator.Bullet>
              <Rectangle Width="5" Height="5" Fill="Gray" />
            </BulletDecorator.Bullet>
            <TextBlock TextWrapping="Wrap" Margin="20,0,0,0">If you need to run something (a query, job, script, process, etc.) that will take a long time to complete (definitely overnight jobs), then reboot your workstation manually before you do start this work and you won't have to worry about the workstation rebooting for another 72hours.</TextBlock>
          </BulletDecorator>
        </TextBlock>
      </Canvas>
      <Canvas Background="#E0E0E0" Height="43" VerticalAlignment="bottom">
        <Separator Canvas.Top="0" Width="525" Margin="0" />
        <Button x:Name="AckButton" Margin="0" Canvas.Right="9" Canvas.Top="9" Padding="10,3,10,3">Acknowledge</Button>
      </Canvas>
    </DockPanel>
</Window>
'@
function Convert-XAMLtoWindow
{
    param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $XAML
    )
    
    Add-Type -AssemblyName PresentationFramework
    
    $reader = [XML.XMLReader]::Create([IO.StringReader]$XAML)
    $result = [Windows.Markup.XAMLReader]::Load($reader)
    $reader.Close()
    $reader = [XML.XMLReader]::Create([IO.StringReader]$XAML)
    while ($reader.Read())
    {
        $name=$reader.GetAttribute('Name')
        if (!$name) { $name=$reader.GetAttribute('x:Name') }
        if($name)
        {$result | Add-Member NoteProperty -Name $name -Value $result.FindName($name) -Force}
    }
    $reader.Close()
    $result
}


function Show-WPFWindow
{
    param
    (
        [Parameter(Mandatory)]
        [Windows.Window]
        $Window
    )
    
    $result = $null
    $null = $window.Dispatcher.InvokeAsync{
        $result = $window.ShowDialog()
        Set-Variable -Name result -Value $result -Scope 1
    }.Wait()
    $result
}

$window = Convert-XAMLtoWindow -XAML $xaml

$window.Icon = "$currentdir\warning_n7N_icon.ico"
$window.Image.Source = "$currentdir\facepalm.png"

$window.AckButton.add_click({
    $window.Close()
})

$window.Topmost = $true
$window.WindowStartupLocation = 'CenterScreen'

$null = Show-WPFWindow -Window $window