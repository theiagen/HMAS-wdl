version 1.0

task calculate_mix_sites {
  input {
    File vcf
    String samplename
    Float threshold = 0.1
    String docker="biocontainers/pysam:v0.15.2ds-2-deb-py3_cv1"
    Int memory = 32
    Int cpu = 12
    Int disk_size = 500
  }
  command <<<
    python3 <<CODE
    import pysam

    # Open the VCF file
    vcf = pysam.VariantFile("~{vcf}")

    with open('~{samplename}_allele_frequencies.tsv', 'w') as out_file:
        # count number of variants in vcf
        total_variants = 0
        mixed_sites = 0

        # Iterate over each variant in the VCF file
        for variant in vcf:
            total_variants += 1
            # Calculate the reference and alternative counts
            ref_count = variant.info['DP4'][0] + variant.info['DP4'][1]
            alt_count = variant.info['DP4'][2] + variant.info['DP4'][3]
            # Calculate the total count
            total_count = ref_count + alt_count
            # Calculate the reference and alternative frequencies
            ref_freq = ref_count / total_count
            alt_freq = alt_count / total_count
            # Write the results to the output file if the alternative frequency is greater than 0.1
            if (alt_freq > ~{threshold} or ref_freq < 1 - ~{threshold}) and (alt_freq < 1 - ~{threshold} or ref_freq > ~{threshold}):
                mixed_sites += 1
                out_file.write(str(variant.chrom) + '\t' + str(variant.pos) + '\t' + str(variant.ref) + '\t' + str(variant.alts) + '\t' + str(ref_freq) + '\t' + str(alt_freq) + '\n')

        with open('mix_sites_percentage.txt', 'w') as mix_sites_file:
            mix_sites_file.write(str(mixed_sites) + '/' + str(total_variants))
    CODE
  >>>
  output {
    File allele_frequencies = "~{samplename}_allele_frequencies.tsv"
    String mix_sites_percentage = read_string("mix_sites_percentage.txt")
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