---
layout: post
title:  "Building a Bridgetown Website"
date:   2022-06-11 19:59:53 +0200
updated:   2022-07-21 01:59:53 +0200
slug: ruby
publish: true
categories: ruby jamf website
summary: Steps to build a Bridgetown Website / Blogsite
---

I wanted to play with some new web technologies and rebuild my website/blog with my own Design and make it human and machine searchable.

I decided to give Bridgetown a try - as I am familiar with Ruby and thought and wanted to get familiar with TailwindCSS.

## Overview

1. Download bridgetown gem
2. Create a new Bridgetown project (Tailwind optional)
3. Install Flowbite (optional - JS helpers for CSS)
4. Website Layout (navbar, footer, page, posts, article)
5. Configure Blog Articles
6. CSS for Code Formatting

## Bridgetown Gem

First install bridgetown gem. (-N -- no documentation)
```bash
gem install bridgetown -N
```

## Create a new Site

It took me some time to find the setup I wanted - `-t erb` uses the erb template instead of liquid (I already know erb), use Tarlilwind, and I'll deploy on netlify - so we'll create the project with:

```bash
bridgetown new btihen_flowbite -t erb -c tailwindcss,netlify
cd btihen_flowbite
git add .
git commit -m 'initial commit'
```

Let's start this and be sure we get the default starter page:
```bash
bin/bridgetown start
```

## Add Flowbite

_Javscript helpers for Tailwind CSS_

**Install:**
```bash
npm i flowbite
```

**Import Flowbite Javascript:**
```javascript
// frontend/javascript/index.js
import 'flowbite'
```

**Integrate Flowbite with TailwindCSS**
```javascript
// tailwind.config.js
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './src/**/*.{html,md,liquid,erb,serb}',
    './frontend/javascript/**/*.js',
    './node_modules/flowbite/**/*.js'
  ],
  theme: {
    extend: {},
  },
  plugins: [
    require('flowbite/plugin')
  ],
}
```

Now you also need to clear out your `frontend/styles/index.css` file - and update it with your preferences.  I changed mine to:

```css
/* frontend/styles/index.css */
@import "jit-refresh.css"; /* triggers frontend rebuilds */

/* Set up Tailwind imports */
@tailwind base;
@tailwind components;
@tailwind utilities;

a {
  color: var(--action-color);
  font-weight: 600;
  text-decoration: underline;
  text-decoration-color: #5588ff;
}

h1 {
  margin: 1rem 0 3rem;
  text-align: center;
  font-weight: 900;
  font-size: 2.5rem;
  color: var(--heading-color);
  line-height: 1.2;
}

h2 {
  margin: 1rem 0 2rem;
  text-align: left;
  font-weight: 800;
  font-size: 2.0rem;
  color: var(--heading-color);
  line-height: 1.1;
}

h3 {
  margin: 1rem 0 1.5rem;
  text-align: left;
  font-weight: 700;
  font-size: 1.5rem;
  color: var(--heading-color);
  line-height: 1.0;
}

p {
  margin: 0 0 1.5rem;
}

hr {
  border: none;
  border-top: 2px dotted #88ccff;
  margin: 3rem 0;
}

pre {
  margin: 0 0 1.5rem;
  padding: 0.75rem;
}
```

## Website Layout

### Logo

I used **Zen Brush 3** to make a logo with bold lines.

I exported / saved the image as png _with a transparent background_

I then used **Affinity Photo** to save the `png` as a `svg`

I then copied the svg logo to:
```
src/images/logo_mnt_shaded.svg
```

Now this image can be accessed with the path `/images/logo_mnt_shaded.svg`

### Navbar (Bridgetown Component)

Like many other frontend frameworks reusable (and encapsulated - including CSS) components are possible - the default navbar is an example of this.  Components accept parameters - in this case you can see in `src/_components/shared/navbar.rb` it accepts `metadata` & `resource` in the statement: `initialize(metadata:, resource:)`

I only updated it's `src/_components/shared/navbar.erb` file to match my preferences with (the search field is used later with a plugin).

