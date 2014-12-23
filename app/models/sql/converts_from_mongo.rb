module Sql
  class ConvertsFromMongo
    def convert_data!(mongo, ar_type, initial_attrs = {})
      sql = ar_object_for(mongo, ar_type).tap do |sql|
        sql.assign_attributes(initial_attrs)
        prohibited_keys = %w(deleted_at gravatar icon version location)

        keys(mongo, sql).each do |key|
          if key == "_id"
            sql.mongo_id = mongo.id.to_s
          elsif prohibited_keys.include?(key) || /^(?!_).*_ids*$/.match(key.to_s)
            nil
          elsif sql.respond_to?("apply_mongo_#{key}!")
            sql.send("apply_mongo_#{key}!", mongo.send(key))
          elsif mongo.respond_to?(key) && !key.end_with?("_id") && !key.end_with?('_ids')
            sql.send("#{key}=", mongo.send(key))
          end
        end
        sql.save!(validate: false)
      end
    end

    def convert_relations!(mongo, ar_type)
      sql = ar_object_for(mongo, ar_type).tap do |sql|
        relation_ids = mongo.attributes.select { |key, value| /^(?!_).*_ids*$/.match(key.to_s) }
        relation_ids.delete('gravatar')
        relation_ids.delete('icon')
        sql_ids = relation_ids.inject({}) do |memo, (key, value)|
          klass = key.to_s.split('_')[0].capitalize
          klass = /^.*[^_ids*]/.match(key.to_s).to_s.camelize
          klass = 'Team' if klass == 'LeaderTeam'
          klass = "Sql::#{klass}".constantize
          if value.is_a?(Array)
            sql_ids = klass.where(mongo_id: value.map(&:to_s)).map(&:id)
          else
            sql_ids = klass.find_by_mongo_id(value.to_s).try(:id)
          end
          memo[key.to_s] = sql_ids
          memo
        end
        sql.assign_attributes(sql_ids)

        sql.save!(validate: false)
      end
    end

    private

    def ar_object_for(mongo, ar_type)
      ar_type.where(:mongo_id => mongo.id.to_s).first || ar_type.new
    end

    def keys(mongo, sql)
      (mongo.attributes.keys + sql.attributes.keys).uniq - ['id']
    end
  end
end
