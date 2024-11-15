package = "kong-plugin-path-prefix"
version = "0.2.0-1"

local pluginName = "path-prefix"

supported_platforms = {"linux", "macosx"}
source = {
  url = "git@github.com:liyangau/kong-plugin-path-prefix.git",
  tag = "0.2.0"
}

description = {
  summary = "A Kong plugin for rewriting upstream route uris.",
  license = "MIT"
}

dependencies = {}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins.path-prefix.handler"] = "kong/plugins/path-prefix/handler.lua",
    ["kong.plugins.path-prefix.schema"] = "kong/plugins/path-prefix/schema.lua",
  }
}
