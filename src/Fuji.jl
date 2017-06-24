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

function route!(action::Function, server::FujiServer, path::AbstractString)
    route = Route(action, path)
    push!(server.routes, route)
end

function start(theserver::FujiServer)
    http = HttpHandler() do req::Request, res::Response
        for route in theserver.routes
            if route.path == req.resource
                return Response(route.action())
            end
        end

        Response(404)
    end

    server = Server(http)
    run(server, 8000)
end

end # module
