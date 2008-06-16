class DatabaseController < ApplicationController

  require 'paginator'

  include Switch

  #
  # Deletes a table row
  #
  def del_row
    if request.post?
      get_database( params[:id] )
      get_table( @database, params[:table] )
      get_fields( @table )
      get_row( @table, params[:pk] )
      if @row
        @table.del_row( @row[ 'id' ] )
        flash[:notice] = "row #{ @row[ 'id' ] } deleted"
      else
        flash[:notice] = "row #{ params[:pk] } not found"
      end
      redirect_to :controller => :database,
                  :table      => @table.name,
                  :action     => :browse,
                  :id         => @database
    end
  end

  #
  # Used to modify a table row
  #
  def edit_row
    get_database( params[:id] )
    get_table( @database, params[:table] )
    get_fields( @table )
    get_row( @table, params[:pk] )
    if request.post? && @row
      @table.update_row( @row[ 'id' ], params[:row] )
      flash[:notice] = "row #{ @row[ 'id' ] } updated"
      redirect_to :controller => :database,
                  :action     => :browse,
                  :table      => @table.name,
                  :id         => @database
    end
  end

  #
  # Inserts rows of data into a table
  #
  def insert
    session[:num_rows] = 1
    get_database( params[:id] )
    get_table( @database, params[:table] )
    get_fields( @table )
    if request.post?
      1.upto( params[params[:table].to_sym].size ) do |x|
        @table.create( params[params[:table].to_sym][x.to_s] )
      end
      flash[:notice] = "#{ params[params[:table].to_sym].size } objects added"
      redirect_to :controller => :database,
                  :table      => @table.name,
                  :action     => :browse,
                  :id         => @database
    end
  end

  #
  # Increments the session count for blank insert fields, then it's RJS
  # template loads the new insert partial into the table.
  #
  def blank_insert
    if request.xhr?
      get_database( params[:id] )
      get_table( @database, params[:table] )
      get_fields( @table )
      session[:num_rows] += 1
    end
  end

  #
  # Decrements the session count for blank insert fields, then it's RJS
  # template removes the last insert row.
  #
  def blank_remove
    if request.xhr?
      if session[:num_rows] > 1
        get_database( params[:id] )
        get_table( @database, params[:table] )
        get_fields( @table )
        @row_id = session[:num_rows]
        session[:num_rows] -= 1
      end
    end
  end

  #
  # Get some rows from the table
  #
  def browse
    get_database( params[:id] )
    get_table( @database, params[:table] )
    get_fields( @table )
    @link_span = LINK_SPAN
    @current_page = params[:page] ? params[:page].to_i : 1
    @active_count = @table.row_count
    @total_pages = ( @active_count.to_f / PER_PAGE.to_f ).ceil
    @order = @table.field_names.first
    @order = 'name' if @table.field_names.include? 'name'
    @order = 'id' if @table.field_names.include? 'id'
    @pager = ::Paginator.new( @active_count, PER_PAGE ) do |offset, per_page|
      @table.find(  :all,
                    :limit  => per_page,
                    :offset => offset,
                    :order  => @order )
    end
    @page = @pager.page( params[:page] )
  end

  #
  # List the tables in a database.
  #
  def index
    get_database( params[:id] )
    begin
      @tables = @database.tables
    rescue RuntimeError
      flash[:notice] = $!.to_s
      redirect_to :controller => :home,
                  :action     => :databases
    end
  end

  #
  # Increments the session count for blank fields, then it's RJS
  # template loads the new table row partial into the table.
  #
  def blank_field
    get_database( params[:id] )
    session[:field_blanks] += 1
  end

  #
  # Lists the fields in a table
  #
  def table
    get_database( params[:id] )
    get_table( @database, params[:table] )
    @fields = @table.fields
  end

  #
  # This method is used to create new tables
  #
  def add_table
    get_database( params[:id] )
    @errors           = {}
    session[:fields]  = {}
    field_errors      = {}
    field_types       = get_field_types( @database.driver.name )
    if request.post?
      @errors['name']   = 'invalid table name' unless params[:name] =~ /[\.0-9a-z\-_]{1,64}/
      @errors['add_id'] = 'selection required' if params[:add_id].nil?
      if params[:fields]['1'][:name].empty?
        field_errors['1'] = {}
        field_errors['1'][:name] = 'at least one field required'
      end
      x = 1
      while params[:fields][x.to_s]
        unless params[:fields][x.to_s][:name].empty?
          session[:fields][x.to_s] = {}
          FIELD_ATTRIBUTES.collect{ |k| k.to_sym }.each do |k|
            session[:fields][x.to_s][k] = params[:fields][x.to_s][k]
          end
          unless field_types.include? params[:fields][x.to_s][:type]
            field_errors[x.to_s] = {}
            field_errors[x.to_s][:type] = 'valid field type required'
          end
        end
        x += 1
      end
      session[:field_blanks] = params[:fields].size
      session[:name] = params[:name].to_s if params[:name] && params[:name] =~ /[\.0-9a-z\-_]{1,64}/
      @errors[:fields] = field_errors unless field_errors.size.zero?
      if @errors.empty?
        begin
          @database.create_tbl( params )
        rescue RuntimeError
          flash.now[:notice] = "An error occured:<br /><br />#{ $!.to_s }"
        else
          session[:field_blanks] = nil
          session[:name] = nil
          flash[:notice] = 'table created'
          redirect_to :controller => :database, :action => :index, :database => params[:database]
        end
      end
    end
    session[:field_blanks] = ( session[:field_blanks] && session[:field_blanks] > 5 ) ? session[:field_blanks] : 5
    @add_id_yes_checked = true
    @add_id_no_checked  = false
    if params[:add_id] && params[:add_id] == '0'
      @add_id_yes_checked = false
      @add_id_no_checked  = true
    end
  end

  #
  # This method provides a way to delete an entire table
  #
  def del_table
    get_database( params[:id] )
    get_table( @database, params[:table] )
    if request.post?
      @database.del_table( @table.name )
      flash[:notice] = 'table deleted'
      redirect_to :controller => :database,
                  :id         => @database
    end
  end

  def edit_table
    get_database( params[:id] )
    get_table( @database, params[:table] )
  end

  #
  # This method provides a way to add any number of new fields to a database
  #
  def add_fields
    get_database( params[:id] )
    get_table( @database, params[:table] )
    @errors           = {}
    session[:fields]  = {}
    field_errors      = {}
    field_types       = get_field_types( @database.driver.name )
    if request.post?
      if params[:fields]['1'][:name].empty?
        field_errors['1'] = {}
        field_errors['1'][:name] = 'at least one field required'
      end
      x = 1
      while params[:fields][x.to_s]
        unless params[:fields][x.to_s][:name].empty?
          session[:fields][x.to_s] = {}
          FIELD_ATTRIBUTES.collect{ |k| k.to_sym }.each do |k|
            session[:fields][x.to_s][k] = params[:fields][x.to_s][k]
          end
          unless field_types.include? params[:fields][x.to_s][:type]
            field_errors[x.to_s] = {}
            field_errors[x.to_s][:type] = 'valid field type required'
          end
        end
        x += 1
      end
      session[:field_blanks] = params[:fields].size
      @errors[:fields] = field_errors unless field_errors.size.zero?
      if @errors.empty?
        begin
          @table.add_fields( params )
        rescue RuntimeError
          flash.now[:notice] = "An error occured:<br /><br />#{ $!.to_s }"
        else
          session[:field_blanks] = nil
          flash[:notice] = 'new fields added'
          redirect_to :controller => :database,
                      :action     => :table,
                      :id         => @database
        end
      end
    end
    session[:field_blanks] = ( session[:field_blanks] && session[:field_blanks] > 1 ) ? session[:field_blanks] : 5
  end

  #
  # This method provides a way to edit a single table field
  #
  def edit_field
    get_database( params[:id] )
    get_table( @database, params[:table] )
    get_field( @table, params[:field] )
    @errors          = {}
    session[:fields] = { '1' => @field.attributes }
    field_errors     = { '1' => {} }
    field_types      = get_field_types( @database.driver.name )
    if request.post?
      field_errors['1'][:name] = 'field name required' if params[:fields]['1'][:name].empty?
      field_errors['1'][:type] = 'valid field type required'unless field_types.include? params[:fields]['1'][:type]
      FIELD_ATTRIBUTES.collect{ |k| k.to_sym }.each do |k|
        session[:fields]['1'][k] = params[:fields]['1'][k]
      end
      @errors[:fields] = field_errors unless field_errors['1'].size.zero?
      if @errors.empty?
        begin
          @field.update( params )
        rescue RuntimeError
          flash.now[:notice] = "An error occured:<br /><br />#{ $!.to_s }"
        else
          flash[:notice] = 'field updated'
          redirect_to :controller => :database,
                      :action     => :table,
                      :id         => @database,
                      :table      => @table.name
        end
      end
    end
  end

  #
  # This method deletes a field from a table.  It prevents the last
  # field from being deleted.
  #
  def del_field
    get_database( params[:id] )
    get_table( @database, params[:table] )
    if @table.field_count == 1
      flash[:notice] = 'last field cannot be deleted, delete table instead'
      redirect_to :controller => :database,
                  :id         => @database
    end
    get_field( @table, params[:field] )
    if request.post?
      @table.del_field( @field.name )
      flash[:notice] = 'field deleted'
      redirect_to :controller => :database,
                  :action     => :table,
                  :id         => @database,
                  :table      => @table.name
    end
  end

  private

  #
  # Finds a table row by table and id
  #
  def get_row( table, id )
    @row = table.find( :all,
                       :conditions => [ 'id = ?', id ] ).first
  end

  #
  # Gets all fields from a given table
  #
  def get_fields( table )
    @fields = table.fields.collect{ |f| f.name }
  end

  #
  # Finds a field by table and name
  #
  def get_field( table, field )
    @field = table.get_field( field )
    if @field.nil?
      flash[:notice] = "field &quot;#{ field }&quot; not found"
      redirect_to :controller => :database,
                  :id         => table.database,
                  :table      => table.name
    end
  end

  #
  # Finds a table by database and name
  #
  def get_table( database, name )
    @table = Table.new( database, name )
    if @table.nil?
      flash[:notice] = "table &quot;#{ name }&quot; not found"
      redirect_to :controller => :home,
                  :action     => :databases
    end
  end

  #
  # Finds a database by id
  #
  def get_database( id )
    @database = Database.find( :first, :conditions => [ 'id = ?', id ] )
    if @database.nil?
      flash[:notice] = "database &quot;#{ database }&quot; not found"
      redirect_to :controller => :home,
                  :action     => :databases
    end
  end

end
