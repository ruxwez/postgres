package utils

import (
	"fmt"
	"regexp"
)

func NormalizeVersion(v string) (string, error) {
	re := regexp.MustCompile(`(\d+)(?:\.(\d+))?(?:\.(\d+))?`)
	parts := re.FindStringSubmatch(v)
	if parts == nil || parts[0] == "" {
		return "", fmt.Errorf("no version found in: %s", v)
	}

	major := parts[1]
	minor := parts[2]
	patch := parts[3]

	version := major
	if minor != "" {
		version += "." + minor
	} else {
		version += ".0"
	}
	if patch != "" {
		version += "." + patch
	} else {
		version += ".0"
	}

	return version, nil
}


