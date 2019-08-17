local artist = box.space.artist
if artist then artist:drop() end

artist = box.schema.space.create 'artist'
artist:format {
    {'id', 'integer'},
    {'name', 'string'},
    {'songs', 'array'},
}
artist:create_index('uniq', {sequence = true})

local song = box.space.song
if song then song:drop() end

song = box.schema.space.create 'song'
song:format {
    {'id', 'integer'},
    {'title', 'string'},
    {'artist', 'integer'},
}
song:create_index('uniq', {sequence = true})
