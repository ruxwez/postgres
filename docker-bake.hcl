# Single source of truth for which images are built and how they're tagged.
#
#   docker buildx bake --print                  # show every target
#   docker buildx bake pg-17                    # build one version
#   RELEASE=1.4.0 docker buildx bake --print    # tags of a release build

variable "IMAGE" {
  default = "ruxwez/postgres"
}

# Newest supported major. It is also published as :latest.
variable "LATEST" {
  default = "18"
}

# Project version (semver, without the leading "v"). Set by CI when a vX.Y.Z
# git tag is pushed; empty for regular builds.
variable "RELEASE" {
  default = ""
}

# Upstream source, revision and version in the standard OCI labels.
variable "REVISION" {
  default = ""
}

function "release_tags" {
  params = [major]
  result = RELEASE == "" ? [] : [
    "${IMAGE}:${major}-v${RELEASE}",                     # immutable
    "${IMAGE}:${major}-v${split(".", RELEASE)[0]}",      # compatible updates
  ]
}

target "pg" {
  name   = "pg-${major}"
  matrix = {
    major = ["14", "15", "16", "17", "18"]
  }
  args = {
    POSTGRES_VERSION = major
  }
  tags = concat(
    ["${IMAGE}:${major}"],
    major == LATEST ? ["${IMAGE}:latest"] : [],
    release_tags(major),
  )
  labels = {
    "org.opencontainers.image.source"   = "https://github.com/ruxwez/postgres"
    "org.opencontainers.image.version"  = RELEASE
    "org.opencontainers.image.revision" = REVISION
  }
}

group "default" {
  targets = ["pg"]
}
