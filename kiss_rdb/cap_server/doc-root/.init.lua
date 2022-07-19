-- BEGIN right from the get-go, ensure what we need from environ/args or exit
--
-- (it's a bit arbitrary that we do the "file exists?" check here and
-- not in the server start script. This could change.)
--
-- (it's cruel to punish endpoints that don't use the RECFILE in this way,
-- but meh for now.)


len = #arg
if 0 == len then
  print("missing required argument RECFILE. exiting.")
  -- (the bash script also checks for this arg and suggests an existing file)
  unix.exit(3)
end

if 1 < len then
  print("unexpected argument: " .. arg[2])
  unix.exit(3)
end

RECFILE = arg[1]

if not unix.stat(RECFILE) then
  print("")
  print("RECFILE file does not exist: " .. RECFILE)
  print("Won't bother starting server because of the above (for now).")
  print("(example recfile: " .. _ExampleRecfile() .. ")")
  unix.exit(3)
end

-- END

require 'io'

function OnHttpRequest()
  -- Override this API hook to pass back the entire doo-hah as-is
  local path = GetPath()

  -- If the url is for a static asset, serve normally
  local to_here = string.find(path, '/', 2)
  if nil ~= to_here then
    local first_entry = string.sub(path, 2, to_here-1)
    if 'assets' == first_entry or 'vendor-themes' == first_entry then
      Route()  -- Do what you would do normally
      return
    end
  end

  -- THE FIRST ARG is the python routing executable itself
  local system_command_args = {"./kiss_rdb/cap_server/generate_html.py"}

  -- THE SECOND ARG is whatever the
  table.insert(system_command_args, _MyEscape('fparam:url=' .. path))

  -- THE THIRD ARG is the HTTP method used
  local http_method = GetMethod()
  table.insert(system_command_args, 'fparam:http_method=' .. http_method)

  -- THE FOURTH ARG is the recfile (whether they need it or not)
  table.insert(system_command_args, _MyEscape('fparam:collection=' .. RECFILE))

  -- MAYBE there are params
  local params = GetParams()
  if #params then
    params = _DictionaryViaParams(params)  -- eek
    -- #todo under what circumstances does 'bparams' have nothing following it?
    table.insert(system_command_args, 'bparams')
    for k, v in pairs(params) do
      table.insert(system_command_args, _MyEscape(k .. '=' .. v))
    end
  end

  local system_command_line = table.concat(system_command_args, ' ')

  if true then
    print("\n\n\n\nOPENING SUBPROCESS:\n")
    print(system_command_line)
    print("\n\n\n\n")
  end

  if false then
    return
  end

  local fh = io.popen(system_command_line)
  _MaybeRedirect(fh)

end

-- Support

