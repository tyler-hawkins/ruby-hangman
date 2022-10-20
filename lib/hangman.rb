require "yaml"

$words = File.readlines("lib\\google-10000-english-no-swears.txt").select {|word| word.length >= 5 && word.length <= 12} # Select all words between 5 and 12 characters
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
    def initialize(secret_word = nil, current_guess = nil, guesses_left = 6, guessed_letters = Hash.new())
        @secret_word = $words.sample().chomp if secret_word.nil? # Select a random word in the array above
        @guesses_left = guesses_left
        @guessed_letters = guessed_letters
        @current_guess = "_ " * @secret_word.length # Initial state of the prompt the user sees
        @solved = false # Has the secret word been solved?

        if guessed_letters.empty? then
            print "Press any key to begin a new game or \"l\" to load your previous game: "
            option = gets.chomp
            if option.downcase == "l" then
                self.new(load_game())
            end
        end
        playGame()

    end

        
    def saveGame()
        puts YAML.dump({
            :secret_word => @secret_word,
            :guesses_left => @guesses_left,
            :guessed_letters => @guessed_letters,
            :current_guess => @current_guess
        })
    end
    
    def loadGame()

    end

    def playGame()
        while @guesses_left > 0 && !@solved do
            puts "#{$hangman[@guesses_left]}"
            puts "\n#{@current_guess} \t #{@guesses_left} guess" + (@guesses_left == 1 ? "" : "es") + " left \t Guesses: #{@guessed_letters.keys}" # Prompt the user
            print "Enter a guess or write \"save\" to save your game: "
            guess = gets.chomp.downcase
            # If the user guesses the entire word outright, they win
            if guess == @secret_word then
                @solved = true
                break
            end
        
            if guess == "save" then
                saveGame()
                puts "Your game has been saved."
                break
            end
        
            # If they guess something non-alphabetic, prompt again
            if !guess.match?(/[[:alpha:]]/) then
                next
            end
            # Get the first letter of their input and lowercase it
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

Hangman.new()