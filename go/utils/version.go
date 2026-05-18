package utils

import (
	"fmt"

	"github.com/Masterminds/semver/v3"
)

func NormalizeVersion(v string) (string, error) {
	ver, err := semver.NewVersion(v)
	if err != nil {
		return "", fmt.Errorf("Invalid version: %s", v)
	}
	return ver.String(), nil
}

func ValidateVersionRange(rng string) error {
	_, err := semver.NewConstraint(rng)
	return err
}
