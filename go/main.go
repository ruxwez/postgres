package main

import (
	"log"
	"postgres-extensor/extensions"
	"postgres-extensor/instance"
)

func main() {

	var ins = instance.New()

	for _, playground := range extensions.Playgrounds {
		err := playground.Run(ins)
		if err != nil {
			log.Fatalf("[PLYD]: Error installing '%s' for PostgreSQL '%s'. Error: %v", playground.Name, ins.PGVersion, err)
		}
	}
}
