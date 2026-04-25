package=icu4c
$(package)_version=55.2
$(package)_download_path=https://github.com/unicode-org/icu/releases/download/release-55-2/
$(package)_file_name=$(package)-55_2-src.tgz
$(package)_sha256_hash=eda2aa9f9c787748a2e2d310590720ca8bcc6252adf6b4cfb03b65bef9d66759
$(package)_patches=icu-001-dont-build-static-dynamic-twice.patch

define $(package)_set_vars
  $(package)_config_opts=
  $(package)_config_opts += --disable-shared
  $(package)_config_opts += --enable-static
endef

define $(package)_config_cmds
  patch -p1 < $($(package)_patch_dir)/icu-001-dont-build-static-dynamic-twice.patch && \
  cp config.guess config.sub source/ && \
  mkdir -p build-host build-target && \

  cd build-host && \
  ../source/runConfigureICU Linux && \
  $(MAKE) -j$(JOBS) && \

  cd ../build-target && \
  ../source/runConfigureICU Linux \
    --prefix=$(host_prefix) \
    --enable-static=yes \
    --disable-shared \
    --with-cross-build=$(CURDIR)/build-host
endef

define $(package)_build_cmds
  cd build-target && \
  $(MAKE) -j$(JOBS)
endef

define $(package)_stage_cmds
  cd build-target && \
  $(MAKE) DESTDIR=$($(package)_staging_dir) install
endef
