.PHONY: all configure deploy restart build flash clean

MODE ?= dev
PACKAGE ?= all
CLEAN ?= false

all: deploy

#
# Configuration
#

configure:
	@./scripts/configure.sh

#
# Build
#

build:
ifeq ($(CLEAN),true)
	@./scripts/build.sh $(MODE) clean
else
	@./scripts/build.sh $(MODE)
endif

#
# Déploiement
#

deploy:
ifeq ($(PACKAGE),all)
	@$(MAKE) -C kbrd-api deploy
	@$(MAKE) -C kbrd-web deploy
	@$(MAKE) -C kbrd-dev deploy
else
	@$(MAKE) -C kbrd-$(PACKAGE) deploy
endif

#
# Redémarrage
#

restart:
ifeq ($(PACKAGE),all)
	@$(MAKE) -C kbrd-api restart
	@$(MAKE) -C kbrd-dev restart
else
	@$(MAKE) -C kbrd-$(PACKAGE) restart
endif

#
# Flash
#

flash:
	@./scripts/flash.sh

#
# Nettoyage
#

clean:
	@rm -rf output