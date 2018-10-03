local is51 = _VERSION == 'Lua 5.1'
local global = _ENV or _G
local make_environment
make_environment = function(node_handler)
  local environment
  do
    environment = setmetatable({ }, {
      __index = function(self, key)
        local _exp_0 = key
        if 'escape' == _exp_0 then
          return function(...)
            return ...
          end
        else
          return global[key] or function(...)
            return self.node(key, ...)
          end
        end
      end
    })
  end
  if is51 then
    setfenv(1, environment)
  end
  local _ENV = _ENV and environment
  local flatten
  flatten = function(tab, flat)
    if flat == nil then
      flat = { }
    end
    for key, value in pairs(tab) do
      if type(key) == "number" then
        if type(value) == "table" then
          flatten(value, flat)
        else
          flat[#flat + 1] = value
        end
      else
        if type(value) == "table" then
          flat[key] = table.concat(value(' '))
        else
          flat[key] = value
        end
      end
    end
    return flat
  end
  local inner
  inner = function(content)
    print("Environment: " .. tostring(_ENV))
    for _index_0 = 1, #content do
      local entry = content[_index_0]
      local _exp_0 = type(entry)
      if 'string' == _exp_0 then
        print(escape(entry))
      elseif 'function' == _exp_0 then
        entry()
      else
        print(escape(tostring(entry)))
      end
    end
  end
  node = function(tagname, ...)
    local arguments = flatten({
      ...
    })
    local content = { }
    for k, v in ipairs(arguments) do
      content[k] = v
      arguments[k] = nil
    end
    local handle_content
    if #content > 0 then
      handle_content = function()
        return inner(content)
      end
    else
      handle_content = nil
    end
    return node_handler(print, tagname, arguments, handle_content)
  end
  return environment
end
local call
call = function(self, fnc)
  if type(fnc) ~= 'function' then
    error("Argument must be a function!", 3)
  end
  return error("This land is peaceful, it's inhabitants kind. But thou dost not belong.", 3)
end
local derive
derive = function(self)
  local derivate = language(self.node_handler)
  local meta = getmetatable(derivate)
  meta.__index = function(key)
    return self[key] or meta.__index
  end
  return derivate
end
local language
language = function(node_handler)
  return setmetatable({
    node_handler = node_handler,
    derive = derive,
    environment = make_environment(node_handler)
  }, {
    __call = call
  })
end
local void
do
  local _tbl_0 = { }
  local _list_0 = {
    "area",
    "base",
    "br",
    "col",
    "command",
    "embed",
    "hr",
    "img",
    "input",
    "keygen",
    "link",
    "meta",
    "param",
    "source",
    "track",
    "wbr"
  }
  for _index_0 = 1, #_list_0 do
    local key = _list_0[_index_0]
    _tbl_0[key] = true
  end
  void = _tbl_0
end
local escapes = {
  ['&'] = '&amp;',
  ['<'] = '&lt;',
  ['>'] = '&gt;',
  ['"'] = '&quot;',
  ["'"] = '&#039;'
}
local xml = language(function(print, tag, args, inner)
  args = table.concat((function()
    local _accum_0 = { }
    local _len_0 = 1
    for key, value in pairs(args) do
      _accum_0[_len_0] = '#{key}="#{value}"'
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end)(), ' ')
  if inner then
    print("<" .. tostring(tag) .. " " .. tostring(args) .. ">")
    inner()
    return print("</" .. tostring(tag) .. ">")
  else
    return print("<" .. tostring(tag) .. " " .. tostring(args) .. "/>")
  end
end)
local html = language(function(print, tag, args, inner)
  do
    local _accum_0 = { }
    local _len_0 = 1
    for key, value in pairs(args) do
      _accum_0[_len_0] = '#{key}="#{value}"'
      _len_0 = _len_0 + 1
    end
    args = _accum_0
  end
  if inner then
    print("<" .. tostring(tag) .. " " .. tostring(args) .. ">")
    inner()
    return print("</" .. tostring(tag) .. ">")
  else
    return print("<" .. tostring(tag) .. " " .. tostring(args) .. " />")
  end
end)
local xhtml = xml:derive()
xhtml.environment.escape = function(str)
  return str:upper()
end
print("XML Environment:   " .. tostring(xml.environment))
print("XHTML Environment: " .. tostring(xhtml.environment))
return xhtml.environment.html("test")
