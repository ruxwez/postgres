package extensions

import (
	"log"
	"postgres-extensor/instance"
	"postgres-extensor/plyd"
)

var pgmq = plyd.New(
	"pgmq",
	plyd.NewHandlersList(
		plyd.NewHandler("v16.0.0", func(ins *instance.InstanceInfo) error {
			log.Println("v16.0.0")
			return nil
		}),
		plyd.NewHandler("<=16.0.0", func(ins *instance.InstanceInfo) error {
			log.Println("<=16.0.0")
			return nil
		}),
		plyd.NewHandler(">=16.0.0, <=17.10", func(ins *instance.InstanceInfo) error {
			log.Println(">=16.0.0, <=17.0")
			return nil
		}),
	),
)
