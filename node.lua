gl.setup(512, 128)
local font = resource.load_font("default.ttf")
local score = "0 - 0"
util.json_watch("config.json", function(config)
    score = config.score_text or "0 - 0"
end)
function node.render()
    gl.clear(0, 0, 0, 1)
    local fontsize = 100
    local x = 256 - font:width(score, fontsize) / 2
    font:write(x, 15, score, fontsize, 1, 1, 1, 1)
end