```html
<!-- src/_components/shared/navbar.erb -->
<!-- <header> --><!-- navbar scrolls off the top -->
<header class="top-0 sticky z-50"> <!-- fixed navbar z-50 places navbar in-front of other elements -->
  <nav class="bg-blue-100 border-gray-200 px-2 sm:px-4 py-2.5 rounded dark:bg-gray-800">
    <div class="container flex flex-wrap justify-between items-center mx-auto">
    <a href="/" class="flex items-center">
        <img src="/images/logo_mnt_shaded.svg" class="mr-3 h-6 sm:h-9" alt="Flowbite Logo">
        <span class="self-center text-xl font-semibold whitespace-nowrap dark:text-white">btihen</span>
    </a>
    <div class="flex md:order-2">
      <button type="button" data-collapse-toggle="mobile-menu-3" aria-controls="mobile-menu-3" aria-expanded="false" class="md:hidden text-gray-500 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700 focus:outline-none focus:ring-4 focus:ring-gray-200 dark:focus:ring-gray-700 rounded-lg text-sm p-2.5 mr-1">
        <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z" clip-rule="evenodd"></path></svg>
      </button>
      <div class="hidden relative md:block">
        <div class="flex absolute inset-y-0 left-0 items-center pl-3 pointer-events-none">
          <svg class="w-5 h-5 text-gray-500" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z" clip-rule="evenodd"></path></svg>
        </div>
        <input type="text" id="search-navbar" class="block p-2 pl-10 w-full text-gray-900 bg-gray-50 rounded-lg border border-gray-300 sm:text-sm focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500" placeholder="Search...">
      </div>
      <button data-collapse-toggle="mobile-menu-3" type="button" class="inline-flex items-center p-2 text-sm text-gray-500 rounded-lg md:hidden hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-gray-200 dark:text-gray-400 dark:hover:bg-gray-700 dark:focus:ring-gray-600" aria-controls="mobile-menu-3" aria-expanded="false">
      <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M3 5a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zM3 10a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zM3 15a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z" clip-rule="evenodd"></path></svg>
      <svg class="hidden w-6 h-6" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd"></path></svg>
      </button>
    </div>
      <div class="hidden justify-between items-center w-full md:flex md:w-auto md:order-1" id="mobile-menu-3">
        <div class="relative mt-3 md:hidden">
          <div class="flex absolute inset-y-0 left-0 items-center pl-3 pointer-events-none">
            <svg class="w-5 h-5 text-gray-500" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z" clip-rule="evenodd"></path></svg>
          </div>
          <input type="text" id="search-navbar" class="block p-2 pl-10 w-full text-gray-900 bg-gray-50 rounded-lg border border-gray-300 sm:text-sm focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500" placeholder="Search...">
        </div>
        <ul class="flex flex-col mt-4 md:flex-row md:space-x-8 md:mt-0 md:text-sm md:font-medium">
          <li>
            <a href="/" class="block py-2 pr-4 pl-3 text-white bg-blue-700 rounded md:bg-transparent md:text-blue-700 md:p-0 dark:text-white" aria-current="page">Home</a>
          </li>
          <li>
            <a href="/about" class="block py-2 pr-4 pl-3 text-gray-700 border-b border-gray-100 hover:bg-gray-50 md:hover:bg-transparent md:border-0 md:hover:text-blue-700 md:p-0 md:dark:hover:text-white dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white md:dark:hover:bg-transparent dark:border-gray-700">About</a>
          </li>
          <li>
            <a href="/posts" class="block py-2 pr-4 pl-3 text-gray-700 border-b border-gray-100 hover:bg-gray-50 md:hover:bg-transparent md:border-0 md:hover:text-blue-700 md:p-0 dark:text-gray-400 md:dark:hover:text-white dark:hover:bg-gray-700 dark:hover:text-white md:dark:hover:bg-transparent dark:border-gray-700">Posts</a>
          </li>
        </ul>
      </div>
    </div>
  </nav>
</header>
```
NOTE: the logo is referenced in the image tag with the path "/images/logo_mnt_shaded.svg"

