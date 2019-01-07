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
