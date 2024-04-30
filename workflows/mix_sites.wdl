version 1.0

import "../tasks/task_minimap2.wdl" as minimap2_task
import "../tasks/task_sam_2_bam.wdl" as sam_2_bam_task
import "../tasks/task_bcftools.wdl" as bcftools_task
import "../tasks/task_calculate_mixed_sites.wdl" as calculate_mix_sites_task

workflow mix_sites_wf {
  meta {
    description: "Workflow for HMAS analysis of mixed sites in amplicon sequencing data"
  }
  input {
    File read1
    File read2
    File reference
    String samplename
  }
  call minimap2_task.minimap2 {
    input:
      query1 = read1,
      query2 = read2,
      reference = reference,
      samplename = samplename,
      output_sam = true

  }
  call sam_2_bam_task.sam_to_sorted_bam {
    input:
      sam = minimap2.minimap2_out,
      samplename = samplename
  }
  call bcftools_task.bcftools {
    input:
      bam = sam_to_sorted_bam.bam,
      bai = sam_to_sorted_bam.bai,
      reference = reference,
      samplename = samplename
  }
  call calculate_mix_sites_task.calculate_mix_sites {
    input:
      vcf = bcftools.vcf,
      samplename = samplename
  }
  output {
    File mixed_sites_bam = sam_to_sorted_bam.bam
    File mixed_sites_bai = sam_to_sorted_bam.bai
    File mixed_sites_vcf = bcftools.vcf
    File mixed_sites_detailed_tsv = calculate_mix_sites.allele_frequencies
    String mixed_sites_summary = calculate_mix_sites.mix_sites_percentage
  }
}