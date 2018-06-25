#!/usr/bin/env bash

set -e

info() {
	echo -e "\033[1;34m$*\033[0;0m"
}

info 'Setting up configurations'

cat - > "$PWD/.prettierrc" <<RC
{
	"semi": false,
	"singleQuote": true
}
RC

cat - > "$PWD/.eslintignore" <<IGNORE
node_modules/*
packages/*/node_modules/*
IGNORE

cat - > "$PWD/.editorconfig" <<CONFIG
[*.js]
indent_style = spaces
indent_size = 2
[*.json]
indent_style= spaces
indent_size = 2
CONFIG

cat - > "$PWD/.eslintrc.yaml" <<CONFIG
extends: standard
rules:
  # This is the only override required for prettier and standard style to
  # work together properly.
  space-before-function-paren:
    - error
    - never
overrides:
  - files:
    - 'test/**/*js'
    env:
      mocha: true
CONFIG

info 'Installing dependencies'
npm install --save-dev eslint eslint-config-standard eslint-plugin-import eslint-plugin-node eslint-plugin-standard eslint-plugin-promise

npm install --save-dev prettier

info 'Updating package.json scripts'

node <<JAVASCRIPT
var path = require('path')
var fs = require('fs')
var packageJson = require(path.join(process.cwd(), 'package.json'))
Object.assign(packageJson.scripts, {
	format: 'prettier --write \'**/*.js\'',
	lint: 'prettier --list-different \'**/*.js\' && eslint \'**/*.js\'',
	fix: 'eslint --fix \'**/*.js\''
})
fs.writeFileSync(
	path.join(process.cwd(), 'package.json'),
	JSON.stringify(packageJson, null, 2))
JAVASCRIPT

npm run format
npm run fix || true
npm run lint
