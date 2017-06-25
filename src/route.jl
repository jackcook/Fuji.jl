import Base.ismatch

immutable Route
    action::Function
    endpoint::AbstractString
end

function ismatch(route::Route, request::Request)
    named_param_regex = r":[A-z0-9\-_]+"
    splat_param_regex = r"\*"
    component_string = "([A-z0-9\\-_]+)"

    # Replace named parameters with regex string to see if it matches the request
    endpoint = replace(route.endpoint, named_param_regex, component_string)

    # Replace splat parameters with regex string to see if it matches the request
    endpoint = replace(endpoint, splat_param_regex, component_string)

    endpoint_regex = Regex(string("^", endpoint, "\$"))
    return ismatch(endpoint_regex, request.resource)
end
