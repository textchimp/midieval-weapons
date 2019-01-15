use_osc '192.168.1.4', 9999

# Top row rotaries have:
# /1/rotary/1, /1/rotary/1/name, /1/rotary/1/val

unless defined? @touchosc_map
  @touchosc_map = {}
end

@touchosc_defaults = {
  # '/1/fader/spread1beat' => 5,
  # '/1/fader/2amp' => 120,
  # '/1/fader/2amp' => 120,
  # '/1/fader/1' => 0.5,
  # '/1/rotary/1' => 1.0,
  # '/1/fader/1' => 1.0,
  # '/1/fader/2' => 0.5,
  # '/1/fader/3' => 0.5,
  # '/1/fader/4' => 0.0,
  # '/1/rotary/5' => 1
}

@touchosc_handlers = {}

def osc_handler(path, &block)
  path = path.sub(/^\/osc/, '')  # ignore leading '/osc' if given
  @touchosc_handlers[ path ] = block
end

def handle_touchosc_event(path, val)

  # exact match first
  if @touchosc_handlers.has_key? path
    # cl "EXACT path match", path
    @touchosc_handlers[ path ].call( path, val )
  end

  # partial match, also pass in remainder of path
  @touchosc_handlers.keys.each do |k|
    if path != k && path.start_with?( k )
      @touchosc_handlers[ k ].call(k, val, path.sub(k, ''))
    end
  end

end

def spread_highlight( s, current )
  #  USAGE:
  #  cl "#{@acc}/#{@beats}:%2d - #{spread_highlight(spr, n)}" % (n+1)

  out = s.to_a.map.with_index do |elem, i|
    el = elem ? '1' : '0'
    if i == current
      el = elem ? el.red : el.green
    end
    el
  end
  out.join ' '
end

def osc_main_sync_loop
  live_loop :osc do
    path, vals = sync "/osc/1/**", path:true   # wait for OSC message
    path = path.split("/osc")[1]  # chop off /osc head
    handle_touchosc_event( path, vals )
    @touchosc_map[path] = vals
  end
end
osc_main_sync_loop

# never let this OSC-reading loop die! (or at least, restart it)
if defined? __add_stop_hook
  __add_stop_hook do
    # cl "OSC keep-alive stop hook running"
    osc_main_sync_loop
  end
end
# __clear_stop_hooks

@touchosc_reply_cache = {}

def touchosc_reply(path, label:nil, val:nil) #, formatter=nil)

  # skip unchanged values - save network traffic to TouchOSC
  # (but always send all values on first iteration of a loop (look))
  return if val == @touchosc_reply_cache[path] && look > 0

  @touchosc_reply_cache[path] = val

  comment do
  # path = "/#{page}/#{elem}/#{id}"
  # if elem == 'xy'
  #   # xy control
  #   ##| puts "REPLY: xy: ", page, elem, id, label, val
  #   path = "/#{page}/#{elem}/#{id}/label"
  #   # touchosc_send(path, [label + ': ' + val.to_s])
  #   osc path, label + ': ' + val.to_s
  #   return
  # elsif elem == 'toggle'
  #   path = "/#{page}/#{elem}/#{id}/val"
  #   osc path, label # + ': ' + val.to_s])
  #   return
  # end
  end

  if val
    osc path + "/val", val
  end

  if label
    osc path + "/name", label   # path = "/#{page}/#{elem}/#{id}/name"

    if label.include? '%s'
      osc path + "/label", label.sub('%s', val.to_s)
    end
  end

end

def osc_get_last_value(path, initial)
  if @touchosc_map[path]
    osc path, @touchosc_map[path] if look == 0
    @touchosc_map[path] # default to last received value if set
  else
    ret = initial || @touchosc_defaults[path] || 0
    osc path, ret    # also sets last value to TouchOSC if not initialised
    ret
  end
end

def o(id, label, min_or_max=nil, max=nil, round:2, map:[], i:false, int:false, first:nil)

  if id.is_a? Numeric
    # shorthand: integer first arg converted to '/1/fader/INT'
    path = "/1/fader/#{id}"
  else
    path = id
  end

  _, page, *elem = path.split '/'


  if min_or_max || max

    # check if one or both of min/max values given:
    # - if just one arg, it's the max, min is 0
    # - if both given, use both as min..max
    if max
      min = min_or_max.to_f
      max = max.to_f
    else
      min = 0
      max = min_or_max.to_f
    end

    val = min + osc_get_last_value(path, first) * (max - min).to_f
    val_print = val.round( round )

  else
    # NO ARGS = treat as either button, or default range

    if elem == 'multitoggle'
      val = @touchosc_notegrid[y.to_i][x.to_i]
      return val
    elsif elem == 'toggle'
      # button type , true/false
      val = @touchosc_map[path].to_f > 0
      puts "TOGGLE", val
      touchosc_reply(path, label:label)
      return val
    else
      # Standard control element, no min/max given
      # Treat as default range 0-1, i.e. use value provided by TouchOSC
      val = osc_get_last_value(path, first)

      # Mapping of normalised value to array elements
      if map.any?
        # NOTE: 'first:' arg when used with map: will be treated
        # as normalised value to plug in to map_list below, not final value!
        val, index = map_list(val, map)
        val_print = val.to_s rescue index
      else
        # only round off non array-mapped values
        val_print = val.round( round )
      end

    end # normal element

  end  # no min/max args

  comment do
    # DON'T BOTHER WITH THE FOLLOWING WHEN USING sync() for OSC:
    # use a hash to store values and only send update if value changed;
    # should save osc network traffic on updates which would otherwise
    # be sent on every sonic pi loop iteration
    # if (not @touchosc_update.key? path) or val != @touchosc_update[path][:val]
    #
    #   # cl "UPDATE send:", path, val, @touchosc_update
    #
    #   val_reply = val   # use new var, in case original val is changed by block
    #
    #   if block_given?
    #     # allow a block to be given which can pre-format value, ie lookup in array/hash
    #     val_reply = yield val
    #   elsif @touchosc_reply_format.key? path
    #     # use predefined format lambda from hash
    #     val_reply = @touchosc_reply_format[path].call( val )
    #   else
    #     val_reply = val_reply.round(3) if val_reply.is_a? Numeric  # default formatting: round num to 3 decimal places
    #   end
    #
    #   @touchosc_update[path]= { val: val, val_display: val_reply, val_osc: @touchosc_map[path] }
    #
    #   cl page, elem, id+coord, label, val_reply
    #   touchosc_reply(path, label:label, val:val_reply) #, formatter)
    # end
  end

  if block_given?
    val_print = yield val
  end

  if i || int
    # convert to integer
    val = val.to_i
    val_print = val_print.to_i
  end

  # send label/value data back to TouchOSC if there's been a change
  touchosc_reply(path, label:label, val:val_print)

  val
end

def map_list(norm, list)
  if norm >= 1
    [list.last, list.length-1]
  elsif norm < 0
    [list.first, 0]
  else
    ind = (list.length * norm).to_i
    [ list[ind], ind  ]
  end
end

cl "TouchOSC lib: loaded"
