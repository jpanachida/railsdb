
function t( id, b )
{
  var e;

  if( document.getElementById )
    e = document.getElementById( id );
  else if( document.all )
    e = document.all[ id ];
  else if( document.layers )
    e = document.layers[ id ];
  
  if( e && e.style )
  {
    if( b == 1 )
    {
      try {
        e.style.display = 'table-row';
      } catch( er ) {
        e.style.display = 'block';
      } 
    }
    else e.style.display = 'none';
  }
}
