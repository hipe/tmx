module Skylab::TestSupport::Regret::API

  class Support::Templo_  # read [#026] the templo narrative #storypoint-5

    class << self
      alias_method :begin, :new  # #storypoint-10
    end

    def render_to x
      @render_to_p[ x ]
    end

  private

    # ~ template support

    def get_templates *a
      a.map( & method( :get_template ) )
    end

    def get_template i
      Lib_::Template[ self.class.dir_pathname.join( "#{ i }#{ EXT__ }" ).read ]
    end

    # ~ option support & hook-outs

  public
    def any_exit_status_from_set_options option_a  # mutates
      Set_Options__.new( frml_options, self, option_a ).resolve_any_exit_status
    end
  private
    def frml_options
      self.class.formal_opts
    end
    class << self
      def formal_opts
        @formal_opts ||= bld_formal_options
      end
    private
      def bld_formal_options
        Parse_formal_options__[ const_get :OPTION_X_A__, false ]
      end
    end
  public
    def unhandled_options_from_set_options opt_a
      formals = frml_options
      @snitch.say :notice do
        "invalid template option(s) #{
        }#{ opt_a.map( & :inspect ) * ', ' } - valid option(s): #{
        }(#{ formals.map( & :name_i ) * ', ' })"
      end
      FAILED__
    end
  private
    def show_option_help
      @snitch.puts "available template options:"
      build_section_yielder = -> y, name_i do
        first = true
        ::Enumerator::Yielder.new do |line|
          if first
            y << [ name_i.to_s, line ]
            first = false
          else
            y << [ '', line ]
          end
        end
      end
      ea = ::Enumerator.new do |y|
        frml_options.values.each do |opt|
          opt.summarize_p[ build_section_yielder[ y, opt.name_i ] ]
        end
      end
      Lib_::CLI_table[
        :field, :id, :name,
        :field, :id, :desc, :left,
        :show_header, false,
        :left, '| ', :sep, '    ',
        :write_lines_to, @snitch.method( :puts ),
        :read_rows_from, ea ]
      nil
    end

    class Parse_formal_options__
      def self.[] x_a
        new( x_a ).execute
      end
      def initialize x_a
        @scn = Array_Scanner__.new x_a
      end
      def execute
        name_i = @scn.gets and bld_nonzero_box name_i
      end
    private
      def bld_nonzero_box name_i
        box = Basic::Box.new
        while true
          opt = Option__.new name_i, @scn
          box.add name_i, opt
          name_i = @scn.gets
          name_i or break
        end
        box
      end
    end

    class Array_Scanner__
      def initialize a
        d = -1 ; last = a.length - 1
        @gets_p = -> do
          d < last and a.fetch d += 1
        end
        @peek_p = -> do
          d < last and a.fetch( d + 1 )
        end
        @skip_p = -> do
          d < last and d += 1 ; nil
        end
      end
      def gets ; @gets_p[] ; end
      def peek ; @peek_p[] ; end
      def skip ; @skip_p[] ; end
    end


    Simple_array_scanner__ = -> a do
      d = -1 ; last = a.length - 1
      -> { d < last and a.fetch d += 1 }
    end

    class Option__
      def initialize name_i, scn
        name_i.respond_to?( :id2name ) or raise ::ArgumentError,
          "no implicit conversion of #{ name_i.class } into symbol"
        @name_i = name_i ; @scn = scn
        map_reduce_p = self.class.map_reduce_method_name_p
        loop do
          i = scn.peek or break
          m_i = map_reduce_p[ i ] or break
          scn.skip
          send m_i
        end
      end
      class << self
        def map_reduce_method_name_p
          @mrmn_p ||= bld_map_reduce_method_name_p
        end
      private
        def bld_map_reduce_method_name_p
          -> i do
            m_i = :"#{ i }="
            private_method_defined?( m_i ) and m_i
          end
        end
      end
      attr_reader :name_i, :summarize_p,
        :when_not_provided_p, :when_provided_p
    private
      def when_not_provided=
        @when_not_provided_p = @scn.gets ; nil
      end
      def when_provided=
        @when_provided_p = @scn.gets ; nil
      end
      def summarize=
        @summarize_p = @scn.gets ; nil
      end
    end

    class Set_Options__
      def initialize formals, client, actual_a
        @actual_a = actual_a ; @client = client ; @formals = formals ; nil
      end
      def resolve_any_exit_status
        es = nil
        @formals.each_pair do |name_i, opt|
          if @actual_a and (( idx = @actual_a.index name_i.to_s ))
            es = prcs_formal_arg opt.when_provided_p, idx
            es.nil? or break
          else
            @client.instance_exec( & opt.when_not_provided_p )
          end
        end
        es.nil? and @actual_a and es = fnsh_options
        es
      end
    private
      def prcs_formal_arg p, d
        @actual_a[ d ] = nil
        @client.instance_exec( & p )
      end
      def fnsh_options
        @actual_a.compact!
        if @actual_a.length.nonzero?
          @client.unhandled_options_from_set_options @actual_a
        end
      end
    end

    FUN = ::Module

    FUN::Descify = -> do
      rx = /:\z/
      -> str do
        no_colon = str.gsub rx, ''
        no_colon.inspect
      end
    end.call

    EXT__ = '.tmpl'.freeze
    FAILED__ = false
    PROCEDE__ = true
  end
end
