version 1.0

task hmas {
  input {
    Array[File] read1
    Array[File] read2
    File primers
    String docker="us-docker.pkg.dev/general-theiagen/internal/hmas:1.0.0"
    Int memory = 32
    Int cpu = 12
    Int disk_size = 500
  }
  command <<<
    date | tee DATE

    read1_array=(~{sep=' ' read1})
    read2_array=(~{sep=' ' read2})

    echo "Read1 files: ${read1_array[@]}"
    echo "Read2 files: ${read2_array[@]}"

    # move read files to new directory
    mkdir reads
    for i in ${!read1_array[@]}; do
      cp ${read1_array[$i]} reads/
      cp ${read2_array[$i]} reads/
    done

    # copy HMAS-QC-Pipeline2 to current directory
    cp -r /HMAS-QC-Pipeline2/* ./

    # Run nextflow
    nextflow run hmas2.nf --outdir OUT --reads reads --primer ~{primers}

  >>>
  output {
    String hmas_docker = docker
    String analysis_date = read_string("DATE")
    File hmas_report = "OUT/report.csv"
    Array[File] hmas_clean_read1 = glob("OUT/*/temp/*.1.fastq")
    Array[File] hmas_clean_read2 = glob("OUT/*/temp/*.2.fastq")
    Array[File] hmas_consensus_fasta = glob("OUT/*/*final.unique.fasta")
  }
  runtime {
    docker: "~{docker}"
    memory: "~{memory} GB"
    cpu: cpu
    disks: "local-disk ~{disk_size} SSD"
    maxRetries: 3
    preemptible: 0
  }
}