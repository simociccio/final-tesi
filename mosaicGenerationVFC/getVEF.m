function Fext=getVEF(dbdir,filename)

outPath='';

%close all;
% mu=0.1;
sigma=0;

enddot = max(find(filename== '.'));
suffix = filename(enddot+1:enddot+3);

A=imread(filename);
[row col chan]=size(A);
rx=row;
ry=col;

if (strcmp(suffix,'pgm'))||(strcmp(suffix,'raw'))
    imageGray = rawread([dbdir,filename]);
else
    if (strcmp(suffix,'jpg') || strcmp(suffix,'bmp') || strcmp(suffix,'hdf') || strcmp(suffix,'pcx') || strcmp(suffix,'tif') || strcmp(suffix,'png'))
        origImage = imread([dbdir,filename]);
        imageGray=origImage(:,:,1);
    end
end

[ysize,xsize]=size(imageGray);
imageGrayDouble=double(imageGray);
maxvalue=max(max(imageGrayDouble,[],2));
imageGrayDouble = 1 - imageGrayDouble/maxvalue;


% if (sum(sum(imageGrayDouble-imageGrayDouble.^2),2)>xsize*ysize/255)
%     GradientOn=1;
% else
%     GradientOn=0;
% end;

if sigma~=0
    f = gaussianBlur(imageGrayDouble,sigma);
else
    f = imageGrayDouble;
end;

% if GradientOn
%     imageGradient = abs(gradient2(f));
% else
%     imageGradient = f;
% end;


%disp(['Iter:',num2str(indIter)]);
% [u,v] = GVF(imageGradient, mu, NoGVFIterations);
% [u,v] = VEF(f, rx,ry,1);
K = AM_VFK(2, ry,'power',1.8);
Fext = AM_VFC(f, K, 1);
%    u=-u;
%    v=-v;

%mag = sqrt(u.*u+v.*v);
%pxn = u./(mag+1e-10); pyn = v./(mag+1e-10);
%px=u; py=v;



end
            
            