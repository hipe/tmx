module Skylab::FileMetrics

  class API::Actions::Ext

    extend API::Common::ModuleMethods

    include API::Common::InstanceMethods

    LIB_.system_open2 self

    -> do

      _NLP_EN_agent = nil

      define_method :run do ||
        res = false
        begin
          ext_count_h = get_ext_count_h or break
          count = Count.new 'Extension Counts'
          single_a = nil
          ext_count_h.values.each do |cnt|
            if 1 == cnt.count and @req[:group_singles]
              ( single_a ||= [ ] ) << cnt.extension
            else
              count << Count.new( "*#{ cnt.extension }", cnt.count )
            end
          end
          if single_a
            count << Count.new( '(monadic *)', single_a.length )
          end
          if count.zero_children?
            @ui.err.puts "(no extensions)"
            res = nil
          else
            count.collapse_and_distribute or break
            render_table count, @ui.err
            if single_a
              @ui.err.puts( _NLP_EN_agent.calculate do
                "(* only occuring once #{ s single_a, :was }: #{
                  }#{ and_ single_a })"
              end )
            end
            res = true
          end
        end while nil
        res
      end

      _NLP_EN_agent = LIB_.EN_agent

    end.call

  private

    Count = FM_::Models::Count.subclass :total_share, :max_share,
      :lipstick_float

    Count_ = ::Struct.new :extension, :count

    -> do  # `get_ext_count_h`

      define_method :get_ext_count_h do
        res = false
        begin
          file_a = get_file_a or break
          pat_a = []
          pat_a << Pattern_h.fetch( :git_object ) if @req[:git]  # eew
          pat_a << Pattern_h.fetch( :dotfile )
          ext_count_h = ::Hash.new do |h, k|
            h[k] = Count_[ k, 0 ]
          end
          # resolve *some* logical extension ("type") for each file - for those
          # files without an actual extension use the patterns.
          file_a.each do |file|
            pn = ::Pathname.new file
            use_ext = pn.extname.to_s
            # (please leave this line intact, below was *perfect* [#bs-010])
            if EMPTY_S_ == use_ext  # (yes, '.foo' has an extname of '' thankfully)
              pat = pat_a.detect { |p| p.rx =~ file }
              use_ext = if pat then pat.label else pn.basename.to_s end
            end
            ext_count_h[ use_ext ].count += 1
          end
          res = ext_count_h
        end while nil
        res
      end
      private :get_ext_count_h

      Pattern_ = ::Struct.new :rx, :label

      Pattern_h = {
        git_object: Pattern_[ /\A[0-9a-f]{38,40}\z/, 'git object' ],
        dotfile: Pattern_[ /\A\./, 'dotfile' ],
        no_extension: Pattern_[ nil, 'no extension' ]
      }

    end.call

    def get_file_a

      cmd = build_find_files_command @req[ :paths ]

      if @req[ :show_commands ] || @req.fetch( :debug_volume )
        @ui.err.puts cmd.string
      end

      _, o, e = FM_::Library_::Open3.popen3( * cmd.args )  # :+[#004]

        # used to use [#fa-003], redundant with  [#hl-048] but can't
        # because it takes command strings and must be annnihilated

      s = e.gets
      if s
        s.chomp!
        fail "not exptecting stderr output from find cmd - #{ s.inspect }"
      end

      y = []
      out = if @req.fetch( :debug_volume )
        -> line do
          y.push line
          @ui.err.write line
        end
      else
        -> line do
          y.push line
        end
      end

      begin
        s = o.gets
        s or break
        s.chomp!
        out[ s ]
        redo
      end while nil

      y
    end

    -> do  # `render_table`

      percent = -> v { "%0.2f%%" % ( v * 100 ) }

      define_method :render_table do |count, out|
        rndr_tbl out, count, -> do
          fields [
            [ :label,               header: 'Extension' ],
            [ :count,               header: 'Num Files' ],
            [ :rest,                :rest ],  # if we forgot any fields, glob them here
            [ :total_share,         prerender: percent ],
            [ :max_share,           prerender: percent ],
            [ :lipstick_float,      :noop ],
            [ :lipstick,            FM_::CLI::Lipstick.instance.field_h ]
          ]
        end
      end
      private :render_table
    end.call
  end
end
