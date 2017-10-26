# frozen_string_literal: true

module Skylab::BeautySalon

  class CrazyTownReports_::PreviewSelected < Common_::MagneticBySimpleModel

    # -

      def self.describe_into_under y, expag

        y << 'this is for seeing whether your selector selects the things you want it to'
      end

      attr_writer(
        :code_selector,
        :file_path_upstream_resources,
        :listener,
      )

      def execute

        @file_path_upstream_resources.line_stream_via_file_chunked_functional_definition do |y, oo|

          line_cache = nil
          stats = Stats___.new

          oo.define_document_processor :plan_A do |o|

            curr_path = nil

            o.before_each_file do |potential_sexp|

              line_cache = nil
              curr_path = potential_sexp.path
              stats.__receive_before_file_
            end

            @code_selector.on_each_occurrence_in o do |wrapped_sexp|

              line_cache ||= MyLineCache___.new curr_path
              line_cache.__receive_this_occurrence_ wrapped_sexp

              stats.__receive_occurrence_
            end

            o.after_each_file do |potential_sexp|

              if line_cache
                line_cache.__flush_into_ y, @file_path_upstream_resources
              end
            end

            o.listener = @listener
          end

          oo.on_each_file_path do |path, o|

            o.execute_document_processor :plan_A
          end

          oo.after_last_file do

            y << "# (#{ stats.total_match_count } total match(es) in #{ stats.file_count } file(s))"
          end
        end
      end
    # -

    # ==

    class MyLineCache___

      # you can't express (to final UI) the features as you encounter them,
      # because you don't know beforehand whether this current feature is
      # the last feature on the line..

      # assume that each next feature occurs on the same line or a
      # subsequent line of each previous feature (while asserting this)..

      def initialize path
        @_receive = :__receive_initial
        @path = path
      end

      def __receive_this_occurrence_ wrapped_sexp
        send @_receive, wrapped_sexp
      end

      def __receive_initial wrapped_sexp

        _feat = Feature__.new wrapped_sexp

        @_blocks = [ LineBlock__.new( _feat ) ]

        @_receive = :__receive_subsequent ; nil
      end

      def __receive_subsequent wrapped_sexp

        feat = Feature__.new wrapped_sexp

        begin_lineno_feat = feat.begin_lineno
        begin_lineno_block = @_blocks.last.begin_lineno

        case begin_lineno_block <=> begin_lineno_feat
        when -1 ; __when_feature_in_or_after_block feat
        when  0 ; __when_feature_cobegins_block feat
        when  1 ; interesting
        else    ; never
        end
      end

      def __when_feature_cobegins_block feat
        @_blocks.last.__receive_feature_ feat
      end

      def __when_feature_in_or_after_block feat

        begin_lineno_feat = feat.begin_lineno
        end_lineno_block = @_blocks.last.end_lineno

        case end_lineno_block <=> begin_lineno_feat
        when -1 ; __when_feature_begins_after_block_ends feat
        when  0 ; __add_feature_into_block__COVER_ME feat
        when  1 ; interesting
        else    ; never
        end
      end

      def __when_feature_begins_after_block_ends feat

        if @_blocks.last.end_lineno + 1 == feat.begin_lineno
          __append_feature_which_will_begin_next_line_in_block__COVER_ME feat
        else
          @_blocks.push LineBlock__.new feat
          DID_ADD_FEATURE_
        end
      end

      DID_ADD_FEATURE_ = nil

      # -- read

      def __flush_into_ y, rsx

        y << "file: #{ @path }"

        _hi = rsx.file_lines_cache__ @path

        @_blocks.each do |block|
          block.__as_block_flush_into_ y, _hi
        end
        y
      end
    end

    # ==

    class LineBlock__

      # (features could hypothetically overlap (but we'd rather they didn't),
      # however one feature must never encompass another (both begin before
      # the other and end after the other).)

      def initialize feat
        @features = [ feat ]
      end

      def __receive_feature_ feat
        @features.push feat
      end

      def __as_block_flush_into_ y, file_lines_cache

        a = @features
        len = a.length

        feat = a.first
        begin_lineno = feat.begin_lineno
        end_lineno = feat.end_lineno
        if 1 == len
          s = SPACE_
        else
          d = a.last.end_lineno
          if end_lineno < d
            end_lineno = d
          end
          s = 's'
        end

        _where = if begin_lineno == end_lineno
          "on line #{ '%3d' % begin_lineno }"
        else
          "on lines #{ begin_lineno }-#{ end_lineno }"
        end

        _line = file_lines_cache.line_via_lineno__ begin_lineno

        y << "#{ len } feature#{ s } #{ _where }: #{ _line }"
      end

      def end_lineno
        @features.last.end_lineno
      end

      def begin_lineno
        @features.first.begin_lineno
      end

      attr_reader(
        :features,
      )
    end

    # ==

    class Feature__

      def initialize wrapped_sexp
        @begin_lineno = wrapped_sexp.begin_lineno__
        @end_lineno = wrapped_sexp.end_lineno__
        @WRAPPED_SEXP_ABANDONED_FOR_NOW = true
      end

      attr_reader(
        :begin_lineno,
        :end_lineno,
      )
    end

    # ==

    class Stats___

      def initialize
        @file_count = 0
        @total_match_count = 0
      end

      def __receive_before_file_
        @file_count += 1
      end

      def __receive_occurrence_
        @total_match_count += 1
      end

      attr_reader(
        :file_count,
        :total_match_count,
      )
    end

    # ==
    # ==
  end
end
# #born.
