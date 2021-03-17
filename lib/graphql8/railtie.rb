# frozen_string_literal: true


module GraphQL8
  class Railtie < Rails::Railtie
    rake_tasks do
      # Defer this so that you only need the `parser` gem when you _run_ the upgrader
      def load_upgraders
        require_relative './upgrader/member'
        require_relative './upgrader/schema'
      end

      namespace :graphql do
        task :upgrade, [:dir] do |t, args|
          unless (dir = args[:dir])
            fail 'You have to give me a directory where your GraphQL8 schema and types live. ' \
             'For example: `bin/rake graphql8:upgrade[app/graphql8/**/*]`'
          end

          Dir[dir].each do |file|
            # Members (types, interfaces, etc.)
            if file =~ /.*_(type|interface|enum|union|)\.rb$/
              Rake::Task["graphql8:upgrade:member"].execute(Struct.new(:member_file).new(file))
            end
          end

          puts "Upgrade complete! Note that this is a best-effort approach, and may very well contain some bugs."
          puts "Don't forget to create the base objects. For example, you could run:"
          puts "\tbin/rake graphql8:upgrade:create_base_objects[app/graphql]"
        end

        namespace :upgrade do
          task :create_base_objects, [:base_dir] do |t, args|
            unless (base_dir = args[:base_dir])
              fail 'You have to give me a directory where your GraphQL8 types live. ' \
                   'For example: `bin/rake graphql8:upgrade:create_base_objects[app/graphql]`'
            end

            destination_file = File.join(base_dir, "types", "base_scalar.rb")
            unless File.exists?(destination_file)
              FileUtils.mkdir_p(File.dirname(destination_file))
              File.open(destination_file, 'w') do |f|
                f.puts "class Types::BaseScalar < GraphQL8::Schema::Scalar\nend"
              end
            end

            destination_file = File.join(base_dir, "types", "base_input_object.rb")
            unless File.exists?(destination_file)
              FileUtils.mkdir_p(File.dirname(destination_file))
              File.open(destination_file, 'w') do |f|
                f.puts "class Types::BaseInputObject < GraphQL8::Schema::InputObject\nend"
              end
            end

            destination_file = File.join(base_dir, "types", "base_enum.rb")
            unless File.exists?(destination_file)
              FileUtils.mkdir_p(File.dirname(destination_file))
              File.open(destination_file, 'w') do |f|
                f.puts "class Types::BaseEnum < GraphQL8::Schema::Enum\nend"
              end
            end

            destination_file = File.join(base_dir, "types", "base_union.rb")
            unless File.exists?(destination_file)
              FileUtils.mkdir_p(File.dirname(destination_file))
              File.open(destination_file, 'w') do |f|
                f.puts "class Types::BaseUnion < GraphQL8::Schema::Union\nend"
              end
            end

            destination_file = File.join(base_dir, "types", "base_interface.rb")
            unless File.exists?(destination_file)
              FileUtils.mkdir_p(File.dirname(destination_file))
              File.open(destination_file, 'w') do |f|
                f.puts "module Types::BaseInterface\n  include GraphQL8::Schema::Interface\nend"
              end
            end

            destination_file = File.join(base_dir, "types", "base_object.rb")
            unless File.exists?(destination_file)
              File.open(destination_file, 'w') do |f|
                f.puts "class Types::BaseObject < GraphQL8::Schema::Object\nend"
              end
            end
          end

          task :schema, [:schema_file] do |t, args|
            schema_file = args.schema_file
            load_upgraders
            upgrader = GraphQL8::Upgrader::Schema.new File.read(schema_file)

            puts "- Transforming schema #{schema_file}"
            File.open(schema_file, 'w') { |f| f.write upgrader.upgrade }
          end

          task :member, [:member_file] do |t, args|
            member_file = args.member_file
            load_upgraders
            upgrader = GraphQL8::Upgrader::Member.new File.read(member_file)
            next unless upgrader.upgradeable?

            puts "- Transforming member #{member_file}"
            File.open(member_file, 'w') { |f| f.write upgrader.upgrade }
          end
        end
      end
    end
  end
end
