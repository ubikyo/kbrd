.PHONY: all deploy api web dev restart restart-api restart-dev

all: deploy

deploy: api web dev
	@printf "\n\033[47;30m %-60s \033[0m\n\n" " KBRD : déploiement terminé "

api:
	@printf "\n\033[47;30m %-60s \033[0m\n\n" " KBRD : API "
	$(MAKE) -C kbrd-api deploy

web:
	@printf "\n\033[47;30m %-60s \033[0m\n\n" " KBRD : WEB "
	$(MAKE) -C kbrd-web deploy

dev:
	@printf "\n\033[47;30m %-60s \033[0m\n\n" " KBRD : DEV "
	$(MAKE) -C kbrd-dev deploy


restart: restart-api restart-dev
	@printf "\n\033[47;30m %-60s \033[0m\n\n" " KBRD : services redémarrés "

restart-api:
	@printf "\n\033[47;30m %-60s \033[0m\n\n" " KBRD : redémarrage API "
	$(MAKE) -C kbrd-api restart

restart-dev:
	@printf "\n\033[47;30m %-60s \033[0m\n\n" " KBRD : redémarrage DEV "
	$(MAKE) -C kbrd-dev restart