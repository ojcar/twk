module SnippetsHelper
  
  def chartlist(data)
    total = data.inject(0.0) { |sum, datum| sum + datum[:count] }
    if total == 0
        total = 0.001
    end
    bars = ''

    data.each do |datum|
      # link  = content_tag 'a', datum[:name], :href => datum[:href]
      # count = content_tag 'span', datum[:count], :class => 'count'
      # index = content_tag 'span', "(#{(datum[:count]/total*100).to_i}%)", :class => 'index', :style => "width: #{(datum[:count]/total*100).to_i}%"
      # bars << content_tag('li', link << count << index)
      count = content_tag 'span', datum[:name], :class => 'count'
      if datum[:name] == "yes"
        index = content_tag 'span', "(#{(datum[:count]/total*100).to_i}%)", :class => 'index green', :style => "width: #{(datum[:count]/total*100).to_i}%"
      else
        index = content_tag 'span', "(#{(datum[:count]/total*100).to_i}%)", :class => 'index red', :style => "width: #{(datum[:count]/total*100).to_i}%"
      end
       bars << content_tag('li', count << index)
       
    end

    content_tag 'ul', bars, :class => 'chartlist'
  end
end
