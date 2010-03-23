module Hipe
  module Assess
    module OptParseLite
      include CommonInstanceMethods
      include HashExtra
      class << self
        def enhance(opts, controller)
          opts.extend(self)
          opts.controller = controller
        end
        def parse_args argv, controller
          options = argv.select { |piece| piece =~ /^-/ }
          argv   -= options
          command = argv.shift
          opts = Hash[* options.map do |flag|
            # key, value = flag.split('=')  # no good for detecting -i=''
            key,value = flag.match(/\A([^=]+)(?:=(.*))?\Z/).captures
            [key.sub(/^--?/, '').intern, value.nil? ? true : value ]
          end.flatten ]
          enhance opts, controller
          [ command, opts, argv ]
        end
      end

      attr_accessor :controller

      def valid? &block
        yield(self) if block_given?
        is_valid = (@errors.nil? || !@errors.any?)
        if (bads = bad_args_hack).any?
          is_valid = false
          my_name = controller.send(:this_command, 3) # aggregious @fixme
          s = bads.length > 1 ? 's' : ''
          controller.send(:ui).puts("#{my_name}: unrecognized option#{s} "<<
            oxford_comma(bads.map(&:inspect)))
        end
        is_valid
      end

      def bad_args_hack
        (keys - handled).map do |sym|
          sym.to_s.length > 1 ? "--#{sym}" : "-#{sym}"
        end
      end

      OnCommas = /, */

      ShortOrLong = RegexpExtra[
        /\A *(?:-([a-z0-9])|--([a-z0-9][-a-z0-9]+)) */i
      ]

      OptOrRequiredArg = RegexpExtra[
        /\A *=(?:([A-Z_]+)|\[([A-Z_]+)\]) */
      ]

      def handled *names
        @handled ||= []
        if names.any?
          @handled.concat names
        else
          @handled
        end
      end

      def parse! str, make_method
        opt = self.parse_parse(str)
        ok = true
        if (found = (opt.names & keys)).any?
          handled(*found)
          if found.size > 1
            add_error("Can't handle multiple arguments for #{opt.name}")
            ok =false
          else
            used_name = found.first
            value = self[used_name]
            if value==true
              if opt.required?
                add_error("#{opt.name.inspect} missing required value "<<
                "#{opt.argument_name}")
                ok = false
              else
                def! make_method, value
              end
            else
              if ! opt.takes_argument?
                add_error("#{opt.name.inspect} does not take an argument "<<
                "(#{value.inspect})")
                ok = false
              else
                def! make_method, value
              end
            end
          end
        else
          def! make_method, nil
        end
        ok
      end

      def add_error msg
        @errors ||= []
        @errors.push msg
        # this is so aggregious @fixme
        my_name = controller.send(:this_command, 4)
        controller.send(:ui).puts "#{my_name}: #{msg}"
        nil
      end

      class OptParseParse < Struct.new(:names, :takes_argument, :required,
        :optional, :argument_name, :short, :long)
        alias_method :required?, :required
        alias_method :optional?, :optional
        alias_method :takes_argument?, :takes_argument
        def name
          long.any? ? long.first : short.first
        end
      end

      def parse_parse str
        names, reqs, opts, short, long = [[],[],[],[],[]]
        str.split(OnCommas).each do |opt|
          caps = nil
          pp_fail("#{str.inspect}") unless caps = ShortOrLong.parse!(opt)
          names.push(caps[0] || caps[1])
          long.push "--#{caps[1]}" if caps[1]
          short.push "-#{caps[0]}" if caps[0]
          if caps = OptOrRequiredArg.parse!(opt)
            (caps[0] ? reqs : opts).push(caps[0] || caps[1])
          end
          pp_fail("unparsable remains: #{str.inspect}") unless opt.empty?
        end
        pp_fail("can't have both required and optional arguments: "<<
          str.inspect) if reqs.any? && opts.any?
        arg_names = opts | reqs
        pp_fail("spell the argument the same way each time: "<<
          oxford_comma(arg_names)) if arg_names.length > 1
        OptParseParse.new(
          names.map(&:to_sym), opts.any? || reqs.any?,
          reqs.any?, opts.any?, arg_names, short, long
        )
      end

      def pp_fail msg
        fail("parse parse fail: bad option syntax synatx: #{msg}")
      end
    end
  end
end

