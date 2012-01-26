module ActiveRecord
  module ConnectionAdapters #:nodoc:
    class TableDefinition
      %w( unsigned string text integer float decimal datetime timestamp time date binary boolean ).each do |column_type|
        class_eval <<-EOV, __FILE__, __LINE__ + 1
          def #{column_type}(*args)                                               # def string(*args)
            options = args.extract_options!                                       #   options = args.extract_options!
            column_names = args                                                   #   column_names = args
                                                                                  #
            column_names.each { |name| column(name, '#{column_type}', options) }  #   column_names.each { |name| column(name, 'string', options) }
          end                                                                     # end
        EOV
      end
    end
    
    class Table
      %w( unsigned string text integer float decimal datetime timestamp time date binary boolean ).each do |column_type|
        class_eval <<-EOV, __FILE__, __LINE__ + 1
          def #{column_type}(*args)                                          # def string(*args)
            options = args.extract_options!                                  #   options = args.extract_options!
            column_names = args                                              #   column_names = args
                                                                             #
            column_names.each do |name|                                      #   column_names.each do |name|
              column = ColumnDefinition.new(@base, name, '#{column_type}')   #     column = ColumnDefinition.new(@base, name, 'string')
              if options[:limit]                                             #     if options[:limit]
                column.limit = options[:limit]                               #       column.limit = options[:limit]
              elsif native['#{column_type}'.to_sym].is_a?(Hash)              #     elsif native['string'.to_sym].is_a?(Hash)
                column.limit = native['#{column_type}'.to_sym][:limit]       #       column.limit = native['string'.to_sym][:limit]
              end                                                            #     end
              column.precision = options[:precision]                         #     column.precision = options[:precision]
              column.scale = options[:scale]                                 #     column.scale = options[:scale]
              column.default = options[:default]                             #     column.default = options[:default]
              column.null = options[:null]                                   #     column.null = options[:null]
              @base.add_column(@table_name, name, column.sql_type, options)  #     @base.add_column(@table_name, name, column.sql_type, options)
            end                                                              #   end
          end                                                                # end
        EOV
      end
    end
    
    class Mysql2Adapter < AbstractAdapter
      
      def native_database_types #:nodoc:
        NATIVE_DATABASE_TYPES.merge(
          :primary_key  => "int(11) unsigned DEFAULT NULL auto_increment PRIMARY KEY".freeze,
          :unsigned     => { :name => "int", :limit => 4 }
        )
      end
  
      def type_to_sql(type, limit = nil, precision = nil, scale = nil)
        return super unless ['integer', 'unsigned'].include?(type.to_s)
        u = type.to_s == 'unsigned' ? ' unsigned' : nil
        case limit
        when 1; 'tinyint' + u
        when 2; 'smallint' + u
        when 3; 'mediumint' + u
        when nil, 4, 11; 'int(11)' + u  # compatibility with MySQL default
        when 5..8; 'bigint' + u
        else raise(ActiveRecordError, "No integer type has byte size #{limit}")
        end
      end
    end
    
    class MysqlAdapter < AbstractAdapter
      
      def native_database_types #:nodoc:
        NATIVE_DATABASE_TYPES.merge(
          :primary_key  => "int(11) unsigned DEFAULT NULL auto_increment PRIMARY KEY".freeze,
          :unsigned     => { :name => "int", :limit => 4 }
        )
      end
  
      def type_to_sql(type, limit = nil, precision = nil, scale = nil)
        return super unless ['integer', 'unsigned'].include?(type.to_s)
        u = type.to_s == 'unsigned' ? ' unsigned' : nil
        case limit
        when 1; 'tinyint' + u
        when 2; 'smallint' + u
        when 3; 'mediumint' + u
        when nil, 4, 11; 'int(11)' + u  # compatibility with MySQL default
        when 5..8; 'bigint' + u
        else raise(ActiveRecordError, "No integer type has byte size #{limit}")
        end
      end
    end
  end
end

