# frozen_string_literal: true

module Skylab::TestSupport

  module Quickie

    module Models_::Specify

      # this is an EXPERIMENTAL extension to look more like r.s for the
      # construct that falls under the "keyword" `specify`
      #
      #   - the value of this extension is a function of how well liked it
      #     is in *contemporary* r.s idiom-spehere (something that at
      #     writing is unknown).
      #
      #   - as it has worked out, we have whittled where we use this down
      #     to one practical use case (in one file in [ba]).
      #
      #   - NOTE currently this has *no* coverage.

      class << self

        def apply_if_not_defined tcc  # tcc = test context class
          if tcc.respond_to? :specify
            ::Object.const_defined? :RSpec or sanity
          else
            tcc.method_defined? :should and sanity
            tcc.send :define_singleton_method, :specify, SPECIFY__
            tcc.send :define_method, :should, SHOULD__ ; nil
          end
        end
      end  # >>

      SPECIFY__ = -> & proc_use_2x do
        _loc = caller_locations( 1, 1 )[0]  # #spot1.1 (necessary redundancy)

        wee = new :_no_statistics_to_record_TS
        wee.extend HackyMethodsOverwrittenForRecording_YIKES___
        wee.__init_as_doohah_
        wee.instance_exec( & proc_use_2x )

        _desc_s = "should #{ wee.__flush_etc_ }"
        self.ADD_EXAMPLE_TS_ _loc.lineno, proc_use_2x, [ _desc_s ]
      end

      SHOULD__ = -> pred do
        _actual_x = subject
        expect( _actual_x ).to pred
      end

      module HackyMethodsOverwrittenForRecording_YIKES___

        def __init_as_doohah_
          @__this_one_mutex_SPECIFY = nil
        end

        def should pred
          remove_instance_variable :@__this_one_mutex_SPECIFY
          @__predicate_SPECIFY = pred ; nil
        end

        def __flush_etc_
          _pred = remove_instance_variable :@__predicate_SPECIFY
          # assume should
          _pred.to_uninflected_verb_phrase_
        end
      end

      # ==
      # ==
    end
  end
end
# #history-A.1: rewrote to freshen up during purging of `should`
# #pending-rename: this is weird here..
