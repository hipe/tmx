module Skylab::Snag

  Models::Parse = ::Module.new

  Models::Parse::Events = ::Module.new

  Models::Parse::Events::Failure = Snag_::Model_::Event.
      new :expecting, :near, :line, :line_number, :pathname do

    def to_hash
      {
        line: line,
        line_number: line_number,
        pathname: pathname.to_s,
        invalid_reason_string: "expecting \"#{ expecting }\" #{
          }near \"#{ near }\""
      }
    end
  end
end
