PROFILE ?= 8
COMPOSE = docker compose -f compose.yaml -f profiles/$(PROFILE)gb.yaml
STUDENT_COMPOSE = docker compose -f compose.student.yaml -f profiles/$(PROFILE)gb.yaml
ifeq ($(PROFILE),plus)
COMPOSE = docker compose -f compose.yaml -f profiles/plus.yaml
STUDENT_COMPOSE = docker compose -f compose.student.yaml -f profiles/plus.yaml
endif

.PHONY: help check build build-hadoop build-spark build-hive benchmark-images smoke hadoop-up spark-up integration-up hive-up hive-shell hive-test hive-spark-up hive-spark-test cluster-up down reset status stats images logs-hadoop logs-spark logs-hive test-hdfs test-mapreduce test-spark test-integration student-pull student-hadoop-up student-spark-up student-hive-up student-hive-spark-up student-cluster-up student-down student-status student-test-hdfs student-test-mapreduce student-test-spark student-test-hive student-test-integration student-test-cluster student-test-resources student-test-all

help:
	@echo 'Usage: make PROFILE=8|16|plus <target>'
	@echo 'Developer: build smoke hadoop-up spark-up hive-up hive-spark-up down'
	@echo 'Student: student-pull student-hadoop-up student-spark-up student-hive-up student-hive-spark-up student-down'
	@echo 'Student tests: student-test-all student-test-hdfs student-test-mapreduce student-test-spark student-test-hive student-test-integration student-test-cluster student-test-resources'
	@echo 'Developer tests: test-hdfs test-mapreduce test-spark test-integration hive-test hive-spark-test'

build-hadoop:
	@$(COMPOSE) build hadoop

build-spark:
	@$(COMPOSE) build spark

build-hive:
	@if [ '$(PROFILE)' = '8' ]; then docker pull apache/hive:4.2.1; else $(COMPOSE) build metastore hive-full; fi

build: build-hadoop build-spark build-hive

benchmark-images:
	@bash scripts/benchmark-images.sh

smoke:
	@bash scripts/static-smoke.sh

check:
	@bash scripts/check-host.sh $(PROFILE)

hadoop-up:
	@$(COMPOSE) --profile hadoop up -d --build hadoop

spark-up:
	@$(COMPOSE) --profile spark up -d --build spark

integration-up:
	@if [ '$(PROFILE)' = '8' ]; then echo '8 Go: Hadoop et Spark doivent être utilisés séparément.'; exit 2; fi
	@$(COMPOSE) --profile hadoop --profile spark up -d --build hadoop spark

hive-up:
	@if [ '$(PROFILE)' = '8' ]; then 		$(COMPOSE) --profile hadoop --profile hive-lite up -d --build hadoop hive-lite; 	else 		$(COMPOSE) --profile hadoop --profile hive-full up -d --build hadoop postgres metastore hive-full; 	fi

hive-shell:
	@if [ '$(PROFILE)' = '8' ]; then 		$(COMPOSE) exec hive-lite beeline -u 'jdbc:hive2://localhost:10000/default'; 	else 		$(COMPOSE) exec hive-full beeline -u 'jdbc:hive2://localhost:10000/default'; 	fi

hive-test:
	@if [ '$(PROFILE)' = '8' ]; then 		bash scripts/test-hive.sh "$(COMPOSE)" hive-lite; 	else 		bash scripts/test-hive.sh "$(COMPOSE)" hive-full; 	fi

hive-spark-up:
	@if [ '$(PROFILE)' = '8' ]; then echo 'Hive + Spark simultanés nécessitent PROFILE=16 ou plus.'; exit 2; fi
	@$(COMPOSE) --profile hadoop --profile spark --profile hive-full up -d --build hadoop spark postgres metastore hive-full

hive-spark-test:
	@if [ '$(PROFILE)' = '8' ]; then echo 'Hive + Spark simultanés nécessitent PROFILE=16 ou plus.'; exit 2; fi
	@bash scripts/test-hive-spark.sh "$(COMPOSE)" hive-full

cluster-up:
	@if [ '$(PROFILE)' != 'plus' ]; then echo 'Cluster multi-DataNode réservé à PROFILE=plus'; exit 2; fi
	@$(COMPOSE) --profile hadoop --profile cluster up -d --build hadoop worker2

status:
	@$(COMPOSE) ps -a

stats:
	@docker stats --no-stream

images:
	@docker image ls 'bigdata-lab/*'

logs-hadoop:
	@$(COMPOSE) logs --tail=100 hadoop

logs-spark:
	@$(COMPOSE) logs --tail=100 spark

logs-hive:
	@if [ '$(PROFILE)' = '8' ]; then $(COMPOSE) logs --tail=150 hive-lite; else $(COMPOSE) logs --tail=150 hive-full metastore postgres; fi

test-hdfs:
	@bash scripts/test-hdfs.sh "$(COMPOSE)"

