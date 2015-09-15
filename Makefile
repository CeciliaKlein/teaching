PYENV = env
LOGO = assets/crg_blue_logo.jpg
README = readme.rst
HTML_FILE = index.html
BOOTSTRAP_VERSION = 3.0.0
DEFAULT_OUT_FOLDER = out

ifndef RNASEQ_TUTORIAL_FOLDER
	RNASEQ_TUTORIAL_FOLDER = $(shell pwd)/$(DEFAULT_OUT_FOLDER)
endif

html: $(RNASEQ_TUTORIAL_FOLDER)/$(HTML_FILE)
$(RNASEQ_TUTORIAL_FOLDER)/$(HTML_FILE): $(PYENV) $(RNASEQ_TUTORIAL_FOLDER) $(README)
	@$(PYENV)/bin/rst2html5 --bootstrap-css --bootstrap-css-opts \
		 version=$(BOOTSTRAP_VERSION) --jquery --embed-stylesheet $(README) \
		 > $(RNASEQ_TUTORIAL_FOLDER)/$(HTML_FILE)
	@echo "== Written '$(HTML_FILE)' to '$(RNASEQ_TUTORIAL_FOLDER)'."

$(PYENV): $(PYENV)/bin/activate
$(PYENV)/bin/activate: requirements.txt
	@test -d $(PYENV) || virtualenv $(PYENV)
	@$(PYENV)/bin/pip install -Ur requirements.txt

$(RNASEQ_TUTORIAL_FOLDER): $(LOGO)
	@mkdir -p $(RNASEQ_TUTORIAL_FOLDER)/assets
	@cp -n $(LOGO) $(RNASEQ_TUTORIAL_FOLDER)/assets || true

clean:
	rm -rf $(RNASEQ_TUTORIAL_FOLDER)

deepclean: clean
	rm -rf $(PYENV)
