module ActionView
  module Helpers
    module NumberHelper
      def number_to_currency_with_currency(number, options = {})
        defaults = {:unit => ''}
        s = @current_user.practice.currency_unit unless options[:unit]
        s << number_to_currency_without_currency(number, defaults.merge(options))
      end
      alias_method_chain :number_to_currency, :currency
    end
  end
end