SHELL=/bin/bash

# Be sure that the infra has totally stopped, and then start it again (to reload SQL dumps in case of any change).
start:
	make stop; docker-compose up

# Stop the entire infra.
stop:
	docker-compose down

# Run the PoC. Shoud only be executed when MariaDB is totally started.
poc:
	@docker exec -i mariadb mysql -u root -psecret poc <<< 'SET GLOBAL query_cache_size = 0; SET PROFILING=1; SELECT * FROM `docs` LIMIT 10 OFFSET 2850001; SHOW PROFILES;'
	@printf "\n"
	@docker exec -i mariadb mysql -u root -psecret poc <<< 'SET GLOBAL query_cache_size = 0; SET PROFILING=1; SELECT * FROM `docs` WHERE id > 2850000 LIMIT 10; SHOW PROFILES;'
