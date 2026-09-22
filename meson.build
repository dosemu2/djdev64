# dj64 - 64bit djgpp-compatible tool-chain
# meson build definition

project('djdev64', 'c',
  version : '0.5',
  license : 'GPL-3.0-or-later',
  default_options : [
    'c_std=gnu11',
    'warning_level=1',
    'default_library=shared',
  ],
)

cc = meson.get_compiler('c')

# Shared object versions of the produced libraries.
# libdjdev64.so.0.2 / libdjstub64.so.0.2 with SONAME libdjXXX64.so.0
lib_version = '0.2'
lib_soversion = '0'
darwin_versions = ['0.2', '0.2']

# API versions as advertised by the pkg-config files. They are
# deliberately not tied to the shared object versions above.
djdev64_pc_version = '0.5'
djstub64_pc_version = '0.6'

gnu_source_arg = '-D_GNU_SOURCE'

pkgconfig = import('pkgconfig')

conf = configuration_data()

#
# Mandatory system headers
#
foreach h : ['dlfcn.h', 'setjmp.h', 'fcntl.h', 'unistd.h', 'stdint.h',
             'sys/mman.h', 'sys/stat.h']
  if not cc.has_header(h)
    error('required header <@0@> not found'.format(h))
  endif
endforeach

#
# libdl / dlopen()
#
libdl_dep = cc.find_library('dl', required : false)
dl_deps = libdl_dep.found() ? [libdl_dep] : []

if not cc.has_function('dlopen',
    prefix : '#include <dlfcn.h>',
    dependencies : dl_deps)
  error('dlopen() not available, but it is required to run dj64 executables')
endif

#
# dlmopen() - needed for asan support and for the platforms where neither
# symbol versioning nor RTLD_DEEPBIND is available. Optional: djdev64.c
# falls back to its emu_dlmopen() when HAVE_DLMOPEN is not defined.
#
dlmopen_prefix = '''#define _GNU_SOURCE
#include <dlfcn.h>
'''
have_dlmopen = cc.has_function('dlmopen',
  prefix : dlmopen_prefix,
  args : gnu_source_arg,
  dependencies : dl_deps)
if have_dlmopen and not cc.has_header_symbol('dlfcn.h', 'LM_ID_NEWLM',
    args : gnu_source_arg)
  message('dlmopen() found but LM_ID_NEWLM is missing, disabling dlmopen()')
  have_dlmopen = false
endif
conf.set('HAVE_DLMOPEN', have_dlmopen,
  description : 'Define if dlmopen() and LM_ID_NEWLM are available')

# Purely informational: the sources test these with #ifdef straight from
# <dlfcn.h>, but report them so that a misconfigured platform is obvious.
have_rtld_deepbind = cc.has_header_symbol('dlfcn.h', 'RTLD_DEEPBIND',
  args : gnu_source_arg)
have_rtld_default = cc.has_header_symbol('dlfcn.h', 'RTLD_DEFAULT',
  args : gnu_source_arg)

if not have_dlmopen and not have_rtld_deepbind
  warning('neither dlmopen() nor RTLD_DEEPBIND is available: ' +
          'loading of dj64 executables may fail on this platform')
endif

#
# libelf (elfutils or the classic libelf)
#
libelf_dep = dependency('libelf', required : false)
if not libelf_dep.found()
  libelf_dep = cc.find_library('elf', required : true,
    has_headers : ['libelf.h', 'gelf.h'])
endif

foreach h : ['libelf.h', 'gelf.h']
  if not cc.has_header(h, dependencies : libelf_dep)
    error('required header <@0@> not found, install the libelf '.format(h) +
          'development package (libelf-dev / elfutils-libelf-devel)')
  endif
endforeach

libelf_prefix = '''#include <libelf.h>
#include <gelf.h>
'''
foreach f : ['elf_version', 'elf_memory', 'elf_kind', 'elf_nextscn',
             'elf_getdata', 'elf_strptr', 'elf_end',
             'gelf_getehdr', 'gelf_getphdr', 'gelf_getshdr', 'gelf_getsym']
  if not cc.has_function(f, prefix : libelf_prefix, dependencies : libelf_dep)
    error('libelf does not provide @0@()'.format(f))
  endif
endforeach

#
# pthreads
#
thread_dep = dependency('threads')

config_h = configure_file(output : 'config.h', configuration : conf)

inc_root = include_directories('.')
inc_pub = include_directories('include')

subdir('src')

pkgconfig.generate(libdjdev64,
  name : 'djdev64',
  description : 'djdev64 suit',
  version : djdev64_pc_version,
)

pkgconfig.generate(libdjstub64,
  name : 'djstub64',
  description : 'djstub64 libs',
  version : djstub64_pc_version,
)

install_headers(
  'include/djdev64/dj64init.h',
  'include/djdev64/djdev64.h',
  'include/djdev64/djdpmi.h',
  'include/djdev64/dpmi_inc.h',
  'include/djdev64/stub.h',
  subdir : 'djdev64',
)

summary({
    'dlmopen()' : have_dlmopen,
    'RTLD_DEEPBIND' : have_rtld_deepbind,
    'RTLD_DEFAULT' : have_rtld_default,
    'symbol versioning' : have_version_script,
  }, section : 'Features', bool_yn : true)
