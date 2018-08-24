# KORSA processing framework

## Overview

- `convert` : AG501 raw conversion (parsing session description, creating dataspace)
- `preproc` : raw preprocessing (downsampling, filtering, reference frame alignment)
- `pcamovs` : movement segmentation (PCA transform, spline approximation, segmentation)
- `manmovs` : manual movement selection
- `finsigs` : finalize signals (spline approximation, q-narrowing, minimum roi)

- `preview` : AG501 raw signal inspection
- `inspect` : general signal inspection
- `animate` : general signal animation

## Details

This is a collection of Matlab scripts and packages for processing data of the KORSA database of repetitive speech articulations.

### Preparation

In order to use this software the following requirements must be met:

- You have an installation of Matlab on your computer. Any version above or equal to R2017a will work. Earlier versions (at least with Handle graphics version 2 officially introduced in version R2014b) might work as well but have not been tested.
- You obtained a subset of the KORSA database and placed it at some location Matlab has access to (external hardrives are fine).
- You have downloaded and installed the software presented here. Use the green button at the top on the right to download the zip archive and extract it to some location of your choice. You do not need to add any search path in Matlab.
- You have downloaded and installed the convenience library `xis` which can be found [here](TODO). Read the instructions there for installation and usage.

### Processing

Data processing is designed as a multi-stage procedure. At any stage processing runs on a dedicated copy of the data. In order to guarantee an accurate processing stages need to be run progressively. If processing of a particular stage is required to be reiterated all following stages must be run subsequently in proper order.

1. `convert`

### 


## Data abnormalities

- st/... front biteplate sensor failure
- cs/r1/sweep 46 [ka] has zero-length audio
- fk/... contains lots of uncut audio (unconnected sweep cable)
- dg/... jaw and right biteplate sensor failure

