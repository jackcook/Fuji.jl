using HttpServer

import Base.ismatch

immutable Route
    action::Function
    endpoint::String
    methods::Array{String,1}
end

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
        ismatch(endpoint_regex, request.resource)
    else
        false
    end
end
