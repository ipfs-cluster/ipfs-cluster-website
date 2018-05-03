DOMAIN="cluster.ipfs.io"

IPFSLOCAL="http://localhost:8080/ipfs/"
IPFSGATEWAY="https://ipfs.io/ipfs/"
OUTPUTDIR=public
NPMBIN=./node_modules/.bin

ifeq ($(DEBUG), true)
	PREPEND=
	APPEND=
else
	PREPEND=@
	APPEND=1>/dev/null
endif

build: install lint css
	$(PREPEND)hugo && \
	echo "" && \
	echo "Site built out to ./public dir"

help:
	@echo 'Makefile for a cluster.ipfs.io, a hugo built static site.                                                 '
	@echo '                                                                                                          '
	@echo 'Usage:                                                                                                    '
	@echo '   make                                Build the optimised site to ./$(OUTPUTDIR)                         '
	@echo '   make serve                          Preview the production ready site at http://localhost:1313         '
	@echo '   make lint                           Check your CSS is ok                                               '
	@echo '   make css                            Compile the *.css to ./static/css                                  '
	@echo '   make dev                            Start a hot-reloding dev server on http://localhost:1313           '
	@echo '   make deploy                         Add the website to your local IPFS node                            '
	@echo '   make publish-to-domain              Update $(DOMAIN) DNS record to the ipfs hash from the last deploy  '
	@echo '   make clean                          remove the generated files                                         '
	@echo '                                                                                                          '
	@echo '   DEBUG=true make [command] for increased verbosity                                                      '

clean:
	$(PREPEND)[ ! -d $(OUTPUTDIR) ] || rm -rf $(OUTPUTDIR) && \
	[ ! -d static/css ] || rm -rf static/css/main.css

node_modules:
	$(PREPEND)npm i $(APPEND)

install: node_modules
	$(PREPEND)[ -d static/css ] || mkdir -p static/css

lint: install
	$(PREPEND)$(NPMBIN)/lessc --lint layouts/less/*

css: install
	$(PREPEND)$(NPMBIN)/lessc --clean-css --autoprefix layouts/less/main.less static/css/main.css $(APPEND)

serve: install lint css
	$(PREPEND)hugo server

dev: install css
	$(PREPEND)( \
		$(NPMBIN)/nodemon --watch layouts/css --exec "$(NPMBIN)/lessc --clean-css --autoprefix layouts/less/main.less static/css/main.css" & \
		hugo server -w \
	)

deploy:
	$(PREPEND)ipfs swarm peers >/dev/null || (echo "ipfs daemon must be online to publish" && exit 1)
	ipfs add -r -q $(OUTPUTDIR) | tail -n1 >versions/current
	cat versions/current >>versions/history
	@export hash=`cat versions/current`; \
		echo ""; \
		echo "published website:"; \
		echo "- $(IPFSLOCAL)$$hash"; \
		echo "- $(IPFSGATEWAY)$$hash"; \
		echo ""; \
		echo "next steps:"; \
		echo "- ipfs pin add -r /ipfs/$$hash"; \
		echo "- make publish-to-domain"; \

publish-to-domain: versions/current
	DNSIMPLE_TOKEN="$(shell if [ -f auth.token ]; then cat auth.token; else cat $$HOME/.protocol/dnsimple.token; fi)" \
        ./dnslink.sh $(DOMAIN) $(shell cat versions/current)

.PHONY: build help install lint css serve deploy publish-to-domain clean
