local space, artist = require("wrapper")("test_data.artist")
space:relations{
  songs_list = {require "test_data.song", 'songs'}
}

local super = space.new
function space:new(data)
  data.songs = data.songs or {}
  return super(self, data)
end

function artist:to_string()
  local str = ("Artist#{id} '{name}' songs:\n"):gsub('{(%w+)}', self)
  for _, song in pairs(self.songs_list) do
    str = str .. song:to_string() .. '\n'
  end
  return str
end

function artist:add_song(data)
  self.songs = {data.id, unpack(self.songs)}
  data.artist = self.id
  return self
end
