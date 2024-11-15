local PathPrefixHandler = {PRIORITY = 800, VERSION = "0.2.0"}

local function escape_hyphen(path_prefix, should_escape)
  if should_escape then
    return string.gsub(path_prefix, "%-", "%%%1")
  end
  return path_prefix
end

function PathPrefixHandler:access(conf)
  local service_path = kong.router.get_service().path or ""
  local full_path = kong.request.get_path()
  local replace_match = escape_hyphen(conf.path_prefix, conf.escape)
  local path_without_prefix = full_path:gsub(replace_match, "", 1)

  if path_without_prefix == "" and service_path == "" then
    path_without_prefix = "/"
  end

  local new_path = path_without_prefix
  kong.log.debug("rewriting ", full_path, " to ", path_without_prefix)

  if service_path ~= "" then
    kong.log.debug("Prefixing request with service path ", service_path)
    new_path = service_path .. new_path
  end

  if conf.forwarded_header then
    kong.log.debug("Adding Header: X-Forwarded-Prefix ", conf.path_prefix)
    ngx.var.upstream_x_forwarded_prefix = conf.path_prefix
  end

  kong.service.request.set_path(new_path)
end

return PathPrefixHandler
