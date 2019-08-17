require "test_data.schema"

local artists = require "test_data.artist"
local songs = require "test_data.song"

artists:new({
  name = 'Feint'
})
:add_song(songs:new{
  title = 'Snake Eyes'
})
:add_song(songs:new{
  title = "We Won't Be Alone"
})

artists:new({
  name = 'Rogue'
})
:add_song(songs:new{
  title = 'Rattlesnake'
})
:add_song(songs:new{
  title = 'Fury'
})

local assert_equals = require("util").assert_equals

assert_equals(2, #artists:all())
assert_equals(4, #songs:all())

assert_equals({
  {1, 'Feint', {2, 1}},
  {2, 'Rogue', {4, 3}},
}, box.space.artist:select{})

assert_equals({
  {1, 'Snake Eyes', 1},
  {2, "We Won't Be Alone", 1},
  {3, 'Rattlesnake', 2},
  {4, 'Fury', 2},
}, box.space.song:select{})

assert_equals(
[[Artist#1 'Feint' songs:
Song#2 'We Won't Be Alone' written by 'Feint'
Song#1 'Snake Eyes' written by 'Feint'
]], artists:get(1):to_string())

assert_equals(
[[Artist#2 'Rogue' songs:
Song#4 'Fury' written by 'Rogue'
Song#3 'Rattlesnake' written by 'Rogue'
]], artists:get(2):to_string())

artists:new({name = 'tmp'})
assert_equals(3, #artists:all())
assert_equals({3, 'tmp', {}}, box.space.artist:select{}[3])
artists:get(3):set{name = 'TMP', id = 4}
assert_equals({3, 'tmp', {}}, box.space.artist:select{}[3])
assert_equals({4, 'TMP', {}}, box.space.artist:select{}[4])

artists:delete(3)
artists:delete(4)
assert_equals(2, #artists:all())

assert_equals({
  {1, 'Feint', {2, 1}},
  {2, 'Rogue', {4, 3}},
}, box.space.artist:select{})
