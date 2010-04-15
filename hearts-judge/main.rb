#!/usr/bin/ruby

require 'logger'
require 'agent_chan.rb'
require 'opaque_player.rb'

###################
# Procedural Code #
###################

# Turn off Ruby warnings
$VERBOSE = nil

$logger = Logger.new(STDERR)
$logger.level = Logger::DEBUG
$logger.debug('Created logger.')


# Phase 1

$stdout.puts 'Agent Chan'
$stdout.flush

$logger.info '*** Phase 1 - Initialization ***'

player_id = $stdin.gets.chomp!.to_i
$logger.info "Player ID: #{player_id}"

game = Hearts::Game.new

4.times do |i|
  if i == player_id
    game << Hearts::AgentChan.new(i,game)
  else
    game << Hearts::OpaquePlayer.new(i,game)
  end
end

agent = game.players[player_id]

cards = (1..13).map{ Hearts::Card.from_string($stdin.gets.chomp!) }
$stdin.gets
$logger.info "Phase 1 OK."

agent.deal_cards(cards)


# Phase 2

$logger.info '*** Phase 2 - Card Passing ***'

direction = case $stdin.gets.chomp!
  when 'PL' then :left
  when 'PR' then :right
  when 'PA' then :across
  when 'NP' then :nopass
end

$logger.info "Pass direction: #{direction}"

to = game.players[$stdin.gets.chomp!.to_i]
$stdin.gets

cards = agent.request_pass(to,direction)
$stdout.puts cards.join $/
$stdout.flush

$logger.info "Phase 2 OK."


# Phase 2a
$logger.info '*** Phase 2a - Card Passing (Confirmation) ***'
cards = (1..3).map{ Hearts::Card.from_string($stdin.gets.chomp!) }
to.receive_pass(agent,cards)
$logger.info "Cards from judge: #{cards.join ' '}"
$stdin.gets
$logger.info "Phase 2a OK."


# Phase 3
$logger.info '*** Phase 3 - Receiving Cards ***'
from = game.players[$stdin.gets.chomp!.to_i]
cards = (1..13).map{ Hearts::Card.from_string($stdin.gets.chomp!) }
$stdin.gets

# Just to be safe
agent.deal_cards(cards) 
$logger.info "Phase 3 OK."

13.times do |i|
  $logger.info "---------- Round #{i} ----------"
  
  # Phase 4
  $logger.info '*** Phase 4 - Playing a Card ***'
  $logger.info "Round: #{$stdin.gets.chomp!}"
  
  trick = nil
  starter = game.players[$stdin.gets.chomp!.to_i]
  
  $logger.info "Hearts broken: #{$stdin.gets.chomp!}" # ignore
  
  count = $stdin.gets.chomp!.to_i
  $logger.info "Cards count: #{count}"
  
  trick = game.current_trick
    
  if count == 0
    if i == 0
      game.start!
      trick = game.current_trick
      card = agent.request_start(trick)
    else
      card = agent.request_play(trick)
    end
  else
    if i == 0
      starter.has!(C2)
      game.start!
      trick = game.current_trick
    end
      
    count.times do
      player = trick.current_player
      card = Hearts::Card.from_string($stdin.gets.chomp!)
      player.card_played(trick,card)
    end
    
    card = agent.request_play(trick)
  end
  
  $stdin.gets
  $logger.info "*** Card : #{card}"
  $stdout.puts card
  $stdout.flush
  
  $logger.info "Phase 4 OK."
  
  # Phase 4a
  $logger.info '*** Phase 4a - Playing a Card (Confirmation) ***'
  card = Hearts::Card.from_string($stdin.gets.chomp!)
  agent.card_played(trick,card)
  $stdin.gets
  $logger.info "Phase 4a OK."
  
  # Phase 5
  $logger.info '*** Phase 5 - Round Summary ***'
  $logger.info "Round: #{$stdin.gets.chomp!}"
  player = game.players[$stdin.gets.chomp!.to_i]
  $logger.info "Hearts broken: #{$stdin.gets.chomp!}"
  4.times do
    card = Hearts::Card.from_string($stdin.gets.chomp!)
    player.card_played(trick,card) unless trick.cards.include? card
    player = player.neighbour(:left)
  end
  $logger.info "Winner: #{$stdin.gets.chomp!}"
  game.next_trick!
  $logger.info "Points: #{$stdin.gets.chomp!}"
  $stdin.gets
  $logger.info "Phase 5 OK."
end

# Phase 6
$logger.info '*** Phase 6 - Game Summary ***'
points = (1..4).map{$stdin.gets.chomp!}
$logger.info "Points: #{points.join ' '}"
$logger.info "Phase 6 OK."

$logger.info "Quitting."