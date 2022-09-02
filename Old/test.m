function imageArray = testImageWriting
% Draws an oval in the top left corner of the screen, and outputs a jpg image
% of that dot. 

try
    wPtr = Screen('OpenWindow', 0);
    HideCursor;

    Screen('FillRect', wPtr, 0);
    Screen(wPtr, 'Flip');
    white = WhiteIndex(wPtr);

    % Draws the display to be turned into an image file
    a = [100 100 150 150]';
    b = [100 200 150 200]';
    ovalSpecs = [a b];
    Screen('FillOval', wPtr, white, ovalSpecs );
    Screen(wPtr, 'Flip');

    % GetImage call. Alter the rect argument to change the location of the screen shot
    imageArray = Screen('GetImage', wPtr, [0 0 300 300]);

    % imwrite is a Matlab function, not a PTB-3 function
    imwrite(imageArray, 'test.jpg')

    WaitSecs(.5);
    ShowCursor;
    Screen('CloseAll');

catch
    ShowCursor;
    Screen('CloseAll');

end