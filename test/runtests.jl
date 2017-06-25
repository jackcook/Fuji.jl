using Base.Test
using Fuji
using Requests

req(endpoint) = Requests.get("http://localhost:8000$endpoint")

server = FujiServer()
@spawn Fuji.start(server)

@testset "simple route" begin
    @test size(server.routes, 1) == 0

    route!(server, "/hi") do
        "hi"
    end

    @test size(server.routes, 1) == 1
    @test server.routes[1].endpoint == "/hi"
    @test server.routes[1].action() == "hi"

    @test req("").status == 404
    @test req("/hi").status == 200
end

@testset "splat param" begin
    route!(server, "/hello/:name") do
        "hello!"
    end

    @test Requests.get("http://localhost:8000/hello/:name").status == 404
    @test Requests.get("http://localhost:8000/hello").status == 404
    @test Requests.get("http://localhost:8000/hello/jack/asdf").status == 404
    @test Requests.get("http://localhost:8000/hello/ja;ck").status == 404

    @test Requests.get("http://localhost:8000/hello/jack").status == 200
    @test Requests.get("http://localhost:8000/hello/j-a_ck0-1").status == 200
end
