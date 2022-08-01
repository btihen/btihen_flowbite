---
layout: post
title:  "Modular Rails using Packwerk"
date:   2022-07-31 01:59:53 +0200
updated:   2022-07-31 01:59:53 +0200
slug: ruby
publish: true
categories: ruby modules citadel architechture
excerpt: Packwerk enables lightweight modular Rails projects.  It is a flexible, low overhead alterntive to Rails Engines. Crucially, for established code it allows a gradual migration and to only enforce module boundaries when the code is sufficiently refactored with low coupling.
---

I have been interested in building Rails with much less accidental coupling.  Until recently, Engines have been the best way to do that, but the setup effort is rather heavy (to integrate the migrations, tests, namespaces, ...).  In fact, heavy enough that most people do without modules.

Packwerk however, makes it easy to use modules and critcially migrate toward modules overtime.  Packwerk allows you to organize into modules, without enforcing boundaries - until you are ready to fully refactor and disentagle your code.

------------

## Setup

Packwerk its self is a simple gem install.  Crucially, Packwerk has a companion tool `graphwerk` to visualize your modules and their dependencies. We will install and demostrate both.

### Prequisits

In oder to use graphwerk you must have graphviz installed:
```bash
brew install graphviz
```
does the trick on MacOS

You will also need to use at least `Ruby 2.6+` and `Rails 6.0+` with `Zeitwerk` as the loader (which is the default for new Projects).

### Install Packwerk

This will be a very simple projects (too simple to need modules), but that also makes the examples easier to grock.

We will start with a fresh rails projects to keep the complexity low and make it straight-forward to follow along before using in your own established projects.

```bash
rails new packwerk --javascript=esbuild --css=tailwind
cd packwerk
bin/rails db:create
```

Now add the packwerk and graphwerk gems to `./Gemfile`
```ruby
# Gemfile
...
# Packwerk (modular Rails) - dependency tooling and mapping
gem "packwerk", "~> 2.2"
gem 'graphwerk', group: %i[development test]
```
of course normally, I would install rspec and a slew of other tools, but the focus here is simply the usage of Packwerk and its associated tools.

Now of course we need to finalize the install and config:
```bash
bundle install
# make it easy to
bundle binstub packwerk
# create intial packwerk config files
bin/packwerk init
```

now we should see a file `./packwerk.yml` with all the configs commented out.
```ruby
# packwerk.yml

# See: Setting up the configuration file
# https://github.com/Shopify/packwerk/blob/main/USAGE.md#setting-up-the-configuration-file

# List of patterns for folder paths to include
# include:
# - "**/*.{rb,rake,erb}"

# List of patterns for folder paths to exclude
# exclude:
# - "{bin,node_modules,script,tmp,vendor}/**/*"

# Patterns to find package configuration files
# package_paths: "**/"

# List of custom associations, if any
# custom_associations:
# - "cache_belongs_to"

# Whether or not you want the cache enabled (disabled by default)
# cache: true

# Where you want the cache to be stored (default below)
# cache_directory: 'tmp/cache/packwerk'
```
We will update the configs as we progress.

----------

Now lets be sure dependency visualization tool works:
```bash
bin/rails graphwerk:update
```

Now we should see an intial dependency map named `./packwerk.png` looking like:

![Intial Structure](/images/rails_modules_using_packwerk/initial_dependency_map.png)

### Configure Packages

First, we need a location to place your packages - let's make a folder:
```bash
mkdir app/packages
```

Now Tell rails how to find & load the code in your packages (remember this is dependent on Zeitwerk) `config.paths.add 'app/packages', glob: '*/{*,*/concerns}', eager_load: true` to `config/application.rb`. Now it will look something like:
```ruby
# config/application.rb
...
module RailsPack
  class Application < Rails::Application
    ...
    # config packages fur packwerk
    config.paths.add 'app/packages', glob: '*/{*,*/concerns}', eager_load: true
  end
end
```

Finally, let the controllers know how to find the views within packages  `app/controllers/application_controller.rb` to:
```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  append_view_path(Dir.glob(Rails.root.join('app/packages/*/views')))
end
```

------------

## Using Packwerk

### Package Structure

Let's assume we are buildig a manageable blog app for multiple users.

Let's decide what packages (Domains) needed (there are several options depending on archichture and other fixed needs) but that istn't the focus here.

- **published** - publicly available, landing page and access to completed blog artciles
- **compose** - where authors compse and manage their blog articles
- **manage** - manage site admins manager users, and possibly moderate blog articles
- **core** - aspects of code common to all (multiple) aspects of the code basis

The focus of this article is on impletementing packages according to the architectural design.

We will put our packages in a folder called `app/packages` with:
```bash
mkdir app/packages
```

We can add our proposed packages with:
```bash
mkdir app/packages/marketing
mkdir app/packages/published
mkdir app/packages/compose
mkdir app/packages/manage
mkdir app/packages/core
```

