# Cardiorespiratory Phase-Dependent Multimodal Signal Processing

This repository contains MATLAB code for multimodal physiological signal processing used in the published study:

**Santhana Gopalan P.R., Hämäläinen, J., Penttonen, M., and Nokia M.S.**

*"Impact of cardiac cycle and respiratory rhythm phase on visual attention in healthy young and older adults."*

Published in **Scientific Reports (2026)**.

DOI: https://doi.org/10.1038/s41598-026-47916-6

---

# Overview

This project investigates how cardiac cycle phase and respiratory phase influence attention-related EEG responses and behavioral performance during the Attention Network Task (ANT).

The analysis pipeline synchronizes EEG, ECG, and respiration signals to quantify physiological phase-dependent modulation of neural and behavioral attention effects in healthy young and older adults.

---

# Signals

* EEG (128-channel)
* ECG
* Respiration
* ANT event markers

---

# Implemented Processing Steps

* ECG R-peak detection
* Cardiac cycle segmentation (systole, early diastole, late diastole)
* Respiration phase estimation using the Hilbert transform
* Physiological phase assignment for individual trials
* EEG-ECG-respiration synchronization
* Event-related potential (ERP) extraction
* Attention Network Task condition analysis
* Reaction time analysis
* Group-level statistical comparison

---

# Input Data

* EEG recordings
* ECG recordings
* Respiration recordings
* ANT event markers

---

# Output

* Cardiac phase labels
* Respiration phase labels
* Physiological phase-binned trials
* Phase-dependent ERP measures
* Behavioral performance measures
* Group-level statistics

---

# Main Findings

* Attention-related ERP responses differed between young and older adults.
* Cardiac cycle phase modulated neural attention effects.
* Respiratory phase influenced attention-related EEG responses.
* Physiological rhythms contributed to behavioral attention performance.

---

# Analysis Workflow

Raw EDF recordings

→ EEG preprocessing (filtering, ICA, artifact rejection)

→ ERP extraction

→ ECG R-peak detection

→ Cardiac phase segmentation

→ Respiration phase extraction

→ Physiological phase assignment

→ Phase-dependent ERP computation

→ Behavioral analysis

→ Group-level statistics

---

# Requirements

* MATLAB
* EEGLAB
* FieldTrip

---

# Citation

If you use this code, please cite:

Santhana Gopalan, P.R., Hämäläinen, J., Penttonen, M., and Nokia M.S., (2026).

Impact of cardiac cycle and respiratory rhythm phase on visual attention in healthy young and older adults.

Scientific Reports.

https://doi.org/10.1038/s41598-026-47916-6

---

# Status

Research code accompanying the published Scientific Reports article.
