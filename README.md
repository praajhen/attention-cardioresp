# Cardiac cycle, respiration phase and visual attention (ANT): analysis code

MATLAB/FieldTrip code for:

> Santhana Gopalan, P. R., Hämäläinen, J., Penttonen, M., & Nokia, M. S. (2026). Impact of cardiac cycle and respiratory rhythm phase on visual attention in healthy young and older adults. *Scientific Reports*, 16, 18096. https://doi.org/10.1038/s41598-026-47916-6

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.22975053.svg)](https://doi.org/10.5281/zenodo.22975052)

## Overview

Young (n = 25) and older (n = 25) adults performed a modified Attention Network Test (no-cue/double-cue, congruent/incongruent) while 128-channel EEG, ECG and respiration were recorded (NeurOne, 1 kHz). The code:

1. preprocesses the EEG (channel interpolation, ICA, 1-30 Hz filter),
2. extracts cue-locked epochs and ERPs (N1, P3) for each condition,
3. computes reaction times,
4. sorts trials by respiration phase (2 bins) and cardiac phase (3 bins) at target onset,
5. writes the tables and difference waves used for the statistics.

Statistics were run in IBM SPSS Statistics 28 (ANOVAs, t-tests) and BESA Statistics 2.1 (cluster-based permutation tests). Those steps are not part of this repository.

## Requirements

- MATLAB R2022b (EEG) and R2024b (reaction times); Signal Processing Toolbox
- FieldTrip 20230427
- EGI HydroCel GSN 128 layout (`GSN-HydroCel-128.sfp`, included in FieldTrip)

## Data

Participant data are not included. They are available from the corresponding author on reasonable request. This also applies to the final cardiac bin edges (`edges.mat`, see below).

## Usage

1. Edit the paths at the top of `ant_config.m`.
2. Run the scripts in order. `s01` and `s02` are interactive and run one participant at a time.

| Script | Step | Paper |
|---|---|---|
| `01_preprocessing/s01_interpolate_bad_channels.m` | Visual inspection, bad channel interpolation (average method) | Methods: Electroencephalogram |
| `01_preprocessing/s02_ica.m` | ICA (runica, 30 components), removal of ocular and cardiac components | Methods: Electroencephalogram |
| `01_preprocessing/s03_bandpass_filter.m` | 1-30 Hz band-pass | Methods: Electroencephalogram |
| `02_erp/s04_epoch_erp.m` | Cue-locked epochs (-200 ms pre-cue to 500 ms post-target), baseline, artifact rejection, average reference, ERPs | Methods: Electroencephalogram |
| `02_erp/s05_grand_average_roi.m` | Grand-averaged ROI waveforms | Fig. 6 |
| `03_behaviour/s06_reaction_times.m` | RTs, relative RTs, alerting and conflict effects | Figs. 2-3 |
| `04_physiology/s07_cardiac_bin_edges.m` | Proposed cardiac bin edges from the mean ECG waveform | Methods: Respiration and cardiac cycle phase |
| `04_physiology/s08_check_respiration_phase.m` | Visual check of respiration phase vs. raw signal | Methods: Respiration and cardiac cycle phase |
| `04_physiology/s09_heart_and_breathing_rate.m` | Descriptive heart and breathing rate | |
| `05_phase_analyses/s10_phase_bin_erps.m` | ERPs per respiration/cardiac bin and difference waves for BESA | Figs. 8-11 |
| `05_phase_analyses/s11_phase_bin_amplitudes.m` | ROI amplitudes per bin for the global ANOVAs | Results: Cardiac phase, but not respiration phase, modulates N1 and P3 |
| `05_phase_analyses/s12_phase_bin_rt.m` | Relative RTs per bin | Figs. 4-5 |

`functions/` contains the trial definition (`ant_trialfun.m`), artifact rejection and phase-binning helpers.

## Key parameters

All parameters are set in `ant_config.m`.

- **Epochs:** -200 to 1000 ms relative to the (possible) cue; target at 500 ms. Baseline -200 to 0 ms pre-cue. Only correct responses.
- **Artifact rejection:** epoch rejected if peak-to-peak exceeds 175 µV in more than 25 channels, or 300 µV in any channel (computed from sample 150 onward).
- **N1:** electrodes 52, 72, 92, 65, 70, 75, 83, 90 (P3, POz, P4, PO7, O1, Oz, O2, PO8); 165-215 ms after target.
- **P3:** electrodes 62, 72, 75 (Pz, POz, Oz); 290-350 ms after target.
- **Respiration phase:** `angle(hilbert(resp))` of the raw respiration signal at target onset, rounded to two decimals, split at 0 rad.
- **Cardiac phase:** time from the preceding R-peak to target onset, sorted into systole, early diastole and late diastole with per-participant edges.
- **Excluded:** participant A016 (excessive EEG noise).

## Notes on implementation details

- **Event codes.** 11 no-cue marker, 12 double cue, 21 no-cue congruent, 22 no-cue incongruent, 23 double-cue congruent, 24 double-cue incongruent, 31 correct response.

## Citation

If you use this code, please cite the article above and this repository (see `CITATION.cff`).

## License

MIT, see `LICENSE`.

## Contact

Praghajieeth Raajhen Santhana Gopalan, University of Jyväskylä (ORCID [0000-0003-4244-485X](https://orcid.org/0000-0003-4244-485X))
