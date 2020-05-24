module Anngler
    module Helpers
        class << self

            def magnitude(vec)
                Math.sqrt(vec.square.to_a.reduce(:+))
            end

            def cosine_distance(a, b)
                1 - a.dot(b) / (magnitude(a) * magnitude(b))
            end

        end 

    end
end