package extensions

import (
	"fmt"
	"postgres-extensor/instance"
	"postgres-extensor/plyd"
)

var PGMQ = plyd.New(
	"pgmq",
	plyd.NewHandlersList(
		plyd.NewHandler("v16.0.0", func(ins *instance.InstanceInfo) error {
			fmt.Println("v16.0.0")
			return nil
		}),
		plyd.NewHandler("<=16.0.0", func(ins *instance.InstanceInfo) error {
			fmt.Println("<=16.0.0")
			return nil
		}),
		plyd.NewHandler(">=16.0.0, <=17.10", func(ins *instance.InstanceInfo) error {
			fmt.Println(">=16.0.0, <=17.0")
			return nil
		}),
	),
)
