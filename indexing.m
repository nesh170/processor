x=480;
y=640;
hw = zeros(x,y);

count=0;
for r=1:x
    for c=1:y
        count = count + 1;
        hw(r,c) = count;
    end
end