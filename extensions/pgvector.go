package extensions

import (
	"fmt"

	"postgres-extensor/instance"
	"postgres-extensor/plyd"
)

var pgvector = plyd.New(
	"pgvector",
	plyd.NewHandlersList(
		plyd.NewHandler(">=14.0.0, <19.0.0", func(ins *instance.InstanceInfo) error {
			err := plyd.Run(
				"git clone --branch v0.8.2 --depth 1 " +
					"https://github.com/pgvector/pgvector.git /tmp/pgvector",
			)
			if err != nil {
				return err
			}
			err = plyd.Run("cd /tmp/pgvector && make && make install")
			if err != nil {
				return err
			}

			// Verify installation
			if err := plyd.Run("ls $(pg_config --sharedir)/extension/vector.control > /dev/null"); err != nil {
				return fmt.Errorf("failed to verify pgvector installation: %w", err)
			}

			return plyd.Run("rm -rf /tmp/pgvector")
		}),
	),
)