function _MaybeRedirect (fh)
  -- Big flex (fragile hack): If the first line "looks like" an html doc, etc
  local line = fh:read('L')
  if nil == line then
    Write("Strange -- file was empty\n")
    return
  end

  -- If it looks like the start of an html document (lol), assume it is
  local first_char = string.sub(line, 1, 1)
  if "<" == first_char then
    Write(line)
    return _WriteEveryLineAndClose(fh)
  end

  local line2 = fh:read('L')
  if line2 then
    Write("wasn't expecting more than one line of headers for now: " .. line2)
    return
  end

  -- If the line looks like a response header .. (new in #history-C.4)
  local digits = string.find(line, '^%d%d%d ')
  if digits then
    Write(line .. '<br>\n')
    Write("(we don't actually send the actual header response code yet)")  -- #todo
    return
  end

  -- Otherwise, look for one of our "custom" "headers" (probably just this one)
  if "redirect " == string.sub(line, 1, 9) then
    return _DoRedirect(string.sub(line, 9, -2))  -- chomp
  end

  Write("unrecognized directive: " .. line)  -- #todo
end

function _DoRedirect (url)
  SetStatus(303) -- "See Other; Used to redirect after a PUT or a POST, so .."
  SetHeader("Location", url)
end

function _WriteEveryLineAndClose (fh)
  local line = fh:read('L')
  while line do
    Write(line)
    line = fh:read('L')
  end
  fh:close()
end

function _HandleTheRest_USE_ME (args, rest)
  local params = nil

  -- If last item is a table, it's k-v pairs to be encoded (e.g #here2)
  if 'table' == type(rest[#rest]) then
    params = rest[#rest]
    params["action"] = nil   -- Until #feat:namespace_for_CGI_params [#872.C]
    table.remove(rest, #rest)
  end

  -- For each item (except any that one above), just append it as a positional
  for _,v in ipairs(rest) do
    assert('string' == type(v))
    table.insert(args, _MyEscape(v))
  end

  if not params then
    return
  end

  -- If you had a table representing key-value pairs (form parameters)..
  for k, v in pairs(params) do
    local use = k .. ':' .. _MyEscape(v)
    table.insert(args, use)
  end
end

function _DictionaryViaParams (param_list)
  local result = {}
  for _, v in ipairs(param_list) do
    local use_key = nil
    local use_val = nil
    if 1 == #v then
      use_key = v[1]
      use_val = ""
    else
      assert(2 == #v)
      use_key = v[1]
      use_val = v[2]
    end
    if result[use_key] ~= nil then
      print("oops, collision on key '" .. use_key .. "'?")
      return
    end
    result[use_key] = use_val
  end
  return result
end

function _MyEscape (s)
  -- WARNING Getting this wrong has potentially catastrophic consequences!

  -- At writing, we don't know of a way to open a subprocess from lua other
  -- than doing it lua's way with `io.popen` which is ONE BIG STRING that gets
  -- processed by a `bin/sh`.

  -- Passing user input over such a string is dire: characters like carriage
  -- returns, newlines, pipes, greater than/less than characters, dollar signs,
  -- parenthesis, BACKTICKS; in shell they all have special meaning. (And there
  -- are probably others we forgot!)
  --
  -- If they occur in user data and are not given special handling, they could
  -- lead to any number of disgusting mishaps; including the glaring
  -- vulnerability of *arbitrary command execution* on the system, for example
  -- wiping out the entire hard drive.

  -- We would prefer lua's API function for this to accept an *array of string
  -- tokens* that do *not* get expanded by a shell (as other platforms do), but
  -- it does not. (There is -- talk of a 3rd party module that that does this.
  -- .#open [#872.K] is to schlurp-in the relevant part of their implementation.)

  -- At #history-C.2 we flipped from using double-quotes to single-quotes:
  -- with single quotes there are less characters that need escaping, and
  -- thanks to help from Rob Normal and Gertlex we now know a way within a
  -- single-quoted string to escape single-quotes.

  -- At #history-C.1 we flipped this from an optimistic approach to a paranoid
  -- approach: Now, unless the string looks totally "ordinary", we wrap it in
  -- quotes and escape certain special characters with a backslash.

  -- This table lists some characters that should have special attention,
  -- and what we do about them within different kinds of string literals.
  --   - Do *not* assume this list is exhaustive.
  --   - Somewhat arbitrarily we attempt to order this list from
  --     "least potentially harmful" to "most"
  --   - "SQ" = in a Single-Quoted string   "DQ" = in a Double-Quoted string
  --   - "DSSQ" = "in a Dollar-Sign Single-Quoted string"
  --     (as https://stackoverflow.com/questions/8254120/)
  --   - Not pictured is all the semantic effects these chars can have if
  --     you're *not* within a quoted string.
  --
  -- | Char that triggers    |       SQ       |      DQ       |     DSSQ[3]
  -- | --------------------- | ------------------------------------------------
  -- | a single space  (" ") |   leave as-is  |  leave as-is  | leave as-is
  -- | a tab character       |   leave as-is  |  leave as-is  | leave as-is
  -- | carriage return / newl|   leave as-is  |  leave as-is  | leave as-is
  -- | a single quote        |  see [1] below |  leave as-is  | backslash it
  -- | a double quote        |   leave as-is  | backslash it  | leave as-is
  -- | a dollar sign         |   leave as-is  | backslash it  | leave as-is
  -- | less / greater than   |   leave as-is  |  leave as-is  | leave as-is
  -- | exclamation point [2] |   leave as-is  |  leave as-is  | leave as-is
  -- | pipe                  |   leave as-is  |  leave as-is  | leave as-is
  -- | a backslash           |   backslash it | backslash it  | backslash it
  -- | a backtick            |   leave as-is  | backslash it  | leave as-is
  --
  --
  -- [1]: The shells appear to consider this an escape sequence: ('"'"')
  --      although (by design) it looks like the closing of a single string
  --      and etc.
  -- [2]: If you're trying these out from zsh as we do, zsh may give special
  --      meaning to the exclamation point. zsh is not relevant here.
  -- [3]: We were excited about the dollar-sign-single-quoted-string at first
  --      but it appears to be a bash shell thing, and we are stuck with a
  --      Bourne shell under lua. The column is left intact for reference and
  --      novelty.

  -- Play it safe: escape the token *unless* it looks like this:
  if string.find(s, "^[a-zA-Z0-9_]+$") then
    return s
  end

  -- Implement the "rule table" above
  local inside = string.gsub(s, '[\'\\\\]', function (c)
    if "'" == c then
      return "'\"'\"'"
    end
    assert('`' == c)
    return "\\`"
  end)
  return "'" .. inside .. "'"
end

-- #history-C.4: massive overhaul of architecture: send back the request url
-- #history-C.3: renamed to .init.lua from index.lua
-- #history-C.2
-- #history-C.1
-- #born
