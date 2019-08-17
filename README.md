# Tarantool wrapper
Middleware for working with tarantool spaces and rows as simple as with lua objects. May call it ORM.

## Usage
- Format your spaces.
- Define your business logic for spaces/rows.

Look [test.lua](./test.lua) for details.

## API
#### wrapped_space
- `:new(data)` creates new row in space using `data` provided. `data` can be in 2 forms
   - list with values as for [space_object.put](https://www.tarantool.io/en/doc/2.2/book/box/box_space/#box-space-replace).
   - table with key-value pairs where key is column-name and value is column-value.

  Returns `wrapped_object` for this `data`.
- `:get(idx)` [searches](https://www.tarantool.io/en/doc/2.2/book/box/box_space/#box-space-select) space using idx value as key. </br>
Returns `wrapped_object` representing matched row or `nil`.
- `:delete(idx)` [deletes](https://www.tarantool.io/en/doc/2.2/book/box/box_space/#box-space-delete) row from space using idx as key.
- `:all()` returns list with all rows from space converted to `wrapped_object`. </br> Assumes row first field can be used as key.
- `:relations(data)` sets relations lookup map. _Use it if facing require loop._ </br>
`data` contains key-value pairs where key is field name for wrapped_object
and value is
   - `wrapped_space` if key shadows existing field
   - `{wrapped_space, field_name}` if key doesn't shadow existing field. `field_name` specifies field to use data from.

  When accessing `wrapped_object` field having relation it returns `wrapped_object` from referenced space, using shadowed or referenced field data as key to search in that space.

#### wrapped_object
- `.new(tnt)` creates `wrapped_object` from tarantool row.
- `:set(data)` updates `wrapped_object` replacing row in space. `data` table with key-value pairs to update. _Can be used for copying objects_.
- `:get_table(deep)` converts `wrapped_object` to lua table with field names as keys. `deep` flag specifies if to use relation lookup.
##### Metatable
- `__index` returns row field data or if field has relation lookups specified `wrapped_space`.
- `__newindex` changes field value by replacing row in space. When using arrays you should replace it ___entirely___.

#### Module
[wrapper.lua](./wrapper.lua) exports only one function:
`wrapped_space, wrapped_object = require("wrapper")(mod_name[, space_name][, relations_table])`
- `mod_name` lua module name to use for require loop avoidance.
- `space_name` optional space name to use. If not specified last part of `mod_name` used as `space_name`
- `relations_table` optional relations lookup table. _Although wrapper function can work with require loops, requires placed here can not._
