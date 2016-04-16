clear
input_file = 'horizon.jpg';
output_file = 'horizon.mif';
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

[img] = imread(input_file);
imgresized = imresize(img, [numrows numcols]);

[rows, cols, rgb] = size(imgresized);

imgscaled = imgresized/16 - 1;
imshow(imgscaled*16);
color_index_matrix = ones(rows,cols);
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
        color =  double(imgresized(r, c, 1)).*double(imgresized(r, c, 2)).*double(imgresized(r, c, 3));
        color = double(color);
        [index_color] = find_closest_8bit(color,color_index);
        fprintf(fid,'%4u : %4u;\n',count, index_color);
        color_index_matrix(r,c) = index_color(1);
        count = count + 1;
    end
end
toc
fprintf(fid,'END;');
fclose(fid);




