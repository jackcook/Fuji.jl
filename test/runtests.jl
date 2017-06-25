using Base.Test
using Fuji
using Requests

get(endpoint) = Requests.get("http://localhost:8000$endpoint")

@spawn Fuji.start()

@testset "simple route" begin
    @test size(Fuji.server.routes, 1) == 0

    route("/hi") do req, res
        "hi"
    end

    route("/histatus") do req, res
        204
    end

    @test size(Fuji.server.routes, 1) == 2
    @test Fuji.server.routes[1].endpoint == "/hi"
    @test Fuji.server.routes[2].endpoint == "/histatus"

    @test get("/hi").status == 200
    @test get("/histatus").status == 204
end

@testset "adding two of the same route" begin
    @test size(Fuji.server.routes, 1) == 2

    route("/hi") do req, res
        "hello"
    end

    @test size(Fuji.server.routes, 1) == 2
    @test length(get("/hi").data) == 5
end

@testset "removing a route" begin
    r = route("/hi") do req, res
        "hello"
    end

    @test size(Fuji.server.routes, 1) == 2

    unroute(r)

    @test size(Fuji.server.routes, 1) == 1
end

@testset "named parameter" begin
    route("/hello/:name") do req, res
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
    route("/hi/*") do req, res
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

@testset "before filter" begin
    x = 0

    before() do req, res
        x += 1
    end

    route("/before") do req, res
        string(x)
    end

    @test get("/before").data[1] == 0x31 # 1
    @test get("/something").status == 404

    @test x == 2
end

@testset "after filter" begin
    x = 0

    after() do req, res
        x += 1
    end

    route("/after") do req, res
        string(x)
    end

    @test get("/after").data[1] == 0x30 # 0
end
