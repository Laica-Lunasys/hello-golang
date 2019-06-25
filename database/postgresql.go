package database

import (
	"database/sql"
	"fmt"

	"github.com/Laica-Lunasys/hello-golang/utils"
	_ "github.com/lib/pq"
)

type App struct {
	db *sql.DB
}

const DRIVER = "postgres"

var app *App

func Init() {
	psqlInfo := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		utils.Getenv("POSTGRES_HOST", "localhost"),
		utils.Getenv("POSTGRES_PORT", "5432"),
		utils.Getenv("POSTGRES_USER", "postgres"),
		utils.Getenv("POSTGRES_PASSWORD", "postgres"),
		utils.Getenv("POSTGRES_DB", "hello_golang"),
	)

	db, err := sql.Open(DRIVER, psqlInfo)
	if err != nil {
		panic(err)
	}

	if err := db.Ping(); err != nil {
		panic(err)
	}

	app = &App{
		db: db,
	}
}

func Close() {
	if app != nil {
		app.db.Close()
	}
}

func GetConn() *App {
	return app
}
