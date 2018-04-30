class Integer
  def my_times
    c = 0
    until c == self
      yield(c)
      c += 1
    end
    self
  end
end

class Array
  def my_each
    size.my_times do |i|
      yield self[i]
    end
    self
  end

  # def my_times ?
  #   array = Array.new(self)
  #   c = 0
  #   array.my_each do
  #     array[c] = c
  #     yield(c)
  #     c += 1
  #   end
  #   self  
  # end

  def my_each
    c = 0
    until c == size
      yield(self[c])
      c += 1
    end
    self
  end
end
