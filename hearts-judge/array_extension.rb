class Array
  def randomly_pick(n=nil)
    if n.nil?
      shuffle.first
    else
      shuffle.first(n)
    end
  end
  
  def shuffle
    clone.shuffle!
  end

  def shuffle!
    n = self.length
    while(n > 1) do
      k = rand(n)
      n = n - 1
      self[k], self[n] = self[n], self[k]
    end
    self
  end
end