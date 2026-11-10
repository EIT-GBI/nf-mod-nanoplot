# nf-mod-nanoplot

Nextflow module for [NanoPlot](https://github.com/wdecoster/NanoPlot) (long-read
QC plots and summary statistics). Used as a git submodule by pipelines.

Image: `ghcr.io/eit-gbi/nf-mod-nanoplot:v1.0.0`

Published for `linux/amd64` only; the arm64 build is unverified. On an arm64
host, run with `docker.runOptions = '--platform=linux/amd64'`.

## Processes

| Process | Path | Inputs | Emits |
| --- | --- | --- | --- |
| `NANOPLOT_NANOPLOT` | `nanoplot/main.nf` | `tuple val(meta), path(bam), path(bai)` | `report` |

`report` is a directory named after `meta.id`, holding the HTML report and its
plots. Those files embed a generation timestamp, so the directory is not a
stable thing to checksum in a test — assert on the summary statistics instead.

## Publishing

This process publishes to `${params.outdir}/qc/nanoplot`. Pipelines that want a
different layout override `publishDir` with a `withName` selector.

## Tool arguments

Flags are passed through `task.ext.args` rather than read from pipeline
`params`, so the module never depends on a particular pipeline's parameter
names:

```groovy
process {
    withName: NANOPLOT_NANOPLOT {
        ext.args = '--plots dot --N50'
    }
}
```

## Pinned dependencies

Built on `debian:13-slim`, with NanoPlot installed by pip into a venv. Two
upstream pins, both found by running NanoPlot rather than by checking
`--version`:

| Pin | Why |
| --- | --- |
| `kaleido<1.0` | `nanoplotter` imports `kaleido.scopes.plotly`, removed in 1.x |
| `plotly<6` | `nanoplotter` calls `figure_factory.create_2d_density`, removed in 6.x |

**Known upstream limitation:** `report.stats2html` parses `NanoStats.txt` with
`sep=':'`, so a run whose read names contain colons dies with a pandas
`ParserError` after the plots are written. Real ONT read names are UUIDs, but
synthetic test data often is not.

## Use as submodule

Pin to a release tag rather than a branch, so pipeline runs stay reproducible:

```bash
git submodule add https://github.com/EIT-GBI/nf-mod-nanoplot.git modules/nanoplot
git -C modules/nanoplot checkout v1.0.0
```

Then include the module's container config from your `nextflow.config`. Nextflow
does not read a submodule's config on its own, so without this line the
process has no image:

```groovy
includeConfig 'modules/nanoplot/conf/module.config'
```

`conf/module.config` pins the image to the version built from this same commit,
and carries no `manifest {}` block, so it will not overwrite your pipeline's
own manifest. Override it in your pipeline with a `withName` selector if needed.

And include the process:

```groovy
include { NANOPLOT_NANOPLOT } from './modules/nanoplot/nanoplot/main.nf'
```

## Requirements

Nextflow 26.04.4 or newer.

## Releasing

Merging a PR to `main` with exactly one `bump:patch`, `bump:minor` or
`bump:major` label bumps `manifest.version` in `nextflow.config`, tags the
release and publishes the container image.
