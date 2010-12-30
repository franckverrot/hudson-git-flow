$:<< '.'
%w( xml_config commands ).each { |lib| require "lib/job/build/#{lib}" }

module Api
  class <<self  

    def config=(path)
      #@config ||= YAML.load_file('lib/config/config.yml')
      @config ||= YAML.load_file(path)
    end
    
    def config
      @config || raise('You should first specify the configuratio file using Api.config = "path/to/conf/file"')
    end
    
    def logger
      @logger ||= Logger.new(config['log'])
    end
    
    def server
      @server ||= RestClient::Resource.new config['server'], config['user'], config['password']
    end

    def parse(response)
      JSON.parse(response)
    end
    
    def jobs
      parse(server[config['json_api_url']].get).fetch('jobs')
    end
    
    def job_names
      jobs.map { |job| job['name'] }
    end
    
    def add_jobs_to_hudson
      new_branches.each do |name|
        xml_config = XmlConfig.generate!(name)
        logger.debug "adding new job: #{name}"
        server["/createItem?name=#{name}"].post xml_config, :content_type => 'text/xml'
      end
    end
    
    def add_branches!
      add_jobs_to_hudson if new_branches
    end
    
    def new_branches
      github_feature_branches - hudson_feature_jobs
    end 

    def filter_branch
      Proc.new do |hash| 
        hash.reject! { |k,v| k !~ Regexp.new(config['filter']) } 
      end
    end
    
    def github_feature_branches
      filter_branch.call(branches)
    end
    
    def hudson_feature_jobs
      filter_branch.call(job_names)
    end
    
    def sanitize(name)
      name.gsub(/\W+/, config['sanitize']) 
    end
    
    def remote(repo)
      "origin/#{$1}/#{$2}" if repo.match(/(^\w+)\W(.*)/)
    end

    def build(name)
      server["/job/#{name}/build"].get if job_names.any? { name }
    end
      
    def branches
      branches = RestClient::Resource.new(config['github']['branches'], config['github']['user'] + "/token", config['github']['token']).get
      parse(branches).fetch('branches').keys.map do |branch| 
        sanitize(branch) 
      end
    end
    
    %w( successful stable failed ).each do |type|
      define_method("last_#{type}".to_sym) do |name|
        server["/job/#{name}/last#{type.capitalize}Build/api/json"].get.tap do |resp|
          parse(resp).each_pair do |k,v| 
            puts "#{k}: #{v}" unless k.include? 'actions' 
          end
        end
      end
    end

  end
end
