type FujiRequest
    params::Dict{String,String}

    FujiRequest(params=Dict{String,String}()) = new(params)

    FujiRequest(route::Route, request::Request) = begin
        req = new()

        splat_param_regex = r":([A-z0-9\-_]+)"

        if ismatch(splat_param_regex, route.endpoint)
            params = Dict{String,String}()

            splat_names = Array{String,1}()
            splat_values = Array{String,1}()

            endpoint = route.endpoint

            while ismatch(splat_param_regex, endpoint)
                m = match(splat_param_regex, endpoint)
                push!(splat_names, m.captures[1])

                endpoint = replace(route.endpoint, splat_param_regex, m.captures[1])
            end

            regex_endpoint = Regex(string("^", replace(route.endpoint, splat_param_regex, "([A-z0-9\\-_]+)"), "\$"))
            resource_match = match(regex_endpoint, request.resource)

            for capture in resource_match.captures
                push!(splat_values, capture)
            end

            for i in 1:length(splat_names)
                params[splat_names[i]] = splat_values[i]
            end

            req.params = params
        end

        req
    end
end
