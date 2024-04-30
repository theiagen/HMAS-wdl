version 1.0

task bcftools {
  meta {
    description: "From sorted BAM to VCF using bcftools"
  }
  input {
    File bam
    File bai
    File reference
    String samplename
    String docker = "us-docker.pkg.dev/general-theiagen/staphb/bcftools:1.20"
    Int disk_size = 100
    Int cpu = 2
    Int memory = 8
  }
  command <<<
    bcftools --version | head -n1 | cut -d' ' -f2 | tee VERSION

    bcftools mpileup -Ou -f ~{reference} ~{bam} | bcftools call -mv -Ov -A -o ~{samplename}.vcf
  >>>
  output {
    File vcf = "~{samplename}.vcf"
    String bcftools_version = read_string("VERSION")
    String bcftools_docker = "~{docker}"
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
