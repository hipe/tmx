module Skylab::Snag

  module Models::Parse
  end

  module Models::Parse::Events
  end

  class Models::Parse::Events::Failure <
    Snag::Model::Event.new :expecting, :near, :line, :line_number, :pathname

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
