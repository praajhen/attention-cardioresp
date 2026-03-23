# Cardiorespiratory Phase-Dependent Multimodal Signal Processing

This repository contains MATLAB code for multimodal physiological signal processing used in the study:

**"Impact of cardiac cycle and respiratory rhythm phase on visual attention in healthy young and older adults"**  
(Currently under review, Scientific Reports)

# Overview
This project investigates how **cardiac cycle phase** and **respiration phase** modulate **attention-related EEG responses** and **reaction time** during the Attention Network Task (ANT).

The pipeline synchronizes **EEG**, **ECG**, and **respiration** signals to extract phase-dependent neural and behavioral effects.

# Signals
- EEG (128-channel)
- ECG
- Respiration
- Event markers (ANT task)

# Implemented steps
- ECG R-peak detection  
- Cardiac cycle segmentation (systole, early diastole, late diastole)  
- Respiration phase estimation using Hilbert transform  
- Trial sorting based on physiological phase  
- Multimodal synchronization (ECG + respiration + EEG)  
- Phase-dependent ERP extraction  
- Reaction time analysis  
- Group-level comparison (young vs older adults)

# Input
- ECG signal  
- Respiration signal  
- EEG data  
- Event markers  

# Output
- Cardiac phase labels  
- Respiration phase labels  
- Phase-binned trials  
- Phase-dependent ERP analysis  
- Reaction time modulation results  

# Key Results
## ERP attention effects (young vs older adults)
![ERP attention](results/figures/ERP_attention task.jpg)
ERP differences between no-cue and double-cue conditions (N1), and congruent vs incongruent targets (P3) in young and older adults.

## Cardiac and respiration phase modulation
![Cardiac respiration](results/figures/ECG_Resp,RT.jpg)
Attention-related effects are modulated by both cardiac cycle phase and respiration phase.

## Behavioral attention effects
![Behavioral](results/figures/RT_attention task.jpg)
Reaction time differences across Attention Network Task conditions for young and older adults.

# Methods Summary
The analysis pipeline:
Raw EDF data  
→ EEG preprocessing (filtering, ICA, artifact rejection)  
→ ERP extraction (ANT conditions)  
→ ECG R-peak detection  
→ cardiac phase segmentation  
→ respiration phase extraction (Hilbert transform)  
→ trial binning by physiological phase  
→ phase-dependent ERP computation  
→ behavioral analysis  

# Requirements
MATLAB  
FieldTrip toolbox  
EEGlab


# Status
Research code accompanying manuscript currently under review.