function [fx, fy] = VEF(f, rx,ry,rz)
% reference:
%  Hyun Keun Park and Myung Jin Chung, External force of snake: virtual electric field,IEE Electronics Letters,38(24)1500-1502, 2002
%  Dan Yuan, Siwei Lu, Simulated static electric field (SSEF) snake for deformable models,IEEE ICIP, 83-86, 2002
%  Zhanjun Yue, Ardeshir Goshtasby, Laurens V Ackerman, Automatic detection of rib borders in chest radiographs, IEEE trans Med. Imag., 14(3):525-536, 1995
%  Andrei C. Jalba, M.H.F. Wilkinson, and J.B.T.M. Roerdink, CPM: A Deformable Model for Shape Recovery and Segmentation Based on Charged Particles, IEEE TPAMI, 26(10) 1320-1335, 2004
%  Andrew DJ Cross, Edwin R. Hancock, scale space vector fields for symmetry detection, IVC, 17:337-345,1999
%  CONVEF is an extension of the VEF, therefore, the CONVEF can be implemented by adjust the parameters of VEF in this function.

[m,n] = size(f);
fmin  = min(f(:));
fmax  = max(f(:));
f = (f-fmin)/(fmax-fmin);  

flag89 = 1;% Using eq.8 or eq.9, if 1, Eq.8.
n = 1;

if flag89 == 1,
    [Mx,My] = createMaskEq8(rx,ry,0,n);%这个是VFC模型中的公式8，我们修改后加了rz即理论模型CONVEF中的参数"h"
else
    %-----------------Gaussian Blur for TIP paper revision,2011/03/27----------
    kesi = rz;
    [Mx,My] = createMaskEq9(rx,ry,kesi);%这个VFC模型中的公式9，不是我们修改后的CONVEF
    %-----------------Gaussian Blur for TIP paper revision,2011/03/27 end------
end

fx = xconv2(f,Mx);
fy = xconv2(f,My);

% fprintf(1,'  in VEF, rx [%d], ry [%d]\n', rx,ry);


function [Mx,My] = createMaskEq8(rx,ry,rz,n)%
fprintf('sono in 8');
Rx = floor(rx) - 1;
Ry = floor(ry) - 1;
i = -Ry:Ry;
j = -Rx:Rx;
im = repmat(i',1,2*Rx+1);
jm = repmat(j,2*Ry+1,1);
rzz = ones(2*Ry+1,2*Rx+1).*rz;

Mx(i+ Ry+1,j+Rx+1) = -jm./power(im.*im + jm.*jm + rzz,1+ 0.5*(n));%  n=2.6 for 3 shape
My(i+ Ry+1,j+Rx+1) = -im./power(im.*im + jm.*jm + rzz,1+ 0.5*(n)); % 1 + 0.5*(n), sqrt is absent due to computation cost.

Mx(Ry+1,Rx+1) = 0;
My(Ry+1,Rx+1) = 0;

% for i = -Ry:Ry,
%     for j = -Rx:Rx,
%         if i == 0 & j == 0,
%             Mx(i+ Ry+1,j+Rx+1) = 0;
%             My(i+ Ry+1,j+Rx+1) = 0;           
%             continue;
%         end
%         Mx(i+ Ry+1,j+Rx+1) = -j/power(sqrt(i*i + j*j + rz),4.);
%         My(i+ Ry+1,j+Rx+1) = -i/power(sqrt(i*i + j*j + rz),4.);
%     end
% end

function [Mx,My] = createMaskEq9(rx,ry,kesi)
fprintf('sono in 9');
Rx = floor(rx) - 1;
Ry = floor(ry) - 1;

for i = -Ry:Ry
    for j = -Rx:Rx,
        if i == 0 & j == 0,
            Mx(i+ Ry+1,j+Rx+1) = 0;
            My(i+ Ry+1,j+Rx+1) = 0;           
            continue;
        end
        m2 = exp(-(i*i + j*j )/kesi^2.0);
        Mx(i+ Ry+1,j+Rx+1) = -j/sqrt(i*i + j*j )*m2;
        My(i+ Ry+1,j+Rx+1) = -i/sqrt(i*i + j*j )*m2;
   end
end

function Y = xconv2(I,G)
[n,m] = size(I);
[n1,m1] = size(G);
FI = fft2(I,n+n1-1,m+m1-1);  
FG = fft2(G,n+n1-1,m+m1-1);
FY = FI.*FG;
YT = real(ifft2(FY));
nl = floor(n1/2);
ml = floor(m1/2);
Y = YT(1+nl:n+nl,1+ml:m+ml);
