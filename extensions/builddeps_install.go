package extensions

import (
	"fmt"

	"postgres-extensor/instance"
	"postgres-extensor/plyd"
)

var buildDepsInstall = plyd.New(
	"build-deps-install",
	plyd.NewHandlersList(
		plyd.NewHandler(">=13.0.0, <19.0.0", func(ins *instance.InstanceInfo) error {
			if err := plyd.Run("apt-get update -qq"); err != nil {
				return err
			}
			return plyd.Run(fmt.Sprintf(
				"apt-get install -y -qq git make gcc postgresql-server-dev-%s",
				ins.PostgreSQL.Mayor,
			))
		}),
	),
)
