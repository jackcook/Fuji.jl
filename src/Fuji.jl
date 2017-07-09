module Fuji

export
FujiRequest,
FujiServer,
after,
before,
delete,
get,
patch,
post,
put,
render_template,
route,
start,
unroute

include("log.jl")
include("route.jl")
include("request.jl")
include("server.jl")
include("template.jl")

server = FujiServer(Nullable{Function}(), Nullable{Function}(), Array{Route,1}())

end
