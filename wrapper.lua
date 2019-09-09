local log = require "log"

local wraps = function(module, space, relations)

  if package.loaded[ module ] and type(package.loaded[ module ]) == "table" then
    return package.loaded[ module ]
  end

  if not space or type(space) == 'table' then
    relations = space
    space = module:match("([^.]+)$")
  end
  relations = relations or {}
  log.debug{"wrapping", module, space}
  local format = box.space[space]:format()
  if #format == 0 then
    log.error('no format specified for space ' .. tostring(space))
  end

  local format_mapping = {name = {}, index = {}}
  for k,v in ipairs(format) do
    format_mapping.index[v.name] = k
    format_mapping.name[k] = v.name
  end

  local wrapped_space = {}
  local wrapped_object = {}

  function wrapped_space:new(data)
    log.debug{"new obj in", space}
    if #data == 0 then
      local to_insert = {}
      for k,v in pairs(data) do
        local pos = format_mapping.index[k]
        to_insert[pos or k] = v
      end
      data = to_insert
    end

    return wrapped_object.new(box.space[space]:insert(data))
  end

  function wrapped_space:get(idx)
    log.debug{"get obj from", space}
    local tnt = box.space[space]:get(idx)
    if tnt then
      return wrapped_object.new(tnt)
    else
      return nil
    end
  end

  function wrapped_space:delete(idx)
    log.debug{"delete obj from", space, idx}
    box.space[space]:delete(idx)
  end

  function wrapped_space:all(idx)
    local result = {}
    local raw_rows = box.space[space]:select(idx or {})
    for _, row in ipairs(raw_rows or {}) do
      local obj = self:get(row[1])
      table.insert(result, obj)
    end
    return result
  end

  function wrapped_space:relations(map)
    relations = map
  end

  local builder_mt = {__index = {
    new = function(self)
      return wrapped_space:new(self)
    end
  }}
  local link_mt = {__index = {
    new = function(self)
      return wrapped_space:get(self.__id)
    end
  }}
  function wrapped_space:builder(data)
    if type(data) == 'table' then
      return setmetatable(data, builder_mt)
    else
      return setmetatable({__id = data}, link_mt)
    end
  end

  local mt = {
    __index = function(self, key)
      if wrapped_object[key] then return wrapped_object[key] end

      local rel = relations[key]
      if rel then
        key = rel[2] or key
        rel = rel[1] or rel
        local field = self.__tnt[format_mapping.index[key]]
        if type(field) == 'table' then
          local values = {}
          for i, v in ipairs(field) do
            values[i] = rel:get(v)
          end
          return values
        else
          return rel:get(field)
        end
      end

      local field = self.__tnt[format_mapping.index[key]]
      return field
    end,
    __newindex = function(self, key, value)
      local new_data = {}
      for k, v in ipairs(self.__tnt) do
        new_data[k] = v
      end
      new_data[format_mapping.index[key]] = value
      self.__tnt = box.space[space]:replace(new_data)
    end,
  }

  function wrapped_object.new(tnt)
    return setmetatable({__tnt = tnt}, mt)
  end

  function wrapped_object:space_name()
    return space
  end

  function wrapped_object:set(data)
    local new_data = {}
    for k, v in ipairs(self.__tnt) do
      new_data[k] = v
    end
    for k, v in pairs(data) do
      new_data[format_mapping.index[k]] = v
    end
    self.__tnt = box.space[space]:replace(new_data)
  end

  function wrapped_object:get_table(deep)
    local t = {}
    if not deep then
      for k, v in ipairs(self.__tnt) do
        t[format_mapping.name[k]] = v
      end
    else
      for k, v in ipairs(self.__tnt) do
        local field = format_mapping.name[k]
        t[field] = self[field]
      end
    end
    return t
  end

  setmetatable(wrapped_space, {__call = wrapped_space.builder})

  package.loaded[ module ] = wrapped_space
  return wrapped_space, wrapped_object
end

return wraps
