# See SearchableRecord::ClassMethods#find_queried for usage documentation.
module SearchableRecord
  def self.included(base_class)   #:nodoc:
    base_class.class_eval do
      extend ClassMethods

      @@searchable_record_settings = {
        :cast_since_as     => "datetime",
        :cast_until_as     => "datetime",
        :pattern_operator  => "like",
        :pattern_converter => lambda { |val| "%#{val}%" }
      }

      cattr_accessor :searchable_record_settings
    end
  end

  private

  module ClassMethods
    # === Description
    #
    # Parses the query parameters the client has given in the URL of the
    # HTTP request. With the query parameters, the client may set a limit,
    # an offset, or an ordering for the items in the search result. In
    # addition, the client may limit the output by allowing only certain
    # records that match to specific patterns.
    #
    # What the client user is allowed to query is defined by specific rules
    # passed to the method as a hash argument. Query parameters that are not
    # explicitly stated in the rules are silently discarded.
    #
    # Essentially, the method is a frontend for
    # <tt>ActiveRecord::Base#find</tt>. The method
    #
    # 1.  parses the query parameters the client has given in the URL for
    #     the HTTP request (+query_params+) against the rules (+rules+), and
    # 2.  calls <tt>find</tt> with the parsed options.
    #
    # ==== Parsing rules
    #
    # The parsing rules must be given as a hash. The recognized keys are the
    # following:
    #
    # *  <tt>:limit</tt>, allowing limiting the number of matching items
    #    (the same effect as with <tt>find</tt>). The value for the key is
    #    irrelevant; use +nil+. The rule enables query parameter "limit"
    #    that accepts an integer value.
    # *  <tt>:offset</tt>, allowing skipping matching items (the same effect
    #    as with <tt>find</tt>). The value for the key is irrelevant; use
    #    +nil+. The rule enables query parameter "offset" that accepts an
    #    integer value.
    # *  <tt>:sort</tt>, which determines the ordering of matching items
    #    (the same effect as with the <tt>:order</tt> option of
    #    <tt>find</tt>). The value is a hash of
    #    <tt>"<parameter_value>" => "<table>.<column>"</tt> pairs. The rule
    #    enables query parameter "sort" that accepts keys from the hash as
    #    its legal values.
    # *  <tt>:rsort</tt>, for reverse sort. Uses the rules of
    #    <tt>:sort</tt>; thus, use +nil+ as the value if you want to enable
    #    "rsort" query parameter.
    # *  <tt>:since</tt>, which sets a lower timedate limit. The value is
    #    either a string naming the database table column that has
    #    timestamps (using the type from default settings'
    #    <tt>:cast_since_as</tt> entry) or a hash that contains entries like
    #    <tt>:column => "<table>.<column>"</tt> and
    #    <tt>:cast_as => "<sql_timedate_type>"</tt>. The rule enables query
    #    parameter "since" that accepts timedate values.
    # *  <tt>:until</tt>, which sets an upper timedate limit. It is used
    #    like <tt>:since</tt>.
    # *  <tt>:patterns</tt>, where the value is a hash containing patterns.
    #    The keys in the hash correspond to additional query parameters,
    #    while the corresponding values to the keys correspond to database
    #    table columns. For each pattern, the value is either directly a
    #    string, or a hash containing an entry like
    #    <tt>:column => "<table>.<column>"</tt>. A pattern's hash may
    #    contain two optional entries in addition to <tt>:column</tt>:
    #    <tt>:converter => lambda { |val| <conversion_operation_for_val> }</tt>
    #    and <tt>:operator => "<sql_pattern_operator>"</tt>.
    #    -  <tt>:converter</tt> expects a block that modifies the input
    #       value; if the key is not given, the converter specified in
    #       <tt>:pattern_converter</tt> in the default settings is used
    #       instead.
    #    -  <tt>:operator</tt> specifies a custom match operator for the
    #       pattern; if the key is not given, the operator specified in
    #       <tt>:pattern_operator</tt> in the default settings is used
    #       instead.
    #
    # If both +sort+ and +rsort+ parameters are given in the URL and both
    # are allowed query parameter by the rules, +sort+ is favored over
    # +rsort+. Unlike with +sort+ and +rsort+ rules (+rsort+ uses the rules
    # of +sort+), the rules for +since+ and +until+ are independent from
    # each other.
    #
    # For usage examples, see the example in README.txt and the specs that
    # come with the plugin.
    #
    # ==== Default settings for rules
    #
    # The default settings for the rules are accessible and modifiable by
    # calling the method +searchable_record_settings+. The settings are
    # stored as a hash; the following keys are recognized:
    #
    # *  <tt>:cast_since_as</tt>,
    # *  <tt>:cast_until_as</tt>,
    # *  <tt>:pattern_operator</tt>, and
    # *  <tt>:pattern_converter</tt>.
    #
    # See the parsing rules above how the default settings are used.
    #
    # === Arguments
    #
    # +extend+::  The same as the first argument to <tt>find</tt> (such as <tt>:all</tt>).
    # +query_params+::  The (unsafe) query parameters from the URL as a hash.
    # +rules+::  The parsing rules as a hash.
    # +options+:: Additional options for <tt>find</tt>, such as <tt>:include => [ :an_association ]</tt>.
    #
    # === Return
    #
    # The same as with <tt>ActiveRecord::Base#find</tt>.
    def find_queried(extend, query_params, rules, options = { })
      # Ensure the proper types of arguments.
      query_params = query_params.to_hash
      rules = rules.to_hash
      options = options.to_hash

      query_params = preserve_allowed_query_params(query_params, rules)

      unless query_params.empty?
        parse_offset(options, query_params)
        parse_limit(options, query_params)
        parse_order(options, query_params, rules)
        parse_conditional_rules(options, query_params, rules)
      end

      logger.debug("find_queried: query_params=<<#{query_params.inspect}>>, resulted options=<<#{options.inspect}>>")

      self.find(extend, options)
    end

    private

    def preserve_allowed_query_params(query_params, rules)
      allowed_keys = rules.keys

      # Add pattern matching parameters to the list of allowed keys.
      allowed_keys.delete(:patterns)
      if rules[:patterns]
        allowed_keys += rules[:patterns].keys
      end

      # Do not affect the passed query parameters.
      Util.pruned_dup(query_params, allowed_keys)
    end

    def parse_offset(options, query_params)
      if query_params[:offset]
        value = Util.parse_positive_int(query_params[:offset])
        options[:offset] = value unless value.nil?
      end
    end

    def parse_limit(options, query_params)
      if query_params[:limit]
        value = Util.parse_positive_int(query_params[:limit])
        options[:limit] = value unless value.nil?
      end
    end

    def parse_order(options, query_params, rules)
      # Sort is favored over rsort.

      if query_params[:rsort]
        raise ArgumentError, "No sort rule specified." if rules[:sort].nil?

        sort_by = rules[:sort][query_params[:rsort]]
        options[:order] = "#{sort_by} desc" unless sort_by.nil?
      end

      if query_params[:sort]
        sort_by = rules[:sort][query_params[:sort]]
        options[:order] = sort_by unless sort_by.nil?
      end
    end

    def parse_conditional_rules(options, query_params, rules)
      cond_strs = [ ]
      cond_syms = { }

      # The hash query_params is not empty, therefore, it contains at least
      # some of the allowed query parameters (as Symbols) below. Those
      # parameters that are not identified are ignored silently.

      parse_since_and_until(cond_strs, cond_syms, query_params, rules)
      parse_patterns(cond_strs, cond_syms, query_params, rules)

      construct_conditions(options, cond_strs, cond_syms) unless cond_strs.empty?
    end

    def parse_since_and_until(cond_strs, cond_syms, query_params, rules)
      if query_params[:since]
        parse_datetime(cond_strs, cond_syms, query_params, rules, :since)
      end

      if query_params[:until]
        parse_datetime(cond_strs, cond_syms, query_params, rules, :until)
      end
    end

    def parse_datetime(cond_strs, cond_syms, query_params, rules, type)
      rule = rules[type]
      cast_type = searchable_record_settings["cast_#{type}_as".to_sym]

      if rule.respond_to?(:to_hash)
        column = rule[:column]

        # Use custom cast type.
        cast_type = rule[:cast_as] unless rule[:cast_as].nil?
      else
        column = rule
      end

      case type
      when :since then op = ">="
      when :until then op = "<="
      else raise ArgumentError, "Could not determine comparison operator for datetime."
      end

      cond_strs << "(#{column} #{op} cast(:#{type} as #{cast_type}))"
      cond_syms[type] = query_params[type]
    end

    def parse_patterns(cond_strs, cond_syms, query_params, rules)
      if rules[:patterns]
        rules[:patterns].each do |param, rule|
          parse_pattern(cond_strs, cond_syms, query_params, param, rule)
        end
      end
    end

    def parse_pattern(cond_strs, cond_syms, query_params, param, rule)
      if query_params[param]
        match_op = searchable_record_settings[:pattern_operator]
        conversion_blk = searchable_record_settings[:pattern_converter]

        if rule.respond_to?(:to_hash)
          column = rule[:column]

          # Use custom pattern match operator.
          match_op = rule[:operator] unless rule[:operator].nil?

          # Use custom converter.
          conversion_blk = rule[:converter] unless rule[:converter].nil?
        else
          column = rule
        end

        cond_strs << "(#{column} #{match_op} :#{param})"
        cond_syms[param] = conversion_blk.call(query_params[param])
      end
    end

    def construct_conditions(options, cond_strs, cond_syms)
      conditions = [ cond_strs.join(" and "), cond_syms ]
      preconditions = options[:conditions]
      conditions[0].insert(0, "(#{preconditions}) and ") unless preconditions.nil?
      options[:conditions] = conditions
    end
  end
end
