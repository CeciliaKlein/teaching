.PHONY: html check_deploy deploy clean deepclean

PYENV = env
HTML_FILE = index.html
CHEATSHEET_HTML = cheatsheet.html
LOGO_FILE = assets/crg_blue_logo.jpg
README = readme.rst
CHEATSHEET = cheatsheet.rst
BOOTSTRAP_VERSION = 2.1.1
BOOTSTRAP_CALLOUT = info
DEPLOY_LIST = deploy-list.txt

html: $(HTML_FILE) $(CHEATSHEET_HTML)
$(HTML_FILE): $(PYENV) $(README)
	@$(PYENV)/bin/rst2html5 --bootstrap-css --bootstrap-css-opts \
		 version=$(BOOTSTRAP_VERSION),callout=$(BOOTSTRAP_CALLOUT) --jquery --embed-stylesheet $(README) \
		 > $(HTML_FILE)
	@echo == Written file $(HTML_FILE)

$(CHEATSHEET_HTML): $(PYENV) $(CHEATSHEET)
	@$(PYENV)/bin/rst2html5 --bootstrap-css --bootstrap-css-opts \
		 version=$(BOOTSTRAP_VERSION),callout=$(BOOTSTRAP_CALLOUT) --jquery --embed-stylesheet $(CHEATSHEET) \
		 > $(CHEATSHEET_HTML)
	@echo == Written file $(CHEATSHEET_HTML)

$(PYENV): $(PYENV)/bin/activate
$(PYENV)/bin/activate: requirements.txt
	@test -d $(PYENV) || virtualenv $(PYENV)
	@$(PYENV)/bin/pip install -Ur requirements.txt

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
	rm $(HTML_FILE) $(CHEATSHEET_HTML) $(DEPLOY_LIST)

deepclean: clean
	rm -rf $(PYENV)
