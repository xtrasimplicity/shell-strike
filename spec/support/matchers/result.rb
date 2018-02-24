require 'rspec/expectations'

RSpec::Matchers.define :return_a_result_object do
  include ChainHelpers

  match do |actual_obj|
    actual_obj.is_a?(ShellStrike::Result) && validate_chains(actual_obj)
  end

  chain :with_a_success_value_of do |val|
    chain_name = __method__
    validator = Proc.new { |actual_object| actual_object.success? == val }

    append_chain_to_used_chains_list(chain_name, validator)
  end

  chain :and_an_error_type_of do |val|
    chain_name = __method__
    validator = Proc.new { |actual_object| actual_object.error_type == val }

    append_chain_to_used_chains_list(chain_name, validator)
  end

  chain :and_a_message_matching do |val|
    chain_name = __method__
    validator = Proc.new { |actual_object| !actual_object.message.match(val).nil? }

    append_chain_to_used_chains_list(chain_name, validator)
  end

  chain :and_no_message do
    chain_name = __method__
    validator = Proc.new { |actual_object| actual_object.message.empty? }

    append_chain_to_used_chains_list(chain_name, validator)
  end
end