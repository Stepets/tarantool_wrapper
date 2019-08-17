local space, song = require("wrapper")("test_data.song")
space:relations {
  artist = require "test_data.artist"
}

local super = space.new
function space:new(data)
  data.artist = data.artist or -1
  return super(self, data)
end

function song:to_string()
  return ("Song#{id} '{title}' written by '<name>'"):gsub('{(%w+)}', self):gsub('<(%w+)>', self.artist)
end
