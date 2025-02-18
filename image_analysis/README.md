# Instructions

Before processing, raw images must be **segmented** and **binarized**. We recommend performing segmentation using **pixel classification** in [Ilastik](https://www.ilastik.org/).  

After processing, a **terminal-only image** will be generated, which can be used for object classification in Ilastik.  

## Example Data  
An example **binary image** is provided in the `import` folder for testing purposes.  

## Parameter Definitions (Example JSON File)  
The example JSON file contains the following parameters:

- **`import_folder`**: Directory containing the input images.  
- **`export_folder`**: Directory where all results will be saved.  
- **`min_size`**: Minimum object size (in pixels) included for skeleton creation.  
- **`square_size`**: Size of the square (in pixels) used to create nerve terminals centered around each branch endpoint.  
- **`min_branch_length`**: Minimum branch length (in pixels).  

Ensure these parameters are correctly set before running the analysis.  
