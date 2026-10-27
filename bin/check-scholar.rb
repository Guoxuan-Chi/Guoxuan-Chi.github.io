#!/usr/bin/env ruby
# Run after building: bundle exec ruby bin/check-scholar.rb [_site] [baseurl] [url]
require 'bibtex'
require 'date'
require 'nokogiri'
require 'yaml'
require 'uri'

source = File.expand_path('..', __dir__)
config = YAML.safe_load_file(File.join(source, '_config.yml'), permitted_classes: [Date], aliases: true)
destination = File.expand_path(ARGV[0] || '_site', source)
baseurl = (ARGV[1] || config['baseurl']).to_s.sub(%r{/$}, '')
origin_uri = URI((ARGV[2] || config.fetch('url')).sub(%r{/$}, ''))
origin_uri.host = origin_uri.host.downcase
origin = origin_uri.to_s
entries = BibTeX.open(File.join(source, '_bibliography/papers.bib')).entries.values

def check(condition, message)
  abort("FAIL: #{message}") unless condition
end

def normalize(value)
  value.to_s.gsub(/[[:space:]]+/, ' ').strip
end

def author_names(entry)
  entry.author.map do |name|
    parts = [name.first, name.prefix, name.last].map { |part| part.to_s.gsub(/[*∗†‡§¶‖&^]/, '') }.reject(&:empty?)
    value = parts.join(' ')
    name.suffix.to_s.empty? ? value : "#{value}, #{name.suffix}"
  end
end

documents = %w[publications/index.html zh/publications/index.html].map do |path|
  Nokogiri::HTML(File.read(File.join(destination, path)))
end
documents.each do |doc|
  check(doc.css('meta[name^="citation_"]').empty?, 'A multi-paper list must not contain page-level citation metadata')
  check(doc.css('.citation_title').length == entries.length, 'Missing publication titles')
  check(doc.css('.more-authors').empty?, 'Authors still require a click')
end

abstract_count = 0
pdf_count = 0
sitemap = File.read(File.join(destination, 'sitemap.xml'))
entries.each do |entry|
  key = entry.key
  expected_names = author_names(entry)
  check(!entry.author.to_s.match?(/<[^>]+>/), "#{key}: HTML in source author field")
  check(!entry.title.to_s.empty? && !expected_names.empty? && entry.year.to_s.match?(/\A\d{4}\z/), "#{key}: incomplete bibliographic data")
  documents.each do |doc|
    row = doc.at_css("[id='#{key}']")
    check(row, "#{key}: missing bibliography entry")
    check(normalize(row.at_css('.citation_title')&.text) == normalize(entry.title), "#{key}: title contaminated or incomplete")
    author_line = row.at_css('.citation_author')
    names = author_line.css('.author-name').map { |node| normalize(node.text) }
    check(names == expected_names, "#{key}: authors missing, reordered, or altered: #{names.inspect}")
    check(author_line.css('strong, b, em, i:not([data-toggle]), [onclick], [hidden]').empty?, "#{key}: emphasis or hidden author content")
    check(!author_line['style'].to_s.match?(/display\s*:\s*none/), "#{key}: invisible authors")
    if entry[:month].to_s.empty?
      check(!row.at_css('.periodical').text.match?(/\b(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\b/), "#{key}: month leaked from another paper")
    end
  end

  if entry[:abstract].to_s.strip.empty?
    # Incomplete local records use the publisher's page instead of inventing an abstract.
    documents.each do |doc|
      link = doc.at_css("[id='#{key}'] .citation_title a")
      check(link && link['href'].start_with?('https://'), "#{key}: no authoritative record linked")
    end
    next
  end

  abstract_count += 1
  path = "/assets/pdf/#{key}.html"
  doc = Nokogiri::HTML(File.read(File.join(destination, path.delete_prefix('/'))))
  values = ->(field) { doc.css("head meta[name='citation_#{field}']").map { |node| node['content'] } }
  check(values.call('title') == [normalize(entry.title)], "#{key}: incorrect citation_title")
  check(values.call('author') == expected_names, "#{key}: incorrect citation_author tags")
  check(values.call('publication_date') == [entry.year.to_s], "#{key}: incorrect citation year")
  check(doc.css('h1.citation_title').length == 1, "#{key}: ambiguous paper title")
  check(doc.at_css('.publication-abstract p')&.text.to_s.length > 100, "#{key}: missing complete visible abstract")
  check(doc.css('.publication-abstract.hidden, .publication-abstract[hidden]').empty?, "#{key}: abstract hidden")
  check(doc.css('meta[name="robots"][content*="noindex"]').empty?, "#{key}: noindex on a paper")
  check(doc.at_css('link[rel="canonical"]')&.[]('href') == "#{origin}#{baseurl}#{path}", "#{key}: bad canonical URL")
  check(sitemap.include?("#{origin}#{baseurl}#{path}"), "#{key}: missing from sitemap")
  documents.each do |listing|
    check(listing.at_css("[id='#{key}'] .citation_title a")&.[]('href') == "#{baseurl}#{path}", "#{key}: unreachable abstract page")
  end
  pdf = entry[:pdf].to_s
  next if pdf.empty? || pdf.include?('://')

  pdf_count += 1
  expected_pdf = "#{origin}#{baseurl}/assets/pdf/#{pdf}"
  check(values.call('pdf_url') == [expected_pdf], "#{key}: incorrect citation_pdf_url")
  check(File.dirname(URI(expected_pdf).path) == File.dirname("#{baseurl}#{path}"), "#{key}: PDF outside abstract directory")
  check(File.file?(File.join(destination, 'assets/pdf', pdf)), "#{key}: PDF missing from build")
end

chameleon = entries.find { |entry| entry.key == 'zhang2025chameleon' }
delving = entries.find { |entry| entry.key == 'zhang2025delving' }
check(author_names(chameleon).length == 11 && author_names(chameleon).last == 'Hao Zhao', 'Chameleon must have all 11 authors')
check(author_names(delving).last(4) == ['Igor Gilitschenski', 'Hongyang Li', 'Hang Zhao', 'Hao Zhao'], 'Delving is missing its last four authors')
documents.each do |doc|
  [chameleon, delving].each do |entry|
    exported = BibTeX.parse(doc.at_css("[id='#{entry.key}'] .bibtex code").text).entries.values.first
    check(exported.type == :inproceedings && author_names(exported) == author_names(entry), "#{entry.key}: stale exported citation")
  end
end

# Exercise the build guard with the old failure pattern, without touching source files.
require 'jekyll'
require_relative '../_plugins/publication-pages'
{
  'author must contain names, not HTML' => '@article{bad, author={<strong>Chi</strong>, <strong>Guoxuan</strong>}, title={Test}, year={2026}}',
  'a paper needs a title, authors and a four-digit publication year' => '@article{bad, author={Chi, Guoxuan}, title={Test}}'
}.each do |message, fixture|
  generator = Jekyll::PublicationPagesGenerator.new
  generator.define_singleton_method(:entries) { BibTeX.parse(fixture).entries.values }
  fake_site = Struct.new(:config, :data).new({ 'scholar' => {} }, {})
  rejected = false
  begin
    generator.generate(fake_site)
  rescue Jekyll::Errors::FatalException => error
    rejected = error.message.include?(message)
  end
  check(rejected, "Build did not reject invalid metadata: #{message}")
end
puts "PASS: #{entries.length} papers in both languages; #{abstract_count} abstract pages; #{pdf_count} linked local PDFs; baseurl=#{baseurl.inspect}"
