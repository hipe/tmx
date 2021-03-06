module Skylab::TanMan::TestSupport

  module Models::Association

    class << self

      def [] tcc
        TS_::Operations[ tcc ]
        tcc.include self
      end

      def __lib
        Home_::Models_::Association
      end
    end  # >>

    # -

      # -- expectations

      def want_message_ msg

        _ev = event_
        _actual = black_and_white _ev
        _actual == msg || fail
      end

      def fails_
        tuple_.result.nil? || fail
      end

      def final_output_
        tuple_.output_string
      end

      def event_
        tuple_.event_of_significance
      end

      # -- setup

      # ~ meh

      def will_remove_association_foo_bar_from_ s
        @SUBJECT_ACTION = [ :association, :rm ]
        @STRING = s ; nil
      end

      def tuple_for_dedicated_emission_and_failure_ term_chan_sym

        tup = ErrorTuple___.new

        _will_call_API EMPTY_S_
          # (frozen string asserts that etc)

        want :error, term_chan_sym do |ev|
          tup.event_of_significance = ev
        end

        tup.result = execute
        tup
      end

      def tuple_for_money_town_

        tup = SuccessTuple___.new

        money_s = ""
        tup.output_string = money_s

        _will_call_API money_s

        yield tup

        tup.result = execute
        tup
      end

      def _will_call_API out_s

        in_s = remove_instance_variable :@STRING

        subject_action_ = remove_instance_variable :@SUBJECT_ACTION

        # ..

        call_API(
          * subject_action_,
          :input_string, in_s,
          :output_string, out_s,
          :from_node_label, "foo",
          :to_node_label, "bar",
        )
        NIL
      end

      def with_feature_branch_for_associations_  # (has counterpart in node)

        _client = TS_::Models::Dot_File.PARSER_INSTANCE

        _path = digraph_file_path_

        _client.parse_file _path do |dc|

          ob = Here___.__lib::AssocFeatureBranchFacade_TM.new dc
          x = yield ob
          x
        end
      end

    # -

    define_method :fixtures_path_, ( Lazy_.call do
      ::File.join TS_.dir_path, 'fixture-dot-files-for-association'
    end )

    # ==

    ErrorTuple___ = ::Struct.new :result, :event_of_significance
    Here___ = self
    SuccessTuple___ = ::Struct.new :result, :event_of_significance, :output_string

    # ==
    # ==
  end
end
