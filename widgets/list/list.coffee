class Dashing.List extends Dashing.Widget
  ready: ->
    if @get('unordered')
      $(@node).find('ol').remove()
    else
      $(@node).find('ul').remove()

   onData: (data) ->
    # Fired when you receive data
    # You could do something like have the widget flash each time data comes in by doing:
    # $(@node).fadeOut().fadeIn()
