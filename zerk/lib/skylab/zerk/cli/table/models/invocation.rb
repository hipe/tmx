module Skylab::Zerk

  module CLI::Table

    class Models::Invocation < SimpleModel_  # 1x here, 1x [tab]

      # the subject's objective is to keep the main rendering logic as
      # ignorant as possible about everything to do with setting up and
      # responding to all the various hooks triggered during the (hence
      # the name) invocation of the entire table render. these include
      # concerns such as summary fields, summary rows, headers..

      # -
        def initialize

          @_features_shared_store_box = nil
          @_receive_design = :__receive_design
          @_receive_mixed_tuple_stream = :__receive_mixed_tuple_stream
          @_receive_notes = :__receive_notes
          @_receive_page_scanner = :__receive_page_scanner

          @_post_define = nil

          yield self

          m_a = remove_instance_variable :@_post_define
          if m_a
            m_a.each( & method( :send ) )
          end

          @notes ||= Here_::Models::Notes.new
          NIL
        end

        def design= x
          send @_receive_design, x
        end

        def mixed_tuple_stream= x
          send @_receive_mixed_tuple_stream, x
        end

        def notes= x
          send @_receive_notes, x
        end

        def the_only_page_survey= x
          _scn = Common_::Polymorphic_Stream.via x
          send @_receive_page_scanner, _scn
        end

        # ~ design

        def __receive_design design

          remove_instance_variable :@_receive_design

          @_typified_mixed_tuple_for_header_row = nil
          @design = design
        end

        # ~ mixed tuple stream

        def __receive_mixed_tuple_stream mt_st

          _close_both_of_these
          ( @_post_define ||= [] ).push :__init_page_scanner_via_two_hops
          @__mixed_tuple_stream = mt_st
        end

        def __init_page_scanner_via_two_hops

          _mixed_tuple_st = remove_instance_variable :@__mixed_tuple_stream

          aof = Application_of_Features___.new self
          aof.execute
          page_survey_choices = aof.page_survey_choices
          @_features_shared_store_box = aof.features_shared_store_box

          _survey_choiceser = -> do
            page_survey_choices
          end

          @page_scanner = Tabular_::Magnetics::
              PageScanner_via_MixedTupleStream_and_SurveyChoiceser.call(
            _mixed_tuple_st,
            _survey_choiceser,
          )
          NIL
        end

        # ~ page scanner

        def __receive_page_scanner ps

          _close_both_of_these
          @page_scanner = ps
        end

        # ~ notes

        def __receive_notes x
          remove_instance_variable :@_receive_notes
          @notes = x
        end

        # -- support for above

        def _close_both_of_these
          remove_instance_variable :@_receive_mixed_tuple_stream
          remove_instance_variable :@_receive_page_scanner ; nil
        end

        # -- runtime

        def flush_to_line_stream
          Here_::Magnetics_::LineStream_via_Invocation[ self ]
        end

        def features_shared_store_read k
          bx = @_features_shared_store_box
          if bx
            bx[ k ]
          end
        end

        def features_shared_store_dereference k
          @_features_shared_store_box.fetch k
        end

        # --

        attr_reader(
          :design,
          :notes,
          :page_scanner,
        )
      # -
      # ==

      class Application_of_Features___

        # now that it's possible to have invocations that do not make the
        # survey pass, experimentally breaking the responsibility out to here

        def initialize invo
          @invocation = invo
        end

        def execute
          Tabular_::Models::PageSurveyChoices.define do |o|
            @page_survey_choices = o
            __boogey_down
          end
          NIL
        end

        def __boogey_down
          branch_mod = Features__
          branch_mod.constants.each do |const|
            mod = branch_mod.const_get const, false
            x = mod.match_feature @invocation
            if x
              __apply_feature x, mod
            end
          end
          NIL
        end

        def __apply_feature x, mod
          args = [ self ]
          meth = mod.method :apply_feature
          if 1 != meth.arity
            args.push x
          end
          meth.call( * args )
          NIL
        end

        # NOTE - the subject node is now doing 3 disparate responsibilities:
        # 1 is implement the application of features, 2 is be a services-for-
        # client for the features, and 3 is expose members that represent
        # the result of this application of features. these can be broken
        # out trivially as needed.

        def features_shared_store_add x, k
          ( @features_shared_store_box ||= Common_::Box.new ).add k, x
          NIL
        end

        def design
          @invocation.design
        end

        attr_reader(
          :features_shared_store_box,
          :invocation,
          :page_survey_choices,
        )
      end

      Features__ = ::Module.new

      # ==

      module Features__::X__Hook_for_End_of_Mixed_Tuple_Stream__

        class << self

          def match_feature invo
            invo.design.summary_rows  # `srs_def`
          end

          def apply_feature ap, srs_def

            invo = ap.invocation

            ap.page_survey_choices.add_by(
              :hook_for_end_of_mixed_tuple_stream
            ) do |_hello_from_table|

              _field_observers_controller =
                invo.features_shared_store_dereference(
                  :_feature_lifecycle_for_field_observers_ )

              _svcs = FeatureServicesForClientFor_EoTS___.new(
                _field_observers_controller )

              _mt_st = srs_def.
                build_tuple_stream_for_summary_rows_at_end_of_user_data(
                  _svcs )

              _mt_st  # #todo
            end
            NIL
          end
        end  # >>

        class FeatureServicesForClientFor_EoTS___

          def initialize foc
            @_ = foc
          end

          def read_observer_ sym
            @_.read_observer sym
          end

          def field_observers_controller__
            @_
          end
        end
      end

      # ==

      module Features__::X__End_of_Page_Hook__

        class << self

          def match_feature invo

            invo.design.summary_fields_index__  # `sf_idx`
          end

          def apply_feature ap, sf_idx

            invo = ap.invocation

            _design = ap.design

            ap.page_survey_choices.add_by :hook_for_end_of_page do |page_data|

              fofl = invo.features_shared_store_read(
                :_feature_lifecycle_for_field_observers_ )

              _svcs = if fofl
                FeatureServicesForClientFor_EoP_Plus___.new fofl, _design
              else
                FeatureServicesForClientFor_EoP_Minus__.new _design
              end

              _hi = sf_idx.mutate_page_data page_data, _svcs

              # #todo (`_hi` is nil)
              NIL
            end
            NIL
          end
        end  # >>

        class FeatureServicesForClientFor_EoP_Minus__
          def initialize design
            @design = design
          end
          attr_reader :design
        end

        class FeatureServicesForClientFor_EoP_Plus___ <
            FeatureServicesForClientFor_EoP_Minus__

          def initialize lc, design
            @__lifecycle = lc
            super design
          end

          def read_observer_ sym
            @__lifecycle.read_observer sym
          end
        end
      end

      # ==

      module Features__::X__Headers_thru_Hook__

          # egads :[#050.1]:
          #
          # we need to report header widths post-expansion because that's
          # the position system that headers use (headers can be specified
          # for any kind of field, input-related or derived alike).
          #
          # however, we need to report header widths before we calculate
          # things for fill fields, because fill fields need to know the
          # present projected total table width, and headers can certainly
          # push this width.

        class << self

          def match_feature invo
            invo.design.do_display_header_row
          end

          def apply_feature ap

            all_defined_fields = ap.design.all_defined_fields
            hfl = FeatureLifecycleForHeaders___.new

            ap.page_survey_choices.add_by(
              :hook_for_special_headers_spot_in_first_page_ever
            ) do |page_surveyish|

              _wee = TypifiedMixedTupleForHeaderRow_via_etc___.call(
                page_surveyish, all_defined_fields )

              hfl.__receive_typified_mixed_tuple_for_header_row_ _wee
              NIL
            end

            ap.features_shared_store_add hfl, :_feature_lifecycle_for_headers_

            NIL
          end
        end  # >>

        TypifiedMixedTupleForHeaderRow_via_etc___ = -> (
          page_surveyish, all_defined_fields
        ) do
          tm_a = ::Array.new all_defined_fields.length

          field_survey_writer = page_surveyish.field_survey_writer

          all_defined_fields.each_with_index do |fld, d|

            if fld
              label = fld.label
            end

            _tm = field_survey_writer.see_then_typified_mixed_via_value_and_index(
              label, d )

            # we rely on #table-spot-6 that we don't have to write it to notes..

            tm_a[ d ] = _tm
          end
          tm_a
        end

        class FeatureLifecycleForHeaders___

          def initialize
            @_receive = :__receive_initial
            @_remove = :__NOT_YET_SET
          end

          def __receive_typified_mixed_tuple_for_header_row_ x
            send @_receive, x
          end

          def __receive_initial x
            remove_instance_variable :@_receive
            @_remove = :__do_remove
            @__value = x ; nil
          end

          def remove_typified_mixed_tuple_for_header_row__
            send @_remove
          end

          def __do_remove
            remove_instance_variable :@__value
          end
        end
      end

      # ==

      module Features__::X__Field_Observers__

        class << self

          def match_feature invo
            invo.design.field_observers
          end

          def apply_feature ap, field_observers

            co = field_observers.build_controller

            _fo_a = co.field_observers_array

            ap.page_survey_choices.field_observers_array = _fo_a

            ap.features_shared_store_add(
              co, :_feature_lifecycle_for_field_observers_ )

            NIL
          end
        end  # >>
      end

      # ==

      module Features__::X__Field_Surveyor__

        class << self

          def match_feature invo
            true
          end

          def apply_feature ap

            _field_surveyor = Here_::Models::FieldSurvey::MyFieldSurveyor.new(
              ap.design )

            ap.page_survey_choices.field_surveyor = _field_surveyor

            NIL
          end
        end  # >>
      end

      # ==

      module Features__::X__Page_Size__

        class << self

          def match_feature invo
            true
          end

          def apply_feature ap

            design = ap.design
            _page_size = design.page_size
            _page_size || design._SANITY

            ap.page_survey_choices.page_size = _page_size
            NIL
          end
        end  # >>
      end

      # ==
    end
  end
end
# #history: full rewrite during unification (was "row formatter")
