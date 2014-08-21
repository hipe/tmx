module Skylab::Brazen

  class Model_  # see [#013]

    class << self

      def get_action_scanner
        Build_action_scanner__[ self ]
      end
    end

    Actor = Lib_::Snag__[]::Model_::Actor


    class Build_action_scanner__
      Actor[ self, :properties, :cls ]

      def execute
        _has = @cls.const_defined? ACTIONS__, false
        _has ||= @cls.entry_tree.instance_variable_get( :@h ).key? ACTIONS___
        _has and work
      end
      ACTIONS___ = 'actions'.freeze
    private
      def work
        @cache_a = bld_cache_a
        @cache_a and flush
      end

      def bld_cache_a
        did_see_promotee = did_see_non_promotee = nil
        mod = @cls.const_get ACTIONS__, false
        cache_a = []
        mod.constants.each do |i|
          cls = mod.const_get i, false
          if cls.is_promoted
            did_see_promotee = true
            cache_a.push cls.new
          else
            did_see_non_promotee = true
          end
        end
        if did_see_non_promotee
          cache_a.push @cls.new
        end
        cache_a.length.nonzero? and cache_a
      end

      def flush
        a = @cache_a ; d = -1 ; last = a.length - 1
        Callback_::Scn.new do
          if d < last
            a.fetch d += 1
          end
        end
      end

      ACTIONS__ = :Actions
    end
  end
end
