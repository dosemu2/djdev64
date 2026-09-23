subdir('stub')

djdev64_sources = files(
  'djdev64.c',
  'elf.c',
  'djexec.c',
)

djdev64_c_args = cc.get_supported_arguments('-Wmissing-prototypes')

libdjdev64 = shared_library('djdev64',
  djdev64_sources, config_h,
  include_directories : [inc_root, inc_pub],
  c_args : djdev64_c_args,
  dependencies : [libelf_dep, thread_dep] + dl_deps,
  version : lib_version,
  soversion : lib_soversion,
  darwin_versions : darwin_versions,
  install : true,
)
