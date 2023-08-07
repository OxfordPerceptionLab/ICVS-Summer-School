function keyName = FindKeypress

KeyIsDown = 0;
pause(.1);

while KeyIsDown == 0
    [KeyIsDown, ~, KeyCode] = KbCheck;
    if KeyIsDown == 1
        keyName=KbName(KeyCode);
    end
end

end
