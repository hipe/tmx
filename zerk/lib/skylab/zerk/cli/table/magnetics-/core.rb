    if false  # keep while #open [#tab-003]

  FLOAT_DETAIL_RX__ = /\A(-?\d+)((?:\.\d+)?)\z/  # used 2x

  module Types__

    mod = Home_::CLI_Support::Styling
    unstyle = mod::Unstyle

    parse_styles = mod::Parse_styles
    unparse_styles = mod::Unparse_style_sexp

    hackable_a = [ :style, :string, :style ]

    common = -> fld do
      fmt = "%#{ '-' if fld.is_align_left }#{ fld.max_width :full }s"
      -> str do
        sexp = parse_styles[ str ]  # are you ready for ridiculous? if the
        if sexp  # string was styled, remove the styling, apply the width
          if hackable_a == sexp.map(& :first )  # resizing, and re-apply styling
            sexp[1][1] = fmt % sexp[1][1]
            unparse_styles[ sexp ]
          else
            unstyle[ str ]  # glhf
          end
        else
          fmt % str
        end
      end
    end

    float_detail_rx = FLOAT_DETAIL_RX__

    float = -> fld do
      int_max = fld.max_width :int_part
      flt_max = fld.max_width :frac_prt
      fmt = "%#{ int_max }s%-#{ flt_max }s"
      fallback = common[ fld ]
      -> str do
        md = float_detail_rx.match str
        if md
          fmt % md.captures
        else
          fallback[ str ]
        end
      end
    end

    STRING = Field_Type__.new :string, rx: //, align: :left, render: common


    BLANK = Field_Type__.new :blank, ancestor: :string,
                                   rx: /\A[[:space:]]*\z/, render: common

    FLOAT = Field_Type__.new :float, ancestor: :string,
                                   rx: /\A-?\d+(?:\.\d+)?\z/, render: float

    INTEGER = Field_Type__.new :integer, ancestor: :float, align: :right,
                                       rx: /\A-?\d+\z/, render: common

  end

  class Type_Stats___

    def has_information
      0 < @num_non_nil_seen
    end

    attr_reader(
      :index,
      :max_h,
      :type_h,
    )

    # --*--

    blank_rx = Types__::BLANK.rx

    float_detail_rx = FLOAT_DETAIL_RX__

    start_type = Types__::INTEGER

    unstyle = Home_::CLI_Support::Styling::Unstyle

    define_method :see do |cel_x|  # `cel_x` must be ::String or nil
      if ! cel_x.nil?
        ::String === cel_x or raise ::ArgumentError, "table cels *must* #{
          }be nil or string for reasons - #{ cel_x.class }"
        @num_non_nil_seen += 1
        raw = unstyle[ cel_x ]
        @max_h[:full] = raw.length if raw.length > @max_h[:full]
        if blank_rx =~ raw
          @type_h[:blank] += 1
        else
          type = start_type
          type = type.ancestor until type.match? raw  # ballzy
          @type_h[ type.symbol ] += 1
          if :float == type.symbol
            md = float_detail_rx.match raw
            @max_h[:int_part] = md[1].length if md[1].length > @max_h[:int_part]
            @max_h[:frac_prt] = md[2].length if md[2].length > @max_h[:frac_prt]
          end
        end
      end
    end
  end
    end   # if false
# #tombstone: was once [#001.C]
# #tombstone: one last external use of :employ_DSL_for_digraph_emitter
# #tombstone: at full rewrite, early field class, "census" class, "type stats" class
