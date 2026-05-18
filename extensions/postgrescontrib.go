package extensions

import (
	"fmt"

	"postgres-extensor/instance"
	"postgres-extensor/plyd"
)

var postgresContrib = plyd.New(
	"postgres-contrib",
	plyd.NewHandlersList(
		plyd.NewHandler(">=14.0.0, <19.0.0", func(ins *instance.InstanceInfo) error {
			// In Debian/Ubuntu pgdg distributions, contrib modules are bundled within the main postgresql package.
			pkg := fmt.Sprintf("postgresql-%s", ins.PostgreSQL.Mayor)
			if err := plyd.Run(fmt.Sprintf("apt-get install -y -qq %s", pkg)); err != nil {
				return err
			}
			
			// Verify installation using a standard contrib module like pg_stat_statements
			if err := plyd.Run("ls $(pg_config --sharedir)/extension/pg_stat_statements.control > /dev/null"); err != nil {
				return fmt.Errorf("failed to verify postgres-contrib installation: %w", err)
			}

			return nil
		}),
	),
)
