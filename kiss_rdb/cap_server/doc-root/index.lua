-- recfile_path = './kiss_rdb_test/fixture-directories/2969-rec/0150-native-capabilities.rec'
recfile_path = './kiss-rdb-doc/recfiles/857.12.recutils-capabilities.rec'

if HasParam('action') then
  action_arg = GetParam('action')
else
  action_arg = 'show_index'
end

if 'POST' == GetMethod() then
  if 'edit_capability' == action_arg then
    _ProcessEditCapability(GetParams())
  elseif 'add_note' == action_arg then
    _ProcessCreateNote(GetParams())
  else
    Write("unrecognized POST action: " .. action_arg)  -- #todo
  end
elseif 'view_capability' == action_arg then
  local eid = GetParam('eid') or 'NO_VALUE'  -- really bad
  _ViewCapability(eid)
elseif 'show_index' == action_arg then
  _ShowIndex()
elseif 'edit_capability' == action_arg then
  _ShowEditCapabilityForm(GetParam('entity_EID'))  -- ..
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

-- #abstracted
