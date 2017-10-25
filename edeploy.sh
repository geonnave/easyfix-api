#!/bin/bash

set -e

mix edeliver build release --skip-git-clean --skip-mix-clean --verbose
mix edeliver deploy release to production --verbose
mix edeliver restart production --verbose
mix edeliver migrate production up --verbose

