# Grant Isom, EECS 665, Project 1
require 'set'

# Global Variables
total_states = ""
init_state = ""
final_states = ""
moves = []
seen_states = []
d_tran_table = Hash.new
final_table = []
final_f_states = []

#Parser for file input
puts "Enter filename: \n"
file_name = gets.chomp
states = []
file = File.open(file_name, "r") do |file|
    file.readlines.each_with_index do |line, idx|
        if idx == 0
            init_state = line.match(/\d+/).to_s.to_i
        elsif idx == 1
            final_states = line.match(/\d+/).to_a.map { |e| e.to_i }.to_set
        elsif idx == 2
            total_states = line.match(/\d+/).to_s.to_i
        elsif idx == 3
            moves = line.split(" ").drop(1)
        else
            states << line
        end
    end
end
states = states.map{|i| i.split(" ").drop(1)}.map{ |i| i.map { |e| e.gsub(/[{}]/, "").split(',').map{|s| s.to_i}.to_set}}

# Takes the array of arrays of Sets and transforms it into a hash table.
for s in 1..total_states
    state_hash = Hash.new
    for move in moves
        state_hash[move] = states[s-1][moves.index(move)]
    end
    d_tran_table[s] = state_hash
end

# This takes in an array of states, a symbol, and the table and makes a move...
def move(states, symbol, table)
    moves = Set.new
    for state in states
        moves.add(table.fetch(state).fetch(symbol))
    end
    return moves.flatten
end

# This finds the E-closure of a set of states.
def e_closure(states, table)
    e_set = Set.new states
    s_size = 0
    while e_set.length != s_size
        s_size = e_set.length
        e_set.merge(move(e_set, "E", table))
    end
    return e_set
end

# Mark handles going through a move and finding new E-closures and also handles printing the first part of the output.
def mark(states, table, moves, seen_states, final_table)
    for m in moves
        x = move(states, m, table)
        if !x.empty?
            y = e_closure(x, table)
            if !seen_states.include?(y)
                seen_states << y
                final_table << (seen_states.index(y) + 1)
                pretty_print(states, m, x, y, (seen_states.index(y) + 1))
            else
                final_table << (seen_states.index(y) + 1)
                pretty_print(states, m, x, y, (seen_states.index(y) + 1))
            end
        else
            final_table << " "
        end
    end
end

# Prints out a move that is not empty and also the e-closure of it
def pretty_print(states, symbol, move, e_closure, placement)
    s1 = "#{states} --#{symbol}--> #{move.to_a}"
    s2 = "E-closure#{move.to_a} = #{e_closure.to_a} = #{placement}"
    puts s1.gsub(/\[/, "{").gsub(/\]/, "}")
    puts s2.gsub(/\[/, "{").gsub(/\]/, "}")
end

# Main function that handles starting the project, doing some intital set up, then boom. You're off to the races.
def start(init_state, total_states, final_states, moves, seen_states, table, final_table, final_f_states)
    init_e_closure = e_closure([init_state], table)
    seen_states << init_e_closure
    marker = 1
    s1 = "E-closure(IO) = #{init_e_closure.to_a} = #{seen_states.index(init_e_closure) + 1}\n"
    puts s1.gsub(/\[/, "{").gsub(/\]/, "}")
    moves.pop()
    for curr_state in seen_states
        puts "\nMark #{marker}"
        mark(curr_state.to_a, table, moves, seen_states, final_table)
        marker = marker + 1
    end
    for state in seen_states
        for s in state
            if final_states.include? s
                final_f_states << (seen_states.index(state) + 1)
            end
        end
    end
end

# Just initialization of the conversion and also the second part of printing the output.
start(init_state, total_states, final_states, moves, seen_states, d_tran_table, final_table, final_f_states)
puts "\nInitial State: #{init_state}"
puts "Final States: {#{final_f_states.join(",")}}"
printf "States"+ moves.map { "%6s" }.join + "\n", *moves
count = 1
for t in 1..final_table.length
    if t % moves.length == 0
        print "{#{final_table[t-1]}}      "
        print "\n"
    elsif t % moves.length == 1
        print "#{count}      "
        print "{#{final_table[t-1]}}      "
        count = count + 1
    else
        print "{#{final_table[t-1]}}      "
    end
end
print "\n" # For looks
