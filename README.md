# Optical Flow for Cell Migration

Use MATLAB's Computer Vision Toolbox to estimate trajectories of cells in a movie.

* `track_grid_example.m` tracks motion in one movie
* `batch_analysis_example.m` batch processes a folder containing multiple movies (i.e. `test_movies`)


## Getting Started

### Dependencies

* Cell segmentation code was developed on Windows 10 using MATLAB 2021a
* MATLAB toolboxes required
    * Image Processing Toolbox
    * Computer Vision Toolbox
* `batch_analysis_example.m` uses the [bio-formats library](https://github.com/microscopepony/bio-formats-matlab)


### `track_grid_example.m`: process one movie

`track_grid_example.m` tracks motion of a grid of points seeded from the first frame using the built in MATLAB toolbox function `opticalFlowFarneback`. You specify the location of the grid by drawing a rectangle on the first frame. You can also specify the spacing of the grid by changing the value of `spaceout`.


### `test_movies`: dataset

Sample movies for cell migration analysis.

* Humnan bronchial airway epithelial cells grown in Air-Liquid Interface culture
* Cells are imaged using time-lapse, phase-contrast microscopy (6 min between frames)

### `batch_analysis_example.m`: batch process movies

`batch_analysis_example.m` processes all movies within a folder (i.e. `test_movies`). This code automatically sets the tracking grid based on distance from the field of view border. The final block of code visualizes the migration paths from the first movie in the folder.

## Authors

Thien-Khoi N. Phung [@tkphung](https://twitter.com/tkphung)


## Acknowledgments

Inspiration, code snippets, etc.
* [Optical Flow Farneback Method (MATLAB)](https://www.mathworks.com/help/vision/ref/opticalflowfarneback.html)