def host_as_hash(host)
  host.instance_variables.collect do |instance_var|
    instance_var_as_str = instance_var.to_s.gsub('@', '').to_sym
    instance_var_value = host.instance_variable_get(instance_var)

    [instance_var_as_str, instance_var_value]
  end.to_h
end