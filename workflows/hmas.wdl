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
    String hmas_docker = hmas.hmas_docker
    String analysis_date = hmas.analysis_date
  }
}