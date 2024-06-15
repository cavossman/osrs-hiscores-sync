zip:
	mkdir -p dist && zip -r ./dist/osrs-hiscores-lambda.zip index.js

deploy:
	make zip && terraform apply