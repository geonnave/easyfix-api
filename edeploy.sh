#!/bin/bash

set -e

opts=
target=staging
branch=master

while [[ ! -z "$@" ]]; do
	case "$1" in
		"fast" )
			opts="--skip-git-clean --skip-mix-clean"
			echo "Running FAST (not SAFE) compilation"
			;;
		"prod" )
			target="production"
			echo "Will deploy to PRODUCTION"
			;;
		"-b" )
			shift
			branch="$1"
			echo "From branch $branch"
			;;
	esac
	shift
done

mix edeliver build release "$opts" --branch="$branch" --verbose
mix edeliver deploy release to "$target" --verbose
mix edeliver restart "$target" --verbose
mix edeliver migrate "$target" --verbose
