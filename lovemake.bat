del /q game.zip
echo CHANGE PATH TO love.exe
powershell.exe -nologo -noprofile -command "& { Compress-Archive -Path main.lua, mgesture.lua, Ball.jpg, Enemy.png, Wizard.jpg, magic.lua, Fireball.png, palka.png -CompressionLevel Optimal -DestinationPath game.zip; cmd /c "copy /b C:\love-11.1.0-win64\love.exe+game.zip game.exe" ; }"
pause
