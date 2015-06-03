function [] = createMosaic(filename)

[XExt,YExt,Xcum,Ycum,tile_mean_R,tile_mean_G,tile_mean_B,center_tiles,tile_x_cell,tile_y_cell,count]=placeTiles(filename,10);


A=imread(filename);
[row col chan]=size(A);


tile_mean_R_norm=tile_mean_R./255;
tile_mean_G_norm=tile_mean_G./255;
tile_mean_B_norm=tile_mean_B./255;

WCanvas=col;
HCanvas=row;

XExt = [0 WCanvas WCanvas 0 0];
YExt = [HCanvas HCanvas 0 0 HCanvas];


figure
hold on


fill(XExt,YExt,[0.5 0.5 0.5])

colors=[tile_mean_R_norm;tile_mean_G_norm;tile_mean_B_norm];

for i=1:count
    fill(tile_x_cell{i},tile_y_cell{i},colors(:,i)')
    axis equal, axis off;
end    

plot(Xcum,Ycum,'color',[0.5 0.5 0.5])

end

