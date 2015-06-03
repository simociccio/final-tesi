function [x_v,y_v,orientations]=createAllTiles(tileSize)

N=1000;

x_v=cell(N,1);
y_v=cell(N,1);
orientations=zeros(N,1);

for i=1:N
    
    [x,y]=createTile(tileSize);
    
    while (polyarea(x,y)<(tileSize^2)/2)
        [x,y]=createTile(tileSize);
    end
    
    %polyarea(x,y)
    
    min_x=min(x);
    max_x=max(x);
    
    min_y=min(y);
    max_y=max(y);
    
    h=figure;
    [f, v] = poly2fv(x, y);
    patch('Faces', f, 'Vertices', v, 'FaceColor', 'k', 'EdgeColor', 'none')
    axis equal, axis off, axis([min_x max_x min_y max_y])
    
    print('-dpng', 'tile.png');
    
    close(h)
    
    img=imread('tile.png');
    
    img_gray=rgb2gray(img);
    
    img_gray_bool=img_gray>0;
    
    tile_bool=not(img_gray);
    
    stats  = regionprops(tile_bool,'Orientation');
    
    orientation=stats.Orientation;
    
    x_v{i}=x;
    y_v{i}=y;
    orientations(i)=orientation;
      
end

save data_tile x_v y_v orientations 