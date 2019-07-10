
PoolStart;

disp('Processing...');


parfor frame = 1:size(I,3)
    
    [img(:,:,frame), sigma(frame),I1(:,:,frame)] = ACSN_core(I(:,:,frame),NA,Lambda,PixelSize,Gain,Offset,Hotspot,Level,Mode,SaveFileName);
    
    
end


if Video(1) ~= 'n'
    
    check = zeros(1,size(img,3)-4);
    
    if Video(1) ~= 'y'
        for ii = 1:size(img,3)-4
            check(ii) = psnr(img(:,:,ii),mean(img(:,:,ii:ii+4),3),max(max(img(:,:,ii))));
        end
    end
    
    check = mean(check);
    %     disp(check);
    
    if check < 30 || Video(1) == 'y'
        disp('Please wait... Additional 3D denoising required')
        psd = mean(sigma).*ones(8);
        
        if strcmp(Search,'Full')
            sType = 2;
        else
            sType = 3;
        end
        
        if sum(size(img)>[256 256 20])  % [256 256 20]
            
            size_y = min(200,size(img,1));
            size_x = min(200,size(img,2));
            size_z = min(100,size(img,3));
            
            Tiles = im2tiles(img,size_x,size_y,size_z);
            parfor idx = 1:numel(Tiles)
                Tiles{idx} = Video_filtering(Tiles{idx},psd,psd,'dct',0,1,sType,'np',0);
            end
            img = cell2mat(Tiles);
            clear Tiles;
            
        else
            
            img = Video_filtering(img,psd,psd,'dct',0,1,sType,'np',0);
            
        end
        
        disp('Wrapping up...');
        
        parfor i = 1:size(img,3)
            %             disp(i)
            img(:,:,i) = Wrapping_up(img(:,:,i),sigma(i));
            
        end
    end
end



parfor i = 1:size(img,3)
    Qscore(i) = metric(I1(:,:,i),img(:,:,i));
    if QM(1)=='y'
        Qmap(:,:,i) = Quality_Map(img(:,:,i),I1(:,:,i));
    end
end

clear I1

disp('Done!');
