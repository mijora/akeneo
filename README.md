# akeneo

API client for accessing Akeneo.

Usage:

```ruby
require 'akeneo'

client = Akeneo::API.new(
  url: 'https://my.akeneo.instance.com',
  client_id: '1337',
  password: 'tb9iiXWKskG2AFsKDaexyNf',
  secret: 'F3vpu3p0ezUmwW6nit5eVqt',
  username: 'API Username'
)

client.product(511707)
# => {"identifier"=>"511707", "family"=>"simple_product", "parent"=>nil, "groups"=>[]...
```

## Configuration

### Caching

If you want to use redis as a caching layer you have to set the `REDIS_URL` ENV variable.
By default the request will be cached for 5 Minutes.
You can alter the cache expiration via the `AKENEO_CACHE_EXPIRES_IN` ENV variable.

Caching is enabled by default whenever you have redis running.
You can disable caching completely by setting
`Akeneo::Cache.disabled = true` before you use the service.
