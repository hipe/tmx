#!/usr/bin/env ruby -w

require 'skylab/test_support'

_cls = Skylab::TestSupport::Servers::Static_File_Server

require 'skylab/task_examples'

_path = ::File.join Skylab::TaskExamples.sidesystem_path, 'test/fixtures'

serr = $stderr
expag = nil
yld = nil

_guy = _cls.new _path, :PID_path, '.' do | * i_a, & ev_p |

  serr.puts "#{ i_a.inspect }:"

  expag ||= ::Skylab::TestSupport.lib_.brazen::API.expression_agent_instance

  # (#[#ca-046] emission handling pattern)

  if :expression == i_a[ 1 ]

    yld ||= ::Enumerator::Yielder.new( & serr.method( :puts ) )

    expag.calculate yld, & ev_p
  else
    _ev = ev_p[]
    _ev.express_into_under serr, expag
  end
  false
end

_guy.execute
