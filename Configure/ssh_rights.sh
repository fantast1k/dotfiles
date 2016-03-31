#!/usr/bin/env bash

# This scripts sets needed rights for ~/.ssh folder

chmod 600 ~/.ssh/*
chmod 644 ~/.ssh/*.pub
chmod 644 ~/.ssh/known_hosts
chmod 644 ~/.ssh/config
chmod 700 ~/.ssh
