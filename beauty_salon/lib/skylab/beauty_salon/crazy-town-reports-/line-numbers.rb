module Skylab::BeautySalon

  class CrazyTownReports_::LineNumbers < Common_::MagneticBySimpleModel

    # check out this bittersweet creation myth:
    #
    # for better or worse, when we were playing with this external tech,
    # we accidentally used the (ahem, conventional, stdlib) method name
    # `lineno` instead of what the external library uses (`line`).
    #
    # because of what we consider to be a mis-feature of the external
    # library (that of the method_missing hack), we were getting a nil
    # result from our incorrect method name, instead of it raising an
    # error. (we are currently fuming about this.)
    #
    # so anyway, to troubleshoot this "issue" we made this report, which
    # is what lead to us creating this whole "report" architecture.
    # even though the report itself is a bit of an uninteresting dud,
    # we consider it a "happy accident" because it led us to discover
    # this "report' architecture that we like.

    # this script has been useful by "regressing" it to do something
    # like a map-reduce aggregate operation: we can get
    # just a stream of the tokens in a file, if for example you are
    # trying to determine which symbols of all known grammar symbols
    # you are missing (for example to reach test coverage)
    #
    #     this_script | awk '{ if the file doesnt start with comment char, print $1 }' | sort | uniq
    #
    #     # ie:
    #
    #     this_script | awk '{ if ("#" != substr($1, 1, 1)) { print $1 } }' | sort | uniq
    #
    # :#spot1.2

    # -

      def self.describe_into_under y, expag

        y << 'simply output the symbol name of EVERY sexp in each file, alongside the line-number'
        y << 'as reported by the parser. output is two-columns (or maybe one for those (any) that'
        y << 'report false-is for a line number).'
        y << nil
        y << 'note that the amount of output in terms of line numbers will be something like'
        y << '10x the amount of input (depending of course on etc.)'
      end

      attr_writer(
        :file_path_upstream_resources,
        :listener,
      )

      def execute

        @file_path_upstream_resources.line_stream_via_file_chunked_functional_definition do |y, oo|

          oo.define_document_hooks_plan :plan_A do |o|

            o.on_each_sexp do |s|
              buffer = s.fetch( 0 ).id2name
              d = s.line
              if d
                buffer << SPACE_
                buffer << d.to_s
              end
              y << buffer
            end
          end

          oo.on_each_file_path do |path, o|

            y << "# (file: #{ path })"

            o.execute_document_hooks_plan :plan_A
          end
        end
      end
    # -
  end
end
# #born.
