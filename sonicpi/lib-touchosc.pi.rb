use_osc '192.168.1.4', 9999

# Top row rotaries have:
# /1/rotary/1, /1/rotary/1/name, /1/rotary/1/val

unless defined? @touchosc_map
  @touchosc_map = {}
end

@def = {
  '/1/fader/spread1beat' => 5,
  '/1/fader/2amp' => 120,
  '/1/fader/2amp' => 120,
  '/1/fader/1' => 0.5,
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

    handle_touchosc_event(path, vals)

    @touchosc_map[path] = vals    # save to map (TODO: need this still? if not comparing for update)
    # cl path, vals
    # cl @touchosc_map
    # if path == '/1/fader/spread1beat'
    #   @beats = o('/1/fader/spread1beat', 'spread acc', 1, 16, &:to_i)
    # elsif path == '/1/fader/spread1acc'
    #   @acc = o('/1/fader/spread1acc', 'spread acc', 1, 16, &:to_i)
    # elsif path == '/1/fader/2'
    #   @bpm = o('/1/fader/2', nil, 20, 160)
    # elsif path == '/1/fader/3'
    #   @rnd = o('/1/fader/3', nil, 0, 1)
    # elsif path == '/1/rotary/1'
    #   @scl = o('/1/rotary/1', nil, 0, scale_names.length){ |v| scale_names[v.to_i] }
    # elsif path == '/1/rotary/2'
    #   @drum = o('/1/rotary/2', nil, 0, sample_names(:bd).length){ |v| sample_names(:bd)[v.to_i] }
    # end

  end
end
osc_main_sync_loop()

# never let this OSC-reading loop die! (or at least, restart it)
if defined? __add_stop_hook
  __add_stop_hook do
    cl "OSC keep-alive stop hook running"
    osc_main_sync_loop
  end
end

def touchosc_reply(path, label:nil, val:nil) #, formatter=nil)
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

  if val
    osc path + "/val", val
  end

  if label
    # path = "/#{page}/#{elem}/#{id}/name"
    osc path + "/name", label  # builtin from sonic pi v3


    if label.include? '%s'
      osc path + "/label", label.sub('%s', val.to_s)  # builtin from sonic pi v3
    end

  end

end


# TODO: same old initialisation issues: need to return default value (0? 1?) for nil values, before first reading
def o(id, label, min_or_max=nil, max=nil, range:1.0, round:2, map:[])

  if id.is_a? Numeric
    # shorthand: integer first arg converted to '/1/fader/INT'
    path = "/1/fader/#{id}"
  else
    path = id
  end

  _, page, *elem = path.split '/'


  # handle optional arguments
  if not min_or_max and not max

    # NO ARGS = treat as either button, or default range

    if elem == 'multitoggle'
      val = @touchosc_notegrid[y.to_i][x.to_i]
      return val
    elsif elem == 'toggle'
      # button type , true/false
      val = @touchosc_map[path].to_f > 0
      puts "TOGGLE", val
      return val
    else
      # treat as default range 0-1, i.e. do nothing with value provided by TouchOSC
      val = @touchosc_map[path] || @def[path] || 0.5
      puts "DEFAULT 0-1", val

      # cl "val current (#{path})", val
      val *= range   # handle nil initial values
    end

  else

    ##| use range to calculate value
    if max
      min = min_or_max.to_f
      max = max.to_f
    else
      min = 0
      max = min_or_max.to_f
    end
    val = (@touchosc_map[path].to_f || 0.5) * (max - min).to_f + min

  end
  # cl val
  val_print = val.round( round )

  # TODO: fix these conditions, get rid of min_or_max & use keyword args
  if map.any?
    # cl "MAPPIN", @touchosc_map[path].to_f, map
    val, index = map_list(@touchosc_map[path].to_f, map)
    val_print = val.to_s rescue index
  end


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

  touchosc_reply(path, label:label, val:val_print)

  val
end

# alias_method :o, :osc

def map_list(norm, list)
  ind = ((norm-0.001).abs * list.length).floor
  [ list.fetch(ind), ind ]
end
