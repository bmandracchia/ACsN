close all

load('cmap');
load('gain');
load('offset');

NA = 1.45;
Lambda = .680;
PxSize = .065;

%%
input1 = double(loadtiff('TIRF_9Hz.tif'));

acsn_009  = ACSN(input1,NA,Lambda,PxSize,'Offset',offset,'Gain',gain,'Mode','Parallel'); 
% The first time the runtime can be longer if the parallel pool is not already active

figure;
% Please note that imfuse rescales the pixel values between [0,255]
imagesc(imfuse(input1(:,:,5),acsn_009(:,:,5),'montage'));
colormap(blow); axis off; axis image;
title('TIRF image of HeLa microtubules recorded at 9 Hz');

figure;
imagesc(imfuse(std(input1,[],3),std(acsn_009,[],3),'montage','Scaling','joint'));
colormap(jet); axis off; axis image;
title('TIRF image of HeLa microtubules recorded at 9 Hz - pixel fluctuation');

%%
input2 = double(loadtiff('TIRF_100Hz.tif'));

acsn_100  = ACSN(input2,NA,Lambda,PxSize,'Offset',offset,'Gain',gain,'Mode','Parallel'); 

figure; 
imagesc(imfuse(input2(:,:,1),acsn_100(:,:,1),'montage'));
colormap(blow); axis off; axis image;
title('TIRF image of HeLa microtubules recorded at 100 Hz');

figure;
imagesc(imfuse(std(input2,[],3),std(acsn_100,[],3),'montage','Scaling','joint'));
colormap(jet); axis off; axis image;
title('TIRF image of HeLa microtubules recorded at 100 Hz - pixel fluctuation');

%%
input3 = double(loadtiff('TIRF_200Hz.tif'));

acsn_200  = ACSN(input3,NA,Lambda,PxSize,'Offset',offset,'Gain',gain,'Mode','Parallel'); 

figure; 
imagesc(imfuse(input3(:,:,9),acsn_200(:,:,9),'montage'));
colormap(blow); axis off; axis image;
title('TIRF image of HeLa microtubules recorded at 200 Hz');

figure;
imagesc(imfuse(std(input3,[],3),std(acsn_200,[],3),'montage','Scaling','joint'));
colormap(jet); axis off; axis image;
title('TIRF image of HeLa microtubules recorded at 200 Hz - pixel fluctuation');
