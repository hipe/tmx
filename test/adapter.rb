module Skylab::Test

  module Adapter
  end

  class Adapter::Collection < ::Module

    def [] filename_i
      ( @cache_h ||= { } ).fetch filename_i do |fn_i|
        before = constants
        require "#{ @dir_pathname }/#{ filename_i }/front"
        additional = constants - before
        case additional.length
        when 0 ; raise "loading \"#{ fn_i }\" added no constants to #{ self }"
        when 1 ; @cache_h[ fn_i ] = const_get( additional.first, false )
        else   ; raise "loading \"#{ fn_i }\" must add exactly one constant #{
          }to #{ self } - added: (#{ additional * ', ' })"
        end
      end
    end
  end

  module Adapter::Anchor_Module

    def self.[] mod
      mod.extend Methods_
      nil
    end
  end

  module Adapter::Anchor_Module::Methods_

  end
end
