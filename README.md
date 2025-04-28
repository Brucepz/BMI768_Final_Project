# Persistent Homology Analysis of Cortical Thickness in Autism
This repository contains MATLAB scripts for computing and comparing persistent homology features from SPHARM-smoothed cortical thickness maps. The study investigates group differences between Autism Spectrum Disorder (ASD) subjects and neurotypical controls using $p$-Wasserstein distances and a fast transposition-based permutation testing framework.

### Project Overview
Input Data: Cortical surface meshes and cortical thickness measurements from ABIDE website.

### Main Steps:

SPHARM smoothing of cortical thickness data.

Computation of $H_1$ persistence diagrams from triangulated meshes.

Wasserstein distance matrix calculation between persistence diagrams.

Group comparison using a test statistic based on between-group and within-group distances.

Fast permutation testing via random transpositions to assess significance.

This implementation closely follows the framework described in:

Chung, M.K., Dalton, K.M., Shen, L. (2019). Exact Topological Inference for Paired Brain Networks via Transposition Test. Information Processing in Medical Imaging (IPMI).



## Folder Structure

```plaintext
/Dataset/
    Autism/
        subject_XXXX_H1_PD.mat
    Control/
        subject_YYYY_H1_PD.mat
/scripts/
    spharm_smoothing.m
    compute_persistence.m
    wasserstein_distance.m
    permutation_test_PD_transposition_func.m
    utils/
        load_PD.m
        topK_PD.m
        get_PD_paths.m
/results/
    permutation_test_result.mat
    plots/
        histogram.png
        convergence_plot.png
 ```
/Dataset/: Input persistence diagrams organized by group.

/scripts/: Main analysis scripts.

/results/: Output files including permutation test results and visualization figures.

## Key Functions
spharm_smoothing.m — Apply SPHARM smoothing to cortical thickness maps.

compute_persistence.m — Compute $H_1$ persistence diagrams from triangulated meshes.

wasserstein_distance.m — Compute pairwise $p$-Wasserstein distances between persistence diagrams.

permutation_test_PD_transposition_func.m — Perform fast permutation test using random transpositions.


## Requirements
MATLAB R2021a or later

Statistics and Machine Learning Toolbox

Parallel Computing Toolbox (optional but recommended for speedup)

## How to Run
Run the calculate_all_PD.m in the Autism and Control folder. It will compute all the persistence diagrams of H0 and H1 for each subject.
Then, run the permutation_test_PD_transposition_func.m. It will compute the permutation test.
Set parameters K, p, and Nperm in permutation_test_PD_transposition_func.m.

Run the permutation test script in MATLAB:

matlab
Copy
Edit
permutation_test_PD_transposition_func('/path/to/Dataset', 1000, 2, 100000);
Results and plots will be saved in /results/.

## Citation
If you use this code for your research, please cite:

bibtex
Copy
Edit
@inproceedings{chung2019exact,
  title={Exact topological inference for paired brain networks via transposition test},
  author={Chung, Moo K. and Dalton, Kevin M. and Shen, Li},
  booktitle={Information Processing in Medical Imaging (IPMI)},
  pages={220--232},
  year={2019},
  organization={Springer}
}
## Acknowledgments
This project was developed under the guidance of Professor Moo K. Chung.
Language polishing and preliminary code debugging were assisted by ChatGPT (OpenAI, 2024).
