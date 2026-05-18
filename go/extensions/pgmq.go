package extensions

import (
	"postgres-extensor/instance"
	"postgres-extensor/plyd"
)

var pgmq = plyd.New(
	"pgmq",
	plyd.NewHandlersList(
		plyd.NewHandler(">=14.0.0, <19.0.0", func(ins *instance.InstanceInfo) error {
			err := plyd.Run(
				"git clone --branch v1.11.1 --depth 1 " +
					"https://github.com/pgmq/pgmq.git /tmp/pgmq",
			)
			if err != nil {
				return err
			}
			err = plyd.Run("cd /tmp/pgmq/pgmq-extension && make && make install")
			if err != nil {
				return err
			}
			return plyd.Run("rm -rf /tmp/pgmq")
		}),
	),
)
