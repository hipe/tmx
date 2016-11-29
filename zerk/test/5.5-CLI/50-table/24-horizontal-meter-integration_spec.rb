$stderr.puts "\n\n\n#{ '>' * 80 }\nDON'T FORGET: totally commented out: #{ __FILE__ }"
$stderr.puts "#{ '<' * 80 }\n\n\n\n"
if false
require_relative '../../../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] CLI support - table - actor - max-share" do

    TS_[ self ]
    use :CLI_support_table_actor
  end
end
end
# #tombstone during unification rewite for new API. spirit is same.
