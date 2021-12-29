#!/bin/bash
if [ "$1" = "sidekiq" ]; then
	bundle install
	bundle exec $@
	sleep 99
	exit
fi;
if [ -e ./.production ]; then
	export RAILS_ENV=production
	echo "============ Precompiling Assets ============"
	bundle exec rake assets:precompile || exit
	echo "============ Migrating Database ============="
	bundle exec rake db:migrate db:seed || exit
	echo "============ Starting Passenger ============="
	export SECRET_KEY_BASE=production
	rails s -b 0.0.0.0
	echo "=============== Serer Stopped  ================"
else
	rm tmp/pids/server.pid
	bundle install
	yarn
	./bin/webpack-dev-server &
	rails s -b 0.0.0.0
	echo "=============== Serer Stopped  ================"
	sleep 99
fi;
