package extensions

import (
	"fmt"

	"postgres-extensor/instance"
	"postgres-extensor/plyd"
)

var buildDepsRemove = plyd.New(
	"build-deps-remove",
	plyd.NewHandlersList(
		plyd.NewHandler(">=14.0.0, <19.0.0", func(ins *instance.InstanceInfo) error {
			if err := plyd.Run(fmt.Sprintf(
				"apt-get remove -y -qq git make gcc postgresql-server-dev-%s",
				ins.PostgreSQL.Mayor,
			)); err != nil {
				return err
			}
			return plyd.Run("apt-get autoremove -y -qq && apt-get clean && rm -rf /var/lib/apt/lists/*")
		}),
	),
)
