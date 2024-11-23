PY_FILES= find . -type f -not -path '*/\.*' | grep -i '.*[.]py$$' 2> /dev/null
DOC_FILES= find . -type f -not -path '*/\.*' | grep -i '.*[.]rst\$\|.*[.]md\$\|.*[.]css\$\|.*[.]py\$\|mkdocs\.yml\|CHANGES\|TODO\|.*conf\.py' 2> /dev/null
ALL_FILES= find . -type f -not -path '*/\.*' | grep -i '.*[.]py\$\|.*[.]rst\$\|.*[.]md\$\|.*[.]css\$\|.*[.]py\$\|mkdocs\.yml\|CHANGES\|TODO\|.*conf\.py' 2> /dev/null


entr_warn:
	@echo "----------------------------------------------------------"
	@echo "     ! File watching functionality non-operational !      "
	@echo "                                                          "
	@echo "Install entr(1) to automatically run tasks on file change."
	@echo "See https://eradman.com/entrproject/                      "
	@echo "----------------------------------------------------------"

test:
	poetry run py.test $(test)

start:
	$(MAKE) test; poetry run ptw .

watch_test:
	if command -v entr > /dev/null; then ${ALL_FILES} | entr -c $(MAKE) test; else $(MAKE) test entr_warn; fi

build_docs:
	$(MAKE) -C docs html

start_docs:
	$(MAKE) -C docs design

design_docs:
	$(MAKE) -C docs design

watch_docs:
	if command -v entr > /dev/null; then ${DOC_FILES} | entr -c $(MAKE) build_docs; else $(MAKE) build_docs entr_warn; fi

serve_docs:
	$(MAKE) -C docs serve

dev_docs:
	$(MAKE) -j watch_docs serve_docs

ruff_format:
	poetry run ruff format .

ruff:
	poetry run ruff check .

watch_ruff:
	if command -v entr > /dev/null; then ${PY_FILES} | entr -c $(MAKE) ruff; else $(MAKE) ruff entr_warn; fi

mypy:
	poetry run mypy `${PY_FILES}`

watch_mypy:
	if command -v entr > /dev/null; then ${PY_FILES} | entr -c $(MAKE) mypy; else $(MAKE) mypy entr_warn; fi

format_markdown:
	prettier --parser=markdown -w *.md docs/*.md docs/**/*.md CHANGES

monkeytype_create:
	poetry run monkeytype run `poetry run which py.test`

monkeytype_apply:
	poetry run monkeytype list-modules | xargs -n1 -I{} sh -c 'poetry run monkeytype apply {}'