### Footer (Bridgetown Partial)

Another important feature of Bridgetown is 'partials' the ability to include an html fragement within another page.  Partials are great when the complexity and data doesnt need to be specifically passed in.

Here I updated `src/_partials/_footer.erb` to:

```html
<footer class="p-4 bg-blue-100 rounded-lg shadow md:flex md:items-center md:justify-between md:p-6 dark:bg-gray-800">
  <span class="text-sm text-gray-500 sm:text-center dark:text-gray-400">
    © 2022 <a href="/" class="hover:underline">btihen</a>. All Rights Reserved.
  </span>
  <ul class="flex flex-wrap items-center mt-3 text-sm text-gray-500 dark:text-gray-400 sm:mt-0">
    <li>
      <a href="/about" class="mr-4 hover:underline md:mr-6 ">
        About
      </a>
    </li>
    <li>
      <a href="/contact" class="hover:underline">
        Contact
      </a>
    </li>
  </ul>
</footer>
```


### Layouts

Layouts control how things are layed-out and look.

I kept the basic structure that is the default with a `src/_layouts/page.erb` (injects the content and refers to the formating layout `src/_layouts/default.erb`).  In this case, I moved the page title into `default.erb` - to differentiate the format of blog article dates - so I updated them to:

```erb
# src/_layouts/page.erb
---
layout default

<%%= yield %>
```
and

```erb
<!-- src/_layouts/default.erb -->
<!doctype html>
<html lang="<%%= site.locale %>">
  <head>
    <%%= render "head", metadata: site.metadata, title: resource.data.title %>
  </head>

  <body class="<%%= resource.data.layout %> <%%= resource.data.page_class %>">

    <%%= render Shared::Navbar.new(metadata: site.metadata, resource: resource) %>
    <!-- default -->

    <main>
      <div class="w-full bg-yellow-50">
        <section class="pt-12 relative">
          <div class="container mx-auto px-4">
            <div class="flex flex-wrap -mx-4">
              <div class="mx-auto relative w-10/12 mlg:w-8/12">
                <h1><%%= resource.data.title %></h1>
                <article class="pt-1">
                  <%%= yield %>
                </article>
              </div>
            </div>
          </div>
        </section>
      </div>
    </main>

    <%%= render "footer", metadata: site.metadata %>
  </body>
</html>
```

## Static Pages (pages)

Normal static pages can be in the root of the `src` folder, but I prefer to put them into `src/_pages` folder:

Everything in `src/_pages` _(or `src`)_ has the url `/file_name` -- for example: `src/_pages/about.md` has the url `/about`

## Blog Articles (collection)

**Blog Posts** pages (posts) are by default written in Markdown (md) and are located in: `src/_posts/` so we will build a page `src/_posts/building_a_bridgetown_website.md`.  The important part for us is the `fromtmatter` - the start of the file:

```markdown
---
layout: post
title:  "Building a Bridgetown Website"
date:   2022-06-11 19:59:53 +0200
updated:   2022-07-21 01:59:53 +0200
slug: ruby
categories: ruby jamf website
summary: Steps to build a Bridgetown Website / Blogsite
---

Giving Bridgetown a try and playing with web technologies ...
```

### Configuration

The important config info goes into: `bridgetown.config.yml`

**URLs (permalinks)**

This is the config for how Bridgetown will build the url.

```
url: "https://btihen.dev"

permalink: pretty
template_engine: erb

collections:
  posts:
    permalink: /:slug/:name/

timezone: Europe/Zurich
pagination:
  enabled: true
```

### Layout

