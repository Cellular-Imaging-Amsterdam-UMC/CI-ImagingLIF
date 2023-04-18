function imout=cfAutocontrast(im)
    imout=imadjust(im,stretchlim(nonzeros(im),[0.01 0.9995]),[]);
end