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
    $UIHash=@{}
    #Build the GUI
    [xml]$xaml = @"
    <Window 
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    x:Name="Window" Title="Powershell Regular Expression Helper" WindowStartupLocation = "CenterScreen" ResizeMode="NoResize"
    Width = "820" Height = "625" ShowInTaskbar = "True" Background = "lightgray"> 
    <Grid > 
        <Grid.RowDefinitions>
            <RowDefinition Height="*" />
            <RowDefinition Height="Auto" />
        </Grid.RowDefinitions>
        <TabControl Grid.Row = '0'>  
            <TabItem Header = 'String RegEx'> 
                <Grid > 
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto" />
                        <RowDefinition Height="Auto" />
                        <RowDefinition Height="*" />
                    </Grid.RowDefinitions>
                    <GroupBox Header = 'Input String' Grid.Row = '0'>      
                        <TextBox x:Name="String_inpbx" Height = "30" AcceptsReturn="True"  /> 
                    </GroupBox>     
                    <GroupBox Header = 'Regular Expression String' Grid.Row = '1'>        
                        <TextBox x:Name="Regex_inpbx" Height = "30" />  
                    </GroupBox> 
                    <GroupBox Header = 'Regular Expression Matches' Grid.Row = '2'> 
                        <DataGrid x:Name='datagrid' AutoGenerateColumns='False' CanUserAddRows='False' 
                            SelectionUnit='CellOrRowHeader' AlternatingRowBackground = 'LightBlue' AlternationCount='2'>
                            <DataGrid.Columns>
                                <DataGridTextColumn Header='Group' Binding='{Binding Key}' IsReadOnly='True' Width='390'/>
                                <DataGridTextColumn Header='MatchedValue' Binding='{Binding Value}' IsReadOnly='True' Width='390'/>
                            </DataGrid.Columns>
                        </DataGrid>  
                    </GroupBox> 
                </Grid > 
            </TabItem>
            <TabItem Header = 'RegEx Log Match'>
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto" />
                        <RowDefinition Height="*" />
                        <RowDefinition Height="Auto" />
                    </Grid.RowDefinitions>
                    <GroupBox Header = 'Regular Expression String' Grid.Row = '0'>  
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>   
                            </Grid.ColumnDefinitions>   
                            <TextBox x:Name="Regex_inpbx_tb2" Height = "30" Grid.Column = '0'/>  
                            <Button x:Name= 'Highlight_btn' Content = 'Highlight' Grid.Column = '1' Width = '60'/>
                        </Grid>      
                    </GroupBox> 
                    <GroupBox Header = 'Log Data' Grid.Row = '1'>        
                        <RichTextBox x:Name="Log_tb2" IsUndoEnabled = 'False' VerticalScrollBarVisibility = 'Auto'/>
                    </GroupBox> 
                    <GroupBox Header = 'Status' Grid.Row = '2'>        
                        <Label x:Name="Status_tb2"  Content = 'Found 0 matches'/>  
                    </GroupBox> 
                </Grid>
            </TabItem>
        </TabControl>
        <GroupBox x:Name = 'RegExOptions' Header = 'Regular Expression Options' Grid.Row = '1'>
            <Grid x:Name = 'OptionsGrid'>
                <Grid.RowDefinitions>
                    <RowDefinition Height="*" />
                    <RowDefinition Height="*" />
                </Grid.RowDefinitions>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="*"/>   
                    <ColumnDefinition Width="*"/> 
                    <ColumnDefinition Width="*"/> 
                    <ColumnDefinition Width="*"/>  
                </Grid.ColumnDefinitions>      
                <CheckBox x:Name = 'None_chkbox' Grid.Column = '0' Grid.Row = '0' Content='None' ToolTip = 'Specifies that no options are set.' />
                <CheckBox Content='IgnoreCase' Grid.Column = '1' Grid.Row = '0' ToolTip = 'Specifies case-insensitive matching.' />
                <CheckBox Content='IgnorePatternWhitespace' Grid.Column = '2' Grid.Row = '0' ToolTip = 'Eliminates unescaped white space from the pattern and enables comments marked with #. However, this value does not affect or eliminate white space in , numeric , or tokens that mark the beginning of individual .'/>
                <CheckBox Content='Compiled' Grid.Column = '3' Grid.Row = '0' ToolTip = 'Specifies that the regular expression is compiled to an assembly.'/>
                <CheckBox Content='MultiLine' Grid.Column = '4' Grid.Row = '0' ToolTip = 'Multiline mode. Changes the meaning of ^ and $ so they match at the beginning and end, respectively, of any line, and not just the beginning and end of the entire string.'/>
                <CheckBox Content='CultureInvariant' Grid.Column = '0' Grid.Row = '1' ToolTip = 'Specifies that cultural differences in language is ignored.'/>
                <CheckBox Content='SingleLine' Grid.Column = '1' Grid.Row = '1' ToolTip = 'Specifies single-line mode. Changes the meaning of the dot (.) so it matches every character (instead of every character except \n).'/>
                <CheckBox Content='RightToLeft' Grid.Column = '2' Grid.Row = '1' ToolTip = 'Specifies that the search will be from right to left instead of from left to right.'/>
                <CheckBox Content='ECMAScript' Grid.Column = '3' Grid.Row = '1' ToolTip = 'Enables ECMAScript-compliant behavior for the expression. This value can be used only in conjunction with the IgnoreCase, Multiline, and Compiled values. The use of this value with any other values results in an exception.'/>
                <CheckBox Content='ExplicitCapture' Grid.Column = '4' Grid.Row = '1' ToolTip = 'Specifies that the only valid captures are explicitly named or numbered groups of the form. This allows unnamed parentheses to act as noncapturing groups without the syntactic clumsiness of the expression (?:…).'/>                        
            </Grid>
        </GroupBox>
    </Grid>
    </Window>
