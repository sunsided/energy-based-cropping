# Feature detection /dev/rand

Matlab scripts for different feature detection purposes.

## Energy-based cropping

In `entropy_crop`, some examples can be found (`ncropX.m`). Additionally,
`crop_example.m` automatically derives the energy threshold from inspecting the variation in border regions of the image.

## Conversion

The code in `conversion` performs different color space conversions to grayscale in order to evaluate the proposed `Gleam` conversion method.

## Sift

The `sift` directory contains scale-space maxima detection as described in Lowe's paper on SIFT.
