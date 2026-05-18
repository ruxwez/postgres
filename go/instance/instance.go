package instance

import (
	"os/exec"
	"regexp"
	"runtime"
	"strings"

	"postgres-extensor/utils"
)

type PGVersion string

type InstanceInfo struct {
	PGVersion PGVersion
	OS        string
	Arch      string
}

func detectPGVersion() PGVersion {
	out, err := exec.Command("postgres", "--version").Output()
	if err != nil {
		panic("Failed to detect PostgreSQL version: " + err.Error())
	}

	re := regexp.MustCompile(`([\d.]+)`)
	match := re.FindString(strings.TrimSpace(string(out)))
	if match == "" {
		panic("Failed to parse PostgreSQL version from: " + string(out))
	}

	normalized, err := utils.NormalizeVersion(match)
	if err != nil {
		panic("Failed to normalize PostgreSQL version from: " + string(out) + ": " + err.Error())
	}

	return PGVersion(normalized)
}

func New() *InstanceInfo {
	if runtime.GOOS != "linux" {
		panic("This software only runs on Linux")
	}

	return &InstanceInfo{
		PGVersion: detectPGVersion(),
		OS:        runtime.GOOS,
		Arch:      runtime.GOARCH,
	}
}
