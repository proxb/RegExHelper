Function Invoke-RegExHelper {
    <#
        .SYNOPSIS
            Tool to help with writing Regular Expressions

        .DESCRIPTION
            Tool to help with writing Regular Expressions

        .NOTES
            Name: Invoke-RegExHelper
            Author: Boe Prox
            Version History:
                1.0 //Boe Prox - 22 Mar 2016
                    - Initial version

        .EXAMPLE
            Invoke-RegExHelper

            Description
            -----------
            Launches the Regular Expression tool
    #>

    $Script:uiHash = [hashtable]::Synchronized(@{})
    $Script:runspaceHash = [hashtable]::Synchronized(@{})
    $Runspacehash.runspace = [RunspaceFactory]::CreateRunspace()
    $Runspacehash.runspace.ApartmentState = "STA"
    $Runspacehash.runspace.Open() 
    $Runspacehash.runspace.SessionStateProxy.SetVariable("Runspacehash",$Runspacehash)
    $Runspacehash.runspace.SessionStateProxy.SetVariable("uiHash",$uiHash)
    $Runspacehash.PowerShell = {Add-Type -AssemblyName PresentationCore,PresentationFramework,WindowsBase}.GetPowerShell() 
    $Runspacehash.PowerShell.Runspace = $Runspacehash.runspace 
    $Runspacehash.Handle = $Runspacehash.PowerShell.AddScript({ 
        #Build the GUI
        [xml]$xaml = @"
    <Window 
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    x:Name="Window" Title="Powershell Regular Expression Helper" WindowStartupLocation = "CenterScreen" ResizeMode="NoResize"
    Width = "820" Height = "625" ShowInTaskbar = "True" Background = "lightgray"> 
    <StackPanel >    
        <GroupBox Header = 'Input String'>      
            <TextBox x:Name="String_inpbx" Height = "30" /> 
        </GroupBox>     
        <GroupBox Header = 'Regular Expression String'>        
            <TextBox x:Name="Regex_inpbx" Height = "30" />  
        </GroupBox> 
        <GroupBox Header = 'Regular Expression Matches'>      
            <DataGrid x:Name='datagrid' Height='400' AutoGenerateColumns='False' CanUserAddRows='False' 
                SelectionUnit='CellOrRowHeader' AlternatingRowBackground = 'LightBlue' AlternationCount='2'>
                <DataGrid.Columns>
                    <DataGridTextColumn Header='Group' Binding='{Binding Key}' IsReadOnly='True' Width='390'/>
                    <DataGridTextColumn Header='MatchedValue' Binding='{Binding Value}' IsReadOnly='True' Width='390'/>
                </DataGrid.Columns>
            </DataGrid>  
        </GroupBox>
        <GroupBox x:Name = 'RegExOptions' Header = 'Regular Expression Options'>
            <WrapPanel x:Name='wrap_panel' Orientation = 'Horizontal' ItemWidth = '155'>
                <CheckBox x:Name = 'None_chkbox' Content='None' ToolTip = 'Specifies that no options are set.'/>
                <CheckBox Content='IgnoreCase' ToolTip = 'Specifies case-insensitive matching.'/>
                <CheckBox Content='IgnorePatternWhitespace' ToolTip = 'Eliminates unescaped white space from the pattern and enables comments marked with #. However, this value does not affect or eliminate white space in , numeric , or tokens that mark the beginning of individual .'/>
                <CheckBox Content='Compiled' ToolTip = 'Specifies that the regular expression is compiled to an assembly.'/>
                <CheckBox Content='MultiLine' ToolTip = 'Multiline mode. Changes the meaning of ^ and $ so they match at the beginning and end, respectively, of any line, and not just the beginning and end of the entire string.'/>
                <CheckBox Content='CultureInvariant' ToolTip = 'Specifies that cultural differences in language is ignored.'/>
                <CheckBox Content='SingleLine' ToolTip = 'Specifies single-line mode. Changes the meaning of the dot (.) so it matches every character (instead of every character except \n).'/>
                <CheckBox Content='RightToLeft' ToolTip = 'Specifies that the search will be from right to left instead of from left to right.'/>
                <CheckBox Content='ECMAScript' ToolTip = 'Enables ECMAScript-compliant behavior for the expression. This value can be used only in conjunction with the IgnoreCase, Multiline, and Compiled values. The use of this value with any other values results in an exception.'/>
                <CheckBox Content='ExplicitCapture' ToolTip = 'Specifies that the only valid captures are explicitly named or numbered groups of the form. This allows unnamed parentheses to act as noncapturing groups without the syntactic clumsiness of the expression (?:…).'/>                        
            </WrapPanel>
        </GroupBox>
    </StackPanel>
    </Window>
"@
 
        $reader=(New-Object System.Xml.XmlNodeReader $xaml)
        $Window=[Windows.Markup.XamlReader]::Load( $reader )

        #Connect to Controls
        $xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]") | ForEach {
            $uiHash[$_.Name] = $Window.FindName($_.Name)
        }

        #Starting Configuration
        [System.Text.RegularExpressions.RegexOptions]$Script:Options = 'None' 
        $uiHash.None_chkbox.IsChecked = $True
        $Script:i=0

        #Events
        [System.Windows.RoutedEventHandler]$Script:CheckBoxCheck = {
            $script:i++
                If ($script:i -eq 1) {
                $RoutedEvent = $_
                Write-Verbose "$($RoutedEvent.routedevent.Name) <$($RoutedEvent.originalsource.content)>"
                If ($RoutedEvent.RoutedEvent.Name -eq 'Checked' -AND $RoutedEvent.originalsource.content -ne 'None') {
                    $uiHash.None_chkbox.IsChecked = $False
                }
                $CheckBoxes = $This.Children
                $Checked = $CheckBoxes | Where {$_.IsChecked} | Select-Object -ExpandProperty Content
                $UnChecked = $CheckBoxes | Where {-NOT $_.IsChecked} | Select-Object -ExpandProperty Content
                Try {
                    If ($Checked -contains 'None') {
                        [System.Text.RegularExpressions.RegexOptions]$Script:Options = 'None'
                        $This.Children | ForEach {
                            If ($_.IsChecked -AND $_.Content -ne 'None') {
                                $_.IsChecked = $False
                            }
                        }
                    } Else {
                        [System.Text.RegularExpressions.RegexOptions]$Script:Options = $Checked -join ', '
                    }  
                }
                Catch {            
                    $uiHash.None_chkbox.IsChecked = $True
                    [System.Text.RegularExpressions.RegexOptions]$Script:Options = 'None'
                }  
                Write-Verbose "Options: $Options"
                Try {
                    Write-Verbose 'Attempting regex check'
                    If (($uiHash.Regex_inpbx.text.length -gt 0) -AND ($uiHash.String_inpbx.Text.length -gt 0)) {
                        $Regex = New-Object System.Text.RegularExpressions.Regex -ArgumentList $uiHash.Regex_inpbx.text, $Script:Options

                        If ($uiHash.String_inpbx.Text -match $Regex){
                            $Script:observableCollection.Clear()
                            ForEach ($Item in ($Matches.GetEnumerator())) {
                                $Script:observableCollection.Add($Item)
                            }
                        } Else {
                            $Script:observableCollection.Clear()
                        }
                    } 
                    Else {
                        $Script:observableCollection.Clear()
                    }
                }
                Catch {
                    $uiHash.None_chkbox.IsChecked = $True
                    $Script:observableCollection.Clear()
                } 
            }  
            $script:i--         
        } 
        $uiHash.wrap_panel.AddHandler([System.Windows.Controls.CheckBox]::CheckedEvent, $CheckBoxCheck)
        $uiHash.wrap_panel.AddHandler([System.Windows.Controls.CheckBox]::UncheckedEvent, $CheckBoxCheck)

        $uiHash.Regex_inpbx.Add_TextChanged({
            Try {
                If (($uiHash.Regex_inpbx.text.length -gt 0) -AND ($uiHash.String_inpbx.Text.length -gt 0)) {
                    $Regex = New-Object System.Text.RegularExpressions.Regex -ArgumentList $uiHash.Regex_inpbx.text, $Script:Options

                    If ($uiHash.String_inpbx.Text -match $Regex){
                        $Script:observableCollection.Clear()
                        ForEach ($Item in ($Matches.GetEnumerator())) {
                            $Script:observableCollection.Add($Item)
                        }
                    } Else {
                        $Script:observableCollection.Clear()
                    }
                } 
                Else {
                    $Script:observableCollection.Clear()
                }
            }
            Catch {
                $Script:observableCollection.Clear()
            }      
        })

        $uiHash.String_inpbx.Add_TextChanged({
            Try {
                If (($uiHash.Regex_inpbx.text.length -gt 0) -AND ($uiHash.String_inpbx.Text.length -gt 0)) {
                    $Regex = New-Object System.Text.RegularExpressions.Regex -ArgumentList $uiHash.Regex_inpbx.text, $Script:Options

                    If ($uiHash.String_inpbx.Text -match $Regex){
                        $Script:observableCollection.Clear()
                        ForEach ($Item in ($Matches.GetEnumerator())) {
                            $Script:observableCollection.Add($Item)
                        }
                    } Else {
                        $Script:observableCollection.Clear()
                    }
                } 
                Else {
                    $Script:observableCollection.Clear()
                }
            }
            Catch {
                $Script:observableCollection.Clear()
            }      
        })

        $uiHash.Window.Add_SourceInitialized({
            $Script:observableCollection = New-Object System.Collections.ObjectModel.ObservableCollection[object]
            $uiHash.datagrid.ItemsSource = $observableCollection   
        })


        $uiHash.Window.Add_Activated({        
            $uiHash.String_inpbx.Focus()
        })
        [void]$uiHash.Window.ShowDialog()
    }).BeginInvoke()
}

New-Alias -Name RegEx -Value Invoke-RegExHelper