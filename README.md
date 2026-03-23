# Cardiorespiratory Phase-Dependent Multimodal Signal Processing

This repository contains MATLAB code for multimodal physiological signal processing used in the study:

"Impact of cardiac cycle and respiratory rhythm phase on visual attention in healthy young and older adults"
(Currently under review, Scientific Reports)

## Overview
The pipeline extracts cardiac and respiratory phases and aligns them with EEG event timing to investigate physiological modulation of attention.

## Implemented steps
- ECG R-peak detection
- Cardiac cycle segmentation (systole, early diastole, late diastole)
- Respiration phase estimation using Hilbert transform
- Trial sorting based on physiological phase
- Multimodal synchronization (ECG + respiration + EEG)
- Phase-dependent ERP extraction

## Input
- ECG signal
- Respiration signal
- EEG data
- Event markers

## Output
- Cardiac phase labels
- Respiration phase labels
- Phase-binned trials
- Phase-dependent ERP analysis

## Status
Research code accompanying manuscript under review.