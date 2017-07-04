using HttpServer

import Base.ismatch

"""
A `Route` represents an endpoint on the Fuji webserver. It currently has three
fields:

* `action`: The block of code that will be run when the endpoint is hit. The
    request and response are both passed to it
* `endpoint`: The endpoint that this route serves
* `methods`: The HTTP methods that this route should serve (e.g. GET, POST)
"""
immutable Route
    action::Function
    endpoint::String
    methods::Array{String,1}
end

"""
    ismatch(request, route)

Returns true if this route 'matches' this request, false if it doesn't. Note
that this is a request from HttpCommon, not from Fuji.
"""
function ismatch(request::Request, route::Route)
    if in(request.method, route.methods)
        named_param_regex = r":[A-z0-9\-_]+"
        splat_param_regex = r"\*"
        component_string = "([A-z0-9\\-_]+)"

        # Replace named parameters with regex string to see if it matches the request
        endpoint = replace(route.endpoint, named_param_regex, component_string)

        # Replace splat parameters with regex string to see if it matches the request
        endpoint = replace(endpoint, splat_param_regex, component_string)

        endpoint_regex = Regex(string("^", endpoint, "\$"))
        return ismatch(endpoint_regex, split(request.resource, "?")[1])
    end

    false
end
