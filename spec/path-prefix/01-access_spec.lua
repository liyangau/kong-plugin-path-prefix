local PLUGIN_NAME = "path-prefix"
local helpers = require "spec.helpers"
local echo_url = "http://echo:8080/anything"

local strategies = helpers.all_strategies ~= nil and helpers.all_strategies or helpers.each_strategy

for _, strategy in strategies() do
  describe(
    "Plugin: " .. PLUGIN_NAME .. " (access) [#" .. strategy .. "]",
    function()
      local client
      local db_strategy = strategy ~= "off" and strategy or nil
      lazy_setup(
        function()
          local bp = helpers.get_db_utils(db_strategy, {}, {PLUGIN_NAME})
          local service1 =
            bp.services:insert {
            url = echo_url
          }
          local route1 =
            bp.routes:insert {
            service = service1,
            hosts = {
              "test1.test"
            },
            paths = {
              "/service-with-plugin-route/foobar"
            }
          }

          local route2 =
            bp.routes:insert {
            service = service1,
            hosts = {
              "test2.test"
            },
            paths = {
              "/service-with-plugin-route/foobar"
            }
          }
          local route3 =
            bp.routes:insert {
            hosts = {
              "test3.test"
            },
            paths = {
              "/service-with-plugin-route/foobar"
            }
          }

          bp.plugins:insert {
            route = {
              id = route1.id
            },
            name = PLUGIN_NAME,
            config = {
              path_prefix = "/service-with-plugin-route"
            }
          }

          bp.plugins:insert {
            route = {
              id = route2.id
            },
            name = PLUGIN_NAME,
            config = {
              path_prefix = "/service-with-plugin-route",
              escape = false
            }
          }

          bp.plugins:insert {
            route = {
              id = route3.id
            },
            name = PLUGIN_NAME,
            config = {
              path_prefix = "/service-with-plugin-route",
              forwarded_header = true
            }
          }

          assert(
            helpers.start_kong(
              {
                database = db_strategy,
                plugins = "bundled," .. PLUGIN_NAME,
                nginx_conf = "spec/fixtures/custom_nginx.template"
              }
            )
          )
        end
      )

      lazy_teardown(
        function()
          helpers.stop_kong()
        end
      )

      before_each(
        function()
          client = helpers.proxy_client()
        end
      )

      after_each(
        function()
          if client then
            client:close()
          end
        end
      )
      describe(
        "access test",
        function()
          it(
            "rewrite the path to the upstream from /service-with-plugin-route/foobar to /foobar",
            function()
              local res =
                assert(
                client:send {
                  method = "GET",
                  path = "/service-with-plugin-route/foobar",
                  headers = {
                    host = "test1.test"
                  }
                }
              )
              assert.response(res).has.status(200)
              local body = assert.response(res).has.jsonbody()
              assert.equals(echo_url .. "/foobar", body.url)
            end
          )
          it(
            "does not escape dash when escape option is false",
            function()
              local res =
                assert(
                client:send {
                  method = "GET",
                  path = "/service-with-plugin-route/foobar",
                  headers = {
                    host = "test2.test"
                  }
                }
              )
              assert.response(res).has.status(200)
              local body = assert(assert.response(res).has.jsonbody())
              assert.equals(echo_url .. "/service-with-plugin-route/foobar", body.url)
            end
          )
          it(
            "does not escape dash when escape option is false",
            function()
              local res =
                assert(
                client:send {
                  method = "GET",
                  path = "/service-with-plugin-route/foobar",
                  headers = {
                    host = "test3.test"
                  }
                }
              )
              local prefix = assert.request(res).has.header("x-forwarded-prefix")
              assert.equals("/service-with-plugin-route", prefix)
            end
          )
        end
      )
    end
  )
end
