import Base.ismatch

immutable Route
    action::Function
    endpoint::AbstractString
end

function ismatch(route::Route, request::Request)
    splat_param_regex = r":[A-z0-9\-_]+"

    if ismatch(splat_param_regex, route.endpoint)
        regex_endpoint = Regex(string("^", replace(route.endpoint, splat_param_regex, "([A-z0-9\\-_]+)"), "\$"))
        ismatch(regex_endpoint, request.resource)
    else
        route.endpoint == request.resource
    end
end
