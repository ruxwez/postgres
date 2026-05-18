package utils

import (
	"fmt"
	"strings"

	"golang.org/x/mod/semver"
)

func NormalizeVersion(v string) (string, error) {
	v = strings.TrimSpace(v)
	if !strings.HasPrefix(v, "v") {
		v = "v" + v
	}
	canonical := semver.Canonical(v)
	if canonical == "" {
		return "", fmt.Errorf("invalid version: %s", v)
	}
	return canonical, nil
}
