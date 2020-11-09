module Anngler
    module Storage
        class MemoryBackend
            def initialize
                @storage = Hash.new( [] )
            end

            def add_vector(bucket, data)
                @storage[bucket] = [data] + @storage[bucket]
            end

            def remove_vector(bucket, data)
                @storage[bucket] = @storage[bucket].reject do |encoded_str|
                    encoded_str == data
                end
            end

            def query_bucket(bucket)
                @storage[bucket]
            end
        end
    end
end