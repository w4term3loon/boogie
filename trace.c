#include <stdio.h>
#include <fcntl.h>
#include <stdbool.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/resource.h>
#include <unistd.h>

#include <bpf/libbpf.h>
#include <bpf/bpf.h>

#include "trace.skel.h"

void read_trace_pipe(void)
{
  int trace_fd;

  trace_fd = open("/sys/kernel/debug/tracing/trace_pipe", O_RDONLY, 0);
  if (trace_fd < 0)
    return;

  while (1) {
    static char buf[4096];
    ssize_t sz;

    sz = read(trace_fd, buf, sizeof(buf) - 1);
    if (sz > 0) {
      buf[sz] = 0;
      puts(buf);
    }
  }
}

int main(void)
{
  struct trace_bpf *obj;
  int err = 0;

  struct rlimit rlim = {
    .rlim_cur = 512UL << 20,
    .rlim_max = 512UL << 20,
  };

  err = setrlimit(RLIMIT_MEMLOCK, &rlim);
  if (err) {
    fprintf(stderr, "failed to change rlimit\n");
    return 1;
  }

  obj = trace_bpf__open();
  if (!obj) {
    fprintf(stderr, "failed to open and/or load BPF object\n");
    return 1;
  }

  err = trace_bpf__load(obj);
  if (err) {
    fprintf(stderr, "failed to load BPF object %d\n", err);
    goto cleanup;
  }

  err = trace_bpf__attach(obj);
  if (err) {
    fprintf(stderr, "failed to attach BPF programs\n");
    goto cleanup;
  }

  read_trace_pipe();

cleanup:
  trace_bpf__destroy(obj);
  return err != 0;
}
