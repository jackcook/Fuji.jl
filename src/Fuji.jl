module Fuji

using HttpServer

export FujiServer, route!, start

immutable Route
    action::Function
    path::AbstractString
end

type FujiServer
    routes::Array{Route,1}
end

FujiServer() = FujiServer(Route[])
log(str...) = println(str...)

function route!(action::Function, server::FujiServer, path::AbstractString)
    route = Route(action, path)
    push!(server.routes, route)
end

function start(server::FujiServer, host=IPv4(127, 0, 0, 1), port=8000)
    http = HttpHandler() do req, res
        timestamp = Dates.format(now(), "u d, yyyy HH:MM:SS")

        response = Response(404)

        for route in server.routes
            if route.path == req.resource
                response = Response(route.action())
            end
        end

        log("[", timestamp, "] ", req.method, " ", req.resource, " -> ", response.status)

        response
    end

    http.events["listen"] = (saddr) -> log(" * Running on http://$saddr/ (Press CTRL+C to quit)")

    web_server = Server(http)

    try
        run(web_server, host=host, port=port)
    catch e
        if isa(e, InterruptException)
            println("Stopping server...")
        end
    end
end

end
