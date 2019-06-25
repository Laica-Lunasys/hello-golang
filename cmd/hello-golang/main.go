package main

import (
	"log"
	"os"

	"github.com/Laica-Lunasys/hello-golang/database"
	"github.com/Laica-Lunasys/hello-golang/server"
)

func startHTTP(s server.Server, port string) error {
	return server.NewHTTPServer(s).Start(port)
}

func main() {
	s := server.NewServer()
	wait := make(chan struct{})

	// postgresql
	go func() {
		database.Init()
	}()

	go func() {
		defer close(wait)
		port := os.Getenv("HTTP_LISTEN_PORT")
		if len(port) == 0 {
			port = ":8080"
		}
		if err := startHTTP(s, port); err != nil {
			log.Fatalf("HTTP ERROR: %s", err)
		}
	}()
	<-wait
}
