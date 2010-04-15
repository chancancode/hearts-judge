class Array
  def randomly_pick(n=nil)
    if n.nil?
      self.shuffle.first
    else
      self.shuffle.first(n)
    end
  end
  
  def shuffle
    self.clone.shuffle!
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
  
  def delete_first(obj)
    i = self.index(obj)
    self.delete_at(i) unless i.nil?
  end
end