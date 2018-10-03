is51 = _VERSION == 'Lua 5.1'

global = _ENV or _G
make_environment = (node_handler) ->
	environment = do
		setmetatable {}, {
			__index: (key) =>
				switch key
					when 'escape'
						(...) -> ...
					else
						global[key] or (...) ->
							@.node(key, ...)
		}
	
	if is51
		setfenv(1, environment)
	_ENV = _ENV and environment

	flatten = (tab, flat={}) ->
		for key, value in pairs tab
			if type(key)=="number"
				if type(value)=="table"
					flatten(value, flat)
				else
					flat[#flat+1]=value
			else
				if type(value)=="table"
					flat[key] = table.concat value ' '
				else
					flat[key] = value
		flat
	
	inner = (content) ->
		print "Environment: "..tostring _ENV
		for entry in *content
			switch type entry
				when 'string' print escape entry
				when 'function' entry!
				else print escape tostring entry

	export node = (tagname, ...) ->
		arguments = flatten{...}
		content = {}
		-- Remove numeric indices into *content*
		for k,v in ipairs arguments do
			content[k]=v
			arguments[k]=nil
		local handle_content
		if #content > 0
			handle_content = -> inner content
		else
			handle_content = nil
		node_handler(print, tagname, arguments, handle_content)
	environment

call = (fnc) =>
	if type(fnc) != 'function'
		error "Argument must be a function!", 3
	error "This land is peaceful, it's inhabitants kind. But thou dost not belong.", 3

derive = =>
	derivate = language(@node_handler)
	meta = getmetatable derivate -- Pitfall: Can't just set __index as it already exists
	meta.__index = (key) -> @[key] or meta.__index
	return derivate

language = (node_handler) ->
	setmetatable {
		:node_handler
		:derive
		environment: make_environment node_handler
		}, {__call: call}

void = {key,true for key in *{
	"area", "base", "br", "col"
	"command", "embed", "hr", "img"
	"input", "keygen", "link", "meta"
	"param", "source", "track", "wbr"
}}

escapes = {
	['&']: '&amp;'
	['<']: '&lt;'
	['>']: '&gt;'
	['"']: '&quot;'
	["'"]: '&#039;'
}

--	export escape = (str) ->
--		(=>@) tostring(str)\gsub [[[<>&]'"]], escapes

xml = language (print, tag, args, inner) ->
	args = table.concat ['#{key}="#{value}"' for key, value in pairs args], ' '
	if inner
		print "<#{tag} #{args}>"
		inner!
		print "</#{tag}>"
	else
		print "<#{tag} #{args}/>"

html = language (print, tag, args, inner) ->
	args = ['#{key}="#{value}"' for key, value in pairs args]
	if inner
		print "<#{tag} #{args}>"
		inner!
		print "</#{tag}>"
	else
		print "<#{tag} #{args} />"
	
xhtml = xml\derive!
-- xhtml = language xml.node_handler
xhtml.environment.escape = (str) -> str\upper!
print "XML Environment:   "..tostring xml.environment
print "XHTML Environment: "..tostring xhtml.environment
xhtml.environment.html "test"