```
<!-- src/_layouts/article.erb -->
<!doctype html>
<html lang="<%%= site.locale %>">
  <head>
    <%%= render "head", metadata: site.metadata, title: resource.data.title %>
  </head>

  <body class="bg-yellow-50 <%%= resource.data.layout %> <%%= resource.data.page_class %>">

    <%%= render Shared::Navbar.new(metadata: site.metadata, resource: resource) %>

    <!-- article -->
    <main>
      <div class="w-full">

        <section class="pt-12 relative">
          <div class="container mx-auto px-4">
            <div class="flex flex-wrap -mx-4">
              <div class="mx-auto relative w-full md:w-10/12">
                <div class="text-md text-right mt-2 mb-0 text-slate-500">Updated: <%%= resource.data.updated.strftime('%F') %></div>
                <h1><%%= resource.data.title %></h1>
                <article class="text-lg pt-1">
                  <%%= yield %>
                </article>
              </div>
            </div>
          </div>
        </section>

      </div>
    </main>

    <%%= render "footer", metadata: site.metadata %>
  </body>
</html>
```

### Sample Blog Page

Let's test our layout with a blog file - `src/_posts/first_post.md`.


```
---
layout: post
title:  "Your First Post on Bridgetown"
date:   2022-06-11 19:59:53 +0200
updated:   2022-06-11 19:59:53 +0200
exclude_from_pagination: true
slug: misc
publish: false
categories: updates
summary: Sample Bridgtown Post
---

You’ll find this post in your `_posts` directory.
View with the URL: `/misc/first_post` - adjust the file `src/_layouts/article.erb` to update the look and feel.
```

NOTE:
* To exclude a page from being listed on **blog** page add `exclude_from_pagination: true` to the page's frontmatter.
* To exclude a page from being listed in search results add `exclude_from_search: true ` to the page's frontmatter.


### Blog Page (list blogs)

Finally lets create the pagigated list of Blog articles so we will edit `src/_pages/posts.md`.

The frontmatter must include:
```
paginate:
  collection: posts
```

But I prefer to add the pagination size and the sorting with the following attributes.
```
paginate:
  collection: posts
  per_page: 8
  sort_field: updated
  sort_reverse: true
```

the main iterator now needs to use `paginator.resources` instead of `collections.posts.resources`.  So now the iterator looks like:
```
<%% paginator.resources.each do |post| %>
  ...<!-- display content -->
<%% end %>
```

Normally you will also want to add pagination navigation links -- the following is simple but works well.
```erb
<%% if paginator.total_pages > 1 %>
  <ul class="pagination">
    <%% if paginator.previous_page %>
    <li>
      <a href="<%%= paginator.previous_page_path %>">Previous Page</a>
    </li>
    <%% end %>
    <%% if paginator.next_page %>
    <li>
      <a href="<%%= paginator.next_page_path %>">Next Page</a>
    </li>
    <%% end %>
  </ul>
<%% end %>
```

So altogether the post page `src/_pages/posts.md` looks like:
```
---
layout: page
title: Posts
paginate:
  collection: posts
  per_page: 8
  sort_field: updated
  sort_reverse: true
---

<div class="grid gap-8 lg:grid-cols-2">
  <%% paginator.resources.each do |post| %>
    <article class="p-6 bg-white rounded-lg border border-gray-200 shadow-md dark:bg-gray-800 dark:border-gray-700">
      <div class="flex justify-between items-center mb-5 text-gray-700">
        <%% post.data.categories.each do |category| %>
          <span class="bg-gray-100 text-gray-800 text-xs font-semibold mr-2 px-2.5 py-0.5 rounded dark:bg-gray-700 dark:text-gray-300">
            <%%= category %>
          </span>
        <%% end %>
        <span class="text-sm">
          Updated: <%%= post.data.updated.strftime('%F') %>
        </span>
      </div>
      <h2 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white"><a href="<%%= post.relative_url %>">
        <%%= post.data.title %></a>
      </h2>
      <p class="mb-5 font-light text-gray-700 dark:text-gray-400">
        <%%= post.data.summary %>
      </p>
      <div class="flex justify-between items-center">
        <div class="flex items-center space-x-4">
          <img class="w-7 h-7 rounded-full" src="https://flowbite.s3.amazonaws.com/blocks/marketing-ui/avatars/jese-leos.png" alt="Jese Leos avatar" />
          <span class="font-medium dark:text-white">
            Bill Tihen
          </span>
        </div>
        <a href="<%%= post.relative_url %>" class="inline-flex items-center font-medium text-primary-600 dark:text-primary-500 hover:underline">
          Read
          <svg class="ml-2 w-4 h-4" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
            <path fill-rule="evenodd" d="M10.293 3.293a1 1 0 011.414 0l6 6a1 1 0 010 1.414l-6 6a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-4.293-4.293a1 1 0 010-1.414z" clip-rule="evenodd">
            </path>
          </svg>
        </a>
      </div>
    </article>
  <%% end %>
</div>

<hr>

<!-- pagination links at the bottom of the page -->
<%% if paginator.total_pages > 1 %>
  <ul class="pagination">
    <%% if paginator.previous_page %>
    <li>
      <a href="<%%= paginator.previous_page_path %>">Previous Page</a>
    </li>
    <%% end %>
    <%% if paginator.next_page %>
    <li>
      <a href="<%%= paginator.next_page_path %>">Next Page</a>
    </li>
    <%% end %>
  </ul>
<%% end %>

If you have a lot of posts, you may want to consider adding [pagination](https://www.bridgetownrb.com/docs/content/pagination)!
```

