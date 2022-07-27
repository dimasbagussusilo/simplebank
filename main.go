package main

import (
	"database/sql"
	"github.com/dbsSensei/simplebank/util"
	"log"

	"github.com/dbsSensei/simplebank/api"
	db "github.com/dbsSensei/simplebank/db/sqlc"
	_ "github.com/lib/pq"
)

func main() {
	config, err := util.LoadConfig("./")
	if err != nil {
		log.Fatal("cannot load config:", err)
	}

	conn, err := sql.Open(config.DBDriver, config.DBSource)
	if err != nil {
		log.Fatal("cannot connect to db:", err)
	}

	store := db.NewStore(conn)
	server := api.NewServer(store)

	err = server.Start(config.ServerAddress)
	log.Fatal("cannot start server:", err)

}
