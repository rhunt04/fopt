#
# ┌────────────────────────────────────────────────────────────────────────────┐
# │ RJH: A fortran project makefile example w/ automated dependency generation │
# 	(depends fortdepend).                                                      │
# └────────────────────────────────────────────────────────────────────────────┘
#

FC       := gfortran
FFLAGS   := -Wall --std=f2003
LBFLAGS  := -O -Wall -fbounds-check -g -Wno-uninitialized
FDEBUG   := -g -Wextra -Werror
FRELEASE := -O3
LINKER   := $(FC) -o
# In principle linker can have different flags.
# FCLINKS  := -g -Wall -Wextra -Werror
ARCH     := $(shell uname -m)

BUILD    := ./build-$(ARCH)
OBJ_DIR  := $(BUILD)/obj
LBFOBJ_DIR := $(BUILD)/lbfobj
APP_DIR  := $(BUILD)/bin

DEP_FILE := dependencies.dep
TARGET   := main

SRC_DIR := src
SRC     := $(wildcard $(SRC_DIR)/*.f03)
LBF_DIR := $(SRC_DIR)/Lbfgsb.3.0
LBF_SRC := $(LBF_DIR)/lbfgsb.f $(LBF_DIR)/linpack.f $(LBF_DIR)/blas.f $(LBF_DIR)/timer.f
OBJ     := $(SRC:%.f03=$(OBJ_DIR)/%.o)
LBFOBJ  := $(LBF_SRC:%.f=$(LBFOBJ_DIR)/%.o)

.DEFAULT_GOAL := all

MAKEDEPEND := fortdepend

red := $(shell echo "\033[0;31m")
grn := $(shell echo "\033[0;32m")
yel := $(shell echo "\033[0;33m")
blu := $(shell echo "\033[0;34m")
mag := $(shell echo "\033[0;35m")
cya := $(shell echo "\033[0;36m")
noc := $(shell echo "\033[0m")

.PHONY: all clean vclean remake dep lbfgsb

# Make and include dependencies file.
dep : $(DEP_FILE)

# Dependencies.
$(DEP_FILE) : $(SRC)
	@echo -n "$(cya)"
	@echo "[D] Running fortdepend on source files (outputting to $@)."
	$(MAKEDEPEND) -w -f $(SRC) -b $(OBJ_DIR) -o $@
	@echo -n "$(noc)"

# Don't try to generate depends file if we're clean or vclean.
ifneq ($(MAKECMDGOALS), clean)
ifneq ($(MAKECMDGOALS), vclean)
-include $(DEP_FILE)
endif
endif

# Make all.
all: $(APP_DIR)/$(TARGET) dep

lbfgsb: $(LBFOBJ)

debug: FFLAGS += $(FDEBUG)
debug: TARGET += _DEBUG
debug: all

release: FFLAGS += $(FRELEASE)
release: all

# Objects.
$(OBJ_DIR)/%.o : %.f03
	@echo -n "$(grn)"
	@echo "[O] Making $@ from $< in $(@D)."
	@mkdir -p $(@D)
	$(FC) $(FFLAGS) -c $< -o $@ -J$(OBJ_DIR)
	@echo -n "$(noc)"

$(LBFOBJ_DIR)/%.o : %.f
	@echo -n "$(grn)"
	@echo "[O] [LEGACY LBFGSB CODE] Making $@ from $< in $(@D)."
	@mkdir -p $(@D)
	$(FC) $(LBFLAGS) -c $< -o $@ -J$(LBFOBJ_DIR)
	@echo -n "$(noc)"

# Linking objects/mods to target.
$(APP_DIR)/$(TARGET) : $(OBJ) $(LBFOBJ)
	@echo -n "$(blu)"
	@echo "[T] Making $@ from $< in $(@D)."
	@mkdir -p $(@D)
	$(LINKER) $@ $(OBJ) $(LBFOBJ) $(FFLAGS) -J$(OBJ_DIR)
	@echo -n "$(noc)"

# Clean objects/mods.
clean :
	@echo -n "$(yel)"
	-@rm -rvf $(OBJ_DIR)
	-@rm -rvf $(LBFOBJ_DIR)
	-@rm iterate.dat
	@echo -n "$(noc)"

# Clean everything.
vclean : clean
	@echo -n "$(red)"
	-@rm -rvf $(BUILD)
	-@rm -rvf $(DEP_FILE)
	-@rm -rvf valgrind-out.txt
	@echo -n "$(noc)"

# vclean, redo.
remake : vclean all
