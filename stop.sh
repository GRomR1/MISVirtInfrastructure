#!/usr/bin/env bash

#Down all executing containers
docker-compose down

#Show info about containers that are executing
docker-compose ps
docker stats --no-stream