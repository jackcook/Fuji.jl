```@meta
Author = "Jack Cook"
```

# Fuji.jl

Fuji is a lightweight web framework written in [Julia](https://julialang.org).
It allows you to quickly build and iterate on web applications with relatively
few lines of code.

## Quickstart

```julia
using Fuji

route("/hello") do req, res
    "Hello, world!"
end

Fuji.start()
```

### See the result

```
http://localhost:8000/hello
```

## Built for productivity

Fuji allows you to get your next website/REST API up and running with minimal
boilerplate code forced upon you by many modern web frameworks. It also comes
with the benefit of running on Julia, one of the best up-and-coming programming
languages available. With over 1,000+ packages and a thriving community, Julia
serves as a great option for your next project.

## Contribute

Found a bug? Have a good idea for improving Fuji? Please feel free to create an
issue or pull request on our [GitHub repo](https://github.com/jackcook/Fuji.jl).
We are a young project, and will always be welcoming to new ideas and
contributions.
