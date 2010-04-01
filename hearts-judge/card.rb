module Hearts
  class Card
    include Comparable   
    attr_reader :suite, :rank
    
    @@suite_order = { 'S'=>1, 'H'=>2, 'C'=>3, 'D'=>4 }
    @@cards = {}
    
    def self.from_string(value)
      @@cards[value] ||= Card.new(value.to_s)
    end
      
    def initialize(value)
      @suite = value[0...1].to_s
      @rank = value[1..-1].to_i
    end
    
    def to_s
      @suite + @rank.to_s
    end
    
    def <=>(other)
      score <=> other.score
    end
        
    def score
      @@suite_order[@suite].to_i * 100 + ((@rank - 2) % 13)
    end
  end
end