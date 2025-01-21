.PHONY: build

build:
	@packer build -var-file="../vars.json" ./build.json.pkr.hcl 2>&1 | tee build.log