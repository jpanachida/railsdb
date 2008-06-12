class DatabaseController < ApplicationController

  require 'paginator'

  include Switch

  #
  # Modify a table row
  #
  def edit_row
    get_database( params[:id] )
    get_table( @database, params[:table] )
    get_row( @table, params[:pk] )
  end

  #
  # Insert a row into a table
  #
  def insert
    get_database( params[:id] )
    get_table( @database, params[:table] )
    @fields = @table.fields.collect{ |f| f.name }
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
  # Get some rows from the table
  #
  def browse
    get_database( params[:id] )
    get_table( @database, params[:table] )
    @fields = @table.fields.collect{ |f| f.name }
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
      redirect_to :controller => :home, :action => :databases
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
  # This parses through everything posted to create a table.
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
  # This does just what you think it does, hope you had backups..
  #
  def del_table
    get_database( params[:id] )
    get_table( @database, params[:table] )
    if request.post?
      @database.del_table( @table.name )
      flash[:notice] = 'table deleted'
      redirect_to :controller => :database, :id => @database
    end
  end

  def edit_table
    get_database( params[:id] )
    get_table( @database, params[:table] )
  end

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
          redirect_to :controller => :database, :id => @database, :action => :table
        end
      end
    end
    session[:field_blanks] = ( session[:field_blanks] && session[:field_blanks] > 1 ) ? session[:field_blanks] : 5
  end

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
          redirect_to :controller => :database, :id => @database, :action => :table, :table => @table.name
        end
      end
    end
  end

  def del_field
    get_database( params[:id] )
    get_table( @database, params[:table] )
    if @table.field_count == 1
      flash[:notice] = 'last field cannot be deleted, delete table instead'
      redirect_to :controller => :database, :id => @database
    end
    get_field( @table, params[:field] )
    if request.post?
      @table.del_field( @field.name )
      flash[:notice] = 'field deleted'
      redirect_to :controller => :database, :id => @database, :action => :table, :table => @table.name
    end
  end

  private

  def get_row( table, id )
    @row = Row.new( table, { :id => id } )
    #debugger
    if @row.nil?
      flash[:notice] = "row &quot;#{ id }&quot; not found"
      redirect_to :controller => :database,
                  :action     => :browse,
                  :id         => table.database,
                  :table      => table.name
    end
  end

  def get_field( table, field )
    @field = table.get_field( field )
    if @field.nil?
      flash[:notice] = "field &quot;#{ field }&quot; not found"
      redirect_to :controller => :database, :id => table.database, :table => table.name
    end
  end

  def get_table( database, name )
    # TODO make this database.get_table
    @table = Table.new( database, name )
    if @table.nil?
      flash[:notice] = "table &quot;#{ name }&quot; not found"
      redirect_to :controller => :home, :action => :databases
    end
  end

  def get_database( id )
    @database = Database.find( :first, :conditions => [ 'id = ?', id ] )
    if @database.nil?
      flash[:notice] = "database &quot;#{ database }&quot; not found"
      redirect_to :controller => :home, :action => :databases
    end
  end

end
