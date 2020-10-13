# track-cells-matlab
Use MATLAB's Computer Vision Toolbox to estimate trajectories of cells in a movie.

# track_grid_example.m
This script tracks motion of a grid of points seeded from the first frame using the built in MATLAB toolbox function `opticalFlowFarneback`. You specify the location of the grid by drawing a rectangle on the first frame. You can also specify the spacing of the grid by changing the value of `spaceout`.