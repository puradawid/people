namespace :db do
  desc 'Convert db from mongo to postgres'
  task convert: :environment do

    def convert!(options = {})
      models = %w(ability admin_role contract_type feature location membership note position project role team user)
      converter = Sql::ConvertsFromMongo.new

      models.each do |model|
        klass = model.camelize.constantize
        sql_klass = "Sql::#{klass}".constantize
        puts "Exporting #{klass}"

        collection = klass.all
        collection.each do |item|
          puts "#{klass} #{item.id}"
          if options[:relations].present?
            converter.convert_relations!(item, sql_klass)
          else
            converter.convert_data!(item, sql_klass)
          end
        end
      end
    end

    convert!
    convert!(relations: true)
  end
end
