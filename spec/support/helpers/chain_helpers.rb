module ChainHelpers
  def append_chain_to_used_chains_list(chain_name, validator_proc)
    used_chains << [chain_name, validator_proc]
  end

  def validate_chains(actual_object)
    raise 'No chain methods have been specified' if used_chains.empty?

    valid_chain_count = 0

    used_chains.each do |chain_name, validator|
      valid_chain_count += 1 if validator.call(actual_object)
    end

    valid_chain_count == used_chains.length
  end

  private

  def used_chains
    @used_chains ||= []
  end
end
