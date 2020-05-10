# ENCODE DCC ChIP-Seq pipeline tester for task macs2
# Author: Jin Lee (leepc12@gmail.com)
import '../../../chip.wdl' as chip
import 'compare_md5sum.wdl' as compare_md5sum

workflow test_macs2 {
	Int cap_num_peak
	Float pval_thresh

	Int fraglen
	Int ctl_subsample
	Boolean ctl_paired_end
	# test macs2 for SE set only
	String se_ta
	String se_ctl_ta

	String ref_se_macs2_npeak # raw narrow-peak
	String ref_se_macs2_bfilt_npeak # blacklist filtered narrow-peak
	String ref_se_macs2_frip_qc 
	String ref_se_macs2_subsample_npeak # raw narrow-peak
	String ref_se_macs2_subsample_bfilt_npeak # blacklist filtered narrow-peak
	String ref_se_macs2_subsample_frip_qc 

	String se_blacklist
	String se_chrsz
	String se_gensz

	String regex_bfilt_peak_chr_name = 'chr[\\dXY]+'

	Int macs2_mem_mb = 16000
	Int macs2_time_hr = 24
	String macs2_disks = 'local-disk 100 HDD'	

	call chip.call_peak as se_macs2 { input :
		peak_caller = 'macs2',
		peak_type = 'narrowPeak',
		tas = [se_ta, se_ctl_ta],
		ctl_subsample = 0,
		ctl_paired_end = ctl_paired_end,
		gensz = se_gensz,
		chrsz = se_chrsz,
		fraglen = fraglen,
		cap_num_peak = cap_num_peak,
		pval_thresh = pval_thresh,
		blacklist = se_blacklist,
		regex_bfilt_peak_chr_name = regex_bfilt_peak_chr_name,

		cpu = 1,
		mem_mb = macs2_mem_mb,
		time_hr = macs2_time_hr,
		disks = macs2_disks,		
	}

	call chip.call_peak as se_macs2_subsample { input :
		peak_caller = 'macs2',
		peak_type = 'narrowPeak',
		tas = [se_ta, se_ctl_ta],
		ctl_subsample = ctl_subsample,
		ctl_paired_end = ctl_paired_end,
		gensz = se_gensz,
		chrsz = se_chrsz,
		fraglen = fraglen,
		cap_num_peak = cap_num_peak,
		pval_thresh = pval_thresh,
		blacklist = se_blacklist,
		regex_bfilt_peak_chr_name = regex_bfilt_peak_chr_name,

		cpu = 1,
		mem_mb = macs2_mem_mb,
		time_hr = macs2_time_hr,
		disks = macs2_disks,		
	}

	call compare_md5sum.compare_md5sum { input :
		labels = [
			'se_macs2_npeak',
			'se_macs2_bfilt_npeak',
			'se_macs2_frip_qc',
			'se_macs2_subsample_npeak',
			'se_macs2_subsample_bfilt_npeak',
			'se_macs2_subsample_frip_qc',
		],
		files = [
			se_macs2.peak,
			se_macs2.bfilt_peak,
			se_macs2.frip_qc,
			se_macs2_subsample.peak,
			se_macs2_subsample.bfilt_peak,
			se_macs2_subsample.frip_qc,
		],
		ref_files = [
			ref_se_macs2_npeak,
			ref_se_macs2_bfilt_npeak,
			ref_se_macs2_frip_qc,
			ref_se_macs2_subsample_npeak,
			ref_se_macs2_subsample_bfilt_npeak,
			ref_se_macs2_subsample_frip_qc,
		],
	}
}
