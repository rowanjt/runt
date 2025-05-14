# Add precision +Runt::DPrecision+ to standard library classes Date and DateTime
# (which is a subclass of Date). Also, add an include? method for interoperability
# with +Runt::TExpr+ classes
require 'date'

module CoreExtensions
  module DatePrecision

    refine Date do
      # alias_method :include?, :eql?

      attr_writer :date_precision

      def date_precision
        # supress warning: instance variable @date_precision not initialized
        @date_precision ||= nil

        if @date_precision.nil?
          if self.class == DateTime
            @date_precision = Runt::DPrecision::SEC
          else
            @date_precision = Runt::DPrecision::DAY
          end
        end

        @date_precision
      end
    end

  end
end