"@
 
        $reader=(New-Object System.Xml.XmlNodeReader $xaml)
        $UIHash.Window=[Windows.Markup.XamlReader]::Load( $reader )

        #Connect to Controls
        $xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]") | ForEach {
            $uiHash[$_.Name] = $UIHash.Window.FindName($_.Name)
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
                    If (($Regex_inpbx.text.length -gt 0) -AND ($String_inpbx.Text.length -gt 0)) {
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
                    $None_chkbox.IsChecked = $True
                    $Script:observableCollection.Clear()
                } 
            }  
            $script:i--         
        } 
        $uiHash.OptionsGrid.AddHandler([System.Windows.Controls.CheckBox]::CheckedEvent, $CheckBoxCheck)
        $uiHash.OptionsGrid.AddHandler([System.Windows.Controls.CheckBox]::UncheckedEvent, $CheckBoxCheck)

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

        <#
        $UIHash.Regex_inpbx_tb2.Add_TextChanged({ 
            $StopWatch = New-Object System.Diagnostics.Stopwatch
            $DocumentRange = New-Object System.Windows.Documents.TextRange -ArgumentList $UIHash.Log_tb2.Document.ContentStart,$UIHash.Log_tb2.Document.ContentEnd
            $DocumentRange.ClearAllProperties()
            $Colors = 'Orange','Yellow'
            $i=0
            If ($UIHash.Regex_inpbx_tb2.Text.length -gt 0 -AND $UIHash.Log_tb2.Document.Blocks.Inlines.Text.length -gt 0) {   
                [System.Text.RegularExpressions.RegexOptions]$Script:Options = 'None'
                $UIHash.Log_tb2.BeginChange() 
                Try {
                    $Regex = New-Object System.Text.RegularExpressions.Regex -ArgumentList $uiHash.Regex_inpbx_tb2.text, $Script:Options
                    $Pointer = $UIHash.Log_tb2.Document.ContentStart  
                    $StopWatch.Start()                                                         
                    While ($Pointer -ne $Null) {                        
                        $Context = $Pointer.GetPointerContext([System.Windows.Documents.LogicalDirection]::Forward)
                        If ($Context -eq [System.Windows.Documents.TextPointerContext]::Text) {
                            $TextRun = $Pointer.GetTextInRun([System.Windows.Documents.LogicalDirection]::Forward)                            
                            $Match = $Regex.Match($TextRun)
                            $Start = $Pointer.GetPositionAtOffset(($Match.Index),([System.Windows.Documents.LogicalDirection]::Forward))
                            $End = $Pointer.GetPositionAtOffset((($Match.Index+$Match.Length)),([System.Windows.Documents.LogicalDirection]::Backward))
                            $TextRange = New-Object System.Windows.Documents.TextRange -ArgumentList $Start,$End
                            $TextRange.ApplyPropertyValue([System.Windows.Documents.TextElement]::BackgroundProperty, $Colors[$i%2])
                            $Pointer = $TextRange.End
                            $i++                            
                        }
                        $Pointer = $Pointer.GetNextContextPosition([System.Windows.Documents.LogicalDirection]::Forward)  
                    }  
                    Write-Verbose "$($StopWatch.Elapsed)" -Verbose                                     
                }
                Catch {$UIHash.Status_tb2.Content = ("Found {0} matches" -f 0)}
                Finally {
                    $UIHash.Log_tb2.EndChange()
                    $StopWatch.Stop()
                }
                $UIHash.Status_tb2.Content = ("Found {0} matches" -f $i)
            } 
            Else {
                $UIHash.Status_tb2.Content = ("Found {0} matches" -f 0)
            }
        })
        #>

        $uihash.Highlight_btn.Add_Click({
            $StopWatch = New-Object System.Diagnostics.Stopwatch
            $DocumentRange = New-Object System.Windows.Documents.TextRange -ArgumentList $UIHash.Log_tb2.Document.ContentStart,$UIHash.Log_tb2.Document.ContentEnd
            $StopWatch.Start()
            
            $DocumentRange.ClearAllProperties()
            Write-Verbose "$($StopWatch.Elapsed)" -Verbose 
            $StopWatch.Restart()
            $Colors = 'Orange','Yellow'
            $i=0
            If ($UIHash.Regex_inpbx_tb2.Text.length -gt 0 -AND $UIHash.Log_tb2.Document.Blocks.Inlines.Text.length -gt 0) {   
                [System.Text.RegularExpressions.RegexOptions]$Script:Options = 'None'                 
                Try {
                    $UIHash.Log_tb2.BeginChange()
                    #$Paragraph = $uihash.Log_tb2.Document.Blocks
                    #$UIHash.Log_tb2.Document.Blocks.Clear()
                    $Regex = New-Object System.Text.RegularExpressions.Regex -ArgumentList $uiHash.Regex_inpbx_tb2.text, $Script:Options
                    $Pointer = $UIHash.Log_tb2.Document.ContentStart                                                                              
                    While ($Pointer -ne $Null) {   
                        $Context = $Pointer.GetPointerContext([System.Windows.Documents.LogicalDirection]::Forward)
                        If ($Context -eq [System.Windows.Documents.TextPointerContext]::Text) {
                            $TextRun = $Pointer.GetTextInRun([System.Windows.Documents.LogicalDirection]::Forward)                            
                            $Match = $Regex.Match($TextRun)
                            $Start = $Pointer.GetPositionAtOffset(($Match.Index),([System.Windows.Documents.LogicalDirection]::Forward))
                            $End = $Pointer.GetPositionAtOffset((($Match.Index+$Match.Length)),([System.Windows.Documents.LogicalDirection]::Backward))
                            $TextRange = New-Object System.Windows.Documents.TextRange -ArgumentList $Start,$End
                            $TextRange.ApplyPropertyValue([System.Windows.Documents.TextElement]::BackgroundProperty, $Colors[$i%2])
                            $Pointer = $TextRange.End   
                            $i++                    
                        }
                        $Pointer = $Pointer.GetNextContextPosition([System.Windows.Documents.LogicalDirection]::Forward) 
                    }  
                    Write-Verbose "$($StopWatch.Elapsed)" -Verbose     
                } 
                Catch {$UIHash.Status_tb2.Content = ("Found {0} matches" -f 0)}
                Finally {
                    #$UIHash.Log_tb2.Document.Blocks.Add($Paragraph)
                    $UIHash.Log_tb2.EndChange()
                    $StopWatch.Stop()
                }
                $UIHash.Status_tb2.Content = ("Found {0} matches" -f $i)
            } 
            Else {
                $UIHash.Status_tb2.Content = ("Found {0} matches" -f 0)
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
}

#New-Alias -Name RegEx -Value Invoke-RegExHelper