class SiteBuilder < Bridgetown::Builder
  # write builders which subclass SiteBuilder in plugins/builders
  Bridgetown::Resource::PermalinkProcessor.register_placeholder :blog_name, lambda { |resource|
    resource.data.blog_name.to_s
  }
end
