module ApplicationHelper
  
  def transliterate(str)
    # Based on permalink_fu by Rick Olsen

    # Escape str by transliterating to UTF-8 with Iconv
    s = Iconv.iconv('ascii//ignore//translit', 'utf-8', str).to_s

    # Downcase string
    s.downcase!

    # Remove apostrophes so isn't changes to isnt
    s.gsub!(/'/, '')

    # Replace any non-letter or non-number character with a space
    s.gsub!(/[^A-Za-z0-9]+/, ' ')

    # Remove spaces from beginning and end of string
    s.strip!

    # Replace groups of spaces with single hyphen
    s.gsub!(/\ +/, '-')

    return s
  end
  
  def duration_to_seconds(duration, precision = 2)
    return 0 if duration.nil?
    hours = duration[/([0-9]{2}):([0-9]{2}):([0-9]{2})\.([0-9]{2})/, 1].to_i
    minutes = duration[/([0-9]{2}):([0-9]{2}):([0-9]{2})\.([0-9]{2})/, 2].to_i
    seconds = duration[/([0-9]{2}):([0-9]{2}):([0-9]{2}\.[0-9]{2})/, 3].to_f
    hours * 3600 + minutes * 60 + seconds.round(precision)
  end
  
  def seconds_to_duration(seconds)
    hours = (seconds / 3600).floor
    mins = ((seconds % 3600) / 60).floor
    secs = ((seconds % 3600) % 60).round(2)
    decimal = ((secs - secs.floor) * 100).to_i
    sprintf("%02d", hours) + ":" + sprintf("%02d", mins) + ":" + sprintf("%02d", secs) + "." + sprintf("%02d", decimal)
  end
  
  def seconds_to_human_time(seconds)
    hours = (seconds / 3600).floor
    mins = ((seconds % 3600) / 60).floor
    secs = ((seconds % 3600) % 60).floor
    str = ''
    str += "#{hours}h " if hours > 0
    str += "#{mins}m " if mins > 0
    str += "#{secs}s" if secs > 0
    return str
  end
  
  def number_to_human_size(number, precision = 2)
    storage_units = ['Bytes', 'KiB', 'MiB', 'GiB', 'TiB']

    number = number.to_f
    base = 1024

    if number.to_i < base
      unit = "Bytes"
      return "#{number.to_i} #{unit}"
    else
      max_exp  = storage_units.size - 1
      exponent = (Math.log(number) / Math.log(base)).to_i # Convert to base
      exponent = max_exp if exponent > max_exp # we need this to avoid overflow for the highest unit
      number  /= base ** exponent

      unit = storage_units[exponent]
      formatted_number = number.round(precision)
      return "#{formatted_number} #{unit}"
    end
  end
  
end
