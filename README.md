### How to use

1. Run irb: `irb -I lib`
1. Do experiments there:

```ruby
require 'app'
app = App.new(invaders: ["--\noo", "--\n-o"], noise_threshold: 1)
app.find_invaders("--\n-o")
app.find_invaders("-o\noo")
app.find_invaders("---\n-oo")
app.find_invaders("---\n---\n-oo")
```
