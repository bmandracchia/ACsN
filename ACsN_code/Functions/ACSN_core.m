function [img, sigma,I1] = ACSN_core(I,NA,Lambda,PixelSize,Gain,Offset,Hotspot,Level,Mode,SaveFileName)


% OTF radius
R = 2*NA/Lambda*PixelSize*size(I,1);
adj = 1.1;
R2 = (.5*size(I,1)*adj);
% multiplicative factor to adjust the sigma of the noise
ratio = sqrt(R2/abs(R-R2));

% rescaling
I1 = (I-Offset)./Gain;
I1(I1<=0) = 1e-6;

% Fourier filter
R1 = min(R,size(I1,1)/2);
[low,high] = Gaussian_image_filtering(I1,'Step',R1);


%% Evaluation of sigma
[Values, BinCenters] = hist(high(:));
bins = BinCenters;

[~, first_min] = min(Values);
a1_est = bins(round(first_min/2));
a0_est = max(Values);

fo = fitoptions('Method','NonlinearLeastSquares',...
    'StartPoint',[a0_est a1_est]);
ft = fittype('a0*exp(-(1/2)*((x)/a1)^2)','options',fo);
[curve] = fit(bins',Values',ft);

a = curve.a1;
w = 1;      %1.5;
sigma = w*ratio*a; %#ok<SAGROW>


%% Remove hot spots
if Hotspot==1
    I1b = padarray(I1,[2 2],'replicate');
    I_med = medfilt2(I1b);
    I_med(1:2,:) = [];
    I_med(:,1:2) = [];
    I_med(end-1:end,:) = [];
    I_med(:,end-1:end) = [];
    
    I1(abs(high)>abs(mean2(high)+3.*std2(high))) = I_med(abs(high)>abs(mean2(high)+3.*std2(high)));
    %     check0(abs(high)>abs(mean2(high)+3.*std2(high))) = 1;
    I1(I1<=0) = 1e-6;
end

%% normalization
M1 = max(max(I1));
M2 = min(min(I1));
I2 = (I1 - M2)./(M1 -M2);

%% weights
low2 = padarray(low,[10 10],'replicate');
W = medfilt2(low2,[5 5]);
W(1:10,:) = [];
W(:,1:10) = [];
W(end-9:end,:) = [];
W(:,end-9:end) = [];

%% Level
% experimental, not active by default
if Level == 0
    % no weighting
    Weight = 1;
elseif Level >= 1
    % automatic weighting
    Weight = nrm(W);
    [Values, BinCenters] = hist(Weight(:));
    bins = BinCenters;
    
    [a0_est, first_max] = max(Values(:));  % Amplitude
    a1_est = bins(round(first_max/2)); % Mean
    %[~, first_min] = min(Values);
    a2_est = a1_est; %bins(round(first_min/2)); % Sigma
    
    [b0_est, second_max] = max(Values(round(first_max*1.2):end));  % Amplitude
    b1_est = bins(round(second_max+first_max)); % Mean
    b2_est = .1*b1_est; % Sigma
    
    fo = fitoptions('Method','NonlinearLeastSquares',...
        'StartPoint',[a0_est a1_est a2_est b0_est b1_est b2_est],'Lower',[0 0 0 0 0 0 ]);
    ft = fittype('a0*exp(-(1/2)*((x-a1)/a2)^2) + b0*exp(-(1/2)*((x-b1)/b2)^2)','options',fo);
    [curve2] = fit(bins',Values',ft);
    
    %         level = min(curve2.a1 + 3*curve2.a2,curve2.b1 - curve2.b2);
    %         point1 = curve2.a1 + (curve2.b1-curve2.a1)/2;
    point2 = curve2.a1 + 3*curve2.a2;
    %         point3 = curve2.b1 - 0*curve2.b2;
    level = min([point2]);
    %         Weight(Weight<level) = Weight(Weight<level).^2;
    Weight(Weight>level) = level;
    Weight = nrm(Weight.^2);
else
    % manual weighting
    Weight = nrm(W);
    Weight(Weight>level) = level;
    Weight = nrm(Weight.^2);
end

%%
I2 = (I2).*Weight;

%% Denoising

% scaling sigma for non-8 bit images
if (M1-M2)>255
    sigma = sigma/(M1-M2)*255;
end


[~, img0] = Sparse_filtering([],I2,sigma,'np');

img = (img0).*(M1-M2)+ M2;



%%
% Save image (if mode == 'Save')
if strcmp(Mode,'Save')
    options.append = true;
    options.message = false;
    options.big = false;
    
    saveastiff(uint16(img),SaveFileName,options);
end

end