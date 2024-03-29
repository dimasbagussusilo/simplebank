banknetwork:
	sudo docker network create bank-network

postgres:
	sudo docker run --name postgres14 --network bank-network -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret -d postgres:14.4-alpine

postgresrestart:
	sudo docker restart postgres14

createdb:
	sudo docker exec -t postgres14 createdb --username=root --owner=root simple_bank

dropdb:
	sudo docker exec -t postgres14 dropdb simple_bank

migrateup:
	migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simple_bank?sslmode=disable" -verbose up

migratedown:
	migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simple_bank?sslmode=disable" -verbose down

sqlc:
	sqlc generate

test:
	go test -v -cover ./...

server:
	go run main.go

mock:
	mockgen -build_flags=--mod=mod -package mockdb -destination db/mock/store.go github.com/dbsSensei/simplebank/db/sqlc Store

dockerbuild:
	sudo docker build -t simplebank:latest .

dockerserver:
	sudo docker run --name simplebank --network bank-network -p 8080:8080 -e GIN_MODE=release -e DB_SOURCE="postgresql://root:secret@postgres14:5432/simple_bank?sslmode=disable" simplebank:latest

proto:
	rm -f pb/*.go
	rm -f doc/swagger/*.swagger.json
	protoc --proto_path=proto --go_out=pb --go_opt=paths=source_relative \
		--go-grpc_out=pb --go-grpc_opt=paths=source_relative \
		--grpc-gateway_out=pb --grpc-gateway_opt=paths=source_relative \
		--openapiv2_out=doc/swagger --openapiv2_opt=allow_merge=true,merge_file_name=simple_bank \
		--experimental_allow_proto3_optional \
		proto/*.proto
		statik -src=./doc/swagger -dest=./doc

evans:
	evans --host localhost --port 9090 -r repl

.PHONY: postgres postgresrestart createdb dropdb migrateup migratedown sqlc test server mock proto evans