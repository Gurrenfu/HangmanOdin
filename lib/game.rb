# play hangman
# 5 to 12 words
# load words from dictionary 
# save game and load game 

#guessing  and checking 
# getting word from database
# saving and loading game


# word_list = File.readlines('dictionary/5desk.txt')
# word_list.filter!{|word| word.length.between?(7,14)}
# word_list_length = word_list.length
# puts word_list[rand(word_list_length)]

class WordList 
    attr_reader :word_list_length

    def initialize(word_array, min = 7, max = 14)
        @word_list = word_array
        @word_list.filter!{|word| word.length.between?(min,max)}
        @word_list_length = @word_list.length
    end

    def get_word(index = rand(@word_list_length))
        @word_list[index]
    end
end

words = WordList.new(File.readlines('dictionary/5desk.txt'))
puts words.get_word(5)