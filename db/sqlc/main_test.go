package db

import (
	"database/sql"
	"github.com/dbsSensei/simplebank/util"
	"log"

	_ "github.com/lib/pq"
	"os"
	"testing"
)

var testQueries *Queries
var testDB *sql.DB

func TestMain(m *testing.M) {
	var err error

	config, err := util.LoadConfig("../../")

	testDB, err = sql.Open(config.DBDriver, config.DBSource)
	if err != nil {
		log.Fatal("cannot connect to db:", err)
	}

	testQueries = New(testDB)

	os.Exit(m.Run())
}
