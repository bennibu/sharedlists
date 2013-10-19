class Supplier < ActiveRecord::Base
  has_many :articles, :dependent => :destroy
  has_many :user_accesses, :dependent => :destroy
  has_many :users, :through => :user_accesses
  
  # save lists in an array in database
  serialize :lists
  
  validates_presence_of :name, :address, :phone
  validates_presence_of :bnn_host, :bnn_user, :bnn_password, :bnn_sync, :if => Proc.new { |s| s.bnn_sync }

  scope :bnn_sync, :conditions => {:bnn_sync => true}
  
  def bnn_path
    File.join(Rails.root, "supplier_assets/bnn_files/", id.to_s)
  end

  def sync_bnn_files
    new_files = FtpSync::sync(self)

    unless new_files.empty?
      logger.info "New bnn files for #{name}: #{new_files.inspect}"

      new_files.each do |file|
        logger.debug "parse #{file}..."
        outlisted_counter, new_counter, updated_counter, invalid_articles =
            update_articles_from_file(File.read(File.join(bnn_path,file)), 'bnn', 'IBM850')
        logger.info "#{file} successfully parsed: #{new_counter} new, #{updated_counter} updated, #{outlisted_counter} outlisted, #{invalid_articles.size} invalid"
      end

      if $missing_bnn_codes
        logger.info "missing bnn-codes: #{$missing_bnn_codes.uniq.sort.join(", ")}"
      end
    end
  end
  
  # parses file and updates articles
  # returns counter for outlisted, new and updated articles
  # also returns articles, where creation or update fails (invalid_articles)
  def update_articles_from_file(data, type, character_set = 'UTF-8')
    
    if character_set == 'UTF-8'
      data = data.force_encoding 'UTF-8'
    else
      # convert characters from given character set to utf8 
      data.encode! 'UTF-8', character_set unless character_set == 'UTF-8'
    end
    
    invalid_articles = Array.new
    outlisted_counter, new_counter, updated_counter = 0, 0, 0
    
    case type
    when 'foodsoft'
      new_or_updated_articles, outlisted_articles = FoodsoftFile::parse(data)

    when 'bnn'
      new_or_updated_articles, outlisted_articles, specials = BnnFile::parse(data)

    when 'borkenstein'
      new_or_updated_articles, outlisted_articles = Borkenstein::parse(data)

    when 'dnb_csv'
      new_or_updated_articles, outlisted_articles = DnbCsvFile::parse(data)

    when 'dnb_xml'
      new_or_updated_articles, outlisted_articles = DnbXmlFile::parse(data)

    when 'terrasana'
      new_or_updated_articles, outlisted_articles = TerrasanaFile::parse(data)

    when 'bdtotaal'
      new_or_updated_articles, outlisted_articles = BdtotaalFile::parse(data)
    end
    
    # delete all outlisted articles
    outlisted_articles.each do |article|
      if (article = articles.find_by_number(article[:number]))
        article.destroy && outlisted_counter += 1
      end
    end
      
    # update or create articles
    new_or_updated_articles.each do |parsed_article|
      if (article = articles.find_by_number(parsed_article[:number]))
        # update
        updated_counter += 1 if article.update_attributes(parsed_article)
      else
        # create
        new_article = articles.build(parsed_article)
        if new_article.valid? && new_article.save
          new_counter += 1
        else
          invalid_articles << new_article
        end
      end
    end
    
    # updates articles with special infos
    if specials
      specials.each do |special|
        if article = articles.find_by_number(special[:number])
          if article.note 
            article.note += " | #{special[:note]}"
          else
            article.note = special[:note]
          end
          article.save
        end
      end
    end
    
    return [outlisted_counter, new_counter, updated_counter, invalid_articles]
  end

  def articles_updated_at
    articles.order('articles.updated_on DESC').first.try(:updated_on)
  end
end

# == Schema Information
#
# Table name: suppliers
#
#  id            :integer(4)      not null, primary key
#  name          :string(255)     not null
#  address       :string(255)     not null
#  phone         :string(255)     not null
#  phone2        :string(255)
#  fax           :string(255)
#  email         :string(255)
#  url           :string(255)
#  delivery_days :string(255)
#  note          :string(255)
#  created_on    :datetime
#  updated_on    :datetime
#  lists         :string(255)
#  bnn_sync      :boolean(1)      default(FALSE)
#  bnn_host      :string(255)
#  bnn_user      :string(255)
#  bnn_password  :string(255)
#

