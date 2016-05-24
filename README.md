# RegExHelper
A UI to help with writing Regular Expressions.

This is a UI built using PowerShell and WPF that allows for simple Regular Expression checking by displaying the results in real time.

Currently this only supports a string match but future versions will allow for locating patterns in a log file or similiar groups of text.

Feedback and improvements are always welcome! Be sure to check out the Dev branch to help out with the log file regular expression helper.

You need to dot source the script to load the Invoke-RegExHelper function.
```PowerShell
. .\Invoke-RegExHelper.ps1
```

```PowerShell
Invoke-RegExHelper
```

![alt tag](https://github.com/proxb/RegExHelper/blob/master/Images/RegExHelper.png)