test-mapreduce:
	@bash scripts/test-mapreduce.sh "$(COMPOSE)"

test-spark:
	@$(COMPOSE) exec -T spark spark-submit --master 'local[2]' --driver-memory 1g /workspace/tp/03-spark-rdd/wordcount.py
	@$(COMPOSE) exec -T spark spark-submit --master 'local[2]' --driver-memory 1g /workspace/tp/04-spark-sql/analytics.py

test-integration:
	@if [ '$(PROFILE)' = '8' ]; then echo 'Integration requires PROFILE=16 or plus'; exit 2; fi
	@$(COMPOSE) exec -T hadoop hdfs dfs -mkdir -p /tp/integration
	@$(COMPOSE) exec -T hadoop hdfs dfs -put -f /workspace/datasets/sales.csv /tp/integration/sales.csv
	@$(COMPOSE) exec -T spark spark-submit --master 'local[2]' --driver-memory 1g /workspace/tp/05-spark-hdfs/read_hdfs.py

down:
	@$(COMPOSE) --profile hadoop --profile spark --profile hive-lite --profile hive-full --profile cluster down

reset:
	@echo 'CAUTION: this deletes HDFS, Derby and PostgreSQL Hive metadata volumes.'
	@$(COMPOSE) --profile hadoop --profile spark --profile hive-lite --profile hive-full --profile cluster down -v

student-pull:
	@$(STUDENT_COMPOSE) --profile hadoop --profile spark --profile hive-lite --profile hive-full --profile cluster pull

student-hadoop-up:
	@$(STUDENT_COMPOSE) --profile hadoop up -d hadoop

student-spark-up:
	@$(STUDENT_COMPOSE) --profile spark up -d spark

student-hive-up:
	@if [ '$(PROFILE)' = '8' ]; then 		$(STUDENT_COMPOSE) --profile hadoop --profile hive-lite up -d hadoop hive-lite; 	else 		$(STUDENT_COMPOSE) --profile hadoop --profile hive-full up -d hadoop postgres metastore hive-full; 	fi

student-hive-spark-up:
	@if [ '$(PROFILE)' = '8' ]; then echo 'Hive + Spark simultanés nécessitent PROFILE=16 ou plus.'; exit 2; fi
	@$(STUDENT_COMPOSE) --profile hadoop --profile spark --profile hive-full up -d hadoop spark postgres metastore hive-full

student-cluster-up:
	@if [ '$(PROFILE)' != 'plus' ]; then echo 'Cluster multi-DataNode réservé à PROFILE=plus'; exit 2; fi
	@$(STUDENT_COMPOSE) --profile hadoop --profile cluster up -d hadoop worker2

student-status:
	@$(STUDENT_COMPOSE) ps -a

student-down:
	@$(STUDENT_COMPOSE) --profile hadoop --profile spark --profile hive-lite --profile hive-full --profile cluster down

student-test-hdfs:
	@bash scripts/test-hdfs.sh "$(STUDENT_COMPOSE)"

student-test-mapreduce:
	@bash scripts/test-mapreduce.sh "$(STUDENT_COMPOSE)"

student-test-spark:
	@$(STUDENT_COMPOSE) exec -T spark spark-submit --master 'local[2]' --driver-memory 1g /workspace/tp/03-spark-rdd/wordcount.py
	@$(STUDENT_COMPOSE) exec -T spark spark-submit --master 'local[2]' --driver-memory 1g /workspace/tp/04-spark-sql/analytics.py

student-test-hive:
	@if [ '$(PROFILE)' = '8' ]; then 		bash scripts/test-hive.sh "$(STUDENT_COMPOSE)" hive-lite; 	else 		bash scripts/test-hive.sh "$(STUDENT_COMPOSE)" hive-full; 	fi

student-test-integration:
	@if [ '$(PROFILE)' = '8' ]; then echo 'Integration requires PROFILE=16 or plus'; exit 2; fi
	@$(STUDENT_COMPOSE) exec -T hadoop hdfs dfs -mkdir -p /tp/integration
	@$(STUDENT_COMPOSE) exec -T hadoop hdfs dfs -put -f /workspace/datasets/sales.csv /tp/integration/sales.csv
	@$(STUDENT_COMPOSE) exec -T spark spark-submit --master 'local[2]' --driver-memory 1g /workspace/tp/05-spark-hdfs/read_hdfs.py

student-test-cluster:
	@if [ '$(PROFILE)' != 'plus' ]; then echo 'Cluster validation requires PROFILE=plus'; exit 2; fi
	@bash scripts/test-cluster.sh "$(STUDENT_COMPOSE)"

student-test-resources:
	@bash scripts/test-resources.sh "$(STUDENT_COMPOSE)"

student-test-all:
	@bash scripts/student-test-all.sh "$(PROFILE)" "$(STUDENT_COMPOSE)"
