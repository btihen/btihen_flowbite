---
layout: page
title: Posts
---

<div class="grid gap-8 lg:grid-cols-2">
  <% collections.posts.resources.each do |post| %>
    <article class="p-6 bg-white rounded-lg border border-gray-200 shadow-md dark:bg-gray-800 dark:border-gray-700">
      <div class="flex justify-between items-center mb-5 text-gray-700">
        <% post.data.categories.each do |category| %>
          <span class="bg-gray-100 text-gray-800 text-xs font-semibold mr-2 px-2.5 py-0.5 rounded dark:bg-gray-700 dark:text-gray-300">
            <%= category %>
          </span>
        <% end %>
        <span class="text-sm">
          Updated: <%= post.data.updated.strftime('%F') %>
        </span>
      </div>
      <h2 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white"><a href="<%= post.relative_url %>">
        <%= post.data.title %></a>
      </h2>
      <p class="mb-5 font-light text-gray-700 dark:text-gray-400">
        <%= post.data.summary %>
      </p>
      <div class="flex justify-between items-center">
        <div class="flex items-center space-x-4">
          <img class="w-7 h-7 rounded-full" src="https://flowbite.s3.amazonaws.com/blocks/marketing-ui/avatars/jese-leos.png" alt="Jese Leos avatar" />
          <span class="font-medium dark:text-white">
            Bill Tihen
          </span>
        </div>
        <a href="<%= post.relative_url %>" class="inline-flex items-center font-medium text-primary-600 dark:text-primary-500 hover:underline">
          Read
          <svg class="ml-2 w-4 h-4" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
            <path fill-rule="evenodd" d="M10.293 3.293a1 1 0 011.414 0l6 6a1 1 0 010 1.414l-6 6a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-4.293-4.293a1 1 0 010-1.414z" clip-rule="evenodd">
            </path>
          </svg>
        </a>
      </div>
    </article>
  <% end %>
</div>

<hr>

If you have a lot of posts, you may want to consider adding [pagination](https://www.bridgetownrb.com/docs/content/pagination)!
