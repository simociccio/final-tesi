function [XExt,YExt,Xcum,Ycum,tile_mean_R,tile_mean_G,tile_mean_B,center_tiles,tile_x_cell,tile_y_cell,count,mosaic_image]=placeTilesSquare(fileName,selectedTiles)


%selectedTiles=10;


tile_x_cell=cell(10000,1);
tile_y_cell=cell(10000,1);

tileSize=9;

R=tileSize/sqrt(2);

A=imread(fileName);
[row col chan]=size(A);


dbdir='';
NoGVFIterations=200;

[u,v] = getVEF(dbdir,fileName);

hold on;quiver(u./sqrt(u.*u + v.*v),v./sqrt(u.*u + v.*v),'k');hold off

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
data_tile=load('data_tile_square.mat');
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


bool_image=zeros(row,col);

mosaic_image=ones(row,col,3)*127;


%Area_int_border=0;

test=0;
for i=1:2:row
    i
    
    %for j=1:2:col
    next_j=1;
    while(next_j<col)  
        
        j=next_j;
        
        next_j=next_j+2;
        
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
            
            
            %controllare che non ci siano intersezioni con le altre tessere già
            %piazzate
            
            x_min=max(floor(min(new_x)),1);
            x_max=min(ceil(max(new_x)),col);
            y_min=max(floor(min(new_y)),1);
            y_max=min(ceil(max(new_y)),row);
            [x_pixels_m y_pixels_m]=meshgrid(x_min:x_max,y_min:y_max);
                       
            x_pixels_v=reshape(x_pixels_m,1,size(x_pixels_m,1)*size(x_pixels_m,2));
            y_pixels_v=reshape(y_pixels_m,1,size(y_pixels_m,1)*size(y_pixels_m,2));
            
            [in,on] = inpolygon(x_pixels_v,y_pixels_v,new_x,new_y); 
            
            curr_pixels_x=x_pixels_v(in&~on);
            curr_pixels_y=y_pixels_v(in&~on);
            
            curr_pixels_x2=x_pixels_v(in);
            curr_pixels_y2=y_pixels_v(in);
            
            
            collision=sum(diag(bool_image(curr_pixels_y,curr_pixels_x)));
            
            if (~collision)
                
                %controllare che non ci siano intersezioni con il bordo
                
                Area_int_border=0;
                if (i<R || i>(row-R) || j<R || j>(col-R))
                    [X_int_border Y_int_border] = polybool('and',XExt,YExt,new_x,new_y);
                    Area_int_border=polyarea(X_int_border,Y_int_border);
                end
            
                Area_int_cum=0;
                if (count>1)
                    
                    min_i=max(i-(round(R)+1),1);
                    max_i=min(i+(round(R)+1),row);
                    min_j=max(j-(round(R)+1),1);
                    max_j=min(j+(round(R)+1),col);
                    
                    bool_region=bool_image(min_i:max_i,min_j:max_j);
                    clear elem;
                    
                    L = logical(bool_region~=0);
                 
                    elem=unique(bool_region);
                    
                    if (elem(1)==0)
                        elem2=elem(2:end);
                    else
                        elem2=elem;
                    end
                    
                    
%                     center_x(count) = j;
%                     vett_center_x = ones(1,numel(center_x));
%                     new_center_x=vett_center_x * j;
% 
% 
%                     center_y(count)= i;
%                     vett_center_y = ones(1,numel(center_y));
%                     new_center_y=vett_center_y * i;

%                     x_vec=center_tiles(elem2,2)
%                     y_vec=center_tiles(elem2,1)
%                     
%                     dist=(new_center_x-center_x).^2+(new_center_y-center_y).^2<(2*R)^2;
%                     dist=(center_tiles(elem2,2)-i).^2+(center_tiles(elem2,1)-j).^2;
                    dist=(center_tiles(:,2)-i).^2+(center_tiles(:,1)-j).^2;
                    
                    bool_dist=dist<(2*R)^2;
                    v_index=[1:length(center_tiles)];
                    v_ind_bool=v_index(bool_dist);
                    for k_ind=v_ind_bool
                        [X_int Y_int] = polybool('and',tile_x_cell{k_ind},tile_y_cell{k_ind},new_x,new_y);
                        Area_int_cum=polyarea(X_int,Y_int);
                        if (Area_int_cum>0)
                            break
                        end
                    end
                end
                %[X_int Y_int] = polybool('and',Xcum,Ycum,new_x,new_y);
                
                %Area_int_cum=polyarea(X_int,Y_int);
                
                if ((Area_int_border==0) && (Area_int_cum==0))
                    clear Area_int_cum;
                    %[Xcum Ycum] = polybool('union',Xcum,Ycum,new_x,new_y);
                    
                    tile_x_cell{count}=new_x;
                    tile_y_cell{count}=new_y;
                    
                    %[mean_r, mean_g, mean_b] = getColor(A,new_x,new_y,j,i,tileSize);
                    mean_r = double(A(i,j,1));
                    mean_g = double(A(i,j,2));
                    mean_b = double(A(i,j,3));
                    
                    %[mean_r, mean_g, mean_b]
                    
                    
                    tile_mean_R=[tile_mean_R mean_r];
                    tile_mean_G=[tile_mean_G mean_g];
                    tile_mean_B=[tile_mean_B mean_b];
                    
                    center_tiles=[center_tiles; j i];
                    
                    
                    for k_ind=1:length(curr_pixels_x)
                        %bool_image(curr_pixels_y(k_ind),curr_pixels_x(k_ind))=1;
                        bool_image(curr_pixels_y(k_ind),curr_pixels_x(k_ind))=count;
                    end
                    
                    for k_ind=1:length(curr_pixels_x2)
                        
                        mosaic_image(curr_pixels_y2(k_ind),curr_pixels_x2(k_ind),1)=mean_r;
                        mosaic_image(curr_pixels_y2(k_ind),curr_pixels_x2(k_ind),2)=mean_g;
                        mosaic_image(curr_pixels_y2(k_ind),curr_pixels_x2(k_ind),3)=mean_b;
                    end
                    
                    
                    next_j=max(curr_pixels_x)+1;
                    
                    count=count+1;
                    
                    break
                end
                
            end
        end
    test=test+1;    
    end
end

count = count-1;

test

% figure
% imshow(uint8(mosaic_image),[])