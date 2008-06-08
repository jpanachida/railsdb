module ApplicationHelper

  #
  # Override @page_title in the view, otheriwse the page
  # gets named 'Home'.
  #
  def page_title
    @page_title || 'Home'
  end

  #
  # Alternating row style setter
  #
  def alt( s='', s2='2')
    " class='alt#{ cycle( s, s2 ) }'"
  end

  #
  # Paginate the rows
  #
  def row_pagination( total_pages )
    render :partial => "database/pagination" if total_pages > 1
  end
  
  #
  # This method Accepts a String or an Array of options and always
  # includes a blank options.
  #
  def get_options( options, selected )
    options = options_for_select( options, selected.to_s ) if options.class == Array
    "<option value=''></option>#{ options }"
  end

  #
  # Collection of table type options appropriate for passing to
  # ActionView::Helpers::FormOptionsHelper.options_for_select
  #
  def field_type_options( driver )
    field_types = get_field_types( driver )
    field_types.collect { |ft| [ ft, ft ] }
  end

end
