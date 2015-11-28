require_relative '../../../../test-support'

module Skylab::System::TestSupport

  describe "[sy] - services - filesystem - bridges - path-tools" do

    TS_[ self ]

    define_singleton_method :o do |str, capture, *tags|

      vp = if capture
        "sees #{ capture.inspect }"
      else
        "doesn't see an absolute path"
      end

      it "in '#{ str }' it #{ vp }", *tags do

        md = services_.filesystem.path_tools.absolute_path_hack_rx.match str

        if capture
          md[0].should eql capture
        else
          md.should be_nil
        end
      end
    end

    o 'foo', nil

    o 'foo/bar', nil

    o '/foo/bar', '/foo/bar'

    o ' "/foo/bar" ', '/foo/bar'

  end
end
