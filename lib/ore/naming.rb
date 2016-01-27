require 'ore/config'

require 'yaml'

module Ore
  #
  # Provides methods for guessing the namespaces and directories
  # of projects. {Naming} uses the naming conventions of project names
  # defined by the
  # [Ruby Packaging Standard (RPS)](http://chneukirchen.github.com/rps/).
  #
  # @since 0.9.0
  #
  module Naming
    # The directory which contains executables for a project
    BIN_DIR = 'bin'

    # The directory which contains the code for a project
    LIB_DIR = 'lib'

    # The directory which contains C extension code for a project
    EXT_DIR = 'ext'

    # The directory which contains data files for a project
    DATA_DIR = 'data'

    # The directory which contains unit-tests for a project
    TEST_DIR = 'test'

    # The directory which contains spec-tests for a project
    SPEC_DIR = 'spec'

    # The directory which contains built packages
    PKG_DIR = 'pkg'

    # Words used in project names, but never in directory names
    IGNORE_NAMESPACES = %w[core ruby rb java]

    # Common abbrevations used in namespaces
    COMMON_ABBREVIATIONS = Hash[File.readlines(File.join(Config::DATA_DIR,'abbreviations.txt')).map { |abbrev|
      abbrev.chomp!
      [abbrev.downcase, abbrev]
    }]

    # Common project prefixes and namespaces
    COMMON_NAMESPACES = YAML.load_file(File.join(Config::DATA_DIR,'common_namespaces.yml'))

    #
    # Splits the project name into individual names.
    #
    # @param [String] name
    #   The name to split.
    #
    # @return [Array<String>]
    #   The individual names of the project name.
    #
    def names_in(name)
      name.split('-').reject do |word|
        IGNORE_NAMESPACES.include?(word)
      end
    end

    #
    # Guesses the module name for a word within a project name.
    #
    # @param [String] word
    #   The word within a project name.
    #
    # @return [String]
    #   The module name.
    #
    # @since 0.1.1
    #
    def module_of(word)
      if COMMON_NAMESPACES.has_key?(word)
        COMMON_NAMESPACES[word]
      elsif COMMON_ABBREVIATIONS.has_key?(word)
        COMMON_ABBREVIATIONS[word]
      else
        word.capitalize
      end
    end

    #
    # Guesses the module names from a project name.
    #
    # @param [String] name
    #   The name of the project.
    #
    # @return [Array<String>]
    #   The module names for a project.
    #
    def modules_of(name)
      names_in(name).map do |words|
        words.split('_').map { |word| module_of(word) }.join
      end
    end

    #
    # Guesses the full namespace for a project.
    #
    # @param [String] name
    #   The name of the project.
    #
    # @return [String]
    #   The full module namespace for a project.
    #
    def namespace_of(name)
      modules_of(name).join('::')
    end

    #
    # Converts a camel-case name to an underscored file name.
    #
    # @param [String] name
    #   The name to underscore.
    #
    # @return [String]
    #   The underscored version of the name.
    #
    def underscore(name)
      name.gsub(/[^A-Z_][A-Z][^A-Z_]/) { |cap|
        cap[0,1] + '_' + cap[1..-1]
      }.downcase
    end

    #
    # Guesses the namespace directories within `lib/` for a project.
    #
    # @param [String] name
    #   The name of the project.
    #
    # @return [Array<String>]
    #   The namespace directories for the project.
    #
    def namespace_dirs_of(name)
      names_in(name).map { |word| underscore(word) }
    end

    #
    # Guesses the namespace directory within `lib/` for a project.
    #
    # @param [String] name
    #   The name of the project.
    #
    # @return [String]
    #   The namespace directory for the project.
    #
    def namespace_path_of(name)
      File.join(namespace_dirs_of(name))
    end
  end
end
