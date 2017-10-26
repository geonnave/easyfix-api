#!/bin/bash

set -e

opts=
target=staging

while [[ ! -z "$@" ]]; do
	case "$1" in
		"fast" )
			opts="--skip-git-clean --skip-mix-clean";;
		"prod" )
			target="production";;
	esac
	shift
done

mix edeliver build release "$opts" --verbose
mix edeliver deploy release to "$target" --verbose
mix edeliver restart "$target" --verbose
mix edeliver migrate "$target" --verbose

