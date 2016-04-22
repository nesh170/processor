function[bit_index,fail_index,color] = find_closest_8bit(red,green,blue,red_list,green_list,blue_list,fail_index)
    tolerance = 30;
    red_indices = find(abs(red_list-red) <= tolerance);
    green_indices = find(abs(green_list-green) <= tolerance);
    blue_indices = find(abs(blue_list-blue) <= tolerance);
    common_indices = intersect(intersect(red_indices,green_indices),blue_indices);
    if(size(common_indices,1)==0)
        fail_index = fail_index +1;
        bit_index = 1;
    elseif(size(common_indices,1)==1)
        bit_index = common_indices;
    else
        color_diff_arr = abs(red_list(common_indices).*green_list(common_indices).*blue_list(common_indices) - red*green*blue);
        min_index = find(color_diff_arr == min(color_diff_arr));
        bit_index = common_indices(min_index(1));
    end
    color = [red_list(bit_index), green_list(bit_index), blue_list(bit_index)];
end