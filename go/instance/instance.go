package instance

import (
	"os/exec"
	"regexp"
	"runtime"
	"strings"
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
		panic("failed to detect PostgreSQL version: " + err.Error())
	}

	re := regexp.MustCompile(`(\d+\.\d+)`)
	match := re.FindStringSubmatch(strings.TrimSpace(string(out)))
	if match == nil {
		panic("failed to parse PostgreSQL version from: " + string(out))
	}

	return PGVersion(match[1])
}

func New() *InstanceInfo {
	if runtime.GOOS != "linux" {
		panic("this software only runs on Linux")
	}

	return &InstanceInfo{
		PGVersion: detectPGVersion(),
		OS:        runtime.GOOS,
		Arch:      runtime.GOARCH,
	}
}
