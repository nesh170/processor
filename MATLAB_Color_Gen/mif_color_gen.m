function [color_index_matrix] = mif_color_gen( input_file,output_file,numrows,numcols)
%mif_color_gen This method takes in an image from the user and outputs a
%.mif file

%  Indexes all the colors and finds them in the closest 8 bit range
fid = fopen('color.txt');
line1 = fgetl(fid);
res=line1;
while ischar(line1)
   res =char(res,line1);
   line1 = fgetl(fid);
end
color_index = res(2:257,:);
fclose(fid);

img = imread(input_file);
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

count = 0;
for r = 1:rows
    for c = 1:cols
        red = uint8(imgscaled(r,c,1));
        green = uint8(imgscaled(r,c,2));
        blue = uint8(imgscaled(r,c,3));
        color = red*(2^16) + green*(2^8) + blue;
        index_color = find_closest_8bit(color);
        fprintf(fid,'%4u : %4u;\n',count, index_color);
        color_index_matrix(r,c) = index_color;
        count = count + 1;
    end
end
fprintf(fid,'END;');
fclose(fid);

    function[bit_index] = find_closest_8bit(color)
        min_diff_index = 0;
        smallest_diff = 1e9;
        for i=1:size(color_index,1)
            new_number = hex2dec(color_index(i,:));
            if(abs(color-new_number)<=smallest_diff)
                smallest_diff = abs(color-new_number); 
                min_diff_index = i;
            end
        end
        bit_index = min_diff_index;
    end

end


