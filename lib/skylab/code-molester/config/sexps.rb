module Skylab::CodeMolester

  module Config

    module Sexps

      # (for a visual depiction of this-esque, open doc/sexps.dot in graph-viz)

      Value_Proprietor_Methods__ = ::Module.new

      class FileSexp < Sexp_

        register :file

        include Value_Proprietor_Methods__

        # ~ mutators

        def set_mixed_at_name x, name_x
          content_items[ name_x ] = x ; nil
        end

        def add_via_mixed_and_string x, s
          if x.respond_to? :each_pair
            sections_sexp.add_via_pairs_and_string x, s
          else
            nosecs_sexp.add_via_value_and_string x, s
          end
        end

        def replace_via_new_mixed_and_old_value_and_name x_, x, name_x
          # (live dangerously for now - assume nosecs, not section)
          nosecs_sexp.replace_via_new_mixed_and_old_value_and_name x_, x, name_x
        end

        def insert_pairs_and_name_immediately_after_section pairs, name_s, sec
          Config_::Actors__::Set_section_via_hash[ pairs, name_s, sec, sections_sexp ]
        end

        # ~ readers

        def has_name x
          content_items.has_name x
        end

        def aref s
          if s.respond_to? :ascii_only?
            content_items[ s ]
          else
            raise ::TypeError, say_not_string( s )
          end
        end

        def value_items
          nosecs_sexp.value_items
        end

        def sections  # :+#covered-by:cu
          content_items
        end

        def content_items
          @ci ||= Content_items__[].new self
        end

        def to_content_item_scan
          _scan = nosecs_sexp.to_content_item_scan
          _scan_ = sections_sexp.to_content_item_scan
          Callback_::Stream.concat _scan, _scan_
        end

        def nosecs_sexp
          self[ 1 ]
        end

        def sections_sexp
          self[ 2 ]
        end
      end

      class Nosecs < Sexp_

        register :nosecs

        def prepend_comment line
          x = build_comment_line line
          if x
            self[ 1, 0 ] = [ x ]
          end
          x
        end

        def add_via_value_and_string x, name_s
          if x.respond_to? :ascii_only?
            add_via_string_and_string x, name_s
          else
            raise ::ArgumentError, say_not_string( x )
          end
        end

        def add_via_string_and_string value_s, name_s
          _three = via_scan_calculate do |scn|
            lookup_three_indexes_via_scan_for_name scn, name_s, -> x do
              x.respond_to?( :symbol_i ) or next
              :assignment_line == x.symbol_i or next
              true
            end
          end
          set_via_three( * _three, value_s, name_s )
        end

        def set_via_three lesser_d, target_d, greater_d, value_s, name_s
          if target_d
            self[ target_d ].set_item_value x
          else
            _d = if lesser_d
              lesser_d + 1
            elsif greater_d
              greater_d
            end
            Config_::Actors__::Add_assignment[ value_s, name_s, _d, self ]
          end ; nil
        end

        def replace_via_new_mixed_and_old_value_and_name x_, x, name_x
          if name_x.respond_to? :ascii_only?
            replace_via_new_mixed_and_old_value_and_string x_, x, name_x
          else
            raise ::TypeError, say_not_string( name_x )
          end
        end

        def replace_via_new_mixed_and_old_value_and_string x_, x, name_x
          x.set_item_value x_; nil
        end

        # ~

        def value_items
          @vi ||= Content_items__[].new self
        end

        def to_content_item_scan
          produce_scan_for :assignment_line
        end
      end

      class Sections < Sexp_

        register :sections

        def add_via_pairs_and_string pairs, name_s
          Config_::Actors__::Set_section_via_hash[ pairs, name_s, false, self ]
        end

        def to_content_item_scan
          produce_scan_for nil
        end

        def lookup_three_indexes name_s
          via_scan_calculate do |scn|
            lookup_three_indexes_via_scan_for_name scn, name_s
          end
        end
      end

      class Section < Sexp_

        register :section

        include Value_Proprietor_Methods__

        # ~ mutators

        def add_via_mixed_and_string x, s
          if x.respond_to? :ascii_only?
            add_via_string_and_string x, s
          else
            raise ::ArgumentError, say_not_string( x )
          end
        end

        def set_mixed_at_name x, name_x
          if x.respond_to? :ascii_only?
            if name_x.respond_to? :ascii_only?
              set_via_string_and_string x, name_x
            elsif name_x.respond_to? :id2name
              set_via_string_and_string x, name_x.id2name
            else
              raise ::TypeError, say_not_string( name_x )
            end
          else
            raise ::ArgumentError, say_not_string( x )
          end
        end

        def add_via_string_and_string value_s, name_s
          set_via_string_and_string value_s, name_s
        end

        def set_via_string_and_string value_s, name_s
          _three = value_items_sexp.via_scan_calculate do |scn|
            lookup_three_indexes_via_scan_for_name scn, name_s, -> x do
              x.respond_to?( :symbol_i ) or next
              :assignment_line == x.symbol_i or next
              true
            end
          end
          set_via_three( * _three, value_s, name_s )
        end

        def set_via_three lesser_d, target_d, greater_d, value_s, name_s
          if target_d
            self[ target_d ].set_item_value x
          else
            _d = if lesser_d
              lesser_d + 1
            elsif greater_d
              greater_d
            end
            Config_::Actors__::Add_assignment[ value_s, name_s, _d, value_items_sexp ]
          end ; nil
        end

        # ~ readers

        def item_leaf?
          false
        end

        def key
          item_name
        end

        def section_name
          item_name
        end

        def item_name
          self[1][1][2][1]
        end

        def item_name= str
          self[1][1][2][1] = str
        end

        alias_method :section_name=, :item_name=

        def item_value
          @vi ||= Section_shell__[].new self
        end

        def to_content_item_scan
          value_items_sexp.produce_scan_for :assignment_line
        end

        def value_items_sexp
          self[ 2 ]
        end

        # ~ mut
      end


  class AssignmentLine < Sexp_

    register :assignment_line

    class << self
      def indent_string
        INDENT_STRING__
      end
    end
    INDENT_STRING__ = '  '.freeze

    def set_item_value value
      self[VALUE][1] = value.to_s
      nil
    end

    NAME = 2
    VALUE = 4
    TRAILING_WHITESACE = 5
    def item_leaf?
      true
    end
    def item_value
      self[VALUE][1]
    end
    alias_method :value, :item_value  # #comport
    def item_name
      self[NAME][1]
    end
    alias_method :key, :item_name  # #comport

    MEMBER_I_A__ = %i( item_name item_value ).freeze
  end

      class Comment < Sexp_

        register :comment

        # node_reader :body

      end

      Content_items__ = Callback_.memoize do

        class Content_Items__ < Callback_::Stream.mutable_with_random_access

          def initialize sexp
            super sexp.method( :to_content_item_scan ), :item_name
            @sexp = sexp
          end

          def map_aref_value x
            x.item_value
          end

          def add_via_mixed_and_name x, name_x
            @sexp.add_via_mixed_and_name x, name_x
          end

          def replace_via_new_mixed_and_old_value_and_name  x_, x, name_x
            @sexp.replace_via_new_mixed_and_old_value_and_name x_, x, name_x
          end

          def unparse
            @sexp.unparse
          end

          def to_stream  # :+#covered-by:cu
            @scan_p.call
          end

          self
        end
      end

      Section_shell__ = Callback_.memoize do

        class Section_Shell__ < Content_items__[]

          def section_name
            @sexp.section_name
          end

          self
        end
      end

      module Value_Proprietor_Methods__

        def add_via_mixed_and_name x, name_x
          if name_x.respond_to? :ascii_only?
            add_via_mixed_and_string x, name_x
          else
            raise ::TypeError, say_not_string( s )
          end
        end
      end

      Sexps_ = self

    end
  end
end
