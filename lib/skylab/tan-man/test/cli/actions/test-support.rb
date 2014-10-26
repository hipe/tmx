require_relative '../test-support'

module Skylab::TanMan::TestSupport::CLI::Actions

  ::Skylab::TanMan::TestSupport::CLI[ TS_ = self ]

  include Constants

  module InstanceMethods

    def cd pathname, &block
      fu = TestLib_::FUC[].new -> msg do
        if do_debug
          TestSupport_::Stderr_[].puts "    (tanmun vreeboze: #{ msg })"
        end
      end
      fu.cd pathname, &block
    end

    def client
      @client ||= build_client
    end

    def build_client
      spy = output  # is a [ts] IO spy group
      o = TanMan_::CLI.new nil, spy.for( :paystream ), spy.for( :infostream )
      o.program_name = 'timmin'
      o
    end

    attr_reader :dotfile_pathname

    def using_dotfile str
      clear_and_prepare
      pathname = tanman_tmpdir.touch 'floo.dot'
      pathname.open( 'w' ) { |fh| fh.write str }
      with_config  using_dotfile: 'floo.dot'
      @dotfile_pathname = pathname
      nil
    end

    def using_config whole_string  # will clear tmpdir too
      clear_and_prepare
      with_config_file_handle_and_get_pathname do |fh|
        fh.write whole_string
      end
    end

    def clear_and_prepare
      clear_api_if_necessary
      tanman_tmpdir.prepare
      nil
    end

    def with_config hash         # assume tmpdir has been cleared
      lines = hash.reduce( [ ] ) do |m, (k, v)|
        /\A[_a-z]+\z/ =~ k.to_s or fail 'sanity'
        m << "#{ k }= #{ v }"
        m
      end
      with_config_file_handle_and_get_pathname do |fh|
        lines.each do |line|
          fh.puts line
          if do_debug
            debug_IO.puts "#{ cfn }: #{ line }"
          end
        end
      end
    end

    def with_config_file_handle_and_get_pathname
      pathname = tanman_tmpdir.touch_r cfn
      pathname.open( 'w' ) do |fh|
        yield fh
      end
      pathname
    end
  end
end
