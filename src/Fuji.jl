module Fuji

using HttpServer

include("log.jl")
include("route.jl")
include("request.jl")

export FujiRequest, FujiServer, after, before, delete, get, patch, post, put, route, start, unroute

type FujiServer
    after::Nullable{Function}
    before::Nullable{Function}
    routes::Array{Route,1}
end

server = FujiServer(Nullable{Function}(), Nullable{Function}(), Array{Route,1}())

after(action::Function) = server.after = action
before(action::Function) = server.before = action

function route(action::Function, endpoint::String, methods::Array{String,1}=["GET"])
    route = Route(action, endpoint, methods)

    # ensure that there is only one route with a given endpoint
    before = size(server.routes, 1)
    unroute(route)
    after = size(server.routes, 1)

    if before > after
        warn("There was already a route with the endpoint ", endpoint, ". Removing the previous one now...")
    end

    # add the route to the routes list, effectively turning it on
    push!(server.routes, route)

    route
end

post(action::Function, endpoint::String) = route(action, endpoint, ["POST"])
put(action::Function, endpoint::String) = route(action, endpoint, ["PUT"])
patch(action::Function, endpoint::String) = route(action, endpoint, ["PATCH"])
delete(action::Function, endpoint::String) = route(action, endpoint, ["DELETE"])

function unroute(route::Route)
    # remove all routes with the same endpoint as the one that was just passed
    filter!(server.routes) do r
        if r.endpoint == route.endpoint
            return length(intersect(r.methods, route.methods)) == 0
        end

        true
    end
end

function start(host=IPv4(127, 0, 0, 1), port=8000)
    http = HttpHandler() do req, res
        timestamp = Dates.format(now(), "u d, yyyy HH:MM:SS")
        request = FujiRequest(req)
        route_found = false

        for route in server.routes
            if ismatch(req, route)
                request = FujiRequest(req, route)

                if !isnull(server.before)
                    server.before.value(request, res)
                end

                value = route.action(request, res)

                if isa(value, Int64)
                    res.status = value
                elseif isa(value, AbstractString)
                    res.data = value
                end

                route_found = true

                break
            end
        end

        if !route_found
            if !isnull(server.before)
                server.before.value(request, res)
            end

            res.status = 404
        end

        log("[", timestamp, "] ", request.method, " ", request.resource, " -> ", res.status)

        if !isnull(server.after)
            server.after.value(request, res)
        end

        res
    end

    http.events["listen"] = (saddr) -> log(" * Running on http://$saddr/ (Press CTRL+C to quit)")
    web_server = Server(http)

    try
        run(web_server, host=host, port=port)
    catch e
        if isa(e, InterruptException)
            log("Stopping server...")
        end
    end
end

end