### Code Formatting

For technical blogs this is very helpful and straightforward.

Bridgetown MD parser creates Pygments classes - so you will need to use Pygments CSS to your site with either `npm i pygments-css` or if you want to customize then copy a format from: https://github.com/richleland/pygments-css - here https://pygments.org/demo/ you can see what you like.


NOTE: to show ERB files you must exscape the `<%%=` with a `<%%%=` for example:
<pre><code class="highlighter-rouge">
```erb
<%%%= yeild %>
```
</code></pre>

## Plugins

### Site Search

Now that we have added a blog with more potentially more pages than we can explicity link to - search is very useful.

There is a great search plugin: https://github.com/bridgetownrb/bridgetown-quick-search that's easy to implement.

So here is how it is done in a three quick steps:

1) Install the plugin:
```bash
bundle add bridgetown-quick-search -g bridgetown_plugins
```

2) include the javascript code in `frontend/javascript/index.js`

```javascript
// frontend/javascript/index.js

import "bridgetown-quick-search/dist"
```

3) add the search component (I've added it to the header)

```erb
<%= liquid_render "bridgetown_quick_search/search" %>
```

if you want to get fancy you can add the attributes :
```erb
<%= liquid_render "bridgetown_quick_search/search",
                  placeholder: "Search",
                  input_class: "input",
                  theme: "dark",
                  snippet_length: 200 %>
```

In my case in the navbar `src/_components/shared/navbar.erb` I replaced:
```erb
<!-- src/_components/shared/navbar.erb -->
<!-- old -->
<div class="flex absolute inset-y-0 left-0 items-center pl-3 pointer-events-none">
  <svg class="w-5 h-5 text-gray-500" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
    <path fill-rule="evenodd" d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z" clip-rule="evenodd">
    </path>
  </svg>
</div>
<input type="text" id="search-navbar" class="block p-2 pl-10 w-full text-gray-900 bg-gray-50 rounded-lg border border-gray-300 sm:text-sm focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500" placeholder="Search...">

<!-- new -->
<div class="flex absolute inset-y-0 right-7 items-center pl-3 pointer-events-none">
  <svg class="w-5 h-5 text-gray-500" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
    <path fill-rule="evenodd" d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z" clip-rule="evenodd">
    </path>
  </svg>
</div>
<%%= liquid_render 'bridgetown_quick_search/search', snippet_length: 200, placeholder: 'search' %>
```

for further styling see: https://github.com/bridgetownrb/bridgetown-quick-search#styling

### Search

###

## Resources

### Bridgetown

* https://www.bridgetownrb.com/docs
* https://fpsvogel.com/posts/2021/build-a-blog-with-bridgetown

### Flowbite

* https://flowbite.com/docs/getting-started/introduction/#getting-started

### Pygments

* https://richleland.github.io/pygments-css/
* https://github.com/richleland/pygments-css
* https://www.npmjs.com/package/pygments-css
* https://raw.githubusercontent.com/richleland/pygments-css/master/monokai.css
