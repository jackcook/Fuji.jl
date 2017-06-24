using Base.Test
using Fuji
using Requests

@testset begin
    server = FujiServer()

    @test size(server.routes, 1) == 0

    route!(server, "/hello") do
        "hi"
    end

    @test size(server.routes, 1) == 1
    @test server.routes[1].path == "/hello"
    @test server.routes[1].action() == "hi"

    @spawn Fuji.start(server)

    @test Requests.get("http://localhost:8000").status == 404
    @test Requests.get("http://localhost:8000/hello").status == 200
end
