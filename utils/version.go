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

// VersionLess returns true if a should be sorted before b.
// Specific versions come before ranges; both groups are sorted ascending.
func VersionLess(a, b string) bool {
	va, erra := semver.NewVersion(a)
	vb, errb := semver.NewVersion(b)

	switch {
	case erra == nil && errb == nil:
		return va.LessThan(vb)
	case erra == nil:
		return true
	case errb == nil:
		return false
	default:
		return a < b
	}
}
