module Skylab::FileMetrics

  class API::Actions::Ext

    extend API::Common::ModuleMethods

    include API::Common::InstanceMethods

    include Face::Open2

    -> do

      inflect = nil

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
              @ui.err.puts inflect[ -> {
                "(* only occuring once #{ s single_a, :was }: #{
                  }#{ and_ single_a })"
              } ]
            end
            res = true
          end
        end while nil
        res
      end

      inflect = Headless::NLP::EN::Minitesimal::FUN.inflect

    end.call

  private

    Count = Models::Count.subclass :total_share, :max_share, :lipstick_float,
      :lipstick

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
            if '' == use_ext  # (yes, '.foo' has an extname of '' thankfully)
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

    # this does things wierdly as an experiment for massively progressive output
    def get_file_a
      res = false
      begin
        cmd = build_find_files_command( @req[:paths] ) or break
        if @req[:show_commands] || @req.fetch( :debug_volume )
          @ui.err.puts cmd.string
        end
        buff = Services::StringIO.new
        stay = true
        open2 cmd.string do |o|  # [#004]
          o.err do |s|
            fail "not exptecting stderr output from find cmd - #{ s.strip }."
            stay = false
          end
          o.out( & ( if @req.fetch( :debug_volume )
            -> s do
              buff.write s
              @ui.err.write s
            end
          else -> s { buff.write s } end ) )
        end
        stay or break
        scn = Services::StringScanner.new buff.string  # not good just fun
        file_a = [ ]
        loop do
          scn.skip( /\n+/ )
          line = scn.scan( /[^\n]+/ ) or break
          file_a << line
        end
        res = file_a
      end while nil
      res
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
            [ :lipstick,            FileMetrics::CLI::Lipstick.instance.field_h ]
          ]
        end
      end
      private :render_table
    end.call
  end
end
