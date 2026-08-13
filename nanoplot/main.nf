// Long-read QC with NanoPlot, run on the sorted BAM (alignment-based stats).

process NANOPLOT_NANOPLOT {
    tag "${meta.id}"

    publishDir "${params.outdir}/qc/nanoplot", mode: 'copy'

    input:
    tuple val(meta), path(bam), path(bai)

    output:
    tuple val(meta), path("${meta.id}"), emit: report

    script:
    def args = task.ext.args ?: ''
    """
    NanoPlot \\
        ${args} \\
        -t ${task.cpus} \\
        --bam ${bam} \\
        -o ${meta.id} \\
        -p ${meta.id}_
    """

    stub:
    """
    mkdir ${meta.id}
    touch ${meta.id}/${meta.id}_NanoPlot-report.html
    """
}
