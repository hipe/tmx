module Skylab::TanMan::TestSupport

  module Models::Dot_File

    class << self
      def [] tcc
        TS_::Operations[ tcc ]
        tcc.include self
      end
    end  # >>

    # -
      def prepare_to_produce_result
        @parse = Here__.PARSER_INSTANCE
        true
      end
    # -

    define_singleton_method :PARSER_INSTANCE, ( Lazy_.call do

      # even the standalone parsing "client" needs an invocation so that
      # it can make a #[#007.C] sub-invocation to the "paths" service.
      # memoizing this invocation (which in turn memoizes one particular
      # path) frees us from invoking a lot of heavy machinery many dozens of
      # times just to produce the same path over and over. under #tombstone-B
      # that action was a plain old proc, but perhaps was heavier than this
      # memoized.

      _ms_invo = Home_::API.invocation_via_argument_array do |*i_a, &ev_p|
        TS_._COVER_ME__something_failed_at_a_low_level__
      end

      _path = Here__.dir_path

      _cls = TS_::client_proximity_index_.nearest_such_class_to_path _path
        # (the above is now just to #excersize the #feature-island. finds `Client`)

      _parser = _cls.new _ms_invo

      _parser  # hi. #todo
    end )

    # --

    Here__ = self

    # ==
    # ==
  end
end
# :#tombstone-B: attempting to get rid of memoized, monolithic kernel
# (document history: "proximity index" broke out of this and took the history)
