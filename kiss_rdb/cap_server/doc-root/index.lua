require 'io'

-- recfile_path = './kiss_rdb_test/fixture-directories/2969-rec/0150-native-capabilities.rec'
recfile_path = './kiss-rdb-doc/recfiles/857.12.recutils-capabilities.rec'

if HasParam('action') then
  action_arg = GetParam('action')
else
  action_arg = 'show_index'
end

function _ProcessCreateNote (params_list)  -- #here2
  local params = _DictionaryViaParams(params_list)
  local fh = _OpenCallToBackend('process_form', recfile_path, 'Note', params)
  _MaybeRedirect(fh)
end

function _ShowCreateNoteForm (parent_EID)
  local fh = _OpenCallToBackend('show_form', recfile_path, 'Note', parent_EID)
  _WriteEveryLineAndClose(fh)
end

function _ViewCapability (eid)
  local fh = _OpenCallToBackend('view_capability', recfile_path, eid)
  _WriteEveryLineAndClose(fh)
end

function _ShowIndex ()
  local action_name
  if HasParam('index_style') and 'tree' == GetParam('index_style') then
    action_name = 'tree'
  else
    action_name = 'table'
  end
  _WriteEveryLineAndClose(_OpenCallToBackend(action_name, recfile_path))
end

function _TestUI ()
  _WriteEveryLineAndClose(_OpenCallToBackend('test_UI'))
end

function _ShowPing ()
  fh = _OpenCallToBackend('ping')
  line = fh:read('L')
  Write(line)
  fh:close()
end

-- Support

function _MaybeRedirect (fh)
  if not fh then  -- (when debugging, we print stuff ourselves and return nil)
    return
  end
  -- Big flex (fragile hack): If the first line "looks like" an html doc, etc
  local line = fh:read('L')
  if nil == line then
    Write("Strange -- file was empty\n")
    return
  end
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

  -- Otherwise, look for one of our "custom" "headers" (probably just this one)
  if "redirect " == string.sub(line, 1, 9) then
    return _DoRedirect(string.sub(line, 9, -2))  -- chomp
  end

  Write("unrecognized directive: " .. first_line)  -- #todo
end

function _DoRedirect (url)
  SetStatus(303) -- "See Other; Used to redirect after a PUT or a POST, so .."
  SetHeader("Location", url)
end

function _WriteEveryLineAndClose (fh)
  if not fh then  -- #here3 and #todo
    Write("No open filehandle to write. Debugging line turned on?\n")
    return
  end
  local line = fh:read('L')
  while line do
    Write(line)
    line = fh:read('L')
  end
  fh:close()
end

function _OpenCallToBackend (sanitized_action_name, ...)
  -- Every backend call will have at least the script name and the
  -- action name:
  local rest = {...}
  local args = {"./kiss_rdb/cap_server/generate_html.py", sanitized_action_name}

  -- Typically, if a parameter was passed, it's the recfile path.
  -- Maybe there will be other parameters.
  -- #todo is there a more idiomatic way to glob this alla python?

  if #rest then
    _HandleTheRest(args, rest)
  end

  local line = table.concat(args, ' ')

  if true then
    print("\n\n\n\n\n\n")
    print("OPENING SUBRPOCESS:\n")
    print(line)
    print("\n\n\n\n\n\n")
  end

  if false then  -- :#here3
    return
  end

  return io.popen(line)
end

function _HandleTheRest (args, rest)
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
  -- processed by a `bin/sh`. (We would prefer to pass the command as a list
  -- of tokens and circumvent a shell.)

  -- If this one string has special characters like carriage returns, newlines,
  -- pipes, greater than/less-than characters, dollar signs, parenthesis
  -- (others); it can lead to *arbitrary unintended execution*, for example
  -- wiping out your hard-drive.

  -- At #history-C.1 we flipped this from an optimistic approach to a paranoid
  -- approach: Now, unless the string looks totally "ordinary", we wrap it in
  -- quotes and escape certain special characters with a backslash.

  -- (Previously, we weren't giving special handling to carriage
  -- returns/newlines and greater-than/less-than, and we had exposed an
  -- arbitrary execution vulnerability (!).)

  -- (Experimentally) We currently chose to use double-quotes over single
  -- quotes for the wrapping.
  -- PRO's of single quotes:
  -- - Can pass-thru as-isis: dollar signs, exclamation points
  -- CON of single quotes:
  -- - Impossible to represent a literal single quote; gotta break into more tokens

  -- This table lists some characters that should have special attention,
  -- and what we do about them. (Somewhat arbitrarily, we have attempted to
  -- order them from "least potentially harmful" to "most")
  --
  -- | Char that triggers    | How we handle it
  -- | --------------------- | ----------------
  -- | a single space  (" ") | leave as-is; should be okay within quotes
  -- | a tab character       | leave as-is; should be okay within quotes
  -- | carriage return / newl| leave as-is; terrifying, should be okay in quotes
  -- | a single quote        | leave as-is (IFF using double quotes)
  -- | a double quote        | escape with a backslahs (IFF using DQ's)
  -- | a dollar sign         | escape with backslash (IFF using DQ's)
  -- | less / greater than   | leave as-is; no magic meaning in quotes
  -- | exclamation point     | (surprisingly) do NOT escape (DQ's)
  -- | pipe                  | leave as-is; no magic meaning in quotes
  -- | a backslash           | VERY IMPORTANT escape it with another backslash

  -- Play it safe: escape the token *unless* it looks like this:
  if string.find(s, "^[a-zA-Z0-9_]+$") then
    return s
  end

  -- Implement the "rule table" above
  local inside = string.gsub(s, '["$\\\\]', function (c)
    return "\\" .. c
  end)
  return '"' .. inside .. '"'
end

if 'POST' == GetMethod() then
  if 'add_note' == action_arg then
    _ProcessCreateNote(GetParams())
  else
    Write("unrecognized POST action: " .. action_arg)  -- #todo
  end
elseif 'view_capability' == action_arg then
  local eid = GetParam('eid') or 'NO_VALUE'  -- really bad
  _ViewCapability(eid)
elseif 'show_index' == action_arg then
  _ShowIndex()
elseif 'add_note' == action_arg then
  local parent_EID = GetParam('parent')
  _ShowCreateNoteForm(parent_EID)
elseif 'test_UI' == action_arg then
  _TestUI()
elseif 'ping' == action_arg then
  _ShowPing()
else
  -- should set header etc, but why
  Write("unrecognized action: " .. action_arg)  -- #todo
end

-- #history-C.1
-- #born
