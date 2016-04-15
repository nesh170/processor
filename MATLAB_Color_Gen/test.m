fid = fopen('color.txt');
line1 = fgetl(fid);
res=line1;
while ischar(line1)
   res =char(res,line1)
   line1 = fgetl(fid);
end
res = res(2:257,:);
fclose(fid);