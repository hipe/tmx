"""Discussion:

Yes this file is really anemic but:

- We don't want vendor-specific stuff in a non-vendor-specific module (so
  at the very least all watchexec stuff needs to be in its adapter module).
- We want to really highlight how the "run" side is distinct from the
  "notify" side (no matter how small both sides are)
- These two sides are never loaded in the same python process anyway,
  so nothing would be "gained" by having them in the same module (file)
"""


def ARGS_FOR_FILE_CHANGED(adapter_event_type, watched_dir, env):

    # There is only one adapter event type for now
    if 'file_changed_in_directory' != adapter_event_type:
        raise RuntimeError(
          "currenly there is only one adapter event type, and it is "
          f"'file_changed_in_directory' (had {adapter_event_type!r})")

    # relevant verbiage taken directly from the watchexec manpage at #birth:

    # Processes started by watchexec have environment variables set describing
    # the modification(s) observed. Which variable is set depends on how  many
    # modifications were observed and/or what type they were.

    if (p := env.get('WATCHEXEC_WRITTEN_PATH')):
        typ = 'file_saved'
    elif (p := env.get('WATCHEXEC_CREATED_PATH')):
        typ = 'file_created'
    elif (p := env.get('WATCHEXEC_REMOVED_PATH')):
        typ = 'file_removed'
    elif (p := env.get('WATCHEXEC_RENAMED_PATH')):
        typ = 'file_renamed'
    elif (p := env.get('WATCHEXEC_META_CHANGED_PATH')):
        typ = 'file_metadata_changed'
    elif (p := env.get('WATCHEXEC_COMMON_PATH')):
        typ = 'multiple_files_changed'
    else:
        typ = 'activity_with_no_associated_file'

    kw = {
        'watched_dir': watched_dir,  # might drop this
        'agnostic_change_type': typ}
    if p is not None:
        kw['path_that_changed'] = p
    return kw

# #birth
