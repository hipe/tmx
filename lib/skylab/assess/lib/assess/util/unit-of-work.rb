require 'assess/util/strict-attr-accessors'

module Hipe
  module Assess

    class UnitsOfWork < Array

      def add_unit_of_work(*args, &block)
        uow = UnitOfWork.new(*args, &block)
        push(uow)
      end

      def run_units_of_work ui, dry_run=false
        num_done = 0
        units_of_work.each do |unit|
          if unit.empty?
            puts unit.describe
          else
            unit.dry_run = dry_run
            ui.puts unit.describe
            unit.commit ui
            num_done += 1
          end
        end
        num_done
      end
    end


    class UnitOfWork
      extend StrictAttrAccessors
      boolean_attr_accessor :dry_run

      attr_accessor :ui

      def initialize(desc, &block)
        @describe = desc
        @block = block
      end

      def commit(ui)
        self.ui = ui
        @block.call(self) if @block
      end

      def empty?
        @block.nil?
      end
    end
  end
end
