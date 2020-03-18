### How to use

1. Run irb: `irb -r ./app.rb`
1. Do experiments there:

```ruby
app = App.new(invaders: ["--\noo", "--\n-o"], noise_threshold: 1)
app.find_invaders("--\n-o")
app.find_invaders("-o\noo")
app.find_invaders("---\n-oo")
app.find_invaders("---\n---\n-oo")
```
