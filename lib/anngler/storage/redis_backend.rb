require 'redis'

module Anngler
    module Storage
        class RedisBackend

            def initialize(instance)
                @instance = instance
            end

            def add_vector(bucket, data)
                @instance.lpush(bucket, data)
            end

            def remove_vector(bucket, data)
                @instance.lrange(bucket, 0, -1).each do |val|
                    if(val == data)
                        @instance.lrem(bucket, 0, val)
                        return
                    end
                end
            end

            def query_bucket(bucket)
                @instance.lrange(bucket, 0, -1)
            end
            
        end
    end
end