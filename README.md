# nf-mod-nanoplot


Nextflow module for nanoplot. Used as a git submodule by pipelines.

Image: `ghcr.io/eit-gbi/nf-mod-nanoplot:latest`

## Processes

- `NANOPLOT` — TODO: describe inputs/outputs

## Use as submodule
```bash
git submodule add https://github.com/eit-gbi/nf-mod-nanoplot.git modules/nanoplot
```

Then in your pipeline:
```
include { NANOPLOT } from './modules/nanoplot/main.nf'
```
