ENV_VARS=NODE_ENV=test PORT=9999
TEST_DIR=test/unit/

MOCHA_BIN=mocha
MOCHA_DEFAULT_OPTS=--recursive -t 30000
MOCHA_OPTS=-R spec

ifneq "$(wildcard ./node_modules/sails-test-helper/node_modules/.bin/mocha)" ""
	MOCHA_BIN=./node_modules/sails-test-helper/node_modules/.bin/mocha
endif
ifneq "$(wildcard ./node_modules/.bin/mocha)" ""
	MOCHA_BIN=./node_modules/.bin/mocha
endif

check: test

test:
	@$(eval TARGETS=$(filter-out $@,$(MAKECMDGOALS)))
	@$(eval TARGETS=$(TARGETS:test/%=%))
	@$(eval TARGETS=$(TARGETS:unit%=%))
	@$(eval TARGETS=$(TARGETS:/%=%))
	@$(eval TARGETS=$(addprefix $(TEST_DIR),$(TARGETS)))
	@$(eval TARGET=$(shell [ -z $(firstword ${TARGETS}) ] && echo ${TEST_DIR}))
	@$(ENV_VARS) $(MOCHA_BIN) $(MOCHA_DEFAULT_OPTS) $(MOCHA_OPTS) $(TARGET) $(TARGETS)

clean:
	scripts/clean.sh nbproject .vagrant
	cd assets
	scripts/clean.sh nbproject .vagrant
	cd ..

install:
	scripts/install.sh

run:
	sails lift

# Commands for interaction with vagrant VM --- START


# Order for make commands: make init_box, make load_box, make install_box, make run_box
# After all dependencies installed, can just use: make load_box, make run_box

init_box:
	vagrant box add ubuntu/trusty64 "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box" --provider virtualbox
	vagrant plugin install vagrant-exec

load_box:
	vagrant up

install_box:
	vagrant exec sudo apt-get --assume-yes install nodejs-legacy npm git
	vagrant exec sudo npm install npm -g
	vagrant exec sudo npm install -g sails
	git clone https://github.com/g2graman/Mustr

run_box:
	vagrant exec cd Mustr
	vagrant exec sudo make install
	vagrant exec sudo make run
	vagrant ssh

clean_box:
	vagrant destroy
	rm -rf .vagrant

init_from_box:
	sudo apt-get --assume-yes install nodejs-legacy npm git
	sudo npm install npm -g
	sudo npm install -g sails
	git clone https://github.com/g2graman/Mustr

run_from_box:
	cd Mustr && sudo make install && sudo make run

# Commands for interaction with vagrant VM --- END

silent:
	@:

%: silent
	@:

.PHONY: check clean clean_box silent test install install_box run load_box run_box run_from_box init_box init_from_box
