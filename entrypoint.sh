#!/bin/sh

setsid runsvdir /var/service

exec svlogtail
