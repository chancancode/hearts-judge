$stdout.puts 'READY'
$stdout.flush

# Phase 1
$stderr.puts '*** Phase 1 - Initialization ***'
$stderr.puts "Player ID: #{$stdin.gets.chomp!}"
cards = (1..13).map{$stdin.gets.chomp!}
$stderr.puts "Cards: #{cards.join ' '}"
$stdin.gets
$stderr.puts "Phase 1 OK."

# Phase 2
$stderr.puts '*** Phase 2 - Card Passing ***'
$stderr.puts "Pass direction: #{$stdin.gets.chomp!}"
$stderr.puts "Passing to: #{$stdin.gets.chomp!}"
$stdin.gets
3.times{$stdout.puts}
$stdout.flush
$stderr.puts "Phase 2 OK."

# Phase 2a
$stderr.puts '*** Phase 2a - Card Passing (Confirmation) ***'
cards = (1..3).map{$stdin.gets.chomp!}
$stderr.puts "Cards: #{cards.join ' '}"
$stdin.gets
$stderr.puts "Phase 2a OK."

# Phase 3
$stderr.puts '*** Phase 3 - Receiving Cards ***'
$stderr.puts "Received from: #{$stdin.gets.chomp!}"
cards = (1..13).map{$stdin.gets.chomp!}
$stderr.puts "Cards: #{cards.join ' '}"
$stdin.gets
$stderr.puts "Phase 3 OK."

13.times do |i|
  $stderr.puts "---------- Round #{i} ----------"
  
  # Phase 4
  $stderr.puts '*** Phase 4 - Playing a Card ***'
  $stderr.puts "Round: #{$stdin.gets.chomp!}"
  $stderr.puts "Starter: #{$stdin.gets.chomp!}"
  $stderr.puts "Hearts broken: #{$stdin.gets.chomp!}"
  count = $stdin.gets.chomp!.to_i
  $stderr.puts "Cards count: #{count}"
  cards = (1..count).map{$stdin.gets.chomp!}
  $stderr.puts "Cards: #{cards.join ' '}"
  $stdin.gets
  $stdout.puts
  $stdout.flush
  $stderr.puts "Phase 4 OK."
  
  # Phase 4a
  $stderr.puts '*** Phase 4a - Playing a Card (Confirmation) ***'
  $stderr.puts "Card: #{$stdin.gets.chomp!}"
  $stdin.gets
  $stderr.puts "Phase 4a OK."
  
  # Phase 5
  $stderr.puts '*** Phase 5 - Round Summary ***'
  $stderr.puts "Round: #{$stdin.gets.chomp!}"
  $stderr.puts "Starter: #{$stdin.gets.chomp!}"
  $stderr.puts "Hearts broken: #{$stdin.gets.chomp!}"
  cards = (1..4).map{$stdin.gets.chomp!}
  $stderr.puts "Cards: #{cards.join ' '}"
  $stderr.puts "Winner: #{$stdin.gets.chomp!}"
  $stderr.puts "Points: #{$stdin.gets.chomp!}"
  $stdin.gets
  $stderr.puts "Phase 5 OK."
end

# Phase 6
$stderr.puts '*** Phase 6 - Game Summary ***'
points = (1..4).map{$stdin.gets.chomp!}
$stderr.puts "Points: #{points.join ' '}"
$stderr.puts "Phase 6 OK."

$stderr.puts "Quitting."