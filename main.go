package main

import (
	"postgres-extensor/extensions"
	"postgres-extensor/instance"
)

func main() {

	var ins = instance.New()

	for _, playground := range extensions.Playgrounds {
		playground.Run(ins)
	}
}
