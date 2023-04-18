function [imout] = cfMaxprojection(im)
    if ndims(im)==3
        imout=transpose(max(im,[],3));
    else
        imout=im;
    end 
end

