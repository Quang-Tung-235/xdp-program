/* SPDX-License-Identifier: GPL-2.0 */
static const char *__doc__ = "XDP loader for Decision Tree\n"
	" - Allows selecting BPF program --progname name to XDP-attach to --dev\n";

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <getopt.h>

#include <locale.h>
#include <unistd.h>
#include <time.h>

#include <bpf/bpf.h>
#include <bpf/libbpf.h>
#include <xdp/libxdp.h>

#include <net/if.h>
#include <linux/if_link.h> /* depend on kernel-headers installed */

#include "../common/common_params.h"
#include "../common/common_user_bpf_xdp.h"
#include "../common/common_libbpf.h"
#include "common_kern_user.h"

static const char *default_filename = "xdp_prog_kern.o";

static const struct option_wrapper long_options[] = {

	{{"help",        no_argument,		NULL, 'h' },
	 "Show help", false},

	{{"dev",         required_argument,	NULL, 'd' },
	 "Operate on device <ifname>", "<ifname>", true},

	{{"skb-mode",    no_argument,		NULL, 'S' },
	 "Install XDP program in SKB (AKA generic) mode"},

	{{"native-mode", no_argument,		NULL, 'N' },
	 "Install XDP program in native mode"},

	{{"auto-mode",   no_argument,		NULL, 'A' },
	 "Auto-detect SKB or native mode"},

	{{"force",       no_argument,		NULL, 'F' },
	 "Force install, replacing existing program on interface"},

	{{"unload",      no_argument,		NULL, 'U' },
	 "Unload XDP program instead of loading"},

	{{"quiet",       no_argument,		NULL, 'q' },
	 "Quiet mode (no output)"},

	{{"filename",    required_argument,	NULL,  1  },
	 "Load program from <file>", "<file>"},

	{{"progname",    required_argument,	NULL,  2  },
	 "Load program from function <name> in the ELF file", "<name>"},

	{{0, 0, NULL,  0 }, NULL, false}
};
#ifndef PATH_MAX
#define PATH_MAX	4096
#endif

const char *pin_basedir =  "/sys/fs/bpf";
const char *map_name    =  "xdp_flow_tracking";
const char *dt_map_name =  "dt_map";

/* Pinning maps under /sys/fs/bpf in subdir */
int pin_maps_in_bpf_object(struct bpf_object *bpf_obj, const char *subdir)
{
	char map_filename[PATH_MAX];
	char pin_dir[PATH_MAX];
	int err, len;

	memset(pin_dir, 0, sizeof(pin_dir));
	len = snprintf(pin_dir, PATH_MAX, "%s/%s", pin_basedir, subdir);
	if (len < 0) {
		fprintf(stderr, "ERR: creating pin dirname\n");
		return EXIT_FAIL_OPTION;
	}

	len = snprintf(map_filename, PATH_MAX, "%s/%s/%s",
		       pin_basedir, subdir, map_name);
	if (len < 0) {
		fprintf(stderr, "ERR: creating map_name\n");
		return EXIT_FAIL_OPTION;
	}

	/* Existing/previous XDP prog might not have cleaned up */
	if (access(map_filename, F_OK ) != -1 ) {
		if (verbose)
			printf(" - Unpinning (remove) prev maps in %s/\n",
			       pin_dir);

		/* Basically calls unlink(3) on map_filename */
		err = bpf_object__unpin_maps(bpf_obj, pin_dir);
		if (err) {
			fprintf(stderr, "ERR: UNpinning maps in %s\n", pin_dir);
			return EXIT_FAIL_BPF;
		}
	}
	if (verbose)
		printf(" - Pinning maps in %s/\n", pin_dir);

	/* Pin all maps explicitly */
	struct bpf_map *map;
	int map_count = 0;
	bpf_object__for_each_map(map, bpf_obj) {
		const char *mapname = bpf_map__name(map);
		char map_path[PATH_MAX];
		
		snprintf(map_path, PATH_MAX, "%s/%s", pin_dir, mapname);
		
		if (verbose)
			printf("   - Pinning map '%s' to %s\n", mapname, map_path);
		
		err = bpf_map__pin(map, map_path);
		if (err) {
			fprintf(stderr, "ERR: Failed to pin map '%s': %s\n", 
				mapname, strerror(-err));
			/* Continue with other maps */
		} else {
			map_count++;
			if (verbose)
				printf("     ✅ Successfully pinned\n");
		}
	}
	
	if (verbose)
		printf(" - Pinned %d map(s)\n", map_count);

	/* Verify that expected maps were pinned */
	if (verbose) {
		char map_path[PATH_MAX];
		snprintf(map_path, PATH_MAX, "%s/%s", pin_dir, map_name);
		if (access(map_path, F_OK) == 0) {
			printf(" - Verified: %s exists\n", map_path);
		} else {
			fprintf(stderr, " - WARNING: %s does not exist after pinning\n", map_path);
		}
		snprintf(map_path, PATH_MAX, "%s/%s", pin_dir, dt_map_name);
		if (access(map_path, F_OK) == 0) {
			printf(" - Verified: %s exists\n", map_path);
		} else {
			fprintf(stderr, " - WARNING: %s does not exist after pinning\n", map_path);
		}
	}

	return 0;
}

