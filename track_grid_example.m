% track_grid_example
% This script tracks the flow of a grid of points throughout a movie.
%
% We seed points of interest in a grid across the field of view.
% We use MATLAB's OpticalFlowFarneback function to generate vector fields
% between frames of the wound healing movie.
% We integrate to "track" the points throughout the movie.

% Thien-Khoi N. Phung (October 13, 2020)

%% Read in video
% Select Video 
[file,folder] = uigetfile;

% Read in Video
vidReader = VideoReader([folder file]);


%% Set up grid for tracking
% Read first frame
frameGray = rgb2gray(read(vidReader,1));

% Plot the first image frame
roiF = figure;
imshow(frameGray)

% Segment region of interest (a rectangle)
prect  = drawrectangle('LineWidth',7,'Color','cyan');
xrect  = [prect.Position(1)  prect.Position(1)+prect.Position(3)];
yrect  = [prect.Position(2)  prect.Position(2)+prect.Position(4)];

% Generate initial grid points
spaceout  = 20; % Spacing of grid (pixels)
[r,c]     = size(frameGray);
[xg,yg]   = meshgrid(1:c,1:r);
[xgd,ygd] = meshgrid(1:spaceout:c,1:spaceout:r);
xo = xgd(:);
yo = ygd(:);

% Keep points inside polygon
inprect  = inpolygon(xo,yo,xrect,yrect);
xx       = xo(inprect);
yy       = yo(inprect);

% Plot the seed points
hold on
plot(xx,yy,'w.','MarkerSize',10)


%% Set up optical flow parameters
opticFlow = opticalFlowFarneback;

% Time step between frames
dt = 1; % frame

%% Calculate flow
% Cycle through each frame in the movie
frame = 1;
while hasFrame(vidReader)
    frame = frame+1;
    disp(['Flow Calculation Frame ' num2str(frame)])
    
    % Read in the frame & estimate the flow
    frameGray = rgb2gray(readFrame(vidReader));
    flow      = estimateFlow(opticFlow,frameGray);

    % Calculate the velocities at the seed points [xx,yy]
    vxint = interp2(xg,yg,double(flow.Vx),xx(:,frame-1),yy(:,frame-1),'spline');
    vyint = interp2(xg,yg,double(flow.Vy),xx(:,frame-1),yy(:,frame-1),'spline');

    % Calculate the new position of the points in the next frame
    xx(:,frame) = xx(:,frame-1) + vxint.*dt;
    yy(:,frame) = yy(:,frame-1) + vyint.*dt;
end

% Plot tracks on original ROI image
figure(roiF)
hold on
plot(xx',yy','-')
