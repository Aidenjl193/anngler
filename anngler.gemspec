Gem::Specification.new do |s|
    s.name = 'anngler'
    s.version = '0.0.1'
    s.date = '2020-05-20'
    s.summary = 'A ruby locality sensitive hashing implementation using Redis for storage'

    s.authors = ['Aiden Leeming']

    s.add_development_dependency "rspec"
    s.add_development_dependency "mock_redis"

    s.files = [
        'lib/anngler.rb',
        'lib/anngler/helpers.rb',
        'lib/anngler/storage/memory_backend.rb',
        'lib/anngler/storage/redis_backend.rb',
        'lib/anngler/index.rb'
    ]
    s.require_paths = ['lib']

    s.add_dependency 'json'
    s.add_dependency 'numo-narray'
    s.add_dependency 'redis'
    s.add_dependency 'zlib'
end