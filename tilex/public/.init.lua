-- DISCUSSION: Similar to what we are doing with the nearby "start-server"
-- file that (at #birth) "apprentices" a same-named file in [cap-server],
-- this file (at #birth) apprentices a same-named file in that project too.
--
-- At this moment, our leveraging redbean is "going well" but is still
-- highly experimental. In the interest of avoiding a mishmash of dependency,
-- we are going to copy-paste-modify on what we need from our apprentice file.

if 0 ~= #arg then
  print("At this time we do not take args. Unexpected: " .. arg[1])
  unix.exit(3)
end

require 'io'  -- for io.popen() below

function OnHttpRequest()
  if 'GET' ~= GetMethod() then
    Write("500 - must be GET for now")
    return
  end

  local get_params = GetParams()

  if 0 < #get_params then
    Write("500 - can't handle GET parameters yet (length: " .. #get_params ..")")
    return
  end

  local path = GetPath()
  local first_entry = _FirstEntryOfPath(path)
  if 'API' ~= first_entry then
    return Route()  -- Do what you would do normally -- serve files
  end

  assert('.json' == string.sub(path, -5))  -- :#here1

  local system_command_args = {"./tilex/API.py"}
  table.insert(system_command_args, _MyEscape('fparam:url=' .. path))
  local system_command_line = table.concat(system_command_args, ' ')

  if true then
    print("\n\n\n\nOPENING SUBPROCESS:\n")
    print(system_command_line)
    print("\n\n\n\n")
  end

  local fh = io.popen(system_command_line)
  local line = fh:read('L')
  if nil == line then
    Write("Strange -- file was empty\n")
    return
  end

  SetHeader("Content-Type", "application/json")  -- because #here1

  while line do
    Write(line)
    line = fh:read('L')
  end
  fh:close()
end

-- BEGIN copy-paste

function _MyEscape (s)
  -- CAUTION (see apprentice file)

  -- Play it safe: escape the token *unless* it looks like this:
  if string.find(s, "^[a-zA-Z0-9_]+$") then
    return s
  end

  -- Implement the "rule table" (see apprentice file)
  local inside = string.gsub(s, '[\'\\\\]', function (c)
    if "'" == c then
      return "'\"'\"'"
    end
    assert('`' == c)
    return "\\`"
  end)
  return "'" .. inside .. "'"
end

-- END

function _FirstEntryOfPath(path)
  local to_here = string.find(path, '/', 2)  -- start after leading "/"
  if nil == to_here then
    return string.sub(path, 2)
  end
  return string.sub(path, 2, to_here-1)
end

-- #birth
