module Skylab::BeautySalon

  class CrazyTownReports_::LineNumbers < Common_::MagneticBySimpleModel

    # check out this bittersweet creation myth:
    #
    # (historical: the below was during our use of 'ruby_parser', not 'parser')
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
    #
    # (historical: that was all during our use of 'ruby_parser', not 'parser')

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
    # :#doc1.1

    # -

      def self.describe_into_under y, expag

        y << 'simply output the symbol name of EVERY sexp in each file, alongside the line-number'
        y << 'as reported by the parser. output is two-columns (or maybe one for those (any) that'
        y << 'report false-ish for a line number).'
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

          oo.define_document_processor :plan_A do |o|

            o.on_each_node do |n|

              buffer = n.type.id2name
              loc = n.location

              if loc.expression
                d = loc.first_line
                d_ = loc.last_line
                if d == d_
                  buffer << " #{ d }"
                else
                  buffer << " #{ d }-#{ d_ }"
                end
              else
                buffer << " (no_associated_expression)"
              end

              y << buffer
            end
          end

          oo.on_each_file_path do |path, o|

            y << "# (file: #{ path })"

            o.execute_document_processor :plan_A
          end
        end
      end
    # -
    Modalities = nil
  end
end
# #born.
