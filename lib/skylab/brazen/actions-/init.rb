module Skylab::Brazen

  class Actions_::Init < Brazen_::Action_

    desc do |o|
      o.puts "init a #{ par 'workspace' }"
      o.puts "never see"
    end
  end
end
