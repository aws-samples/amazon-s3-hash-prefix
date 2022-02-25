REGION := us-east-1
NAMING_PREFIX := hash-prefix
FILES_AMOUNT=50

STACK := s3-$(NAMING_PREFIX)-sample
ACCOUNT := $$(aws sts get-caller-identity --output text | cut -f 1)
LANDING_BUCKET := $(NAMING_PREFIX)-landing-$(ACCOUNT)
ORIGIN_BUCKET := $(NAMING_PREFIX)-origin-$(ACCOUNT)


sample:
	mkdir -p tmp
	cd tmp && for i in $$(seq 1 $(FILES_AMOUNT)); do date > file_$$i; done

sync:
	cd tmp && aws s3 sync --quiet . s3://$(LANDING_BUCKET)
	
deploy:
	sam deploy --resolve-s3 --region $(REGION) --capabilities CAPABILITY_NAMED_IAM --stack-name $(STACK) --parameter-overrides	NamingPrefix=$(NAMING_PREFIX) || true
	
dep:
	cd hash-copy && npm install

clean-tmp:
	rm -f tmp/*

clean-buckets:
	aws s3 rm --recursive --quiet s3://$(LANDING_BUCKET) &
	aws s3 rm --recursive --quiet s3://$(ORIGIN_BUCKET) &

clean: clean-tmp clean-buckets

install: dep deploy

uninstall:
	sam delete --region $(REGION) --stack-name $(STACK)

all: dep deploy sample sync
