class FeedParser

  def self.parse(news_sources, converter = FeedEntriesConverter.new)
    news_sources.each do |news_source|
      if news_source.feed
        entries = parse_feed(news_source.feed)
        converter.convert(news_source.feed, entries) if converter
      end
    end
  end

private

  def self.parse_feed(feed)
    has_already_fetched?(feed) ? update_feed(feed) : fetch_and_parse_feed(feed)
  end

  def self.has_already_fetched?(feed)
    feed.etag && feed.last_modified
  end

  def self.fetch_and_parse_feed(feed)
    feedjira_feed = Feedjira::Feed.fetch_and_parse(feed.url)
    update_cache_headers(feed, feedjira_feed)
    feedjira_feed.entries
  end

  def self.update_feed(feed)
    feedjira_feed = update_feedjira_feed(feed)
    update_cache_headers(feed, feedjira_feed)
    feedjira_feed.updated? ? feedjira_feed.new_entries : []
  end

  def self.update_cache_headers(feed, feedjira_feed)
    feed.update_attributes(last_modified: feedjira_feed.last_modified, etag: feedjira_feed.etag)
  end

  def self.update_feedjira_feed(feed)

    # https://github.com/feedjira/feedjira/issues/144#issuecomment-14932195
    # First create a dummy parser, any type of parser will do
    parser = Feedjira::Parser::RSS.new

    # Set the required Feedzirra values with data from your database
    parser.feed_url = feed.url
    parser.etag = feed.etag
    parser.last_modified = feed.last_modified

    # Set the last entry. This step is important.
    # This allows Feedzirra to detect if a feed that doesn't support last modified and etag has been updated.
    last_entry = Feedjira::Parser::RSSEntry.new

    # Do we have a last entry in the database? If so let Feedzirra know
    latest_feed_entry = latest_feed_entry(feed)
    if latest_feed_entry
     last_entry.url = latest_feed_entry.url
    end

    # Without this Feedzirra will return an empty array or some other surprise
    parser.entries << last_entry

    # Update the feed
    Feedjira::Feed.update(parser)
  end

  def self.latest_feed_entry(feed)
    feed.news_source.articles.order("created_at ASC").last
  end

end
