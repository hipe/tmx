require_relative 'test-support'

module Skylab::Headless::TestSupport::CLI

  describe "[hl] CLI path-tools" do

    fun = Headless::CLI::PathTools::FUN

    define_singleton_method :o do |str, capture, *tags|
      vp = if capture
        "sees #{ capture.inspect }"
      else
        "doesn't see an absolute path"
      end

      it "in '#{ str }' it #{ vp }", *tags do
        md = fun::ABSOLUTE_PATH_HACK_RX.match str
        if capture
          md[0].should eql( capture )
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
