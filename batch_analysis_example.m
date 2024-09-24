% batch_analysis_example.m
% This script takes in the time lapse movies and estimates the cell
% migration speeds. 
% We use the library "bio-formats-matlab" to load movies
% (github.com/microscopepony/bio-formats-matlab)
%
% Thien-Khoi N. Phung (February 22, 2021)

%% Grab all of the images
allimgs = dir('test_movies\*.tiff');

%% Process Speeds
for jz = 1:numel(allimgs)
    
    % Filename
    imgname = [allimgs(jz).folder '\' allimgs(jz).name];
    
    % Time Lapse ID [Date Capture#]
    tlid{jz} = [allimgs(jz).name(1:9),...
                cell2mat(extractBetween(allimgs(jz).name,'s','.ome'))];
    
    % Load in image file   
    data = bfopen(imgname);
    
    % Pixel Resolution
    OMEdata = data{1, 4};
    voxelSizeX = OMEdata.getPixelsPhysicalSizeX(0).value(ome.units.UNITS.MICROMETER); % in µm
    voxelSizeY = OMEdata.getPixelsPhysicalSizeY(0).value(ome.units.UNITS.MICROMETER); % in µm
    pixres = [voxelSizeX.doubleValue() voxelSizeY.doubleValue()]; %(um/pixel)
    
    % Make a video from image sequence
    for ss = 1:size(data{1},1)
        tlstack(:,:,ss) = data{1}{ss,1};
    end
    
    % Generate coordinates for all pixels
    [r,c]     = size(tlstack(:,:,1));
    [xg,yg]   = meshgrid(1:c,1:r);
    
    % Downsample Grid
    spaceout  = round(10/pixres(1)); % Spacing of grid (pixels)- 10 um
    [xgd,ygd] = meshgrid(1:spaceout:c,1:spaceout:r);
    xo = xgd(:);
    yo = ygd(:);
    
    % Remove grid points near border
    border    = round(50/pixres(1)); % 50 um -> pixels
    brectx    = [border c-border];
    brecty    = [border r-border];
    prect = drawrectangle('LineWidth',7,'Color','cyan');
    brectx = [border ...
              border ...
              c-border ...
              c-border];
    brecty = [border ...
              border ...
              r-border ...
              r-border];
         
    inborder  = inpolygon(xo,yo,brectx,brecty);
    xx        = xo(inborder);
    yy        = yo(inborder);
    
    % Setup optical flow
    opticFlow = opticalFlowFarneback;
    dt        = 1; % Time step (Frame rate)
    
    % Calculate flow
    for frame = 1:size(tlstack,3)
        disp(['Flow Calculation Frame ' num2str(frame)])
        
        % Grab frame
        imframe = im2uint8(tlstack(:,:,frame));
        
        % estimate flow
        flow  = estimateFlow(opticFlow,imframe);
        
        if frame>1
        % Calculate the velocities at the seed points [xx,yy]
        vxint = interp2(xg,yg,double(flow.Vx),xx(:,frame-1),yy(:,frame-1),'spline');
        vyint = interp2(xg,yg,double(flow.Vy),xx(:,frame-1),yy(:,frame-1),'spline');

        % Calculate the new position of the points in the next frame
        xx(:,frame) = xx(:,frame-1) + vxint.*dt;
        yy(:,frame) = yy(:,frame-1) + vyint.*dt;
        end
    end
    
    % Estimate migration velocity
    dist = sqrt(diff(xx,[],2).^2 + diff(yy,[],2).^2).*pixres(1); % um
    msd  = mean(dist,2); % um/frame
    velo = msd./(3/60); % um/hour
   
    % Store data
    tldata{jz}.xx   = xx;
    tldata{jz}.yy   = yy;
    tldata{jz}.msd  = msd;
    tldata{jz}.velo = velo;
    tldata{jz}.file = imgname;
    
    clear tlstack
end

%% Visualize tracking
% Which movie to visualize
imid = 1;

figure
plot(tldata{imid}.xx',tldata{imid}.yy','k-')
axis ij equal tight
title(tldata{imid}.file)
