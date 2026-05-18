package extensions

import "postgres-extensor/plyd"

var Playgrounds = []*plyd.Playground{
	buildDepsInstall,
	pgmq,
	pgvector,
	buildDepsRemove,
}
