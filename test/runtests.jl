using Base.Test
using Fuji
using Requests

get(endpoint) = Requests.get("http://localhost:8000$endpoint")

server = FujiServer()
@spawn Fuji.start(server)

@testset "simple route" begin
    @test size(server.routes, 1) == 0

    route!(server, "/hi") do req
        "hi"
    end

    @test size(server.routes, 1) == 1
    @test server.routes[1].endpoint == "/hi"

    @test get("").status == 404
    @test get("/hi").status == 200
end

@testset "splat param" begin
    route!(server, "/hello/:name") do req
        string("hello, ", req.params["name"], "!")
    end

    @test get("/hello/:name").status == 404
    @test get("/hello").status == 404
    @test get("/hello/jack/asdf").status == 404
    @test get("/hello/ja;ck").status == 404

    @test get("/hello/jack").status == 200
    @test length(get("/hello/jack").data) == 12

    @test get("/hello/j-a_ck0-1").status == 200
end
