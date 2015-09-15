LOGO = assets/crg_blue_logo.jpg
BOOTSTRAP_VERSION = 3.0.0
README = readme.rst
PYENV = env

ifndef OUT_FOLDER
$(error Undefined variable - OUT_FOLDER)
endif

html: $(PYENV) out_folder $(README)
	@$(PYENV)/bin/rst2html5 --bootstrap-css --bootstrap-css-opts \
		 version=$(BOOTSTRAP_VERSION) --jquery --embed-stylesheet $(README) \
		 > $(OUT_FOLDER)/index.html
	@echo "== Html file written to '$(OUT_FOLDER)'."

$(PYENV): $(PYENV)/bin/activate

$(PYENV)/bin/activate: requirements.txt
	@test -d $(PYENV) || virtualenv $(PYENV)
	@$(PYENV)/bin/pip install -Ur requirements.txt

out_folder: $(LOGO)
	@mkdir -p $(OUT_FOLDER)/assets
	@cp -n $(LOGO) $(OUT_FOLDER)/assets || true
