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
  <%# collections.posts.resources.select {|r| !!r.data.publish }.each do |post| %>
  <% paginator.resources.each do |post| %>
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
      <h2 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
        <a href="<%= post.relative_url %>"><%= post.data.title %></a>
      </h2>
      <p class="mb-5 font-light text-gray-700 dark:text-gray-400">
        <%= post.data.excerpt %>
      </p>
      <div class="flex justify-between items-center">
        <div class="flex items-center space-x-4">
          <img class="w-7 h-7 rounded-full" src="https://flowbite.s3.amazonaws.com/blocks/marketing-ui/avatars/jese-leos.png" alt="Jese Leos avatar" />
          <span class="font-medium dark:text-white">
            Bill Tihen
          </span>
        </div>
        <a href="<%= post.relative_url %>" class="px-4 py-2 text-sm text-black-700 no-underline bg-blue-200 rounded-full hover:bg-blue-300 hover:underline hover:text-black-700">
          Read Article
        </a>
      </div>
    </article>
  <% end %>
</div>

<div class="pt-6 pb-4 text-center">
  <% if paginator.total_pages > 1 %>
    <ul class="pagination">
      <% if paginator.previous_page %>
      <li>
        <a href="<%= paginator.previous_page_path %>">Previous Page</a>
      </li>
      <% end %>
      <% if paginator.next_page %>
      <li>
        <a href="<%= paginator.next_page_path %>">Next Page</a>
      </li>
      <% end %>
    </ul>
  <% end %>
</div>
