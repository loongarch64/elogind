#if 0 /// The original Makefile follows, which isn't enough for elogind.
# # SPDX-License-Identifier: LGPL-2.1-or-later
#
# all:
# 	ninja -C build
#
# install:
# 	DESTDIR=$(DESTDIR) ninja -C build install
#else // 0
.PHONY: all build clean install justprint loginctl test test-login
export

# Set this to YES on the command line for a debug build
DEBUG      ?= NO

# Set this to yes to not build, but to show all build commands ninja would issue
JUST_PRINT ?= NO

HERE := $(shell pwd -P)

BASIC_OPT  := --buildtype release
BUILDDIR   ?= $(HERE)/build
CGCONTROL  ?= $(shell $(HERE)/tools/meson-get-cg-controller.sh)
CGDEFAULT  ?= $(shell grep "^rc_cgroup_mode" /etc/rc.conf | cut -d '"' -f 2)
DESTDIR    ?=
MESON_LST  := $(shell find $(HERE)/ -type f -name 'meson.build') $(HERE)/meson_options.txt
PREFIX     ?= /tmp/elogind_test
ROOTPREFIX ?= $(PREFIX)
SYSCONFDIR ?= $(PREFIX)/etc
VERSION    ?= 9999

CC    ?= $(shell which cc)
LD    ?= $(shell which ld)
LN    := $(shell which ln) -s
MAKE  := $(shell which make)
MESON ?= $(shell which meson)
MKDIR := $(shell which mkdir) -p
NINJA ?= $(shell which ninja)
RM    := $(shell which rm) -f

# Save users/systems choice
envCFLAGS   := ${CFLAGS}
envLDFLAGS  := ${LDFLAGS}

BASIC_OPT := --buildtype release
NINJA_OPT := --verbose

# Make sure "--just-print" gets translated over to ninja
ifneq (,$(findstring n,$(MAKEFLAGS)))
    FILTER_ME = n
    override MAKEFLAGS    := $(filter-out $(FILTER_ME),$(MAKEFLAGS))
    override MAKEOVERRIDE := $(MAKEFLAGS)
    # Explicitly set JUST_PRINT to "YES"
    JUST_PRINT := YES
endif

# Simulate --just-print?
ifeq (YES,$(JUST_PRINT))
    NINJA_OPT := ${NINJA_OPT} -t commands
endif

# Combine with "sane defaults"
ifeq (YES,$(DEBUG))
    BASIC_OPT := --werror -Dlog-trace=true -Dslow-tests=true -Ddebug-extra=elogind --buildtype debug
    BUILDDIR  := ${BUILDDIR}_debug
    CFLAGS    := -O0 -g3 -ggdb -ftrapv ${envCFLAGS} -fPIE
    LDFLAGS   := -fPIE
    NINJA_OPT := ${NINJA_OPT} -j 1 -k 1
else
    BUILDDIR  := ${BUILDDIR}_release
    CFLAGS    := -fwrapv ${envCFLAGS}
    LDFLAGS   :=
endif

# Set search paths including the actual build directory
VPATH  := $(BUILDDIR):$(HERE):$(HERE)/src

# Set the build configuration we use to check whether a reconfiguration is needed
CONFIG := $(BUILDDIR)/compile_commands.json

# Finalize CFLAGS
CFLAGS := -march=native -pipe ${CFLAGS} -Wunused -ftree-vectorize

# Finalize LDFLAGS
LDFLAGS := ${envLDFLAGS} ${LDFLAGS} -lpthread


all: build

build: $(CONFIG)
	+@(echo "make[2]: Entering directory '$(BUILDDIR)'")
	+(cd $(BUILDDIR) && $(NINJA) $(NINJA_OPT))
	+@(echo "make[2]: Leaving directory '$(BUILDDIR)'")

clean: $(CONFIG)
	+@(echo "make[2]: Entering directory '$(BUILDDIR)'")
	(cd $(BUILDDIR) && $(NINJA) $(NINJA_OPT) -t cleandead)
	(cd $(BUILDDIR) && $(NINJA) $(NINJA_OPT) -t clean)
	+@(echo "make[2]: Leaving directory '$(BUILDDIR)'")

install: build
	+@(echo "make[2]: Entering directory '$(BUILDDIR)'")
	(cd $(BUILDDIR) && DESTDIR=$(DESTDIR) $(NINJA) $(NINJA_OPT) install)
	+@(echo "make[2]: Leaving directory '$(BUILDDIR)'")

justprint: $(CONFIG)
	+(BUILDDIR=$(HERE)/build $(MAKE) all JUST_PRINT=YES)

loginctl: $(CONFIG)
	+@(echo "make[2]: Entering directory '$(BUILDDIR)'")
	(cd $(BUILDDIR) && $(NINJA) $(NINJA_OPT) $@)
	+@(echo "make[2]: Leaving directory '$(BUILDDIR)'")

test: $(CONFIG)
	+@(echo "make[2]: Entering directory '$(BUILDDIR)'")
	(cd $(BUILDDIR) && $(NINJA) $(NINJA_OPT) $@)
	+@(echo "make[2]: Leaving directory '$(BUILDDIR)'")

test-login: $(CONFIG)
	+@(echo "make[2]: Entering directory '$(BUILDDIR)'")
	(cd $(BUILDDIR) && $(NINJA) $(NINJA_OPT) $@)
	+@(echo "make[2]: Leaving directory '$(BUILDDIR)'")

$(BUILDDIR):
	+$(MKDIR) $@

$(CONFIG): $(BUILDDIR) $(MESON_LST)
	@echo " Generating $@"
	+test -f $@ && ( \
		$(MESON) configure $(BUILDDIR) $(BASIC_OPT) \
	) || ( \
		$(MESON) setup $(BUILDDIR) $(BASIC_OPT) \
			--prefix $(PREFIX) \
			--wrap-mode nodownload  \
			-Drootprefix=$(ROOTPREFIX) \
			-Dsysconfdir=$(SYSCONFDIR) \
			-Dacl=true \
			-Dcgroup-controller=$(CGCONTROL) \
			-Ddefault-hierarchy=$(CGDEFAULT) \
			-Defi=true \
			-Dhtml=auto \
			-Dman=auto \
			-Dpam=true \
			-Dselinux=false \
			-Dsmack=true \
	)

#endif // 0
