# WIP

# CopyPasta

Copy active_record objects and associations blazingly fast (for ruby).

Just some random stuff

CopyPasta offers a flexible dsl allowing you to

 - Override custom attributes on a per table basis.
 - Specify the nested data you want copied.
 - Preserves associations.(belongs_to, STI, Polymorphic assocs, belongs_to with custom class names).
 - Preserves join tables.
 - Returns a tree of data of everything copied from and to.
 - Use the tree to safely rollback your data.
 - And of course, its blazingly fast.

## Build locally

gem build copy_pasta.gemspec
gem install --local ./copy_pasta-0.1.0.gem

## Should I use this

TODO

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'copy_pasta'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install copy_pasta

## Usage

```ruby
from_board = Board.find(1)
to_board   = Board.find(2)

CopyPasta.build do
  from from_board
  to   to_board # nil will create a new board.
  tables %i[lists comments activities]

  on :comments, data: from_board.lists.flat_map(&:active_comments)
  on :activities, data: from_board.lists.flat_map(&:activities)
end
```

Override data using the data to be copied.
Relationships can be complicated so you specify the data

```ruby
from_board = Board.find(1)
to_board   = Board.find(2)

CopyPasta.build do
  from from_board
  to   Board.find(2) # nil will create a new board.
  tables %i[lists comments activities]

  on :comments, data: from_board.lists.flat_map(&:comments), override: ->(data) { { commented_at: data.commented_at + 2.days } }
end
```

- Todo
 - [ ] primary key
 - [ ] multi_tenancy id from/to.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/copy_pasta. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/copy_pasta/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the CopyPasta project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/copy_pasta/blob/master/CODE_OF_CONDUCT.md).
