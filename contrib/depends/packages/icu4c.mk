package=icu4c
$(package)_version=55.2
$(package)_download_path=https://github.com/unicode-org/icu/releases/download/release-55-2/
$(package)_file_name=$(package)-55_2-src.tgz
$(package)_sha256_hash=eda2aa9f9c787748a2e2d310590720ca8bcc6252adf6b4cfb03b65bef9d66759
$(package)_patches=icu-001-dont-build-static-dynamic-twice.patch

define $(package)_preprocess_cmds
	cp -f $(BASEDIR)/config.guess $(BASEDIR)/config.sub source/ && \
	patch -p1 < $($(package)_patch_dir)/icu-001-dont-build-static-dynamic-twice.patch
endef

define $(package)_set_vars
$(package)_build_opts= \
	CFLAGS="$($(package)_cflags) $($(package)_cppflags) -DU_USING_ICU_NAMESPACE=0 -DU_STATIC_IMPLEMENTATION -DU_COMBINED_IMPLEMENTATION -fPIC" \
	CXXFLAGS="$($(package)_cxxflags) -Wno-error=implicit-fallthrough -Wno-implicit-fallthrough"
endef

define $(package)_config_cmds
	mkdir -p build-host build-target && \
	cd build-host && \
	../source/configure --disable-shared --enable-static && \
	$(MAKE) && \
	cd ../build-target && \
	../source/configure \
		--host=$(host) \
		--build=$(build) \
		--prefix=$(host_prefix) \
		--enable-static \
		--disable-shared \
		--disable-layout \
		--disable-layoutex \
		--disable-tests \
		--disable-samples \
		--with-data-packaging=static \
		--with-cross-build=$(PWD)/build-host
endef

define $(package)_build_cmds
	cd build-target && $(MAKE) $($(package)_build_opts)
endef

define $(package)_stage_cmds
	cd build-target && $(MAKE) DESTDIR=$($(package)_staging_dir) install
endef
