clear all;
close all;
clc;

%SPIHT
%%%%%%%
bz= wcompress('u','mask1.wtc');
cz = wcompress('u','mask2.wtc');

dz = wcompress('u','mask3.wtc');

%FRACTAL
%%%%%%%%
% Getting the number of iteration
iter_mat=[1,2,4,6,8,10,12];
index=menu('Choose the number of iteration','1','2','4','6','8','10','12');
num_iter=iter_mat(index);
% Loading the decompressed file
h=3;
for gh=1:h
uiload




% Calculating the domain size
domainsize=rangesize*2;

% Decompressing the grayscale image
if choice==0
    
   % Calculating the domain size
    domainsize=rangesize*2;
i1=1:rangesize:l;
i2=rangesize:rangesize:l;
j1=1:rangesize:l;
j2=rangesize:rangesize:l;

% Creating memory buffers for the domain and range screens
domainimage=(zeros(l));
rangeimage=zeros(l);


% Implementing IFS on the compressed image
for iteration=1:num_iter
for i=1:l/rangesize
for j=1:l/rangesize
% Reading data
row=(i-1)*(l/rangesize)+j;
% Location of domain
e=coeff(row,1);
% Location of domain
f=coeff(row,2);
% Affine transformation
M=coeff(row,3);
% Offset
o=coeff(row,4);
% Scaling factor(contrast)
s=coeff(row,5);
% Rescaling the domain blocks
Domain=domainimage(e:e+domainsize-1,f:f+domainsize-1);
Domain=Domain-mean(mean(Domain));
% Transforming the domain
switch M
case 1
% If there is 0 deg rotation
Domain=Domain;
case 2
% If there is 90 deg rotaion
Domain=rot90(Domain);
case 3
% If there is 180 deg rotaion
Domain=rot90(rot90(Domain));
case 4
% If there is 270 deg rotaion
Domain=rot90(rot90(rot90(Domain)));
case 5
% If there is a Horizontal flip
Domain=flipud(Domain);
case 6
% If there is a Vertical flip
Domain=fliplr(Domain);
case 7
% If There is a flip about forward diagonal
Domain=transpose(Domain);
case 8
% If there is a flip about reverse diagonal
Domain=rot90(rot90(transpose(Domain)));
end
% Rescale domain, convert each domainsize x domainsize to
% rangesize x rangesize
D_scale=Domain(1:2:domainsize,1:2:domainsize);
rangeimage(i1(i):i2(i),j1(j):j2(j))=((double(s/10)) * D_scale + o);
end
end
domainimage=rangeimage;
end
rangeimage1(:,:,gh)=rangeimage
    

end


end

%%%%%%

image=idwt2(rangeimage1,bz,cz,dz,'haar');
imshow(uint8(image))
%imshow(uint8(image));
imwrite(uint8(image),'r4m64.bmp')
% PSNR calculation
% %%%%%%%%%%%%%%%%
xx=imread('pepper.tiff');
%xx=imresize(xx,[1024 1024]);
D = abs(double(xx)-double(image)).^2;
mse  = sum(D(:))/numel(xx)
psnr = 10*log10(255*255/mse)
%IDWT
