clear all;
close all;
clc;
count=0;
% set(0,'Recursion',10000)
%Read the input image
%%%%%%%%%%%%%%%%%%%%%
x=imread('pepper.tiff');

x=imresize(x,[1024 1024]);
imwrite(x,'pep.jpg');
[az,bz,cz,dz]=dwt2(x,'haar');

tic
%SPIHT
%%%%%%

LH= wcompress('c',bz,'mask1.wtc','spiht','maxloop',5);  

HL= wcompress('c',cz,'mask2.wtc','spiht','maxloop',5);
HH= wcompress('c',dz,'mask3.wtc','spiht','maxloop',5);

%Fractal Compression
%%%%%%%%%%%%%%%%%%%%
image1 =az;
[l w h]=size(image1);

for gh=1:h

% check for square size image
if l==w
    display('input image is square');
% Setting range sizes to 4, 8 or 16
%ranges=[4 8 16];

% Getting the range size from the user.
%choice = menu('Choose range size','4','8','16');
%rangesize=ranges(choice);
rangesize=4;
choice=0;

%Subimage size
%%%%%%%%%%%%%%
%m=input('enter sub image size:');
m=64;
image=double(image1(:,:,gh));
d={};
coef=[];
coeff=[];
co=[];
coe={};

% Calculating the domain size
domainsize=rangesize*2;
i1=1:rangesize:l/m;
i2=rangesize:rangesize:l/m;
j1=1:rangesize:l/m;
j2=rangesize:rangesize:l/m;


for x=1:m
    for y=1:m
      im=image(((x-1)*l/m)+1:l/m*x,((y-1)*l/m)+1:l/m*y);  
     
      %toc
      count=count+1
      %tic
                   
for i=1:l/(m*rangesize)
for j=1:l/(m*rangesize)
    
  
range=im(i1(i):i2(i),j1(j):j2(j));
% o is the offset, the average of each range
o=(mean(mean(range)));
range=range - o;
% Initialize minerror1
minerror1=10000;
% Partitioning the domain blocks(non-overlapping).
for a=1:1:(l/m)-domainsize+1
for b=1:1:(l/m)-domainsize+1
D_unscaled=im(a:a+domainsize-1,b:b+domainsize-1);

% Now scaling the domain
D_scale=D_unscaled(1:2:domainsize,1:2:domainsize);
% Average of each domain block
ave=mean(mean(D_scale));
Domain=D_scale - ave;
% Scaled domain with a 0 deg rotation
DT_MAT(1:rangesize,1:rangesize,1)=Domain;
% Scaled domain with a 90 deg rotaion
DT_MAT(1:rangesize,1:rangesize,2)=rot90(Domain);
% Scaled domain with a 180 deg rotaion
DT_MAT(1:rangesize,1:rangesize,3)=rot90(rot90(Domain));
% Scaled domain with a 270 deg rotaion
DT_MAT(1:rangesize,1:rangesize,4)=rot90(rot90(rot90(Domain)));
% Scaled domain with a Horizontal flip
DT_MAT(1:rangesize,1:rangesize,5)=flipud(Domain);
% Scaled domain with a Vertical flip
DT_MAT(1:rangesize,1:rangesize,6)=fliplr(Domain);
% Scaled domain with a flip about forward diagonal
DT_MAT(1:rangesize,1:rangesize,7)=transpose(Domain);
% Scaled domain with a flip about reverse diagonal
DT_MAT(1:rangesize,1:rangesize,8)=rot90(rot90(transpose(Domain)));
% Now comparing each range with domain blocks, with each
% possible transformation of the domain
for Loop=1:8
Domain=DT_MAT(1:rangesize,1:rangesize,Loop);
% Calculating the contrast
if sum(sum(Domain.^2))<1
    ss1=0;
else
ss1= sum(sum(range.*Domain))/(sum(sum(Domain.^2)));
end

% Checking if contrast value is greater or equal to zero
% and less than one.
if ss1 >= 0 && ss1 <= 1
minerror=mean(ss1*Domain - range);
if minerror < minerror1
minerror1 = minerror;
e=a+(x-1).*l/m;
f=b+(y-1).*l/m;
M=Loop;
s=(ss1*10);
% Save s as integer
end


end
end

end
end
e=uint8(e);
coef=[e f M o s];
c=mat2cell(coef,1,5);
d(i+((x-1)*(l/(m*rangesize))),j+((y-1)*(l/(m*rangesize))))=c;


% Saving the coefficients

end
end

    end
end
toc;
d=d';
for i=1:((l/rangesize)^2)
    coe=d(i);
    co=cell2mat(coe);
   coeff=[coeff;co];
end
% symbols=[];
% prob=[];
% b=0;
% [q w]=size(coeff);
% scoeff=zeros(1,q*w);
% scoeff(1:q*w)=coeff(1:q*w);
% symbols(1)=scoeff(1);
% for j=1:length(scoeff)
%     for k=1:length(symbols)
%         if scoeff(j)==symbols(k)
%             b=1;
%         end
%     end
%     if b==0
%         symbols=[symbols scoeff(j)];
%     end
%     b=0;
% end
% 

% b=0;
% for j=1:length(symbols)
%     for k=1:length(scoeff)
%         if scoeff(k)==symbols(j)
%             b=b+1;
%         end
%     end
%     prob(j)=b/length(scoeff);
%     b=0;
% end
% dict = huffmandict(symbols,prob);
% hcode = huffmanenco(scoeff,dict);
% 
% j=1;

display('Image is compressed ');
% Clearing all unnecessary variables
%clear DT_MAT D_scaled D_unscaled Domain LH HL HH M Loop a b c ave co coe coef az bz cz dz e f i i1 i2 j j1 j1...
    %l m o minerror minerror1 range s ss x y; 
% Saving image name, image size, range size, choice and the coefficent matrix
sav(coeff,rangesize,l,choice);
% sav(hcode,rangesize,l,choice);
else
    display('use square image');
end
count=0;
end
