# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Ruby gem that provides an API client for the VersaCommerce Theme API. It allows developers to programmatically manage theme files and directories for VersaCommerce shops.

## Requirements

- Ruby >= 3.3.0
- Dependencies: http (~> 5.0), activesupport (>= 4.2, < 8.0), activemodel (>= 4.2, < 8.0)

## Common Commands

### Setup and Development
```bash
bin/setup              # Install dependencies
bin/console            # Launch interactive console for experimentation
bundle install         # Install gem dependencies
```

### Building and Publishing
```bash
rake build             # Build the gem
rake install           # Build and install gem locally
rake release           # Create git tag, build and push gem to rubygems.org
```

## Architecture

### Core Components

**Client (lib/versacommerce/theme_api_client.rb)**
- Entry point for the gem
- Initialized with authorization token
- Provides `directories()` and `files()` methods that return relation objects
- Configurable `base_url` (defaults to https://theme-api.versacommerce.de)
- Dynamically creates resource classes tied to the client instance

**Fetcher (lib/versacommerce/theme_api_client/fetcher.rb)**
- HTTP communication layer using the `http` gem
- Handles all HTTP verbs (GET, POST, PATCH, DELETE, HEAD)
- Adds Theme-Authorization header to all requests
- Defines custom errors: `RecordNotFoundError` and `UnauthorizedError`
- Extends HTTP::Response with a `json` method for parsing JSON responses

**Relation (lib/versacommerce/theme_api_client/relation.rb)**
- Base class for DirectoryRelation and FileRelation
- Implements Enumerable for iteration
- Provides ActiveRecord-like interface: `find()`, `build()`, `create()`, `delete()`
- Supports path scoping with `in_path()` method
- Handles recursive vs non-recursive queries

**Resource (lib/versacommerce/theme_api_client/resource.rb)**
- Base class for Directory and File resources
- Uses ActiveModel for validations and dirty tracking
- Implements `save()`, `update()`, `new_record?` methods
- Each resource class is dynamically created per client instance (see `directory_class` and `file_class` in client)

### Resource Types

**Directory (lib/versacommerce/theme_api_client/resources/directory.rb)**
- Represents theme directories
- Has `path` attribute
- Provides `files()` method to access files within the directory

**File (lib/versacommerce/theme_api_client/resources/file.rb)**
- Represents theme files
- Has `path` and `content` attributes
- Content loading is conditional: text files load automatically, binary files require explicit `load_content: true`
- Provides `reload_content()` and `has_content?` methods

### Key Design Patterns

**Dynamic Class Creation**: The client creates subclasses of Directory and File at runtime (via `directory_class` and `file_class`), binding them to the specific client instance. This allows each resource to access the client's fetcher and configuration.

**Relation Pattern**: Inspired by ActiveRecord, relations provide chainable query interfaces and lazy evaluation. The `in_path()` method modifies the relation's path scope without executing queries.

**Path Helpers**: The client provides `directory_path()`, `file_path()`, `download_path()`, and `tree_path()` helper methods that build Pathname objects for API endpoints.

## Module Structure

```
lib/versacommerce/
  theme_api_client.rb              # Main client class
  theme_api_client/
    client.rb                       # (Appears to be duplicate/alternative entry point)
    fetcher.rb                      # HTTP client wrapper
    relation.rb                     # Base relation class
    resource.rb                     # Base resource class with ActiveModel
    version.rb                      # Gem version constant
    relations/
      directory_relation.rb
      file_relation.rb
    resources/
      directory.rb
      file.rb
      file_behaviour.rb             # Shared file behavior module
```

## Testing

This gem does not appear to have a test suite in the repository. When adding tests, consider creating a spec/ or test/ directory.
