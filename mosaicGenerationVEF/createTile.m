function [x,y]=createTile(tileSize)

%calcolo del quadrato del raggio in funzione della dimensione della
%tessera.
R=sqrt((tileSize.^2)/pi);

sides=[3 4 5 6 7];

%sides=[4];
ind=randperm(length(sides));

sideNumber=sides(ind(1));


theta=360*rand(1,sideNumber);

%sort(theta)

x=R.*cosd(sort(theta));
y=R.*sind(sort(theta));

x=[x x(1)];
y=[y y(1)];

[x, y] = poly2cw(x, y);

%x=-R+2*R.*rand(1,sideNumber)

%yp=sqrt(R.^2-x.^2);

%yn=-sqrt(R.^2-x.^2);

%sely=rand(1,sideNumber)
%sely=sely>0.5
%sely=(sely-0.5).*2

%y=yp.*sely;

%[f, v] = poly2fv(x, y);
%patch('Faces', f, 'Vertices', v, 'FaceColor', 'r', 'EdgeColor', 'none')

%plot(x,y)


