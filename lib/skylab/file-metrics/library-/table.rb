module Skylab::FileMetrics

  module Library_::Table

    # There is no representation of a phycial table here, just a
    # grandiose function for rendering one:

    # Two-pass rendering -
    # - which for now is being baked deep into everything here - is an
    # algorithm for table rendering that involves bumping *every* cel
    # two times: the first pass to let the field resolve an ideal full
    # stringular representation of the data for that cel, and a second
    # pass for the field to decide how to render that cel and that string
    # given a particular positive nonzero integer width, a width that may be
    # wider or narrower than the initial pre-rendered string.
    #
    # This makes possible:
    #
    # + at its simplest, the field can then autonomously handle alignment
    # (e.g left / right) when we don't know beforehand how wide the column is.
    #
    # + more complicatedly it allows the rendering engine to employ whatever
    # best-fit algorithms it wants after it knows the desired space each
    # cel wants, while allowing the individual field again to autonomously
    # decide how best to truncte its data when necessary.
    #
    # + it allows the engine to fall back to one-pass rendering with
    # preset defaults *dynamically at render time* e.g for a large dataset.

  end

  module Library_::Table::Render

    def self.[] out, row_data_enum, design_x

      design = Design_.new design_x ; design_x = nil

      hdr_row_a = body_row_a = summary_row_a = max_a = nil

      -> do  # prerender.

        bump = -> row_a do  # bump maxes
          row_a.each_with_index do |str, idx|
            len = ( str ? str.length : 0 )  # str should be string, pxy, or nil
            ( max_a ||= [ ] )  # extremely cute
            max_a[idx] = len if ! max_a[idx] || max_a[idx] < len
          end
          nil
        end

        hdr_row_a = -> do
          hr = design.prerender_header_row
          hr and begin
            bump[ hr ]
            [ hr ]
          end
        end.call

        body_row_a = row_data_enum.reduce nil do |bra, node|
          br = design.prerender_body_row node
          br and begin
            bump[ br ]
            ( bra ||= [ ] ) << br
          end
          bra
        end

        summary_row_a = -> do
          sre = design.summary_rows
          sre and begin
            sre.reduce nil do |sra, node|
              sr = design.prerender_summary_row node
              sr and begin
                bump[ sr ]
                ( sra ||= [ ] ) << sr
              end
              sra
            end
          end
        end.call

        nil
      end.call

      manifold = design.bake_manifold out, max_a
      manifold.puff_header_rows hdr_row_a if hdr_row_a
      manifold.puff_body_rows body_row_a if body_row_a
      manifold.puff_summary_rows summary_row_a if summary_row_a

      nil
    end

    class Design_ < Lib_::Formal_box_class[]

      # `Table::Render::Design_` -
      # An immutable encapsulation of the visual design of a particular table.
      # Manages per-field (by symbolic name) an ordered collection of metadata
      # about each field ("column"), including any function for rendering the
      # header cel for that field (typically in the first row), and likewise
      # any function for the rendering of each data ("body") cel for that field,
      # and likewise any function for the rending of that field in any summary
      # row(s).

      def prerender_header_row
        @order.map do |sym|
          fld = @hash.fetch sym
          if fld && fld.header
            fld.header
          else
            @hdr[ sym ]
          end
        end
      end

      def prerender_body_row node
        @order.map do |sym|
          x = node[ sym ]
          fld = @hash.fetch sym
          if fld
            if fld.prerender
              did = true
              str = fld.prerender[ x ]
            elsif fld.is_autonomous
              did = true
              str = x  # it is a proxy or something, passthru
            end
          end
          did ? str : "#{ x }"  # le meh
        end
      end

      Lib_::Add_methods_for_the_procs_in_the_ivars[ self, :summary_rows ]

      def prerender_summary_row h
        @order.map do |sym|
          if h.key? sym
            (pre,) = h.fetch sym
            if pre
              pre[]
            end
          end
        end
      end

      def bake_manifold out, col_width_a
        Manifold_.new self, out, col_width_a
      end

      class Manifold_

        # (about the name - the name "manifold" may change, but it was chosen
        # because for an array-ish of fields it "pumps out" rows of cels the
        # way an engine manifold pumps out whatever to an array of cylinders.)

        ( Parts_ = [ :header, :body, :summary ] ).each do |m|
          define_method "puff_#{ m }_rows" do |a|
            instance_variable_get( "@#{ m }" ).call a
            nil
          end
        end

        def initialize design, out, col_width_a
          y = if ! out.respond_to? :puts then out else
            ::Enumerator::Yielder.new { |line| out.puts line }
          end

          sep = design.sep

          fld_a = design.to_a

          sign = nil

          cook = -> idx, align do
            sgn = sign[ align ]
            fmt = "%#{ sgn }#{ col_width_a.fetch idx }s"
            -> str do
              fmt % str
            end
          end

          seplen = sep.length

          cook_autonomous = -> idx, align, fld do
            if fld.is_autonomous
              fld.cook[ col_width_a, seplen ]
            else
              cook[ idx, align ]
            end
          end

          sign = -> do
            h = {
              left: '-',
              right: nil
            }
            -> x do
              h.fetch x
            end
          end.call

          [ [ :header, fld_a.each_with_index.map do |fld, idx|
              cook[ idx, fld.align_header || fld.align || :right ]
            end ],
            [ :body, fld_a.each_with_index.map do |fld, idx|
              cook_autonomous[ idx, fld.align_body || fld.align || :right, fld ]
            end ],
            [ :summary, fld_a.each_with_index.map do |fld, idx|
              cook[ idx, fld.align_summary || fld.align || :right ]
            end ]
          ].each do |m, f_a|
            instance_variable_set "@#{ m }", ( -> row_a do
              row_a.each do |cel_a|
                y << (
                  [ nil, * cel_a.each_with_index.map do |x, i|
                    f_a.fetch( i ).call x
                  end ].join sep  # tied to [#008]
                )
              end
            end )
          end
        end
      end

      attr_reader :sep

    private

      # `initialize` a grandiose function that builds an immutable structure

      def initialize design_x
        super( & nil )

        process_fields = process_field = process_the_rest = nil

        shell = Shell_.new(
          fields:   -> x { process_fields[ x ] },
          field:    -> { process_field },
          hdr:      ->( &blk ) { @hdr = blk },
          lambda:   ->( &b ) { b },
          sep:      -> x { @sep = ( x ? x.dup.freeze : x ) },
          the_rest: -> x { process_the_rest[ x ] }
        )

        @hdr = -> sym { sym.to_s }
        @sep = '  '.freeze

        process_fields = -> do    # NOTE the side effect of all this below
                                  # is simply that @order and @hash are <<
          pcs_fld = nil

          pcs_flds = -> sxp do
            sxp = sxp.dup
            while sxp.length.nonzero?
              pcs_fld[ * sxp.shift ]
            end
            nil
          end

          pcs_fld = -> do
            state = ::Struct.new :to, :match, :act
            state_h = {
              initial:  state[ [ :symbol, :hash ] ],
              symbol:   state[ [ :symbol, :hash ],
                          -> x { x.respond_to? :id2name },
                          -> fld, sym do
                            fld[ :"is_#{ sym }" ] = true
                          end ],
              hash:     state[ [ ],
                          -> x { x.respond_to? :each_pair },
                          -> fld, hsh do
                            hsh.each_pair do |k, v| fld[ k ] = v end
                          end ] }
            -> symbol, *x_a do
              if @hash.key? symbol
                fail "merge is not implemented - #{ symbol }"
              else
                state = state_h.fetch :initial
                field = x_a.reduce Field_.new do |fld, x|
                  nxt = state.to.reduce nil do |_, sym|
                    ( stat = state_h.fetch sym ).match[ x ] and break stat
                  end
                  nxt or raise ::ArgumentError,
                    "can't process - #{ x.inspect }"
                  state = nxt
                  state.act[ fld, x ]
                  fld
                end
                @order << symbol  # `is_noop` must be processed after `rest`
                @hash[ symbol ] = field
              end
              nil
            end
          end.call

          pcs_flds
        end.call

        sra = nil
        process_field = -> sym do
          fetch sym  # sanity
          Field_::Shell_.new(
            summary: -> x, y=nil do
              sra ||= [ { } ]
              i = 0
              while sra[i].key? sym
                sra << { } if ( i += 1 ) == sra.length
              end
              sra[i][sym] = [ x, y ]
            end
          )
        end
        @summary_rows = -> do
          if sra
            ::Enumerator.new do |y|
              sra.each do |h|
                y << h
              end
              nil
            end
          end
        end

        the_rest = nil

        process_the_rest = -> x do
          the_rest = x
          process_the_rest = -> _ do
            raise ::ArgumentError, "can only set `the_rest` once."
          end
          the_rest
        end

        -> do  # finally run the `design_x` against the shell
          h = { 0 => -> f { shell.instance_exec( &f ) },
                1 => -> f { f[ shell ] } }  # your choice
          design_x.each do |func|  # etc.
            h.fetch( func.arity )[ func ]
          end
        end.call

        -> do  # add the rest / CAUTION box hacking! / `rest` node deleted after
          (name,) = defectch -> k, v { v.is_rest }, -> { }
          if name && the_rest
            xtra_a = the_rest - @order
            if xtra_a.length.nonzero?
              @order[ @order.index( name ), 1 ] = xtra_a
              xtra_a.each do |k|
                @hash[k] = nil  # (actually you are adding something)
              end
            end
          end
        end.call

        del_a = reduce nil do |x, (nm, fld)|
          ( x ||= [ ] ) << nm if fld.is_noop || fld.is_rest
          x
        end
        del_a and delete_multiple( del_a )
        nil
      end

        # `Table::Render::Design_::Shell_` - the shell is the ..er..
        # shell through which we express how we want to create the
        # immutable design.

      Shell_ = Lib_::Nice_proxy[ :field, :fields, :hdr, :lambda,
        :sep, :the_rest ]

        # `Table::Render::Design_::Field_` - field metadata in a design.

      Field_ = ::Struct.new :align, :align_body, :align_header,
        :align_summary, :cook, :header, :is_autonomous, :is_noop, :is_rest,
        :prerender

      Field_::Shell_ = Lib_::Nice_proxy[ :summary ]
    end
  end
end
