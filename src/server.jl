using HttpServer

"""
A `FujiServer` represents the webserver itself. There currently should only ever
be one of these, but this may be changed later. It currently has three fields:

* `after`: An optional block of code that may be run after requests are
    evaluated
* `before`: An optional block of code that may be run before requests are
    evaluated
* `routes`: An array of the routes that the server is currently serving
"""
type FujiServer
    after::Nullable{Function}
    before::Nullable{Function}
    routes::Array{Route,1}
end

"""
    after(action)

Adds a block of code that will be evaluated after each request. Can read the
request and read/modify the response.

# Examples

```julia-repl
julia> after() do req, res
           println(req.resource, " was hit")
       end
(::#1) (generic function with 1 method)
```
"""
after(action::Function) = server.after = action

"""
    before(action)

Adds a block of code that will be evaluated before each request. Can read the
request and read/modify the response.

# Examples

```julia-repl
julia> before() do req, res
           println(req.resource, " will be hit")
       end
(::#1) (generic function with 1 method)
```
"""
before(action::Function) = server.before = action

"""
    route(action, endpoint[, methods])

Adds a route to the Fuji webserver. Assumes that the route is only for GET
requests by default, but passing `methods` will allow you to specify multiple
HTTP methods.

# Examples

```julia-repl
julia> route("/hello") do req, res
           "hi there!"
       end
Fuji.Route(#1, "/hello", String["GET"])
```

```julia-repl
julia> route("/hello", ["GET", "POST"]) do req, res
           "hi there!"
       end
Fuji.Route(#1, "/hello", String["GET", "POST"])
```
"""
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

"""
    post(action, endpoint)

Adds a POST route to the Fuji webserver.

# Examples

```julia-repl
julia> post("/hello") do req, res
           "hello"
       end
Fuji.Route(#1, "/hello", String["POST"])
```
"""
post(action::Function, endpoint::String) = route(action, endpoint, ["POST"])


"""
    put(action, endpoint)

Adds a PUT route to the Fuji webserver.

# Examples

```julia-repl
julia> put("/hello") do req, res
           "hello"
       end
Fuji.Route(#1, "/hello", String["PUT"])
```
"""
put(action::Function, endpoint::String) = route(action, endpoint, ["PUT"])


"""
    patch(action, endpoint)

Adds a PATCH route to the Fuji webserver.

# Examples

```julia-repl
julia> patch("/hello") do req, res
           "hello"
       end
Fuji.Route(#1, "/hello", String["PATCH"])
```
"""
patch(action::Function, endpoint::String) = route(action, endpoint, ["PATCH"])


"""
    delete(action, endpoint)

Adds a DELETE route to the Fuji webserver.

# Examples

```julia-repl
julia> delete("/hello") do req, res
           "hello"
       end
Fuji.Route(#1, "/hello", String["DELETE"])
```
"""
delete(action::Function, endpoint::String) = route(action, endpoint, ["DELETE"])

"""
    unroute(route)

Removes a route from the Fuji webserver. If other routes exist with the same
endpoint but with different HTTP methods, those will be preserved.

# Examples

```julia-repl
julia> r = route("/hello") do req, res
           "hello"
       end
Fuji.Route(#1, "/hello", String["GET"])

julia> unroute(r)
0-element Array{Fuji.Route,1}
```
"""
function unroute(route::Route)
    # remove all routes with the same endpoint as the one that was just passed
    filter!(server.routes) do r
        if r.endpoint == route.endpoint
            return length(intersect(r.methods, route.methods)) == 0
        end

        true
    end
end

"""
    start([host, port])

Starts the Fuji webserver so it can begin receiving and interpreting requests.

# Examples

```julia-repl
julia> Fuji.start()
 * Running on http://127.0.0.1:8000/ (Press CTRL+C to quit)
```

```julia-repl
jjulia> Fuji.start(IPv4(127, 0, 0, 1), 8001)
 * Running on http://127.0.0.1:8001/ (Press CTRL+C to quit)
```
"""
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
