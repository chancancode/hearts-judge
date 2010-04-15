#!/usr/bin/ruby

# Judge script

# TODO:
#   feature: implement time limit

require 'logger'
require 'optparse'
require 'constants.rb'
require 'game.rb'
require 'trick.rb'
require 'card.rb'
require 'player.rb'
require 'human_player.rb'
require 'npc_player.rb'
require 'array_extension.rb'
# require 'rubygems'
# require 'ruby-debug'

# Turn off Ruby warnings
$VERBOSE = nil

module Hearts
  class Judge
    
    def initialize  
      # Parse arguments
      # 
      # For player commands...
      # 
      # Java: ruby judge.rb "java -classpath ../java-example/ Player"
      # Ruby: ruby judge.rb "ruby ../ruby-example/dummy.rb"
      # 
      # To supress STDERR of player programs, add "2> /dev/null" to the end of the
      # command, i.e. ruby judge.rb "ruby ../ruby-example/dummy.rb 2> /dev/null"

      @options = {}

      OptionParser.new do |opts|
        opts.banner = "Usage: ruby judge.rb [options] command0 command1 ..."
  
        @options[:shuffle] = false
        opts.on("-s", "--shuffle", "Shuffle the players' positions") do
          @options[:shuffle] = true
        end
  
        @options[:verbose] = false
        opts.on("-v", "--verbose", "Verbose mode") do
          @options[:verbose] = true
        end
        
        @options[:replay] = false
        opts.on("-r", "--replay", "Enable replaying of a set") do
          @options[:replay] = true
        end
        
        @options[:delay] = 30.0
        opts.on("-d", "--delay N", Float, "Delay N seconds before killing clients") do |n|
          @options[:delay] = n
        end
        
        @options[:points] = 100
        opts.on("-p", "--points N", DecimalInteger, "Play until a player scored N points") do |n|
          @options[:points] = n
        end
        
        opts.on("-h", "--help", "Display this message") do
          puts opts
          exit
        end
      end.parse!

      raise ArgumentError, "Too many players!" if ARGV.count > 4
      
      # Initialize logger (global variable)
      $logger = Logger.new(STDERR)
      $logger.level = @options[:verbose] ? Logger::DEBUG : Logger::INFO
      $logger.debug('Created logger.')
      $logger.debug("shuffle=#{@options[:shuffle]}")
      $logger.debug("verbose=#{@options[:verbose]}")
      $logger.debug("replay=#{@options[:replay]}")
      $logger.debug("delay=#{@options[:delay]}")
      $logger.debug("points=#{@options[:points]}")

      # Store the commands
      @commands = ARGV + [nil,nil,nil,nil] # Add some padding...
      @commands = @commands[0..3] # Then trim it.
      @commands.shuffle! if @options[:shuffle]
      
      @games_played = 0
      @current_game = nil
      @points = [0,0,0,0]
      
    end
    
    def play_loop
      while @points.max < @options[:points]
        if @options[:replay]
          $logger.info('*** Starting new set ***')
          @set_points = [0,0,0,0]
          deck = Card.deck.shuffle!
          
          4.times do            
            next_game!
            deal_cards(deck.clone)
            pass_cards
            game_on
            clean_up
            
            temp = deck.slice!(0,13)
            deck = deck + temp
          end
          
          $logger.info("*** Set Summary ***")
          
          @current_game.players.each_with_index do |player,i|
            @points[i] += (@set_points[i] / 4.0)
            $logger.info("#{player} scored #{@set_points[i] / 4.0} points in this set. Total = #{@points[i]}.")
          end
        else
          next_game!
          deal_cards
          pass_cards
          game_on
          clean_up
        end
      end
    end
    
    private
    
    def next_game!
      $logger.info('*** Starting new game ***')
      
      @current_game = Game.new
            
      @commands.each_with_index do |cmd,i|
        @current_game << (cmd ? NPCPlayer.new(i,@current_game,cmd) : HumanPlayer.new(i,@current_game))
      end
      
      $logger.info('All players are ready.')
    end
    
    def deal_cards(deck=nil)
      $logger.info('Dealing cards...')
      
      $logger.debug('Shuffling deck.')
      deck ||= Card.deck.shuffle!
      
      @current_game.players.each do |player|
        $logger.debug("Dealing cards to #{player}")
        player.deal_cards(deck.slice!(0,13))
      end
    end
    
    def pass_cards
      $logger.info('Passing cards...')

      direction = case @games_played % 4
        when 0 then :left
        when 1 then :right
        when 2 then :across
        when 3 then :nopass
      end
      
      cards = []
            
      @current_game.players.each_with_index do |player,i|
        neighbour = player.neighbour(direction)
        $logger.debug("#{player} is picking cards for #{neighbour}...")
        cards[i] = player.request_pass(neighbour,direction)
      end
      
      @current_game.players.each_with_index do |player,i|
        neighbour = player.neighbour(direction)
        $logger.debug("#{player} is passing cards to #{neighbour}...")
        neighbour.receive_pass(player,cards[i])
      end
      
      $logger.debug("Done passing cards.")
    end
    
    def game_on
      $logger.info("Game on!")
      
      @current_game.start!
      
      13.times do
        trick = @current_game.current_trick
        
        4.times do
          player = trick.current_player
                    
          if @current_game.new? && trick.empty?
            player.request_start(trick)
          else
            player.request_play(trick)
          end
          
          trick.next_player!
        end
        
        $logger.info("Player #{trick.winner} won the trick, gained #{trick.points} points.")
        @current_game.next_trick!
      end
    end
   
    def clean_up
      game_points = @current_game.points
      
      @current_game.players.each_with_index do |player,i|
        if @options[:replay]
          @set_points[i] += game_points[i]
          $logger.info("#{player} scored #{game_points[i]} points in this game. Set points = #{@set_points[i]}.")
        else
          @points[i] += game_points[i]
          $logger.info("#{player} scored #{game_points[i]} points in this game. Total = #{@points[i]}.")
        end
        
        player.game_ended # callback
      end
      
      sleep @options[:delay]
      
      @current_game.players.each do |player|
        $logger.debug("Killing #{player}")
        player.kill!
      end
    end
  end
end

j = Hearts::Judge.new
j.play_loop