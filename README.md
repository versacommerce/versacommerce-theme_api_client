# Versacommerce::ThemeAPIClient

[![Gem Version](https://badge.fury.io/rb/versacommerce-theme_api_client.svg)](http://badge.fury.io/rb/versacommerce-theme_api_client)

Versacommerce::ThemeAPIClient is a library to consume the VersaCommerce Theme API.

## Requirements

Ruby ≥ 3.2.0

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'versacommerce-theme_api_client'
```

And then execute:

```sh
$ bundle install
```

Or install it yourself as:

```sh
$ gem install versacommerce-theme_api_client
```

## Usage

Create a client object to work on:

```ruby
require 'versacommerce/theme_api_client'

authorization = 'YOUR_AUTHORIZATION'
client = Versacommerce::ThemeAPIClient.new(authorization: authorization)
```

The client object is tied to a single theme, depending on the authorization. You can get an authorization from your shop's admin section.

### Working with Directories

#### Finding Directories

Calling `#directories` on the client object will get you a `DirectoryRelation` object that responds to `#each`. As it includes the `Enumerable` module, the following will get you an array of all directories:  

```ruby
directories = client.directories.to_a
```

If you want to get an array of a directory's child directories, call:

```ruby
directories = client.directories.in_path('path/to/directory').to_a
```

This is practically the same as calling:

```ruby
directories = client.directories(path: 'path/to/directory')
```

These calls are recursive and will return all directory children by default. If you don't want this behaviour and instead only get direct child directories, turn it off by calling:

```ruby
directories = client.directories(recursive: false)

# respectively:
directories = client.directories.in_path('', recursive: false)
```

#### Finding a single Directory

If you want to find a single directory, call:
```ruby
directory = client.directories.find('path/to/directory')
```

Nesting with the relation is also possible. The following will try to find the directory `assets/font`:

```ruby
directory = client.directories(path: 'assets').find('font')
```

If the directory could be found, a `Directory` instance is returned, else a `RecordNotFoundError` is raised. A `Directory` instance has a `path` instance variable representing its path and responds to `#files`, which returns a `FileRelation` with the directory's path as base for the files.

#### Creating a Directory

In order to create a directory, use `#build` in combination with `#save` or use `#create`:

```ruby
directory = client.directories.build(path: 'special_font')
directory.save # => true or false

# which is basically the same as:
directory = client.directories(path: 'assets/font').create(path: 'special_fonts')
```

If the directory could not be saved, `false` will be returned and the `directory.errors` object populated with the errors that occured.

#### Updating a Directory

Updating a directory is similar to creating one:

```ruby
directory.update(path: 'new/path')

# which is basically the same as:
directory.path = 'new/path'
directory.save
```

#### Deleting a Directory

Delete a directory by calling:

```ruby
directory.delete
```

If you don't want to prefetch a directory in order to delete it, there's also:

```ruby
client.directories.delete('path/to/directory')
```

### Working with Files

#### Finding Files

Working with files is like dealing with directories. You can retrieve all files by calling:

```ruby
files = client.files.to_a
```

This will return an array of all files. A significant difference between a directory and a file is that a file can have content. Finding files using the method described above won't load the files' contents though. Reloading the content is possible:

```ruby
file = client.files.to_a.first
file.content # => nil

file.reload_content
file.content # => returns the content as String
```

Filtering files works like with a directory.

```ruby
files = client.files(path: 'assets').to_a

# or
files = client.files.in_path('assets').to_a
```

will return all files in (or below) the `assets` directory.

#### Finding a single File

```ruby
file = client.files(path: 'assets').find('fonts/some_font.svg')
```

will find the file located at `assets/fonts/some_font.svg`. As this will be a text file, the content will be loaded automatically. If the file is an image (or any other file not in text format) the content will not be loaded. If you want to make sure the content is loaded, provide a `load_content` keyword argument:

```ruby
file = client.files.find('assets/images/banner.png', load_content: true)
```

or load the content afterwards manually if it is missing:

```ruby
file = client.files.find('assets/images/banner.png')
file.reload_content unless file.has_content?
```

#### Creating a File

In order to create a file, use `#build` in combination with `#save` or use `#create`:

```ruby
file = client.directories.build(path: 'assets/fonts/some_font.svg', content: 'content here')
file.save # => true or false

# which is basically the same as:
file = client.directories.create(path: 'assets/font', content: 'content here')
```

If the file could not be saved, `false` will be returned and the `file.errors` object populated with the errors that occured.

#### Updating a File

Updating a file is similar to creating one:

```ruby
file.update(path: 'new/path', content: 'new content')

# which is basically the same as:
file.path = 'new/path'
file.content = 'new content'
file.save
```

#### Deleting a file

Delete a file by calling:

```ruby
file.delete
```

If you don't want to prefetch a file in order to delete it, there's also:

```ruby
client.files.delete('path/to/file')
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

1. Fork it (https://github.com/versacommerce/versacommerce-theme_api_client/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

[MIT](https://github.com/versacommerce/versacommerce-theme_api_client/blob/master/LICENSE.txt "MIT License").