int main(int argc, char **argv)
{
	struct xdp_program *program;
	int err, len;

	struct config cfg = {
		.attach_mode = XDP_MODE_SKB,  // Default to skb-mode for WiFi
		.xdp_flags = XDP_FLAGS_UPDATE_IF_NOEXIST,  // Default force flag
		.ifindex     = -1,
		.do_unload   = false,
	};
	
	/* Set default BPF-ELF object file and BPF program name */
	strncpy(cfg.filename, default_filename, sizeof(cfg.filename));
	strncpy(cfg.progname, "xdp_anomaly_detector", sizeof(cfg.progname) - 1);  // Default progname
	
	/* Cmdline options can change progname */
	parse_cmdline_args(argc, argv, long_options, &cfg, __doc__);

	/* Required option */
	if (cfg.ifindex == -1) {
		fprintf(stderr, "ERR: required option --dev missing\n\n");
		usage(argv[0], __doc__, long_options, (argc == 1));
		return EXIT_FAIL_OPTION;
	}

	char pin_dir[PATH_MAX];
	memset(pin_dir, 0, sizeof(pin_dir));
	len = snprintf(pin_dir, sizeof(pin_dir), "%s/%s", pin_basedir, cfg.ifname);
	if (len < 0) {
		fprintf(stderr, "ERR: creating pin dirname\n");
		return EXIT_FAIL_OPTION;
	}
	strncpy(cfg.pin_dir, pin_dir, sizeof(cfg.pin_dir) - 1);
	cfg.pin_dir[sizeof(cfg.pin_dir) - 1] = '\0';

	program = load_bpf_and_xdp_attach(&cfg);
	if (!program)
		return EXIT_FAIL_BPF;

	if (verbose) {
		printf("Success: Loaded BPF-object(%s) and used program(%s)\n",
		       cfg.filename, cfg.progname);
		printf(" - XDP prog attached on device:%s(ifindex:%d)\n",
		       cfg.ifname, cfg.ifindex);
	}

	/* Use the --dev name as subdir for exporting/pinning maps */
	err = pin_maps_in_bpf_object(xdp_program__bpf_obj(program), cfg.ifname);
	if (err) {
		fprintf(stderr, "ERR: pinning maps\n");
		return err;
	}

	if (verbose) {
		printf(" - Decision Tree map will be at: %s/%s\n", pin_dir, dt_map_name);
		printf(" - Flow tracking map will be at: %s/%s\n", pin_dir, map_name);
		printf(" - Use read_model_to_map.py to load the model\n");
	}

	return EXIT_OK;
}

