function imgStack = loadTiff(imgFile, imgInfo, addWait)
imgWidth = imgInfo(1);
imgHeight = imgInfo(2);
imgNumber = imgInfo(3);
imgStack = zeros(imgHeight, imgWidth, imgNumber, 'uint16');
imgStackID = fopen(imgFile, 'r');
tstack = Tiff(imgFile);
imgStack(:,:,1) = tstack.read();
if addWait
    hWait = helpdlg('Loading image without progress. It''s faster!');
end
imgStack(:,:,1) = tstack.read();
for n = 2:imgNumber
    nextDirectory(tstack);
    imgStack(:,:,n) = tstack.read();
end
fclose(imgStackID);
if addWait
    delete(hWait)
end
end