class Array
  def randomly_pick(n=1)
    shuffle[0...n]
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