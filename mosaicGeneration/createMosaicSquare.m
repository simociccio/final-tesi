function [] = createMosaicSquare(filename)

[XExt,YExt,Xcum,Ycum,tile_mean_R,tile_mean_G,tile_mean_B,center_tiles,tile_x_cell,tile_y_cell,count,raster_image]=placeTilesSquare(filename,1);

tile_x_cell = tile_x_cell(~cellfun(@isempty, tile_x_cell));
tile_y_cell = tile_y_cell(~cellfun(@isempty, tile_y_cell));
x={};
y={};
points={};
arr={};
A=imread(filename);
[row col chan]=size(A);
lunghezza = num2str(row);
larghezza = num2str(col);
view_box = strcat('-4 -4',{' '},lunghezza, {' '}, larghezza);

for i=1:length(tile_x_cell)
    b=tile_x_cell{i};
    c=tile_y_cell{i};
    clear x;
    clear y;
    for j=1:length(b)
       x{j} = num2str(b(j));  
       y{j} = num2str(c(j));
       if j==length(b)
         mean_r = num2str(tile_mean_R(i));
         mean_g = num2str(tile_mean_G(i));
         mean_b = num2str(tile_mean_B(i));
         points{i} = strcat(x, {','}, y, {' '});
         colors{i} = strcat('fill:rgb(', mean_r, ',', mean_g, ',',mean_b,')');
       end
    end
     colors{i};
     arr{i}=strjoin(points{i});
end

docNode = com.mathworks.xml.XMLUtils.createDocument... ;
    ('svg')
svg_node=docNode.getDocumentElement;

svg_node.setAttribute('style','background: grey');
svg_node.setAttribute('preserveAspectRatio','xMinYMin meet');
svg_node.setAttribute('width',larghezza);
svg_node.setAttribute('height',lunghezza);
svg_node.setAttribute('version','1.1');
svg_node.setAttribute('xmlns','http://www.w3.org/2000/svg');
svg_node.setAttribute('xmlns:xlink','http://www.w3.org/1999/xlink');
svg_node.setAttribute('viewBox',view_box);


for i=1:length(tile_x_cell)
    poly_node = docNode.createElement('polyline');
    svg_node.appendChild(poly_node);

    poly_node.setAttribute('points',arr{i});
    svg_node.appendChild(poly_node);

    poly_node.setAttribute('style',colors{i});
    svg_node.appendChild(poly_node);

end

xmlwrite('example1.svg',svg_node)


% figure;
% imshow(uint8(raster_image));
% myaa(9);
% 
% fileID = fopen('cooX.dat','w');
% 
% formatSpec = '%f\n';
% 
% tile_x_cell(cellfun(@(x) any(isnan(x)),tile_x_cell)) = {'space'};
% 
% [nrows,ncols] = size(tile_x_cell);
% for row = 1:nrows
%     if isnan(tile_x_cell{row})
%         tile_x_cell{row}=0;
%     end
%     fprintf(fileID,formatSpec,tile_x_cell{row,:});
% end
% 
% fileID = fopen('cooY.dat','w');
% 
% formatSpec = '%f\n';
% 
% tile_y_cell(cellfun(@(x) any(isnan(x)),tile_y_cell)) = {'space'};
% 
% [nrows,ncols] = size(tile_y_cell);
% for row = 1:nrows
%     if isnan(tile_y_cell{row})
%         tile_y_cell{row}=0;
%     end
%     fprintf(fileID,formatSpec,tile_y_cell{row,:});
% end
% A=imread(filename);
% [row col chan]=size(A);
%
%
% tile_mean_R_norm=tile_mean_R./255;
% tile_mean_G_norm=tile_mean_G./255;
% tile_mean_B_norm=tile_mean_B./255;
%
% WCanvas=col;
% HCanvas=row;
%
% XExt = [0 WCanvas WCanvas 0 0];
% YExt = [HCanvas HCanvas 0 0 HCanvas];
%
%
% figure
% hold on
%
%
% fill(XExt,YExt,[0.5 0.5 0.5])
%
% colors=[tile_mean_R_norm;tile_mean_G_norm;tile_mean_B_norm];
%
% for i=1:count
%     fill(tile_x_cell{i},tile_y_cell{i},colors(:,i)')
%     plot(tile_x_cell{i},tile_y_cell{i},'color',[0.5 0.5 0.5]);
%     axis equal, axis off;
% end
%
%
%
% %plot(Xcum,Ycum,'color',[0.5 0.5 0.5])
%
% end
%
