function [mean_r, mean_g, mean_b] = getColor(image,x,y,px,py,tileSize)

R=tileSize/sqrt(pi);

pixelRange=[-round(R):round(R)];


x_coord=px+pixelRange;
y_coord=py+pixelRange;

pixelNumber=length(pixelRange);

delta=0.1;

square_x=[-delta -delta delta delta];

square_y=[-delta delta delta -delta];



%plot(square_x,square_y)

color_R_v=[];
color_G_v=[];
color_B_v=[];

for i=1:pixelNumber
    cur_y_coord=y_coord(i);
    for j=1:pixelNumber
        cur_x_coord=x_coord(j);
        cur_square_x=square_x+cur_x_coord;
        cur_square_y=square_y+cur_y_coord;
        [X_int Y_int] = polybool('and',cur_square_x,cur_square_y,x,y);
        Area=polyarea(X_int,Y_int);
        if (Area>0)
            if (cur_y_coord) && (cur_x_coord)>0
                color_R_v=[color_R_v image(cur_y_coord,cur_x_coord,1)];
                color_G_v=[color_G_v image(cur_y_coord,cur_x_coord,2)];
                color_B_v=[color_B_v image(cur_y_coord,cur_x_coord,3)];
            end
        end
        
    end
end

mean_r=mean(color_R_v);
mean_g=mean(color_G_v);
mean_b=mean(color_B_v);

end

