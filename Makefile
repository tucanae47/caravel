FILE_SIZE_LIMIT_MB = 25
LARGE_FILES := $(shell find . -type f -size +$(FILE_SIZE_LIMIT_MB)M -not -path "./.git/*")

LARGE_FILES_GZ := $(addsuffix .gz, $(LARGE_FILES))

ARCHIVES := $(shell find . -type f -name "*.gz")
ARCHIVE_SOURCES := $(basename $(ARCHIVES))

ifndef PDK_ROOT
$(error PDK_ROOT is undefined, please export it before running make)
endif

.DEFAULT_GOAL := ship

# We need portable GDS_FILE pointers...
.PHONY: ship
ship: uncompress
	@echo "###############################################"
	@echo "Generating Caravel GDS (sources are in the 'gds' directory)"
	@sleep 1
	@cd mag && MAGTYPE=mag magic -rcfile ${PDK_ROOT}/sky130A/libs.tech/magic/current/sky130A.magicrc -noc -dnull mag2gds.tcl < /dev/null
	mv mag/caravel_out.gds gds


.PHONY: clean
clean:
	echo "clean"



.PHONY: verify
verify:
	echo "verify"



$(LARGE_FILES_GZ): %.gz: %
	@if ! [ $(suffix $<) == ".gz" ]; then\
		gzip -n $< > /dev/null &&\
		echo "$< -> $@";\
	fi

# This target compresses all files larger than 25 MB
.PHONY: compress
compress: $(LARGE_FILES_GZ)
	@echo "Files larger than $(FILE_SIZE_LIMIT_MB) MBytes are compressed!"



$(ARCHIVE_SOURCES): %: %.gz
	gzip -d $< &&\
	echo "$< -> $@"

.PHONY: uncompress
uncompress: $(ARCHIVE_SOURCES)
	@echo "All files are uncompressed!"
