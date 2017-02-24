require_relative '../../test-support'

module Skylab::Plugin::TestSupport

  describe "[pl] lazy index" do

    TS_[ self ]
    use :memoizer_methods
    use :models_lazy_index

    it "loads" do
      subject_module_ || fail
    end

    it "builds" do
      subject_from_state_one_ || fail
    end

    it "touch a plugin (build the instance) - result is an offset" do
      plugin_offset_from_state_two_.zero? || fail
    end

    it "dereference the plugin (instance) using the offset" do

      _subj = subject_from_state_one_
      _d = plugin_offset_from_state_two_

      _plugin = _subj.dereference_plugin _d
      'BUNDLE!' == _plugin  || fail  # per #here
    end

    it "if you touch the same plugin multiple times, same plugin instance" do

      subj = subject_from_state_one_
      loadable_reference = loadable_reference_from_state_two_

      d = subj.offset_of_touched_plugin_via_user_value loadable_reference
      pi = subj.dereference_plugin d

      d_ = subj.offset_of_touched_plugin_via_user_value loadable_reference
      pi_ = subj.dereference_plugin d_

      d == d_ || fail
      pi || fail
      pi.object_id == pi_.object_id || fail
    end

  end
end
# #tombstone-A: full reconception of "dependencies" as "lazy-index"
