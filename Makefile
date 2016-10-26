.PHONY: all html check_deploy deploy clean deepclean

GEMS = env
HTML_FILE = index.html
PDF_FILE = hands-on.pdf
CHEATSHEET_HTML = cheatsheet.html
CHEATSHEET_PDF = cheatsheet.pdf
LOGO_JPG = assets/crg_blue_logo.jpg
LOGO_PNG = assets/crg_blue_logo.png
DRAFT = assets/draft.png
README = hands-on.adoc
CHEATSHEET = cheatsheet.adoc
DEPLOY_LIST = deploy-list.txt
PDF = pdf
ATTRS =

all: html pdf

html: $(HTML_FILE) $(CHEATSHEET_HTML)
$(HTML_FILE): setup $(README)
	GEM_HOME=$(GEMS) $(GEMS)/bin/asciidoctor $(README) $(ATTRS) -o $(HTML_FILE)
	@echo == Written file $(HTML_FILE)
$(CHEATSHEET_HTML): setup $(CHEATSHEET)
	GEM_HOME=$(GEMS) $(GEMS)/bin/asciidoctor $(CHEATSHEET) $(ATTRS) -o $(CHEATSHEET_HTML)
	@echo == Written file $(CHEATSHEET_HTML)

draft: set-draft html
.PHONY: draft set-draft
set-draft:
	$(eval ATTRS := -a draft)


pdf: $(PDF_FILE) $(CHEATSHEET_PDF)
$(PDF_FILE): setup $(README)
	@GEM_HOME=$(GEMS) $(GEMS)/bin/asciidoctor-pdf $(README) -a pdf-stylesdir=$(PDF)/style -a pdf-style=crg -a pdf-fontsdir=$(PDF)/font
		@echo == Written file $(PDF_FILE)

$(CHEATSHEET_PDF): setup $(CHEATSHEET)
	@GEM_HOME=$(GEMS) $(GEMS)/bin/asciidoctor-pdf $(CHEATSHEET) -a pdf-stylesdir=$(PDF)/style -a pdf-style=crg -a pdf-fontsdir=$(PDF)/font
		@echo == Written file $(CHEATSHEET_PDF)

setup: $(GEMS)/bin/asciidoctor $(GEMS)/bin/asciidoctor-pdf

$(GEMS)/bin/asciidoctor: $(GEMS)
	@GEM_HOME=$(GEMS) $(GEMS)/bin/bundle --path=$(GEMS) --binstubs=$(GEMS)/bin

$(GEMS): $(GEMS)/bin/bundle
$(GEMS)/bin/bundle:
	@GEM_HOME=$(GEMS) gem install bundler

$(DEPLOY_LIST): 
	@echo $(HTML_FILE) >> $(DEPLOY_LIST)
	@echo $(CHEATSHEET_HTML) >> $(DEPLOY_LIST)
	@echo $(LOGO_JPG) >> $(DEPLOY_LIST)
	@echo $(LOGO_PNG) >> $(DEPLOY_LIST)
	@echo $(DRAFT) >> $(DEPLOY_LIST)
	@echo css/ >> $(DEPLOY_LIST)

check_deploy:
ifndef RNASEQ_DEPLOY_DIR
	$(error Undefined variable RNASEQ_DEPLOY_DIR)
endif

deploy: html $(DEPLOY_LIST) check_deploy sync
deploy-draft: draft $(DEPLOY_LIST) check_deploy sync

sync:
	rsync -a --files-from=$(DEPLOY_LIST) . $(RNASEQ_DEPLOY_DIR)

clean:
	rm -f $(HTML_FILE) $(CHEATSHEET_HTML) $(PDF_FILE) $(CHEATSHEET_PDF) $(DEPLOY_LIST)

deepclean: clean
	rm -rf $(GEMS) bin .bundle
