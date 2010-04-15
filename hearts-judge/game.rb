require 'constants.rb'
require 'trick.rb'
require 'card.rb'

module Hearts
  class Game
    attr_reader :current_trick
    attr_accessor :players
    
    def initialize
      @players = []
      @heart_broken = false
      @qos_played = false
      @tricks_played = 0
    end
    
    def <<(player)
      raise 'This game cannot accept anymore players!' if @players.count == 4
      $logger.info("#{player} joined the game")
      @players << player
    end
    
    def start!
      # First trick
      starter = @players[NORTH] if @players[NORTH].has? C2
      starter = @players[EAST] if @players[EAST].has? C2
      starter = @players[SOUTH] if @players[SOUTH].has? C2
      starter = @players[WEST] if @players[WEST].has? C2
      @current_trick = Trick.new(0, starter, false)
      
      $logger.info("Round #{@tricks_played}: #{@current_trick.starter} is starting.")
    end
    
    def next_trick!      
      unless ended?
        # update the states
        @tricks_played += 1
        @heart_broken = heart_broken?
        @qos_played = qos_played?
        
        # send trick summary for current trick
        @players.each{ |p| p.trick_summary(@current_trick) }
        
        # notifier winner
        winner = @current_trick.winner
        winner.won_trick(@current_trick)
        
        @current_trick = Trick.new(@tricks_played, winner, @heart_broken)
        
        $logger.info("Round #{@tricks_played}: #{@current_trick.starter} is starting.")
        @current_trick
      end
    end
    
    def heart_broken?
      @heart_broken || (@current_trick && @current_trick.hearts?)
    end
    
    def qos_played?
      @qos_played || (@current_trick && @current_trick.qos?)
    end
    
    def points
      points = @players.map{ |p| p.points }
      
      if points.max == 26
        # Someone shot the moon
        points.map! { |p| 26-p }
      end
      
      points
    end
    
    def new?
      @tricks_played == 0
    end
    
    def ended?
      @tricks_played == 13 && @current_trick.full?
    end
  end
end