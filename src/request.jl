type FujiRequest
    params::Dict{String,String}
    splat::Array{String,1}

    FujiRequest() = new(Dict{String,String}(), Array{String,1}())

    FujiRequest(route::Route, request::Request) = begin
        req = new()

        named_param_regex = r":([A-z0-9\-_]+)"
        splat_param_regex = r"\*"
        component_string = "([A-z0-9\\-_]+)"

        if ismatch(named_param_regex, route.endpoint)
            params = Dict{String,String}()

            named_names = Array{String,1}()
            named_values = Array{String,1}()

            endpoint = route.endpoint

            while ismatch(named_param_regex, endpoint)
                m = match(named_param_regex, endpoint)
                push!(named_names, m.captures[1])

                endpoint = replace(route.endpoint, named_param_regex, m.captures[1], 1)
            end

            regex_endpoint = Regex(string("^", replace(route.endpoint, named_param_regex, component_string), "\$"))
            resource_match = match(regex_endpoint, request.resource)

            for capture in resource_match.captures
                push!(named_values, capture)
            end

            for i in 1:length(named_names)
                params[named_names[i]] = named_values[i]
            end

            req.params = params
        end

        if contains(route.endpoint, "*")
            splat = Array{String,1}()

            regex_endpoint = Regex(string("^", replace(route.endpoint, splat_param_regex, component_string), "\$"))
            resource_match = match(regex_endpoint, request.resource)

            for capture in resource_match.captures
                push!(splat, capture)
            end

            req.splat = splat
        end

        req
    end
end
