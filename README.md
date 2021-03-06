# KORSA processing framework

This is a collection of Matlab scripts and packages for processing data of the [KORSA database](http://www.ling.uni-potsdam.de/%7Ekuberski/projects.html) of repetitive speech articulations.

## Preparation

In order to use this software the following requirements must be met:

- You have an installation of Matlab on your computer. Any version above or equal to R2017a will work. Earlier versions (at least with Handle graphics version 2 officially introduced in version R2014b) might work as well but have not been tested.
- You obtained a subset of the KORSA database and placed it at some location Matlab has access to (external hardrives are fine).
- You have downloaded and installed the software presented here. Use the green button at the top on the right to download a zip archive and extract it to some location of your choice. You do not need to set any search path in Matlab.
- You have downloaded and installed the convenience library `xis` which can be found [here](https://github.com/murtex/xis). Read the instructions there for installation and usage.

## Processing

Data processing is designed as a multi-stage procedure. At any stage processing runs on a dedicated copy of the data. In order to guarantee an accurate processing stages need to be run progressively. If processing of a particular stage is required to be reiterated any subsequent stage must be run again as well.

| Stage | Command   | Actions                                                                                                                                                                                                                                                                                                  |
| :---  | :---      | :---                                                                                                                                                                                                                                                                                                     |
| 1     | `convert` | **AG501 conversion**. Parsing of session description files and logfiles from [Phil Hoole's presentation software](http://www.phonetik.uni-muenchen.de/~hoole/articmanual/index.html). Conversion of [Carstens AG501](http://www.articulograph.de/) device-provided data (sweeps and pre-cut wave files). |
| 2     | `preproc` | **Signal preprocessing**. Multi-stage decimation of EMA signals to 83.33 hertz. Butterworth lowpass of fourth order and 25 hertz cutoff. Head movement correction and alignment to midsagittal-occlusal frame of reference.                                                                              |
| 3     | `segsigs` | **Signal segmentation**. Time-varying moving window principal component analysis (MWPCA) and [quintic-spline approximation](http://www.ling.uni-potsdam.de/~kuberski/methods.html) of the first principal component. Segmentation based on zero velocity and 20% peak velocity value.                    |
| 4     | `selmovs` | **Movement selection**. Manual selection of movements forming or releasing constrictions.                                                                                                                                                                                                                |
| 5     | `finsigs` | **Data finishing**. Quintic-spline approximation of displacement, velocity and acceleration curves. Minimization of region of interest (ROI).                                                                                                                                                            |

## Inspection

Three tools for visual inspection of the data are provided.

| Command   | Description                                                                  |
| :---      | :---                                                                         |
| `preview` | Three-dimensional view of Carstens AG501's raw sweep files.              |
| `inspect` | Multi-channel view of framework signals (EMA and audio).                     |
| `animate` | Three-dimensional animation of of articulators (interactive and MP4 output). |

## Analysis

| Package | Description                                     |
| :---    | :---                                            |
| `+plot` | Panel plots.                                    |
| `+ref`  | Reference implementation of certain statistics. |
|         |                                                 |

