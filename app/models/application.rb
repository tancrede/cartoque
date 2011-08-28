class Application < ActiveRecord::Base
  has_and_belongs_to_many :servers
  has_many :application_instances, :dependent => :destroy
  accepts_nested_attributes_for :application_instances, :reject_if => lambda{|a| a[:name].blank? },
                                                        :allow_destroy => true

  attr_accessible :name, :criticity, :info, :iaw, :pe, :moa, :amoa, :moa_note, :contact, :pnd, :ams,
                  :cerbere, :comment, :identifier, :server_ids, :application_instances_attributes

  validates_presence_of :name

  before_save :update_cerbere_from_instances

  def self.search(search)
    if search
      where("name LIKE ?", "%#{search}%")
    else
      scoped
    end
  end

  def self.find(*args)
    if args.first && args.first.is_a?(String) && !args.first.match(/^\d*$/)
      application = find_by_identifier(*args)
      raise ActiveRecord::RecordNotFound, "Couldn't find Application with identifier=#{args.first}" if application.nil?
      application
    else
      super
    end
  end

  def update_cerbere_from_instances
    self.cerbere = self.application_instances.inject(false) do |memo,app_instance|
      memo || app_instance.authentication_method == "cerbere"
    end
    true
  end

  def sorted_application_instances
    ary = application_instances
    prod = ary.select{|ai| ai.name == "prod"}
    preprod = ary.select{|ai| ai.name == "preprod"}
    ecole = ary.select{|ai| ai.name == "ecole"}
    others = ary.select{|ai| !%w(prod preprod ecole).include?(ai.name) }
    [prod, ecole, preprod, others].flatten.compact
  end

  def self.dokuwiki_pages_dir
    File.expand_path("data/dokuwiki/pages", Rails.root)
  end

  def dokuwiki_pages
    keywords = [name] + application_instances.map(&:application_urls).flatten.map(&:url)
    keywords.map!{|k| k.gsub(%r{^\s*\S+://}, "").gsub(%r{/.*}, "")}
    docs = []
    keywords.each do |kw|
      docs += %x[find #{Application.dokuwiki_pages_dir} -type f \\( -ipath "*/#{kw}/*" -o -ipath "*/#{kw}.*" \\)].split("\n").map do |doc|
        doc.gsub(Application.dokuwiki_pages_dir+"/","").gsub(/\.txt$/,"").gsub("/", ":")
      end
    end
    docs.uniq
  end
end
