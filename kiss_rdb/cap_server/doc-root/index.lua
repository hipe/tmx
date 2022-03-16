require 'io'

-- recfile_path = './kiss_rdb_test/fixture-directories/2969-rec/0150-native-capabilities.rec'
recfile_path = './kiss-rdb-doc/recfiles/857.12.recutils-capabilities.rec'

if HasParam('action') then
  action_arg = GetParam('action')
else
  action_arg = 'show_index'
end

function _ViewCapability (eid)
  fh = _OpenCallToBackend('view_capability', recfile_path, eid)
  _WriteEveryLineAndClose(fh)
end

function _ShowIndex ()
  _WriteEveryLineAndClose(_OpenCallToBackend('index', recfile_path))
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

function _OpenCallToBackend (action_name, ...)
  -- Every backend call will have at least the script name and the
  -- action name:
  local rest = {...}
  local args = {"./kiss_rdb/cap_server/generate_html.py", action_name}

  -- Typically, if a parameter was passed, it's the recfile path.
  -- Maybe there will be other parameters.
  -- #todo is there a more idiomatic way to glob this alla python?
  if #rest then
    for i,v in ipairs(rest) do
      table.insert(args, v)
    end
  end

  local line = table.concat(args, ' ')
  return io.popen(line)
end

if 'view_capability' == action_arg then
  local eid = GetParam('eid') or 'NO_VALUE'  -- really bad
  _ViewCapability(eid)
elseif 'show_index' == action_arg then
  _ShowIndex()
elseif 'test_UI' == action_arg then
  _TestUI()
elseif 'ping' == action_arg then
  _ShowPing()
else
  -- should set header etc, but why
  Write("unrecognized action: " .. action_arg)  -- #todo
end

-- #born
