clear
input_file = 'white_walls.jpg';
output_file = 'white_walls.mif';
numrows=640;
numcols=480;

res=0;
fid = fopen('color.txt');
line1 = fgetl(fid);
color_index=ones(255,1);
count = 1;
while ischar(line1)
   res = char(res,line1);
   color_index(count) = hex2dec(res(count,:));
   line1 = fgetl(fid);
   count=count + 1;
end
color_index = color_index(2:end);
fclose(fid);

img = imread(input_file);
cols = 640;
rows = 480;
imshow(img);
color_index_matrix = ones(rows,cols);
color_matrix = ones(rows,cols,3);
fid = fopen(output_file,'w');
fprintf(fid,'-- %3ux%3u 12bit image color values\n\n',rows,cols);
fprintf(fid,'WIDTH = 12;\n');
fprintf(fid,'DEPTH = %4u;\n\n',rows*cols);
fprintf(fid,'ADDRESS_RADIX = UNS;\n');
fprintf(fid,'DATA_RADIX = UNS;\n\n');
fprintf(fid,'CONTENT BEGIN\n');
tic
count = 0;
for r = 1:rows
    for c = 1:cols
        color =  double(img(r, c, 1)).*double(img(r, c, 2)).*double(img(r, c, 3));
        color = double(color);
        [index_color,out_pixels] = find_closest_8bit(color,color_index);
        fprintf(fid,'%4u : %4u;\n',count, index_color);
        color_index_matrix(r,c) = index_color(1);
        color_matrix(r,c, :) = out_pixels;
        count = count + 1;
    end
end
toc

figure(2)
imshow(color_matrix)

fprintf(fid,'END;');
fclose(fid);




