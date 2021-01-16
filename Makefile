TEMPLATES_DIR = templates
INC_DIR = inc

TEMPLATE_FLAGS = -E -x c -P -C -DTEMPLATE_DATETIME="$(shell "date")" -I. -nostdinc

MAIN_PAGES = \
	index.html \
	posts.html

TEMPLATE_POSTS = $(wildcard posts/*.tp)
TEMPLATE_POSTS_OUTPUT = $(patsubst %.tp, %.html, $(wildcard posts/*.tp))

CORE_TEMPLATE_DEPENDENCIES = $(INC_DIR)/head.inc $(INC_DIR)/nav.inc $(TEMPLATES_DIR)/primary.tp

production: $(MAIN_PAGES) $(TEMPLATE_POSTS_OUTPUT) docs/css/main.min.css
	@mkdir -p docs
	@mkdir -p docs/posts
	./minify -o docs ./
	./minify -o docs/posts ./posts

docs/css/main.min.css: docs/css/main.css
	./minify -o docs/css/main.min.css docs/css/main.css
	
index.html: $(CORE_TEMPLATE_DEPENDENCIES) $(TEMPLATES_DIR)/index.tp 
	gcc $(TEMPLATE_FLAGS) -DTEMPLATE_BODY=\"$(TEMPLATES_DIR)/index.tp\" \
		$(TEMPLATES_DIR)/primary.tp -o docs/$@ -DABOUT_SELECTED=1 -DPAGE_TITLE="About"

posts.html: $(CORE_TEMPLATE_DEPENDENCIES) templates/posts.tp
	gcc $(TEMPLATE_FLAGS) -DTEMPLATE_BODY=\"$(TEMPLATES_DIR)/posts.tp\" \
		$(TEMPLATES_DIR)/primary.tp -o docs/$@ -DPOSTS_SELECTED=1 -DPAGE_TITLE="Posts"

posts/%.html: $(CORE_TEMPLATE_DEPENDENCIES) posts/%.tp
	gcc $(TEMPLATE_FLAGS) -DTEMPLATE_BODY=\"$(patsubst %.html,%.tp,$@)\" \
		$(TEMPLATES_DIR)/primary.tp -o $@ -DPOSTS_SELECTED=1 \
		-DPAGE_TITLE="$(shell grep -P -o "(?<=#define POST_TITLE \").+?(?=\")" $(patsubst %.html,%.tp,$@))"

clean:
	rm -f $(MAIN_PAGES) $(TEMPLATE_POSTS_OUTPUT)

.PHONY: all clean production
