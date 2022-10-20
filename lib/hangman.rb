require "yaml"
# Select all words between 5 and 12 characters, chomp to get rid of newline character adding +1 to length
$words = File.readlines("lib\\google-10000-english-no-swears.txt").select {|word| word.chomp.length >= 5 && word.chomp.length <= 12} 
$hangman = [
    " O \n" +
    "\\|/\n" +
    "/ \\\n",

    " O \n" +
    "\\|/\n" +
    "/  \n",

    " O \n" +
    "\\|/\n" +
    "   \n",

    " O \n" +
    "\\| \n" +
    "   \n",

    " O \n" +
    " | \n" +
    "   \n",

    " O \n" +
    "   \n" +
    "   \n",

    "   \n" +
    "   \n" +
    "   \n",
]

class Hangman
    def initialize(secret_word = nil, guesses_left = 6, guessed_letters = Hash.new(), current_guess = nil)
        if secret_word.nil? then
             # Select a random word in the array above
            @secret_word = $words.sample().chomp  
        else 
            @secret_word = secret_word
        end

        @guesses_left = guesses_left
        @guessed_letters = guessed_letters
        
        if current_guess.nil? then
            # Initial state of the prompt the user sees
            @current_guess = "_ " * @secret_word.length
        else
            @current_guess = current_guess
        end           
    end

    def save_game()
        File.open("lib\\save.yaml", "w") { |file| 
            file.write YAML.dump({
                :secret_word => @secret_word,
                :guesses_left => @guesses_left,
                :guessed_letters => @guessed_letters,
                :current_guess => @current_guess
            })
        }
        puts "Your game has been saved."
    end
    
    def load_game()
        if File.exists?("lib\\save.yaml")
            puts "Loading game..."
            data = YAML.load(File.read("lib\\save.yaml"))
            # Call the hangman constructor with the data loaded from the yaml file
            self.initialize(data[:secret_word], data[:guesses_left], data[:guessed_letters], data[:current_guess])
            self.play_game(false)
        else 
            puts "No save game found"
        end
    end

    def play_game(new_game = true)
        @solved = false # Has the secret word been solved?

        # If starting a new game, prompt the user to load an existing game
        if new_game then
            print "Send any key to begin a new game or write \"load\" to load your previous game: "
            option = gets.chomp
            if option.downcase == "load" then
                load_game()
            end
            if option.downcase == "quit" then
                exit
            end
        end
        while @guesses_left > 0 && !@solved do
            # Display current game info and prompt user for their guess
            puts "#{$hangman[@guesses_left]}"
            puts "\n#{@current_guess} \t #{@guesses_left} guess" + (@guesses_left == 1 ? "" : "es") + " left \t Guesses: #{@guessed_letters.keys}" # Prompt the user
            print "Enter a guess or write \"save\" to save your game: "
            guess = gets.chomp.downcase # 

            # If the user guesses the entire word outright, they win
            if guess == @secret_word then
                @solved = true
                break
            end
        
            # Dump this Hangman instance's variables to a .yaml file and exit
            if guess == "save" then
                save_game()
                exit
            end

            if guess.downcase == "quit" then
                print "[QUITTING] Would you like to save your game first? y/N: "
                yes_no = gets.chomp.downcase
                if yes_no[0] == "y" then
                    save_game()
                end
                exit
            end
        
            # If they guess something non-alphabetic, prompt again
            if !guess.match?(/[[:alpha:]]/) then
                next
            end

            # Get the first letter of their input
            guess = guess[0]
            # If the guess key is already in the guessed letters hash, prompt again
            if @guessed_letters.has_key?(guess) then
                puts "You already guessed #{guess}, try again."
                next
            end
        
            # Add this letter to the user's list of guessed words
            @guessed_letters[guess] = true           
            
            # Search the secret word for the guess
            guess_is_correct = false

            # Loop over each letter in the secret word
            @secret_word.chars.each_with_index do |letter, index|
                # Compare the current letter with the user's guess
                if guess == letter then
                    guess_is_correct = true
                    # Replace every instance of "_" with "guess" in the prompted word
                    # * 2 to account for the spaces between the "_"s
                    @current_guess[index * 2] = guess
                    # If the assembled prompt word matches the secret word character-by-character, the word is solved and the game is over
                    if @current_guess.split(" ").join("") == @secret_word then
                        @solved = true
                    end
                end
            end
            # Only take away a guess amount if the letter they guessed isn't in the secret word
            @guesses_left -= 1 unless guess_is_correct
        end
        
        if @solved then
            puts "#{$hangman[@guesses_left]}"
            puts @secret_word.split().join(" ")
            puts "You win!"
            exit
        end
        
        if @guesses_left <= 0 then
            puts "#{$hangman[@guesses_left]}"
            puts "You lose! The word was #{@secret_word}"
            exit
        end
    end
end

Hangman.new().play_game()