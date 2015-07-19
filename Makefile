# Vars
FONTFORGE = $(shell which fontforge)
TTF2EOT = $(shell which ttf2eot)
TTF2SVG = $(shell which batik-ttf2svg)

# Functions
FONT_NAME = $(notdir $(FONT_PATH))
FONT_EXT = $(suffix $(FONT_NAME))
NEW_FILE_NAME = $(subst $(FONT_EXT),$(1),$(call FONT_NAME))
CSS_FILE = $(subst $(FONT_EXT),.css,$(call FONT_NAME))

ifeq ($(FONT_EXT),.otf)
all: clean generateTtf generateEot generateSvg generateWoff generateCss
else
all: clean copy generateEot generateSvg generateWoff generateCss
endif

copy:
	cp $(FONT_PATH) dest

clean:
	rm -f dest/*.*

generateTtf:
	$(FONTFORGE) -lang=ff -c 'Open($$1);Print($$fontname);' '$(FONT_PATH)' 2> /dev/null
	$(FONTFORGE) -lang=ff -c 'Open($$1);Print($$weight);' '$(FONT_PATH)' 2> /dev/null
	$(FONTFORGE) -lang=ff -c 'Open($$1);Print($$italicangle);' '$(FONT_PATH)' 2> /dev/null
	$(FONTFORGE) -lang=ff -c 'Open($$1);SetFontNames($$3,$$3,$$3);Generate($$2, "", 8);' '$(FONT_PATH)' 'dest/$(call NEW_FILE_NAME,.ttf)' 'false' 2> /dev/null

generateEot:
	$(TTF2EOT) "dest/$(call NEW_FILE_NAME,.ttf)" > "dest/$(call NEW_FILE_NAME,.eot)"

generateSvg:
	$(TTF2SVG) "dest/$(call NEW_FILE_NAME,.ttf)" -id "false" -o "dest/$(call NEW_FILE_NAME,.svg)"

generateWoff:
	$(FONTFORGE) -lang=ff -c 'Open($$1);Generate($$2, "", 8);' '$(FONT_PATH)' 'dest/$(call NEW_FILE_NAME,.woff)' 2> /dev/null

generateCss:
	@echo @font-face { > dest/$(CSS_FILE)
	@echo	'    font-family: "false";' >> dest/$(CSS_FILE)
	@echo	'    src: url("$(call NEW_FILE_NAME,.eot)");' >> dest/$(CSS_FILE)
	@echo	'    src: url("$(call NEW_FILE_NAME,.eot)?#iefix") format("embedded-opentype"),' >> dest/$(CSS_FILE)
	@echo	'         url("$(call NEW_FILE_NAME,.woff)") format("woff"),' >> dest/$(CSS_FILE)
	@echo	'         url("$(call NEW_FILE_NAME,.ttf)") format("truetype"),' >> dest/$(CSS_FILE)
	@echo	'         url("$(call NEW_FILE_NAME,.svg#false)") format("svg");' >> dest/$(CSS_FILE)
	@echo	'    font-weight: false;' >> dest/$(CSS_FILE)
	@echo	'    font-style: false;' >> dest/$(CSS_FILE)
	@echo } >> dest/$(CSS_FILE)