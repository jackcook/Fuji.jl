# Fuji

A lightweight web server written in Julia.

| **Documentation** | **PackageEvaluator** | **Build Status** |
|:-----------------:|:--------------------:|:----------------:|
| [![Stable Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://jackcook.github.io/Fuji.jl/stable) [![Latest Documentation](https://img.shields.io/badge/docs-latest-blue.svg)](https://jackcook.github.io/Fuji.jl/latest) | [![Julia v0.6 Tests](http://pkg.julialang.org/badges/Fuji_0.6.svg)](http://pkg.julialang.org/?pkg=Fuji&ver=0.6) | [![Build Status](https://travis-ci.org/jackcook/Fuji.jl.svg?branch=master)](https://travis-ci.org/jackcook/Fuji.jl) [![Coveralls](https://coveralls.io/repos/github/jackcook/Fuji.jl/badge.svg?branch=master)](https://coveralls.io/github/jackcook/Fuji.jl) |

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
