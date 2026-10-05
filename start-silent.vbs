' 静默后台启动重定向服务（无窗口）
Set WshShell = CreateObject("WScript.Shell")
Set FSO = CreateObject("Scripting.FileSystemObject")

dir = FSO.GetParentFolderName(WScript.ScriptFullName)
WshShell.CurrentDirectory = dir

logFile = dir & "\service.log"
WshShell.Run "cmd /c node server.js >>""" & logFile & """ 2>&1", 0, False