overrides = {}
enum_classes = ObjectSpace.each_object(Class).select do |c|
  c.ancestors.include?(Enumerable)
end
enum_classes.sort_by {|c| c.name}.each do |c|
  overrides[c] = c.instance_methods(false) & Enumerable.instance_methods(false)
end
overrides.delete_if {|c, methods| methods.empty? }
overrides.each do |c,methods|
  puts "Classes #{c} overrides: #{methods.join(", ")}"
end



# Class ARGF.class overrides: to_a 
# Class Array overrides: to_a, to_h, first, reverse_each, find_index, sort, collect, map, select, reject, zip, include?, count, cycle, take,       take_while, drop, drop_while
# Class Enumerator overrides: each_with_index, each_with_object 
# Class Enumerator::Lazy overrides: map, collect, flat_map, collect_concat, select, find_all, reject, grep, zip, take, take_while, drop,           drop_while, lazy, chunk, slice_before
# Class Hash overrides: to_h, to_a, select, reject, include?, member?
# Class ObjectSpace::WeakMap overrides: include?, member?
# Class Struct overrides: to_a, to_h, select
