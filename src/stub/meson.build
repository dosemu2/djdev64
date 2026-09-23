djstub64_sources = files(
  'coff.c',
  'elf.c',
  'util.c',
  'stub.c',
  'dpmiwrp.c',
  'dos.c',
)

djstub64_version_script = files('libdjstub.version')

# Only djstub_main is meant to be exported, see libdjstub.version.
# Not every linker understands --version-script (e.g. Solaris ld, ld64).
version_script_arg = ('-Wl,--version-script=' +
  meson.current_source_dir() / 'libdjstub.version')
have_version_script = cc.has_link_argument(version_script_arg)

djstub64_link_args = []
djstub64_link_depends = []
if have_version_script
  djstub64_link_args += version_script_arg
  djstub64_link_depends += djstub64_version_script
else
  warning('linker does not support --version-script, ' +
          'libdjstub64 symbols will not be versioned')
endif

libdjstub64 = shared_library('djstub64',
  djstub64_sources,
  include_directories : [inc_root, inc_pub],
  link_args : djstub64_link_args,
  link_depends : djstub64_link_depends,
  version : lib_version,
  soversion : lib_soversion,
  darwin_versions : darwin_versions,
  install : true,
)