An important aspect of a package is the `packages.yml` file so we will need one in EACH pagage!  we can do this by using the one in the rails core as a template

```bash
cp package.yml app/packages/marketing/package.yml
cp package.yml app/packages/published/package.yml
cp package.yml app/packages/compose/package.yml
cp package.yml app/packages/manage/package.yml
cp package.yml app/packages/core/package.yml
```

**IDEALLY, by looking within `app/packages` the next person will have a decent idea about what the code does and what happens where.**

### Marketing

Lets generate a landing page:

```bash
bin/rails g controller landing index --no-helper --no-assets
```

now lets update the routes with:
```ruby
# config/routes.rb
Rails.application.routes.draw do
  get '/landing', to: 'landing#index'
  root 'landing#index' # root path route ("/")
end
```

lets see that this worked: `bin/rails start` and go to:

* `http://localhost:3000`
* `http://localhost:3000/landing`

you should see the landing page.

Now lets move this to the marketing package. To do this we will recreate the code structure in the package and then copy the code into the markiting package.

Creating the package structure:
```bash
mkdir app/packages/marketing/controllers
mkdir -p app/packages/marketing/views/landings
# if you created a helper file then also:
mkdir app/packages/marketing/helpers
```

now we can copy the code:
```bash
mv app/controllers/landing_controller.rb app/packages/marketing/controllers/.
mv app/views/landings app/packages/marketing/views/landings
# if helper created
mv app/helpers/landing_helper.rb app/packages/marketing/helpers/.
```

Finally, lets configure the package in the file `app/packages/marketing/package.yml` - we will use the simplest possible config.
```ruby
# app/packages/marketing/package.yml
# Turn on dependency checks for this package
enforce_dependencies: true

# Turn on privacy checks for this package
enforce_privacy: true

# this allows you to modify what your package's public path is within the package
# code that this package publicly shares with other packages
# public_path: public/

# A list of this package's dependencies
# Note that packages in this list require their own `package.yml` file
# '.' - we are dependent on the root application
dependencies:
- '.'
```

----------

if you get the error:
```
LandingController#index is missing a template for request formats: text/html
```

check that `app/controllers/application_controller.rb` looks like
```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  append_view_path(Dir.glob(Rails.root.join('app/packages/*/views')))
end
```

if you get the error `uninitialized constant LandingController`

check that `config/application.rb` has the following code:
```ruby
...
module Packwerk
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    ...
    # load the packages
    config.paths.add 'app/packages', glob: '*/{*,*/concerns}', eager_load: true
  end
end
```

If you forgot this config - you will need to restart rails!

--------

Now that the code works, lets generate a new diagram of our app using:
```bash
bin/rails graphwerk:update
```

if your graph looks the same as before, check that `app/packages/marketing/packages.yml` is there and configured.

If all is well the new graph in `packwerk.png` will look like:

![Marketing Structure](/images/rails_modules_using_packwerk/with_marketing_packages.png)

Now that the package is recognized, lets if packwerk finds any problems
```bash
bin/packwerk check
```

Ideally, packwerk finds no problems and we get:
```bash
No offenses detected
No stale violations detected
```





### Author Pages


### Admin Pages

------------

## Overview

### Benefits

### Drawbacks

-------------

## Resources

### Modular Rails using Packwerk

* [Shopify - Packwerk Code](https://github.com/Shopify/packwerk)
* [Shopify - Packwerk Docs](https://github.com/Shopify/packwerk/blob/main/USAGE.md)
* [Shopify - Packwerk Debug Help](https://github.com/Shopify/packwerk/blob/main/TROUBLESHOOT.md)
* [Shopify - Video introducing Packwerk](https://www.youtube.com/watch?v=olEA157z7kU)
* [Shopify - on Monoliths](https://www.shopify.com/partners/blog/monolith-software)
* [Shopify - enforcing-modularity-rails-apps-packwerk](https://shopify.engineering/enforcing-modularity-rails-apps-packwerk)
* [Package-Based-Rails-Applications Book](https://leanpub.com/package-based-rails-applications), by Stephan Hagemann
* [modularization-with-packwerk](https://thecodest.co/blog/ruby-on-rails-modularization-with-packwerk-episode-i/)
* [packwerk-to-delimit-bounded-contexts](https://www.globalapptesting.com/engineering/implementing-packwerk-to-delimit-bounded-contexts)

### Modular Rails using Engines

* [Rails Engines Docs](https://edgeguides.rubyonrails.org/engines.html)
* [Component-Based-Rails-Applications Website](https://cbra.info/resources/), Stephan Hagemann - many links and articles on using Engines and enforcing boundaries
* [Component-Based Rails Applications Book, 2018](https://www.pearson.com/en-us/subject-catalog/p/Hagemann-Component-Based-Rails-Applications-Large-Domains-Under-Control/P200000009490/9780134774589), by Stephan Hagemann
* [Modular-Rails Book / Website](https://devblast.com/c/modular-rails), by Thibault Denizet
