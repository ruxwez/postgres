package plyd

import (
	"fmt"
	"log"

	"postgres-extensor/instance"

	"github.com/Masterminds/semver/v3"
)

type Playground struct {
	Name     string
	handlers HandlersList
}

func New(name string, handlers HandlersList) *Playground {
	return &Playground{
		Name:     name,
		handlers: handlers,
	}
}

// Match the instance's PostgreSQL version to the appropriate handler
func (p *Playground) matchHandler(v string) (HandlerFunc, error) {

	for _, h := range p.handlers {
		if h.Range == v {
			return h.Runner, nil
		}
	}

	version, err := semver.NewVersion(v)
	if err != nil {
		return nil, fmt.Errorf("Invalid version: %s", v)
	}

	for _, h := range p.handlers {
		constraint, err := semver.NewConstraint(h.Range)
		if err != nil {
			continue
		}
		if constraint.Check(version) {
			return h.Runner, nil
		}
	}

	return nil, fmt.Errorf("No handler found for version %s", v)
}

// Execute the playground with the given instance information
func (p *Playground) Run(ins *instance.InstanceInfo) error {

	log.Printf("[PLYD]: Installing '%s' for PostgreSQL '%s'", p.Name, ins.PostgreSQL.Version)

	handler, err := p.matchHandler(string(ins.PostgreSQL.Version))
	if err != nil {
		return err
	}

	err = handler(ins)
	if err != nil {
		return err
	}

	log.Printf("[PLYD]: Successfully installed '%s' for PostgreSQL '%s'", p.Name, ins.PostgreSQL.Version)

	return nil
}
