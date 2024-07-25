version 1.0

import "../tasks/task_hmas.wdl" as hmas_task

workflow hmas_wf {
  meta {
    description: "A WDL wrapper around the HMAS-QC-Pipeline2 nextflow pipeline."
  }
  input {
    Array[File] read1
    Array[File] read2
    File primers
  }
  call hmas_task.hmas {
    input:
      read1 = read1,
      read2 = read2,
      primers = primers
  }
  output {
    File hmas_report = hmas.hmas_report
    File hmas_multiqc_html = hmas.hmas_multiqc_html
    File hmas_mqc_yaml = hmas.hmas_mqc_yaml
    Array[File] hmas_final_fasta = hmas.hmas_final_fasta
    String hmas_docker = hmas.hmas_docker
    String analysis_date = hmas.analysis_date
  }
}