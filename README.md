[requirements][./marketer-ruby-assignment.md]

### How to use

1. Install required Ruby version (see `.ruby-version`)
1. Install dependencies: `bundle install`
1. Run irb: `irb -I lib`
1. Do experiments there:

```ruby
require 'app'
app = App.new(invaders: ["--\noo", "--\n-o"], mismatch_threshold: 1)
app.find_invaders("--\n-o")
app.find_invaders("-o\noo")
app.find_invaders("---\n-oo")
app.find_invaders("---\n---\n-oo")
```
