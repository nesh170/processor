        function[bit_index,color] = find_closest_8bit(color,color_list)
                color_repeat = ones(size(color_list,1),1)*color;
                diff_vec = abs(color_repeat-color_list);
                small_diff = find(diff_vec==min(diff_vec));
                bit_index = small_diff(1)+1;
                color = hex2rgb(dec2hex(color_list(small_diff(1)),6),256);
        end