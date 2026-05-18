package plyd

import (
	"sort"

	"postgres-extensor/instance"
	"postgres-extensor/utils"
)

type HandlerFunc func(ins *instance.InstanceInfo) error

type Handler struct {
	Range  string
	Runner HandlerFunc
}

// NewHandler creates a new Handler with the specified version range and runner function.
func NewHandler(rng string, runner HandlerFunc) Handler {
	if err := utils.ValidateVersionRange(rng); err != nil {
		panic("Invalid handler range: " + err.Error())
	}

	return Handler{
		Range:  rng,
		Runner: runner,
	}
}

type HandlersList []Handler

// NewHandlersList sorts handlers with specific versions first, ranges last, ascending.
func NewHandlersList(handlers ...Handler) HandlersList {
	sort.Slice(handlers, func(i, j int) bool {
		return utils.VersionLess(handlers[i].Range, handlers[j].Range)
	})

	return handlers
}
