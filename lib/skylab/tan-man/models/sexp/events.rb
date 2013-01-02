module Skylab::TanMan
  module Models::Sexp
    # (only events here!)
  end

  module Models::Sexp::Events
    # all here.
  end

  TanMan::Model::Event || nil # (load it here, then it's prettier below)

  class Models::Sexp::Events::Invalid_Characters <
    Model::Event.new :chars

    def build_message
      x = chars.length
      "html-escaping support is currently very limited. the following #{
      }character#{ s x } #{ s x, :is } not yet supported: #{
        chars.map { |c| "#{ c.inspect } (#{ '%03d' % [ c.ord ] })" }.join ', '
      }"
    end
  end
end
