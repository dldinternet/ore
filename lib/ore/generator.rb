require 'ore/config'
require 'ore/template_dir'
require 'ore/interpolations'

require 'thor/group'
require 'set'

module Ore
  class Generator < Thor::Group

    include Thor::Actions
    include Interpolations

    #
    # The templates registered with the generator.
    #
    def Generator.templates
      @templates ||= {}
    end

    #
    # Registers a template with the generator.
    #
    # @param [String] path
    #   The path to the template.
    #
    def Generator.register_template(path)
      path = File.expand_path(path)
      Generator.templates[File.basename(path)] = path
    end

    Config.templates.each { |path| Generator.register_template(path) }

    class_option :markup, :default => 'rdoc'
    class_option :templates, :type => :array, :aliases => '-T'
    class_option :name, :type => :string, :aliases => '-n'
    class_option :version, :type => :string,
                            :default => '0.1.0',
                            :aliases => '-V'
    class_option :summary, :default => 'TODO: Summary', :aliases => '-s'
    class_option :description, :default => 'TODO: Summary', :aliases => '-D'
    class_option :homepage, :type => :string, :aliases => '-U'
    class_option :email, :type => :string, :aliases => '-e'
    class_option :authors, :type => :array, :default => [], :aliases => '-a'
    class_option :license, :default => 'MIT', :aliases => '-L'
    class_option :rdoc, :type => :boolean, :default => true
    class_option :yard, :type => :boolean, :default => false
    class_option :bundler, :type => :boolean, :default => false
    argument :path, :required => true

    def generate
      self.destination_root = path

      load_templates!
      initialize_variables!

      generate_directories!
      generate_files!
    end

    protected

    #
    # Loads the given templates.
    #
    def load_templates!
      @templates = []
      
      options.templates.each do |name|
        unless (template_dir = Generate.templates[name])
          say "Unknown template #{name.dump}", :red
          exit -1
        end

        source_root template_dir
        @templates << Template.new(template_dir)
      end
    end

    #
    # Initializes variables for the templates.
    #
    def initialize_variables!
      @project_dir = File.basename(destination_root)
      @name = (options.name || @project_dir)

      @modules = @name.split('-').map do |modules|
        modules.split('_').map { |words|
          words.map { |word| word.capitalize }.join
        }
      end

      @namespace = @modules.join('::')
      @namespace_dir = File.join(@name.split('-'))

      @email = options.email
      @safe_email = @email.sub('@',' at ') if @email
      @homepage = options.homepage
      @authors = options.authors
      @author = options.authors.first
      @license = options.license

      @markup = options.markup
    end

    #
    # Creates directories listed in the template directories.
    #
    def generate_directories!
      generated = Set[]

      @templates.each do |template|
        template.each_directory do |dir|
          unless generated.include?(dir)
            path = interpolate(dir)
            empty_directory path

            generated << dir
          end
        end
      end
    end

    #
    # Copies static files and renders templates in the template directories.
    #
    def generate_files!
      generated = Set[]

      @templates.reverse_each do |template|
        template.each_file(@markup) do |dest,file|
          unless generated.include?(dest)
            path = interoplate(dest)
            copy_file file, path

            generated << dest
          end
        end

        template.each_template(@markup) do |dest,file|
          unless generated.include?(dest)
            path = interpolate(dest)

            @current_template_dir = File.dirname(dest)
            template file, path
            @current_template_dir = nil

            generated << dest
          end
        end
      end
    end

    #
    # Renders all include files with the given name.
    #
    # @param [Symbol] name
    #   The name of the include.
    #
    # @return [String]
    #   The combined result of the rendered include files.
    #
    def includes(name)
      name = name.to_sym
      output_buffer = ''

      if @current_template_dir
        context = instance_eval('binding')

        @templates.each do |template|
          if template.includes.has_key?(@current_template_dir)
            path = template.includes[@current_template_dir][name]

            if path
              erb = ERB.new(File.read(path),nil,'-')
              output_buffer << erb.result(context)
            end
          end
        end
      end

      return output_buffer
    end

    #
    # Determines if the project will contain RDoc documented.
    #
    # @return [Boolean]
    #   Specifies whether the project will contain RDoc documented.
    #
    def rdoc?
      options.rdoc?
    end

    #
    # Determines if the project will contain YARD documented.
    #
    # @return [Boolean]
    #   Specifies whether the project will contain YARD documentation.
    #
    def yard?
      options.yard?
    end

    #
    # Determines whether the project will use Bundler.
    #
    # @return [Boolean]
    #   Specifies whether the project will use Bundler.
    #
    def bundler?
      options.bundler?
    end

  end
end
