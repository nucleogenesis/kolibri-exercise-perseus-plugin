.PHONY: help clean clean-pyc release dist

help:
	@echo "clean-build - remove build artifacts"
	@echo "clean-pyc - remove Python file artifacts"
	@echo "release - package and upload a release"
	@echo "dist - package"

clean: clean-build clean-pyc

clean-build:
	rm -fr build/
	rm -fr dist/
	rm -fr dist-packages-cache/
	rm -fr dist-packages-temp/
	rm -fr *.egg-info
	rm -fr .eggs
	rm -fr .cache

clean-pyc:
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +

assets:
	# move mathjax to static folder for our hacky loading.
	rm -r kolibri_exercise_perseus_plugin/static
	mkdir kolibri_exercise_perseus_plugin/static
	cp -r kolibri_exercise_perseus_plugin/node_modules/perseus/lib/mathjax kolibri_exercise_perseus_plugin/static/
	mkdir kolibri_exercise_perseus_plugin/static/images
	cp kolibri_exercise_perseus_plugin/node_modules/perseus/images/spinner.gif kolibri_exercise_perseus_plugin/static/images
	cp -r kolibri_exercise_perseus_plugin/node_modules/perseus/lib/mathquill/fonts kolibri_exercise_perseus_plugin/static/

	# update the constants.js to store the mathjax config file name.
	# Ben: This seems like it doesn't detect the file name?
	> kolibri_exercise_perseus_plugin/assets/src/constants.js
	config_file_name="$(basename kolibri_exercise_perseus_plugin/static/mathjax/2.1/config/*)"
	file_content="const ConfigFileName = '${config_file_name}'; module.exports = { ConfigFileName };"
	echo "${file_content}" >> kolibri_exercise_perseus_plugin/assets/src/constants.js

	cd kolibri_exercise_perseus_plugin && yarn run extract-messages

check-build:
	[ -e kolibri_exercise_perseus_plugin/static/images/spinner.gif ] || ( echo "Please run: make build" && exit 1 )

dist: clean check-build
	python setup.py sdist
	python setup.py bdist_wheel --universal

release: dist
	echo "Ensure that you have built the frontend files using Kolibri"
	echo "Uploading dist/* to PyPi, using twine"
	twine upload -s dist/*
