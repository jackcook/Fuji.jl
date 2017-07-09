using Base.Test
using Fuji
using Requests

import Fuji.post, Fuji.put, Fuji.patch, Fuji.delete

get(endpoint) = Requests.get("http://localhost:8000$endpoint")
post_req(endpoint) = Requests.post("http://localhost:8000$endpoint")
put_req(endpoint) = Requests.put("http://localhost:8000$endpoint")
patch_req(endpoint) = Requests.patch("http://localhost:8000$endpoint")
delete_req(endpoint) = Requests.delete("http://localhost:8000$endpoint")

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

@testset "routes with other http methods" begin
    post("/post") do req, res
        "hi"
    end

    @test post_req("/post").status == 200

    put("/put") do req, res
        "hi"
    end

    @test put_req("/put").status == 200

    patch("/patch") do req, res
        "hi"
    end

    @test patch_req("/patch").status == 200

    delete("/delete") do req, res
        "hi"
    end

    @test delete_req("/delete").status == 200
end

@testset "adding two of the same route" begin
    @test size(Fuji.server.routes, 1) == 6

    route("/hi") do req, res
        "hello"
    end

    @test size(Fuji.server.routes, 1) == 6
    @test length(get("/hi").data) == 5
end

@testset "adding a route with the same endpoint but a different method" begin
    @test size(Fuji.server.routes, 1) == 6

    post("/hi") do req, res
        "hello"
    end

    @test size(Fuji.server.routes, 1) == 7
end

@testset "removing a route" begin
    @test size(Fuji.server.routes, 1) == 7

    r = route("/toremove") do req, res
        "hello"
    end

    @test size(Fuji.server.routes, 1) == 8

    unroute(r)

    @test size(Fuji.server.routes, 1) == 7
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
    @test get("/hi/").status == 404
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

@testset "query parameters" begin
    route("/hello") do req, res
        # if "name" was in the request, return it, otherwise return an empty 204
        try
            req.query_params["name"]
        catch
            204
        end
    end

    @test length(get("/hello?name=jack").data) == 4
    @test get("/hello?name=jack").status == 200
    @test get("/hello?").status == 204
    @test get("/hello?test&hello").status == 204
    @test get("/hello?t=4&x=3&name=2").data[1] == 0x32 # 2
end

@testset "templating" begin
    route("/template") do req, res
        render_template("template.html", Dict("name" => "Jack"))
    end

    @test get("/template").status == 200

    f = open("template_expected.html")
    contents = readstring(f)
    close(f)

    @test contents == render_template("template.html", Dict("name" => "Jack"))
end
