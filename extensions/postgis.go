package extensions

import (
	"fmt"

	"postgres-extensor/instance"
	"postgres-extensor/plyd"
)

var postgis = plyd.New(
	"postgis",
	plyd.NewHandlersList(
		plyd.NewHandler(">=14.0.0, <19.0.0", func(ins *instance.InstanceInfo) error {
			pkg := fmt.Sprintf("postgresql-%s-postgis-3", ins.PostgreSQL.Mayor)
			if err := plyd.Run(fmt.Sprintf("apt-get install -y -qq %s", pkg)); err != nil {
				return err
			}
			
			// Verify installation
			if err := plyd.Run("ls $(pg_config --sharedir)/extension/postgis.control > /dev/null"); err != nil {
				return fmt.Errorf("failed to verify postgis installation: %w", err)
			}

			return nil
		}),
	),
)
