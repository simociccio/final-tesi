function [XExt,YExt,Xcum,Ycum,tile_mean_R,tile_mean_G,tile_mean_B,center_tiles,tile_x_cell,tile_y_cell,count]=placeTiles(fileName,selectedTiles)


%selectedTiles=10;

tile_x_cell=cell(10000,1);
tile_y_cell=cell(10000,1);

tileSize=9;

A=imread(fileName);
[row col chan]=size(A);

dbdir='';
NoGVFIterations=200;

[u,v]=getGVFField(dbdir,fileName,NoGVFIterations);


%a partire dal campo vettoriale prodotto dal GVF calcola gli orientamenti e
%li riporta in un intervallo [-90 90]
angle=atan2(v,u);
bool_gt_90=(angle>(pi/2));
bool_lt_90=(angle<-(pi/2));
bool_other=not(bool_gt_90 | bool_lt_90);
new_angle=((angle-pi).*bool_gt_90)+((angle+pi).*bool_lt_90)+angle.*bool_other;
new_angle=new_angle.*(180/pi);

bool_gt0=new_angle>0;
new_angle=(new_angle-90).*bool_gt0+(new_angle+90).*not(bool_gt0);



%legge i dati relativi ai tasselli
data_tile=load('data_tile.mat');
x_v=data_tile.x_v;
y_v=data_tile.y_v;
orientations=data_tile.orientations;
tileNumber=length(orientations);

%crea il bordo dell'immagine (in modo da non permettere alle tessere di 
%essere posizionate fuori dall'immagine)
WCanvas=col;
HCanvas=row;
maxDim=30;

[XExt YExt] = polybool('-',[-maxDim WCanvas+maxDim WCanvas+maxDim -maxDim -maxDim]',[HCanvas+maxDim HCanvas+maxDim -maxDim -maxDim HCanvas+maxDim]',[0 WCanvas WCanvas 0 0]',[HCanvas HCanvas 0 0 HCanvas]');
exterior_canvas=[XExt YExt];

% plot(exterior_canvas(:,1),exterior_canvas(:,2))

Xcum=[];
Ycum=[];

tile_mean_R=[];
tile_mean_G=[];
tile_mean_B=[];

center_tiles=[];



count=1;

elem_per_row=round(col/tileSize.*1.5);


for i=1:2:row
    i
    for j=1:2:col
        %orientare il tassello in base alla direzione fornita dal GVF nel
        %punto (TO DO da valutare l'effetto di prendere la direzione ortogonale)
        cur_angle=new_angle(i,j);
        
        %considera tutte le tile precomputate
        for k=1:selectedTiles
            ind=randperm(tileNumber);
            x=x_v{ind(k)};
            y=y_v{ind(k)};
                        
            %[x, y] = poly2cw(x_v{ind(k)}, y_v{ind(k)});
            orientation=orientations(ind(k));
            
            %calcola l'angolo tale da allineare il tassello alla direzione
            %proposta dal GVF
            mov_angle=cur_angle-orientation;
            %calcola le nuove coordinate (rotazione)
            new_x=x.*cosd(mov_angle)-y.*sind(mov_angle);
            new_y=x.*sind(mov_angle)+y.*cosd(mov_angle);
            
            %traslazione nel punto in cui tentare di mettere il tassello
            new_x=new_x+j;
            new_y=new_y+i;
            
            %controllare che non ci siano intersezioni con il bordo
            [X_int_border Y_int_border] = polybool('and',XExt,YExt,new_x,new_y);
            
            Area_int_border=polyarea(X_int_border,Y_int_border);
            
            %controllare che non ci siano intersezioni con le altre tessere già
            %piazzate
            
            [X_int Y_int] = polybool('and',Xcum,Ycum,new_x,new_y);
            
            Area_int_cum=polyarea(X_int,Y_int);
            
            if ((Area_int_border==0) && (Area_int_cum==0))
                
                [Xcum Ycum] = polybool('union',Xcum,Ycum,new_x,new_y);
                                             
                tile_x_cell{count}=new_x;
                tile_y_cell{count}=new_y;
                
                [mean_r, mean_g, mean_b] = getColor(A,new_x,new_y,j,i,tileSize);
                
                tile_mean_R=[tile_mean_R mean_r];
                tile_mean_G=[tile_mean_G mean_g];
                tile_mean_B=[tile_mean_B mean_b];
                
                center_tiles=[center_tiles; j i];
                
                count=count+1;

                break
            end
            
        end
        
    end
end

count = count-1;