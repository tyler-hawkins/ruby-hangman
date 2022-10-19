words = File.readlines("lib\\google-10000-english-no-swears.txt").select {|word| word.length >= 5 && word.length <= 12} # Select all words between 5 and 12 characters
secret_word = words.sample().chomp # Select a random word in the array above
guesses_left = 6 # Number of attempts to guess the secret word
solved = false # Has the secret word been solved?
guessed_letters = Hash.new() # Storing the letters the user guessed
current_guess = "_ " * secret_word.length # Initial state of the prompt the user sees
hangman = [
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

while guesses_left > 0 && !solved do
    puts "#{hangman[guesses_left]}"
    puts "\n#{current_guess} \t #{guesses_left} guesses left \t Guesses: #{guessed_letters.keys}" # Prompt the user
    print "Enter a guess: "
    guess = gets.chomp
    # If the user guesses the entire word outright, they win
    if guess == secret_word then
        solved = true
        break
    end

    # If they guess something non-alphabetic, prompt again
    if !guess.match?(/[[:alpha:]]/) then
        next
    end
    # Get the first letter of their input and lowercase it
    guess = guess[0].downcase
    # If the guess key is already in the guessed letters hash, prompt again
    if guessed_letters.has_key?(guess) then
        puts "You already guessed #{guess}, try again."
        next
    end

    # Add this letter to the user's list of guessed words
    guessed_letters[guess] = true
    
    
    # Search the secret word for the guess
    guess_is_correct = false
    # Loop over each letter in the secret word
    secret_word.chars.each_with_index do |letter, index|
        # Compare the current letter with the user's guess
        if guess == letter then
            guess_is_correct = true
            # Replace every instance of "_" with "guess" in the prompted word
            # * 2 to account for the spaces between the "_"s
            current_guess[index * 2] = guess
            # If the assembled prompt word matches the secret word character-by-character, the word is solved and the game is over
            if current_guess.split(" ").join("") == secret_word then
                solved = true
            end
        end
    end
    # Only take away a guess amount if the letter they guessed isn't in the secret word
    guesses_left -= 1 unless guess_is_correct
end

if solved then
    puts "#{hangman[guesses_left]}"
    puts secret_word.split().join(" ")
    puts "You win!"
    exit
end

if guesses_left <= 0 then
    puts "#{hangman[guesses_left]}"
    puts "You lose! The word was #{secret_word}"
    exit
end

