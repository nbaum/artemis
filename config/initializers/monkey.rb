class Array
  def options
    map.with_index{|k,i|[k,i]}
  end
end
