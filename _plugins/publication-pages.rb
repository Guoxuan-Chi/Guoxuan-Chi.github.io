require 'jekyll/scholar'
require 'nokogiri'

module Jekyll
  # Scholar's citation_* tags describe one paper, never a publication list.
  # Only generate an abstract page when the complete abstract is available.
  class PublicationPagesGenerator < Generator
    include Scholar::Utilities
    priority :high

    def generate(site)
      @site = site
      @config = Scholar.defaults.merge(site.config.fetch('scholar', {}))
      site.data['publication_pages'] = {}

      entries.each do |bib_entry|
        if bib_entry[:author].to_s.match?(/<\/?[a-z][^>]*>/i)
          raise Jekyll::Errors::FatalException, "#{bib_entry.key}: author must contain names, not HTML; use publication_authors.liquid for presentation"
        end

        entry = liquidify(bib_entry)
        if plain_text(entry['title']).empty? || Array(entry['author_array']).empty? || !entry['year'].to_s.match?(/\A\d{4}\z/)
          raise Jekyll::Errors::FatalException, "#{bib_entry.key}: a paper needs a title, authors and a four-digit publication year"
        end
        next if plain_text(entry['abstract']).empty?

        citation = entry.transform_values { |value| value.is_a?(String) ? plain_text(value) : value }
        citation['authors'] = entry.fetch('author_array').map do |author|
          name = %w[first prefix last].map { |part| plain_text(author[part]).gsub(/[*∗†‡§¶‖&^]/, '') }.reject(&:empty?).join(' ')
          suffix = plain_text(author['suffix'])
          suffix.empty? ? name : "#{name}, #{suffix}"
        end
        citation['firstpage'], citation['lastpage'] = citation['pages'].to_s.split(/\s*(?:--+|[-–—])\s*/, 2)

        # Keep the abstract and local full text in the same URL directory, as
        # required by Scholar for citation_pdf_url. External PDFs remain links.
        pdf = entry['pdf'].to_s
        if !pdf.empty? && !pdf.include?('://')
          unless File.basename(pdf) == pdf && File.file?(site.in_source_dir('assets/pdf', pdf))
            raise Jekyll::Errors::FatalException, "#{bib_entry.key}: local PDF not found in assets/pdf: #{pdf}"
          end
          citation['local_pdf'] = "/assets/pdf/#{pdf}"
        end

        path = "/assets/pdf/#{entry['key']}.html"
        page = PageWithoutAFile.new(site, site.source, 'assets/pdf', "#{entry['key']}.html")
        page.data.merge!(
          'layout' => 'publication', 'lang' => 'en', 'permalink' => path,
          'title' => citation['title'], 'description' => citation['abstract'],
          'publication' => citation, 'entry' => entry, 'sitemap' => true
        )
        site.pages << page
        site.data['publication_pages'][entry['key']] = path
      end
    end

    private

    def plain_text(value)
      Nokogiri::HTML.fragment(value.to_s).text.gsub(/[[:space:]]+/, ' ').strip
    end
  end
end
