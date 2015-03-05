module UrlHelper
  def self.build_parameterised_url(base, params)
    url = base + '?'

    params.keys.each_with_index do |key, idx|
      url += "#{key}="
      if params[key].is_a? Array
        params[key].each_with_index do |v,i|
          url += "#{v}"

          unless i+1 == params[key].length
            url += ','
          end
        end
      else
        url += "#{params[key]}"
      end

      url += '&' if idx + 1 < params.keys.length
    end

    url #return
  end

  def build_parameterised_url(base, params)
    return self.build_parameterised_url(base, params)
  end
end