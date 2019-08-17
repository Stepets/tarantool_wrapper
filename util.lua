local function equals(a, b)
  if (type(a) == 'table' or type(a) == 'cdata')
  and (type(b) == 'table' or type(b) == 'cdata') then
    for k,v in pairs(a) do
      if not b[k] or not equals(b[k], v) then return false end
    end
    for k,v in pairs(b) do
      if not a[k] or not equals(a[k], v) then return false end
    end
  else
    return a == b
  end
  return true
end

local assert = function(cond, ...)
  if not cond then
    local data = {...}
    local msg = ""
    for _, v in pairs(data) do
      local type = type(v)
      if type == 'table' then
        local tbl = "{"
        for k,v in pairs(v) do
          tbl = tbl .. tostring(k) .. ' = ' .. tostring(v) .. ', '
        end
        msg = msg .. tbl .. '}'
      else
        msg = msg .. tostring(v)
      end
    end
    error(#data > 0 and msg or "assertion failed!")
  end
  return cond
end

local function assert_equals(a,b)
  assert(
    equals(a,b),
    "expected: ", a and a or tostring(a), "\n",
    "got: ", b and b or tostring(b)
  )
end

return {
  equals = equals,
  assert = assert,
  assert_equals = assert_equals
}
