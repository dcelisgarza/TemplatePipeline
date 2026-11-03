# Run the pipeline for one language, for one stage, or for all languages.
#
#   make                 all stages for all languages (make -k to continue after a failure)
#   make rust            all stages for one language
#   make rust-test       one stage for one language
#   make site            make site/index.html for the documentation of all languages
#   make clean           remove build output of all languages
#
# Stages: build test docs package install clean
# PREFIX (default /tmp/template-pipeline) sets where 'install' puts the programs.

LANGS  := c cpp python rust julia fortran typescript go csharp
STAGES := build test docs package install clean

.PHONY: all site clean check-versions $(LANGS) \
        $(foreach l,$(LANGS),$(foreach s,$(STAGES),$(l)-$(s)))

all: $(LANGS) site

$(LANGS):
	./$@/pipeline.sh all

define stage_rule
$(1)-$(2):
	./$(1)/pipeline.sh $(2)
endef
$(foreach l,$(LANGS),$(foreach s,$(STAGES),$(eval $(call stage_rule,$(l),$(s)))))

site:
	./scripts/make-site.sh

check-versions:
	./scripts/check-versions.sh

clean: $(foreach l,$(LANGS),$(l)-clean)
	rm -rf dist site
