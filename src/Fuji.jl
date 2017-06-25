module Fuji

using HttpServer

include("route.jl")
include("request.jl")

export FujiRequest, FujiServer, route, server, start, unroute

type FujiServer
    routes::Array{Route,1}
    on::Bool
end

server = FujiServer(Array{Route,1}(), false)

log(str...) = println(str...)
warn(str...) = println("WARNING: ", str...)

function route(action::Function, endpoint::AbstractString)
    route = Route(action, endpoint)

    # ensure that there is only one route with a given endpoint
    before = size(server.routes, 1)
    unroute(route)
    after = size(server.routes, 1)

    if before > after
        warn("There was already a route with the endpoint ", endpoint, ". Removing the previous one now...")
    end

    push!(server.routes, route)

    route
end

function unroute(route::Route)
    filter!(r -> r.endpoint != route.endpoint, server.routes)
end

function start(host=IPv4(127, 0, 0, 1), port=8000)
    http = HttpHandler() do req, res
        timestamp = Dates.format(now(), "u d, yyyy HH:MM:SS")

        response = Response(404)

        for route in server.routes
            if ismatch(route, req)
                request = FujiRequest(route, req)
                response = Response(route.action(request))
                break
            end
        end

        log("[", timestamp, "] ", req.method, " ", req.resource, " -> ", response.status)

        response
    end

    http.events["listen"] = (saddr) -> log(" * Running on http://$saddr/ (Press CTRL+C to quit)")

    server.on = true
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
