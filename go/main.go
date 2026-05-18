package main

import (
	"postgres-extensor/extensions"
	"postgres-extensor/instance"
)

func main() {

	var ins = instance.New()

	err := extensions.PGMQ.Run(ins)
	if err != nil {
		panic(err)
	}

}
