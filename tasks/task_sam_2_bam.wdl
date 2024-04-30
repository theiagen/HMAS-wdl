version 1.0

task sam_to_sorted_bam {
  meta {
    description: "Converts SAM file to sorted BAM file"
  }
  input {
    File sam
    String samplename
    String docker = "us-docker.pkg.dev/general-theiagen/staphb/samtools:1.17"
    Int disk_size = 100
    Int cpu = 2
    Int memory = 8
  }
  command <<<
    # Samtools verion capture
    samtools --version | head -n1 | cut -d' ' -f2 | tee VERSION

    # Convert SAM to BAM, and sort it based on read name
    samtools view -Sb ~{sam} > "~{samplename}".bam
    samtools sort "~{samplename}".bam -o "~{samplename}".sorted.bam

    # index sorted BAM
    samtools index "~{samplename}".sorted.bam > "~{samplename}".sorted.bam.bai
  >>>
  output {
    File bam = "~{samplename}.sorted.bam"
    File bai = "~{samplename}.sorted.bam.bai"
    String samtools_version = read_string("VERSION")
    String samtools_docker = "~{docker}"
  }
  runtime {
    docker: "~{docker}"
    memory: memory + " GB"
    cpu: cpu
    disks: "local-disk " + disk_size + " SSD"
    disk: disk_size + " GB"
    maxRetries: 0
    preemptible: 0
  }
}
