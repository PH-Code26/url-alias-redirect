' 静默后台启动重定向服务（无窗口）
Set WshShell = CreateObject("WScript.Shell")
Set FSO = CreateObject("Scripting.FileSystemObject")

dir = FSO.GetParentFolderName(WScript.ScriptFullName)
WshShell.CurrentDirectory = dir

WshShell.Run "node server.js", 0, False