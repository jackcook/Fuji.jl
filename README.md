# Fuji

A lightweight web server written in Julia.

[![Build Status](https://travis-ci.org/jackcook/Fuji.jl.svg?branch=master)](https://travis-ci.org/jackcook/Fuji.jl)
[![Coveralls](https://coveralls.io/repos/github/jackcook/Fuji.jl/badge.svg?branch=master)](https://coveralls.io/github/jackcook/Fuji.jl)

## Quickstart

```julia
using Fuji

route("/hi") do req, res
    "hi!"
end

route("/hello/:name") do req, res
    string("hello, ", req.params["name"], "!")
end

Fuji.start()
```

## License

Fuji is available under the MIT license. See the LICENSE file for details.
