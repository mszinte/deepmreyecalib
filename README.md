# DeepMReyeCalib
By: Sina KLING<br/> 
Project: DeepMReye / FrenchMinds<br/> 
With: Bastian CAGNA, Charles LAIDI, Matthias NAU, Guillaume MASSON, Martin SZINTE<br/> 
Version: 1.0 (branch frenchminds)<br/>

## Version description
Eye-movement tasks to collect training data for calibrating the DeepMReye network (Frey, Nau & Doeller, 2021, Nature Neuroscience) and to extend the method to closed-eye measures. 
This branch adapts the task for the FrenchMinds multi-centre cohort: each centre plays a pre-recorded calibration video matched to its scanner TR. 
Adapted from Matthias Nau and colleagues.

## Experiment runner
* run the experiment using main/expLauncher.m

## Task

One run = 146 TRs, 110 trials. 

## Task

| Part | Trials | Duration | Target |
|---|---|---|---|
| Pause (before each part and at the end) | 4 | 5 TR each | screen centre |
| Fixation | 42 (21 positions × 2) | 1 TR each | 7 × 3 grid, ±11° × ±6.19° |
| Smooth pursuit | 54 (3 amplitudes × 18 angles) | 1 TR each | 3, 5 or 6°, chained, linear motion |
| Free viewing | 10 images | 3 TR each | none (not usable as gaze labels) |

Full stimulus specifications (screen, grid, pursuit, images, timing): [CENIR CENTRE specifications.docx](experiment_code/others/CENIR%20CENTRE%20specifications.docx)

