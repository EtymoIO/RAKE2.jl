mutable struct Rake
    stop_words::Vector{String}
    min_char_length::Int
    max_words_length::Int
    min_keyword_frequency::Int
    min_words_length_adj::Int
    max_words_length_adj::Int
    min_phrase_freq_adj::Int
end

struct Score
    rank::Float64
    frequency::Int
end

function Rake(stop_words; min_char_length=3, max_words_length=3, min_keyword_frequency=10,
              min_words_length_adj=1, max_words_length_adj=1, min_phrase_freq_adj=2)
    Rake(stop_words, min_char_length, max_words_length, min_keyword_frequency,
         min_words_length_adj, max_words_length_adj, min_phrase_freq_adj)
end

import Base.run

"Take vector of strings and split each string into all possible keyphrases"
function find_all_possible_keyphrases(phrases, max_phrase_length::Int)
    all_possible_keyphrases = Array(String,0)
    for sentence in phrases
        split_sentence = split.(sentence, ' ')
        for j = 0: max_phrase_length-1
            for i = 1:(length(split_sentence)-j)
                push!(all_possible_keyphrases, join(split_sentence[i:i+j], " "))
            end
        end
    end
    return all_possible_keyphrases
end


function run(text, stop_words, max_phrase_length)

    punct = ['.', '?', '!', '\n', ';', ',', ':', '\u2019', '\u2013']
    whitespace = false
    buffer = ""
    current_word = ""

    phrases = SubString{String}[]
    for i in text
        if i in punct # punctuation
            append!(phrases, find_all_possible_keyphrases([buffer], max_phrase_length))
            buffer = ""
            current_word = ""
            whitespace = false

        elseif (i == ' ') && (!whitespace) # hit whitespace, last character wasnt whitespace
            if current_word in stop_words # stopword
                append!(phrases, find_all_possible_keyphrases([buffer], max_phrase_length))
                buffer = ""
                current_word = ""
                whitespace = false
            else
                if buffer != ""
                    buffer = buffer*" "*string(current_word)
                else
                    buffer = buffer*string(current_word)
                end
                current_word = ""
                whitespace = true
            end

        elseif (i == ' ') && (whitespace) # hit whitspace, last character was whitespace
            continue

        else
            current_word = current_word*string(lowercase(i))
            whitespace = false
        end
    end

    if buffer != ""
        buffer = buffer*" "*string(current_word)
    else
        buffer = buffer*string(current_word)
    end
    print(buffer)
    append!(phrases, find_all_possible_keyphrases([buffer], max_phrase_length))

    keyphrases = unique(phrases)
    d = Dict([(i, count(x->x==i,phrases)) for i in phrases])
    return d
end
