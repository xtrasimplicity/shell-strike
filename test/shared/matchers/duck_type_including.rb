# RSpec `duck_type_including` matcher, yet to be included in RSpec-mocks.
# Specs and the latest version of the code are available in this PR:
# https://github.com/rspec/rspec-mocks/pull/1221
module RSpec
  module Mocks
    module ArgumentMatchers
      # Matches if the actual argument responds to the specified messages, and the values match.
      #
      # @example
      #   expect(object).to receive(:message).with(duck_type_including(name: 'Fred'))
      #   expect(object).to receive(:message).with(duck_type_including(name: 'Fred', last_name: 'Flintstone'))
      def duck_type_including(**args)
        DuckTypeIncludingMatcher.new(**args)
      end


      # @private
      class DuckTypeIncludingMatcher
        def initialize(**methods_to_respond_to_with_values)
          @methods_to_respond_to_with_values = methods_to_respond_to_with_values
        end

        def ===(value)
          @methods_to_respond_to_with_values.all? do |message, expected_value|
            value.respond_to?(message) && value.send(message.to_sym) == expected_value
          end
        end

        def description
          hash_as_string = @methods_to_respond_to_with_values.collect { |k, v| "#{k}: '#{v}'" }.join(', ')
          "duck_type_including(#{hash_as_string})"
        end
      end
    end
  end
end