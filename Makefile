.PHONY: html check_deploy deploy clean deepclean

GEMS = env
HTML_FILE = index.html
CHEATSHEET_HTML = cheatsheet.html
LOGO_FILE = assets/crg_blue_logo.jpg
README = hands-on.adoc
CHEATSHEET = cheatsheet.adoc
DEPLOY_LIST = deploy-list.txt

html: $(HTML_FILE) $(CHEATSHEET_HTML)
$(HTML_FILE): setup $(README)
	@GEM_HOME=$(GEMS) $(GEMS)/bin/asciidoctor $(README) -o $(HTML_FILE)
	@echo == Written file $(HTML_FILE)

$(CHEATSHEET_HTML): setup $(CHEATSHEET)
	@GEM_HOME=$(GEMS) $(GEMS)/bin/asciidoctor $(CHEATSHEET) -o $(CHEATSHEET_HTML)
	@echo == Written file $(CHEATSHEET_HTML)

setup: $(GEMS)/bin/asciidoctor

$(GEMS)/bin/asciidoctor: $(GEMS)
	@GEM_HOME=$(GEMS) $(GEMS)/bin/bundle --path=$(GEMS) --binstubs=$(GEMS)/bin

$(GEMS): $(GEMS)/bin/bundle
$(GEMS)/bin/bundle:
	@GEM_HOME=$(GEMS) gem install bundler

$(DEPLOY_LIST):
	@echo $(HTML_FILE) >> $(DEPLOY_LIST)
	@echo $(CHEATSHEET_HTML) >> $(DEPLOY_LIST)
	@echo $(LOGO_FILE) >> $(DEPLOY_LIST)

check_deploy:
ifndef RNASEQ_DEPLOY_DIR
	$(error Undefined variable RNASEQ_DEPLOY_DIR)
endif

deploy: html $(DEPLOY_LIST) check_deploy
	rsync -a --files-from=$(DEPLOY_LIST) . $(RNASEQ_DEPLOY_DIR)

clean:
	rm -f $(HTML_FILE) $(CHEATSHEET_HTML) $(DEPLOY_LIST)

deepclean: clean
	rm -rf $(GEMS) bin .bundle
