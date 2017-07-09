"""
    render_template(filename[, args])

Renders a Fuji template from a template file. This file can contain valid Julia
expressions and reference variables passed through the `args` parameter. This
can be very useful for creating webpages with dynamic content.

# Examples

hello.txt contents: <p>Hello, {% name %}!</p>

```julia-repl
julia> render_template("hello.txt", Dict("name" => "Jack"))
"<p>Hello, Jack!</p>"
```
"""
function render_template(filename, args = Dict{String,String}())
    f = open(filename)
    lines = readlines(f)
    close(f)

    content = ""
    expression_regex = r"{%([^%]+)%}"

    for (idx, line) in enumerate(lines)
        if ismatch(expression_regex, line)
            matches = eachmatch(expression_regex, line)

            for match in matches
                expression = match.captures[1]
                result = expression

                try
                    result = eval(parse(expression))
                catch e
                    if isa(e, UndefVarError)
                        result = args[strip(expression)]
                    end
                end

                line = replace(line, string("{%", expression, "%}"), result)
            end
        end

        content = string(content, line, "\n")
    end

    content
end
