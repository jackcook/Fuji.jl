using Base.Test
using Fuji
using Requests

get(endpoint) = Requests.get("http://localhost:8000$endpoint")

@spawn Fuji.start()

@testset "simple route" begin
    @test size(server.routes, 1) == 0

    route("/hi") do req
        "hi"
    end

    @test size(server.routes, 1) == 1
    @test server.routes[1].endpoint == "/hi"

    @test get("/hi").status == 200
end

@testset "adding two of the same route" begin
    @test size(server.routes, 1) == 1

    route("/hi") do req
        "hello"
    end

    @test size(server.routes, 1) == 1
    @test length(get("/hi").data) == 5
end

@testset "removing a route" begin
    r = route("/hi") do req
        "hello"
    end

    @test size(server.routes, 1) == 1

    unroute(r)

    @test size(server.routes, 1) == 0
end

@testset "named parameter" begin
    route("/hello/:name") do req
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

@testset "splat parameter" begin
    route("/hi/*") do req
        string("hi, ", req.splat[1], "!")
    end

    @test get("/hi/:name").status == 404
    @test get("/hi").status == 404
    @test get("/hi/jack/asdf").status == 404
    @test get("/hi/ja;ck").status == 404

    @test get("/hi/jack").status == 200
    @test length(get("/hi/jack").data) == 9

    @test get("/hi/j-a_ck0-1").status == 200
end
