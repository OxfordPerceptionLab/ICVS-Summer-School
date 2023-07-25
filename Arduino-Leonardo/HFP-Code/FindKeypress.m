function [keyName, keyNumber] = FindKeypress

KeyIsDown = 0;
pause(.1);

while KeyIsDown == 0
    [KeyIsDown, ~, KeyCode] = KbCheck;
    if KeyIsDown == 1
        keyName=KbName(KeyCode);
        keyNumber = find(KeyCode == 1);
    end
end

end
