local="http://localhost:8080/ipfs/"
gway="https://ipfs.io/ipfs/"
build=public

zone="ipfs.io"
record="@"

build:
	hugo

clean:
	rm -rf "./$(build)"

serve:
	open http://localhost:1313
	hugo serve

deploy: build
	ipfs swarm peers >/dev/null || (echo "ipfs daemon must be online to publish" && exit 1)
	ipfs add -r -q "$(build)" | tail -n1 >versions/current
	cat versions/current >>versions/history
	@export hash=`cat versions/current`; \
		echo ""; \
		echo "published website:"; \
		echo "- $(local)$$hash"; \
		echo "- $(gway)$$hash"; \
		echo ""; \
		echo "next steps:"; \
		echo "- ipfs pin add -r /ipfs/$$hash"; \
		echo "- make publish-to-domain"; \
		open "https://ipfs.io/ipfs/$$hash";

publish-to-domain: auth.token
	DIGITAL_OCEAN=$(shell cat auth.token) node_modules/.bin/dnslink-deploy \
		--domain=$(zone) --record=$(record) --path=/ipfs/$(shell cat versions/current)
