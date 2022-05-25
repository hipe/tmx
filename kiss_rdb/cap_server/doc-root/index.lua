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
  if not fh then
    return
  end
  _WriteEveryLineAndClose(fh)
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

function _WriteEveryLineAndClose (fh)
  line = fh:read('L')
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

  if false then
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
  -- The below table is a list of special characters whose existence triggers
  -- our hand-made "shellescape"; and the second column is how we handle it
  --
  -- | Char that triggers    | How we handle it
  -- | --------------------- | ----------------
  -- | a single space  (" ") | leave as-is, should be okay within single quotes
  -- | a tab character       | leave as-is, it should be okay in single quotes
  -- | a dollar sign         | leave as-is, shells don't expand w/ single quotes
  -- | a single quote        | escape with a backslash
  -- | a double quote        | leave as-is, okay within single quotes
  -- | a backslash           | escape it with another backslash

  -- If the string doesn't have special chars, just use as-is

  if not string.find(s, '[ \t$\'"\\\\]') then
    return s
  end

  -- Escape a literal backslash and escape a single quote (not double) :#here1
  -- (and pray that's all we need to escape - not newlines)

  local inside = string.gsub(s, "[\\\\']", function (c)
    return "\\" .. c
  end)
  return "'" .. inside .. "'"
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

-- #born
