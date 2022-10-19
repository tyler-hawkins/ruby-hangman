words = File.readlines("lib\\google-10000-english-no-swears.txt").select {|word| word.length >= 5 && word.length <= 12}
secret_word = words.sample()
guesses_left = 5
