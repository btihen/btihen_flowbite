---
layout: post
title:  "Building a Bridgetown Website"
date:   2022-06-11 01:59:53 +0200
updated:   2022-07-28 01:59:53 +0200
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

## Site Metadata

Set your site’s info in `src/_data/site_metadata.yml`.

This creates site-wide metadata variables so they’ll be easy to access and will regenerate pages when changed. This is a good place to put `<head>` content like your website title, description, favicon, social media handles, etc. Then you can reference `site.metadata.title`, etc. in your erb templates with:
```erb
<%%= site.metadata.title %>
```

See [https://www.bridgetownrb.com/docs/datafiles](https://www.bridgetownrb.com/docs/datafiles) for examples setting up complex fixed data structures, team lists, etc.

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

### favicon

Now that we have an icon let's add it to the tab (favicon) with the tag (in the header)
`<link rel="icon" href="/images/logo_mnt_shaded.svg" sizes="any" type="image/svg+xml">`

Thus lets update the header page `src/_partials/_head.erb` to look like:

```html
<!-- src/_partials/_head.erb -->
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />

<link rel="icon" href="/images/logo_mnt_shaded.svg" sizes="any" type="image/svg+xml">

<%% resource_title = strip_html(strip_newlines(title)) %>
<title>
  <%% if resource_title != "Index" %>
    <%%= resource_title %> | <%%= metadata.title %>
  <%% else %>
    <%%= metadata.title %>: <%%= metadata.tagline %>
  <%% end %>
</title>

<meta name="description" content="<%%= metadata.description %>" />

<link rel="stylesheet" href="<%%= webpack_path :css %>" />
<script src="<%%= webpack_path :js %>" defer></script>

<%%= live_reload_dev_js %>
```

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
        <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
          <path fill-rule="evenodd" d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z" clip-rule="evenodd"></path>
        </svg>
      </button>
      <div class="hidden relative md:block">
        <div class="flex absolute inset-y-0 left-0 items-center pl-3 pointer-events-none">
          <svg class="w-5 h-5 text-gray-500" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
            <path fill-rule="evenodd" d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z" clip-rule="evenodd"></path>
          </svg>
        </div>
        <input type="text" id="search-navbar" class="block p-2 pl-10 w-full text-gray-900 bg-gray-50 rounded-lg border border-gray-300 sm:text-sm focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500" placeholder="Search...">
      </div>
      <button data-collapse-toggle="mobile-menu-3" type="button" class="inline-flex items-center p-2 text-sm text-gray-500 rounded-lg md:hidden hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-gray-200 dark:text-gray-400 dark:hover:bg-gray-700 dark:focus:ring-gray-600" aria-controls="mobile-menu-3" aria-expanded="false">
      <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
        <path fill-rule="evenodd" d="M3 5a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zM3 10a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zM3 15a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z" clip-rule="evenodd"></path>
      </svg>
      <svg class="hidden w-6 h-6" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
        <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd"></path>
      </svg>
      </button>
    </div>
      <div class="hidden justify-between items-center w-full md:flex md:w-auto md:order-1" id="mobile-menu-3">
        <div class="relative mt-3 md:hidden">
          <div class="flex absolute inset-y-0 left-0 items-center pl-3 pointer-events-none">
            <svg class="w-5 h-5 text-gray-500" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
              <path fill-rule="evenodd" d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z" clip-rule="evenodd"></path>
            </svg>
          </div>
          <input type="text" id="search-navbar" class="block p-2 pl-10 w-full text-gray-900 bg-gray-50 rounded-lg border border-gray-300 sm:text-sm focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500" placeholder="Search...">
        </div>
        <ul class="flex flex-col mt-4 md:flex-row md:space-x-8 md:mt-0 md:text-sm md:font-medium">
          <li>
            <a href="/" class="block py-2 pr-4 pl-3 text-white bg-blue-700 rounded md:bg-transparent md:text-blue-700 md:p-0 dark:text-white" aria-current="page">
              Home
            </a>
          </li>
          <li>
            <a href="/about" class="block py-2 pr-4 pl-3 text-gray-700 border-b border-gray-100 hover:bg-gray-50 md:hover:bg-transparent md:border-0 md:hover:text-blue-700 md:p-0 md:dark:hover:text-white dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white md:dark:hover:bg-transparent dark:border-gray-700">
              About
            </a>
          </li>
          <li>
            <a href="/posts" class="block py-2 pr-4 pl-3 text-gray-700 border-b border-gray-100 hover:bg-gray-50 md:hover:bg-transparent md:border-0 md:hover:text-blue-700 md:p-0 dark:text-gray-400 md:dark:hover:text-white dark:hover:bg-gray-700 dark:hover:text-white md:dark:hover:bg-transparent dark:border-gray-700">
              Posts
            </a>
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

```yaml
# src/_layouts/page.erb
---
layout default

<%%= yield %>
```
and

```html
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

So now the structure looks like:

![folder image](/images/building_a_bridgetown_website/pages_structure.png)

## Blog Articles (collection)

**Blog Posts** pages (posts) are by default written in Markdown (md) and are located in: `src/_posts/` so we will build a page `src/_posts/building_a_bridgetown_website.md`.  The important part for us is the `fromtmatter` - the start of the file:

```yaml
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

```yaml
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

```html
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
                <div class="text-md text-right mt-2 mb-0 text-slate-500">
                  Updated: <%%= resource.data.updated.strftime('%F') %>
                </div>
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

```yaml
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
```yaml
paginate:
  collection: posts
```

But I prefer to add the pagination size and the sorting with the following attributes.
```yaml
paginate:
  collection: posts
  per_page: 8
  sort_field: updated
  sort_reverse: true
```

the main iterator now needs to use `paginator.resources` instead of `collections.posts.resources`.  So now the iterator looks like:
```html
<%% paginator.resources.each do |post| %>
  ...<!-- display content -->
<%% end %>
```

Normally you will also want to add pagination navigation links -- the following is simple but works well.
```html
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
```html
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

Bridgetown MD parser creates Pygments classes - so you will need to use Pygments CSS to your site with either `npm i pygments-css` or if you want to customize then copy a format from: [https://github.com/richleland/pygments-css](https://github.com/richleland/pygments-css) - here [https://pygments.org/demo/](https://pygments.org/demo/) you can see what you like.


So in order to format the code & have it scroll when too long for the code width allowed, I added the follow to `frontend/styles/index.css` from [https://github.com/richleland/pygments-css](https://github.com/richleland/pygments-css) with examples at: [https://pygments.org/styles/](https://pygments.org/styles/) or [https://pygments.org/demo](https://pygments.org/demo)

```css
pre {
  margin: 0 0 1.5rem;
  padding: 0.75rem;
  /* creates a scrollbar when code too long */
  overflow-x: auto;
  /* wraps text when code too long */
  /* white-space: pre-wrap; */
}

/* https: //pygments.org/demo/ */
/* https: //pygments.org/styles/ */
/* Monokai - https: //jwarby.github.io/jekyll-pygments-themes/languages/ruby.html */
/* Monokai - https: //raw.githubusercontent.com/richleland/pygments-css/master/monokai.css */
.highlighter-rouge { color: #f92672 } /* rouge - one=off code-snippet */
.highlight .hll { background-color: #49483e }
.highlight  { background: #272822; color: #f8f8f2 }
.highlight .c { color: #75715e } /* Comment */
.highlight .err { color: #960050; background-color: #1e0010 } /* Error */
.highlight .k { color: #66d9ef } /* Keyword */
.highlight .l { color: #ae81ff } /* Literal */
.highlight .n { color: #f8f8f2 } /* Name */
.highlight .o { color: #f92672 } /* Operator */
.highlight .p { color: #f8f8f2 } /* Punctuation */
.highlight .ch { color: #75715e } /* Comment.Hashbang */
.highlight .cm { color: #75715e } /* Comment.Multiline */
.highlight .cp { color: #75715e } /* Comment.Preproc */
.highlight .cpf { color: #75715e } /* Comment.PreprocFile */
.highlight .c1 { color: #75715e } /* Comment.Single */
.highlight .cs { color: #75715e } /* Comment.Special */
.highlight .gd { color: #f92672 } /* Generic.Deleted */
.highlight .ge { font-style: italic } /* Generic.Emph */
.highlight .gi { color: #a6e22e } /* Generic.Inserted */
.highlight .gs { font-weight: bold } /* Generic.Strong */
.highlight .gu { color: #75715e } /* Generic.Subheading */
.highlight .kc { color: #66d9ef } /* Keyword.Constant */
.highlight .kd { color: #66d9ef } /* Keyword.Declaration */
.highlight .kn { color: #f92672 } /* Keyword.Namespace */
.highlight .kp { color: #66d9ef } /* Keyword.Pseudo */
.highlight .kr { color: #66d9ef } /* Keyword.Reserved */
.highlight .kt { color: #66d9ef } /* Keyword.Type */
.highlight .ld { color: #e6db74 } /* Literal.Date */
.highlight .m { color: #ae81ff } /* Literal.Number */
.highlight .s { color: #e6db74 } /* Literal.String */
.highlight .na { color: #a6e22e } /* Name.Attribute */
.highlight .nb { color: #f8f8f2 } /* Name.Builtin */
.highlight .nc { color: #a6e22e } /* Name.Class */
.highlight .no { color: #66d9ef } /* Name.Constant */
.highlight .nd { color: #a6e22e } /* Name.Decorator */
.highlight .ni { color: #f8f8f2 } /* Name.Entity */
.highlight .ne { color: #a6e22e } /* Name.Exception */
.highlight .nf { color: #a6e22e } /* Name.Function */
.highlight .nl { color: #f8f8f2 } /* Name.Label */
.highlight .nn { color: #f8f8f2 } /* Name.Namespace */
.highlight .nx { color: #a6e22e } /* Name.Other */
.highlight .py { color: #f8f8f2 } /* Name.Property */
.highlight .nt { color: #f92672 } /* Name.Tag */
.highlight .nv { color: #f8f8f2 } /* Name.Variable */
.highlight .ow { color: #f92672 } /* Operator.Word */
.highlight .w { color: #f8f8f2 } /* Text.Whitespace */
.highlight .mb { color: #ae81ff } /* Literal.Number.Bin */
.highlight .mf { color: #ae81ff } /* Literal.Number.Float */
.highlight .mh { color: #ae81ff } /* Literal.Number.Hex */
.highlight .mi { color: #ae81ff } /* Literal.Number.Integer */
.highlight .mo { color: #ae81ff } /* Literal.Number.Oct */
.highlight .sa { color: #e6db74 } /* Literal.String.Affix */
.highlight .sb { color: #e6db74 } /* Literal.String.Backtick */
.highlight .sc { color: #e6db74 } /* Literal.String.Char */
.highlight .dl { color: #e6db74 } /* Literal.String.Delimiter */
.highlight .sd { color: #e6db74 } /* Literal.String.Doc */
.highlight .s2 { color: #e6db74 } /* Literal.String.Double */
.highlight .se { color: #ae81ff } /* Literal.String.Escape */
.highlight .sh { color: #e6db74 } /* Literal.String.Heredoc */
.highlight .si { color: #e6db74 } /* Literal.String.Interpol */
.highlight .sx { color: #e6db74 } /* Literal.String.Other */
.highlight .sr { color: #e6db74 } /* Literal.String.Regex */
.highlight .s1 { color: #e6db74 } /* Literal.String.Single */
.highlight .ss { color: #e6db74 } /* Literal.String.Symbol */
.highlight .bp { color: #f8f8f2 } /* Name.Builtin.Pseudo */
.highlight .fm { color: #a6e22e } /* Name.Function.Magic */
.highlight .vc { color: #f8f8f2 } /* Name.Variable.Class */
.highlight .vg { color: #f8f8f2 } /* Name.Variable.Global */
.highlight .vi { color: #f8f8f2 } /* Name.Variable.Instance */
.highlight .vm { color: #f8f8f2 } /* Name.Variable.Magic */
.highlight .il { color: #ae81ff } /* Literal.Number.Integer.Long */
```

PS: Jekle Code themes are also a good source: [https://github.com/jwarby/jekyll-pygments-themes](https://github.com/jwarby/jekyll-pygments-themes) with examples at: [http://jwarby.github.io/jekyll-pygments-themes/languages/javascript.html](http://jwarby.github.io/jekyll-pygments-themes/languages/javascript.html)

Alternatively: you can also use npm to install the css [https://www.npmjs.com/package/pygments-css](https://www.npmjs.com/package/pygments-css) using:
```bash
npm i pygments-css
```

then add to the index.css file:
```css
@import "monokai.css";
/* or */
/* @import "pygments-css/monokai.css"; */
```

Unfortunately, I didn't get this work work as I wished, but also adding the css directly to index.css makes small adjustments easy.

NOTE: to show ERB files you must exscape the `<%%=` with a `<%%%=` for example:
<pre><code class="highlighter-rouge">
```erb
<%%= yeild %>
```
</code></pre>

## Plugins

### Site Search

Now that we have added a blog with more potentially more pages than we can explicity link to - search is very useful.

There is a great search plugin: [https://github.com/bridgetownrb/bridgetown-quick-search](https://github.com/bridgetownrb/bridgetown-quick-search) that's easy to implement.

So here is how it is done in a three quick steps:

1) Install the plugin:
```bash
bundle add bridgetown-quick-search -g bridgetown_plugins
```

2) include the javascript code in `frontend/javascript/index.js`

```js
// frontend/javascript/index.js

import "bridgetown-quick-search/dist"
```

3) add the search component (I've added it to the header)

```html
<%%= liquid_render "bridgetown_quick_search/search" %>
```

if you want to get fancy you can add the attributes :
```html
<%%= liquid_render "bridgetown_quick_search/search",
                  placeholder: "Search",
                  input_class: "input",
                  theme: "dark",
                  snippet_length: 200 %>
```

In my case in the navbar `src/_components/shared/navbar.erb` I replaced:
```html
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

To round the corners of the search field I added the following to ``:
```css
input[type="search"] {
  border-radius: 15px;
  border: 1px solid rgb(15, 25, 215);
  padding: 0.5rem;
  margin: 0.25rem;
  width: 100%;
}
```

for further styling see: [https://github.com/bridgetownrb/bridgetown-quick-search#styling](https://github.com/bridgetownrb/bridgetown-quick-search#styling)

### Usability & SEO

If we run `lighthouse` (in Chome Dev-Toools) we will find a few problems.  To adress them we can use a few more plugins.

#### SEO Tags & Social Media Sharing

Bridgetown SEO Tag adds important meta tags to your site! As well as creates a social media card. The site image you need to choose and add yourself.

[https://github.com/bridgetownrb/bridgetown-seo-tag](https://github.com/bridgetownrb/bridgetown-seo-tag)

```bash
bundle add bridgetown-seo-tag -g bridgetown_plugins
touch src/_data/site_metadata.yml
```

now got to `src/_data/site_metadata.yml` and add the SEO metadata:

```yaml
title: btihen
tagline: Dev Notes
author: Bill Tihen
email: your-email@example.com
base_url: https://btihen.dev
image: /images/logo_mnt_shaded.svg
description: >-
  Article explorating and notes, so I don't forget & maybe help others
twitter:
  username: btihen
  card: summary
  # image: /image/logo_mnt_shaded.svg
```

A full list of attributes and features can be found at: [https://github.com/bridgetownrb/bridgetown-seo-tag#usage](https://github.com/bridgetownrb/bridgetown-seo-tag#usage)

now in the header `src/_partials/_head.erb`

```html
<!-- ensures we always have an image to share on each social media share -->
<meta property="og:image" content="<%%= metadata.base_url %><%%= metadata.image %>">
<!-- ensures a general description for the site and social media shares -->
<meta property="og:description" content="<%%= metadata.description %>" />
<meta name="description" content="<%%= metadata.description %>" />
<!-- add the seo tags to each page -->
<%%= seo %>
```

NOTE: I added `base_url` in the `src/_data/site_metadata.yml` file since I wasn't able to access the `site.url` data from `bridgetown.config.yml` as I expected from reading the variables page [https://www.bridgetownrb.com/docs/variables](https://www.bridgetownrb.com/docs/variables).

#### Robots.txt File

```markdown
User-agent: *
Allow: /
Disallow:

Sitemap: https://btihen.dev/sitemap.xml
```

now test this works at: `http://localhost:4000/robots.txt`


#### Sitemap generator

[https://github.com/ayushn21/bridgetown-sitemap](https://github.com/ayushn21/bridgetown-sitemap)

now lets build our sitemap.xml

```bash
bundle add bridgetown-sitemap -g bridgetown_plugins
```

now we need to update `bridgetown.config.yml`

First, be sure to define the `url:` attribute.
Second, be sure to define the

```yml

url: "https://btihen.dev" # the base hostname with protocol, e.g. https://example.com
content_engine: "resource" # sitemap.xml directive to use 'resources'
```

Be sure this works by going to: `http://localhost:4000/sitemap.xml`

-------

### Atom feed

[https://github.com/bridgetownrb/bridgetown-feed](https://github.com/bridgetownrb/bridgetown-feed)

### SVG inliner

[https://github.com/ayushn21/bridgetown-svg-inliner](https://github.com/ayushn21/bridgetown-svg-inliner)

## Custom Fonts

Its often nice to add a custom font to a website.

We will add the handlee font as it is distinctive and easy to see that it works (or not). Let’s get it from Google Webfonts Helper - [https://google-webfonts-helper.herokuapp.com/fonts/handlee?subsets=latin](https://google-webfonts-helper.herokuapp.com/fonts/handlee?subsets=latin) - this is a convenient site as it has both the font and the CSS needed.

The following worked well for me.

### download the font

Downloaded the font copy the font in esbuild's path using:

```bash
mkdir -p frontend/fonts/handlee
cp ~/Downloads/handlee-v12-latin/* frontend/fonts/handlee/.
```

### add font to css

Now grab the CSS from the Google Webfonts Helper site and copy it into the `frontend/styles/index.css` file (I like to put the font css just below the tailwind imports). So the start of `frontend/styles/index.css` now looks like:

```css
/* frontend/styles/index.css */

/* triggers frontend rebuilds */
@import "jit-refresh.css";

/* Set up Tailwind imports */
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Import Fonts */
@font-face {
  font-family: 'Handlee';
  font-style: normal;
  font-weight: 400;
  src: local(''),
       url('../fonts/handlee/handlee-v12-latin-regular.woff2') format('woff2'),
       url('../fonts/handlee/handlee-v12-latin-regular.woff') format('woff');
}

/* use the new font in h1 tags */
h1 {
  margin: 1rem 0 3rem;
  text-align: center;
  font-weight: 900;
  font-size: 2.5rem;
  font-family: 'Handlee';
  color: var(--heading-color);
  line-height: 1.2;
}
```

Check and be sure the Title of your Page Title is now using the ‘Handlee’ font.


### add font to tailwind

Now we need to define this font within TailwindCSS config to have it create a font-handlee class so we can use this font within our tailwind class definitions. To do this we will need to update the `tailwind.config.js` file to look like:

```js
module.exports = {
  content: [
    './src/**/*.{html,md,liquid,erb,serb}',
    './frontend/javascript/**/*.js',
  ],
  theme: {
    extend: {
      fontFamily: {
        handlee: ['Handlee']
      },
    },
  },
  plugins: [],
}
```

Let’s update the default layout to use Handlee for the text within the main body. So lets open `src/_layouts/default.erb` and change the main tag to have the class="font-handlee" in it - so now it might look like:

```html
<!-- ... -->
    <main class="font-handlee">
      <%%= yield %>
    </main>
<!-- ... -->
```
Now both the Title and Body of each page (except blog articles) should be using the Handlee font.


## Deploy Bridgetown

Let’s now deploy this Webpage (using the configure command) it is very straightforward!

**First**, be sure you have pushed your project to github or gitlab - create the repo online and push it with:
```bash
git add .
git commit -m "Configured w TailwindCSS and Handlee Font"
git remote add origin git@github.com:gitusername/bridge_tail_site.git
git branch -M main
git push -u origin main
```

**Second**, install the config for your deploy service (in this case netlify) by typing:
```bash
bundle exec bridgetown configure netlify
git add bin/netlify.sh netlify.toml
git commit -m "add netlify config"
git push
```

**Third**, connect your netlify account to the repo you just created.
Four, click deploy within the netlify site (if it hasn’t already startet) and wait 5-10 mins (yes its kinda slow to deploy) and you should have your new website!

## Overview

Overall, its a great, complete (albeit young) platform and will problably grow and become even better.

### Positives

Uses ruby, erb, StimulusJS, TailwindCSS and many popular pre-configured deployments configs (netlify, render, etc) - technologies many rails developers know and understand.

### Drawback

I never got AlpineJS to load as an npm package (also not in Rails 7), however StimulusJS is the recommended JS sprinkles and that installs well.

Unlike Hugo, Gatsby, Next, Nuxt, ... there is to date no easy to use  CMS making it easy for non-techs to use and add content.

The biggest drawback for me is that the Bridgetown errors are often missing, misleading or unspecific - sometimes no line number, sometimes not even the file.  I expect this will improve with time.


## Resources

### Bridgetown

* [https://www.bridgetownrb.com/docs](https://www.bridgetownrb.com/docs)
* [https://fpsvogel.com/posts/2021/build-a-blog-with-bridgetown](https://fpsvogel.com/posts/2021/build-a-blog-with-bridgetown)

### Flowbite

* [https://flowbite.com/docs/getting-started/introduction/#getting-started](https://flowbite.com/docs/getting-started/introduction/#getting-started)

### SVG Favicon

* [https://stackoverflow.com/questions/34446050/svg-favicon-not-working](https://stackoverflow.com/questions/34446050/svg-favicon-not-working)

### Pygments

* [https://richleland.github.io/pygments-css/](https://richleland.github.io/pygments-css/)
* [https://github.com/richleland/pygments-css](https://github.com/richleland/pygments-css)
* [https://www.npmjs.com/package/pygments-css](https://www.npmjs.com/package/pygments-css)
* [https://raw.githubusercontent.com/richleland/pygments-css/master/monokai.css](https://raw.githubusercontent.com/richleland/pygments-css/master/monokai.css)
