REM # Name: Windows Product Key lookup
REM # Author: TripodGG
REM # Purpose: Extract the Windows product key from the registry, then decrypt it so it is readable, from a vbs
REM # License: MIT License, Copyright (c) 2024 TripodGG



REM # Define the shell to be used
Set WshShell = CreateObject("WScript.Shell")

REM # Find the product key in the registry
MsgBox ConvertToKey(WshShell.RegRead("HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DigitalProductId"))

REM # Function to decrypt the product key
Function ConvertToKey(Key)
Const KeyOffset = 52
i = 28
Chars = "BCDFGHJKMPQRTVWXY2346789"
Do
Cur = 0
x = 14
Do
Cur = Cur * 256
Cur = Key(x + KeyOffset) + Cur
Key(x + KeyOffset) = (Cur \ 24) And 255
Cur = Cur Mod 24
x = x -1
Loop While x >= 0
i = i -1
KeyOutput = Mid(Chars, Cur + 1, 1) & KeyOutput
If (((29 - i) Mod 6) = 0) And (i <> -1) Then
i = i -1
KeyOutput = "-" & KeyOutput
End If
Loop While i >= 0
ConvertToKey = KeyOutput
End Function